import AppIntents
import Foundation
import SwiftData

struct TomorrowClassesIntent: AppIntent {
    static let title: LocalizedStringResource = "Tomorrow's Classes"
    static let description = IntentDescription("See how many classes you have tomorrow and when the first one starts.")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let lessons = Self.tomorrowLessons()
        guard !lessons.isEmpty else {
            return .result(dialog: "No classes tomorrow. Enjoy the free day!")
        }
        let first = lessons[0]
        let time = first.startTime.formatted(date: .omitted, time: .shortened)
        let count = lessons.count == 1 ? "You have 1 class tomorrow" : "You have \(lessons.count) classes tomorrow"
        return .result(dialog: "\(count). First: \(first.subject) at \(time).")
    }

    static func tomorrowLessons() -> [Lesson] {
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now) else { return [] }
        do {
            let container = try ModelContainer(for: LessonRecord.self, HomeworkRecord.self, AttendanceRecord.self)
            let context = ModelContext(container)
            let records = try context.fetch(FetchDescriptor<LessonRecord>())
            return records
                .map(\.lesson)
                .filter { $0.occurrence(on: tomorrow, calendar: calendar) != nil }
                .sorted { $0.startTime < $1.startTime }
        } catch {
            return []
        }
    }
}

struct ClassroomShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: TomorrowClassesIntent(),
            phrases: ["\(.applicationName) tomorrow"],
            shortTitle: "Tomorrow's Classes",
            systemImageName: "calendar.day.timeline.left"
        )
    }
}
