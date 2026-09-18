import Foundation
import SwiftData
import SwiftUI

enum ClassroomRole: String, CaseIterable, Identifiable {
    case student = "Student"
    case teacher = "Teacher"

    var id: String { rawValue }

    var symbol: String {
        self == .student ? "backpack.fill" : "book.closed.circle.fill"
    }
}

enum FirstDayOfWeek: String, CaseIterable, Identifiable {
    case monday = "Monday"
    case sunday = "Sunday"

    var id: String { rawValue }
}

enum AppearancePreference: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum ReminderLeadTime: Int, CaseIterable, Identifiable {
    case off = 0
    case five = 5
    case ten = 10
    case fifteen = 15
    case thirty = 30

    var id: Int { rawValue }
    var title: String { self == .off ? "Off" : "\(rawValue) min" }
}

enum DefaultClassDuration: Int, CaseIterable, Identifiable {
    case thirty = 30
    case fortyFive = 45
    case fifty = 50
    case sixty = 60
    case ninety = 90

    var id: Int { rawValue }
    var title: String { "\(rawValue) minutes" }
}

enum IntegrationPermissionStatus: String {
    case notRequested = "Not Requested"
    case authorized = "Allowed"
    case denied = "Not Allowed"
    case limited = "Limited"
}

enum Weekday: Int, CaseIterable, Identifiable, Codable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var id: Int { rawValue }

    var shortTitle: String {
        switch self {
        case .monday: "Mon"
        case .tuesday: "Tue"
        case .wednesday: "Wed"
        case .thursday: "Thu"
        case .friday: "Fri"
        case .saturday: "Sat"
        case .sunday: "Sun"
        }
    }

    static func ordered(firstDay: FirstDayOfWeek) -> [Weekday] {
        firstDay == .monday
            ? [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
            : [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    }
}

enum WeekParity: Int, CaseIterable, Identifiable {
    case everyWeek = 0
    case oddWeeks = 1
    case evenWeeks = 2

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .everyWeek: "Every week"
        case .oddWeeks: "Odd weeks"
        case .evenWeeks: "Even weeks"
        }
    }

    var symbol: String {
        switch self {
        case .everyWeek: "repeat"
        case .oddWeeks: "arrow.triangle.swap.right"
        case .evenWeeks: "arrow.triangle.swap.left"
        }
    }
}

struct Lesson: Identifiable, Hashable {
    let id: UUID
    var subject: String
    var teacher: String
    var room: String
    var startTime: Date
    var endTime: Date
    var weekdays: Set<Weekday>
    var colorHex: String
    var notes: String
    var weekParity: WeekParity
    var skipDates: [Date]
    var reminderLeadMinutes: Int?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        subject: String,
        teacher: String = "",
        room: String = "",
        startTime: Date,
        endTime: Date,
        weekdays: Set<Weekday>,
        colorHex: String = "6C63E8",
        notes: String = "",
        weekParity: WeekParity = .everyWeek,
        skipDates: [Date] = [],
        reminderLeadMinutes: Int? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.subject = subject
        self.teacher = teacher
        self.room = room
        self.startTime = startTime
        self.endTime = endTime
        self.weekdays = weekdays
        self.colorHex = colorHex
        self.notes = notes
        self.weekParity = weekParity
        self.skipDates = skipDates
        self.reminderLeadMinutes = reminderLeadMinutes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func occurs(on weekday: Weekday) -> Bool { weekdays.contains(weekday) }

    var duration: TimeInterval {
        let interval = endTime.timeIntervalSince(startTime)
        if interval > 0, interval <= 86_400 { return interval }
        let wrapped = interval.truncatingRemainder(dividingBy: 86_400)
        return wrapped > 0 ? wrapped : wrapped + 86_400
    }

    var spansMidnight: Bool {
        let calendar = Calendar.current
        let startMinutes = calendar.component(.hour, from: startTime) * 60 + calendar.component(.minute, from: startTime)
        let endMinutes = calendar.component(.hour, from: endTime) * 60 + calendar.component(.minute, from: endTime)
        return endMinutes <= startMinutes
    }

    var reminderOverride: ReminderLeadTime? {
        reminderLeadMinutes.flatMap(ReminderLeadTime.init(rawValue:))
    }

    func isSkipped(on date: Date, calendar: Calendar = .current) -> Bool {
        skipDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }

    func matchesParity(on date: Date, calendar: Calendar = .current) -> Bool {
        guard weekParity != .everyWeek else { return true }
        let weekNumber = calendar.component(.weekOfYear, from: date)
        let isOdd = weekNumber % 2 == 1
        return weekParity == .oddWeeks ? isOdd : !isOdd
    }

    func occurrence(on date: Date, calendar: Calendar = .current) -> DateInterval? {
        guard let weekday = Weekday(rawValue: calendar.component(.weekday, from: date)), occurs(on: weekday) else { return nil }
        guard !isSkipped(on: date, calendar: calendar) else { return nil }
        guard matchesParity(on: date, calendar: calendar) else { return nil }
        let startParts = calendar.dateComponents([.hour, .minute], from: startTime)
        guard let start = calendar.date(
            bySettingHour: startParts.hour ?? 0,
            minute: startParts.minute ?? 0,
            second: 0,
            of: date
        ) else { return nil }
        return DateInterval(start: start, duration: duration)
    }

    func isActive(at date: Date, calendar: Calendar = .current) -> Bool {
        if occurrence(on: date, calendar: calendar)?.contains(date) == true { return true }
        guard let previousDay = calendar.date(byAdding: .day, value: -1, to: date) else { return false }
        return occurrence(on: previousDay, calendar: calendar)?.contains(date) == true
    }

    func duplicate(at date: Date = .now) -> Lesson {
        Lesson(
            subject: "\(subject) Copy",
            teacher: teacher,
            room: room,
            startTime: startTime,
            endTime: endTime,
            weekdays: weekdays,
            colorHex: colorHex,
            notes: notes,
            weekParity: weekParity,
            skipDates: skipDates,
            reminderLeadMinutes: reminderLeadMinutes,
            createdAt: date,
            updatedAt: date
        )
    }
}

enum LessonDateCodec {
    static let dayFormat: (format: String, locale: Locale, timeZone: TimeZone) = ("yyyy-MM-dd", Locale(identifier: "en_US_POSIX"), .current)

    static func dayString(from date: Date, calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dayFormat.format
        formatter.locale = dayFormat.locale
        formatter.timeZone = calendar.timeZone
        return formatter.string(from: calendar.startOfDay(for: date))
    }

    static func encode(_ dates: [Date], calendar: Calendar = .current) -> String {
        dates
            .map { dayString(from: $0, calendar: calendar) }
            .sorted()
            .joined(separator: ",")
    }

    static func decode(_ raw: String, calendar: Calendar = .current) -> [Date] {
        let formatter = DateFormatter()
        formatter.dateFormat = dayFormat.format
        formatter.locale = dayFormat.locale
        formatter.timeZone = calendar.timeZone
        return raw
            .split(separator: ",")
            .compactMap { formatter.date(from: String($0)) }
            .map { calendar.startOfDay(for: $0) }
            .sorted()
    }
}

@Model
final class LessonRecord {
    @Attribute(.unique) var id: UUID
    var subject: String
    var teacher: String
    var room: String
    var startTime: Date
    var endTime: Date
    var weekdaysRaw: String
    var colorHex: String
    var notes: String
    var weekParityRaw: Int = 0
    var skipDatesRaw: String = ""
    var reminderLeadMinutes: Int = -1
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    init(lesson: Lesson) {
        id = lesson.id
        subject = lesson.subject
        teacher = lesson.teacher
        room = lesson.room
        startTime = lesson.startTime
        endTime = lesson.endTime
        weekdaysRaw = lesson.weekdays.map(\.rawValue).sorted().map(String.init).joined(separator: ",")
        colorHex = lesson.colorHex
        notes = lesson.notes
        weekParityRaw = lesson.weekParity.rawValue
        skipDatesRaw = LessonDateCodec.encode(lesson.skipDates)
        reminderLeadMinutes = lesson.reminderLeadMinutes ?? -1
        createdAt = lesson.createdAt
        updatedAt = lesson.updatedAt
    }

    var lesson: Lesson {
        Lesson(
            id: id,
            subject: subject,
            teacher: teacher,
            room: room,
            startTime: startTime,
            endTime: endTime,
            weekdays: Set(weekdaysRaw.split(separator: ",").compactMap { Int($0) }.compactMap(Weekday.init(rawValue:))),
            colorHex: colorHex,
            notes: notes,
            weekParity: WeekParity(rawValue: weekParityRaw) ?? .everyWeek,
            skipDates: LessonDateCodec.decode(skipDatesRaw),
            reminderLeadMinutes: reminderLeadMinutes >= 0 ? reminderLeadMinutes : nil,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    func update(from lesson: Lesson) {
        subject = lesson.subject
        teacher = lesson.teacher
        room = lesson.room
        startTime = lesson.startTime
        endTime = lesson.endTime
        weekdaysRaw = lesson.weekdays.map(\.rawValue).sorted().map(String.init).joined(separator: ",")
        colorHex = lesson.colorHex
        notes = lesson.notes
        weekParityRaw = lesson.weekParity.rawValue
        skipDatesRaw = LessonDateCodec.encode(lesson.skipDates)
        reminderLeadMinutes = lesson.reminderLeadMinutes ?? -1
        updatedAt = lesson.updatedAt
    }
}
