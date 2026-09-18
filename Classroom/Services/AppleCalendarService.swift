import EventKit
import Foundation

enum CalendarExportError: LocalizedError {
    case accessDenied
    case calendarUnavailable

    var errorDescription: String? {
        switch self {
        case .accessDenied: "Calendar access was not granted."
        case .calendarUnavailable: "A writable calendar is not available."
        }
    }
}

protocol CalendarExporting {
    func synchronize(lessons: [Lesson]) async throws
    func removeExportedSchedule() async throws
    func authorizationStatus() -> IntegrationPermissionStatus
}

final class AppleCalendarService: CalendarExporting {
    private let store = EKEventStore()
    private let calendarTitle = "Classroom Schedule"
    private let calendarIdentifierKey = "classroomExportCalendarIdentifier"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func authorizationStatus() -> IntegrationPermissionStatus {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .fullAccess: .authorized
        case .writeOnly: .limited
        case .notDetermined: .notRequested
        default: .denied
        }
    }

    func synchronize(lessons: [Lesson]) async throws {
        guard try await hasAccess() else { throw CalendarExportError.accessDenied }
        let previousCalendar = exportedCalendar

        guard !lessons.isEmpty else {
            if let previousCalendar {
                try store.removeCalendar(previousCalendar, commit: true)
            }
            defaults.removeObject(forKey: calendarIdentifierKey)
            return
        }

        let calendar = try makeClassroomCalendar()

        do {
            for lesson in lessons {
                for weekday in lesson.weekdays {
                    let event = EKEvent(eventStore: store)
                    event.calendar = calendar
                    event.title = lesson.subject
                    event.location = lesson.room
                    event.notes = [lesson.teacher.isEmpty ? nil : "Teacher: \(lesson.teacher)", lesson.notes.isEmpty ? nil : lesson.notes].compactMap { $0 }.joined(separator: "\n")
                    let start = nextOccurrence(of: lesson.startTime, weekday: weekday)
                    event.startDate = start
                    event.endDate = Calendar.current.date(byAdding: .second, value: duration(of: lesson), to: start)
                    event.recurrenceRules = [EKRecurrenceRule(
                        recurrenceWith: .weekly,
                        interval: 1,
                        daysOfTheWeek: [EKRecurrenceDayOfWeek(EKWeekday(rawValue: weekday.rawValue)!)],
                        daysOfTheMonth: nil,
                        monthsOfTheYear: nil,
                        weeksOfTheYear: nil,
                        daysOfTheYear: nil,
                        setPositions: nil,
                        end: nil
                    )]
                    try store.save(event, span: .futureEvents, commit: false)
                }
            }
            try store.commit()
            if let previousCalendar {
                try store.removeCalendar(previousCalendar, commit: true)
            }
            defaults.set(calendar.calendarIdentifier, forKey: calendarIdentifierKey)
        } catch {
            try? store.removeCalendar(calendar, commit: true)
            throw error
        }
    }

    func removeExportedSchedule() async throws {
        guard let calendar = exportedCalendar else {
            defaults.removeObject(forKey: calendarIdentifierKey)
            return
        }
        guard EKEventStore.authorizationStatus(for: .event) == .fullAccess else { throw CalendarExportError.accessDenied }
        try store.removeCalendar(calendar, commit: true)
        defaults.removeObject(forKey: calendarIdentifierKey)
    }

    private func hasAccess() async throws -> Bool {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .fullAccess: true
        case .notDetermined: try await store.requestFullAccessToEvents()
        default: false
        }
    }

    private var exportedCalendar: EKCalendar? {
        guard let identifier = defaults.string(forKey: calendarIdentifierKey) else { return nil }
        return store.calendar(withIdentifier: identifier)
    }

    private func makeClassroomCalendar() throws -> EKCalendar {
        let calendar = EKCalendar(for: .event, eventStore: store)
        calendar.title = calendarTitle
        calendar.source = store.defaultCalendarForNewEvents?.source ?? store.sources.first(where: { $0.sourceType == .local })
        guard calendar.source != nil else { throw CalendarExportError.calendarUnavailable }
        try store.saveCalendar(calendar, commit: true)
        return calendar
    }

    private func nextOccurrence(of time: Date, weekday: Weekday) -> Date {
        var components = DateComponents()
        components.weekday = weekday.rawValue
        components.hour = Calendar.current.component(.hour, from: time)
        components.minute = Calendar.current.component(.minute, from: time)
        return Calendar.current.nextDate(after: Calendar.current.startOfDay(for: .now).addingTimeInterval(-1), matching: components, matchingPolicy: .nextTime) ?? .now
    }

    private func duration(of lesson: Lesson) -> Int {
        max(60, Int(lesson.duration))
    }
}
