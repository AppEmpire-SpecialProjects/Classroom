import Combine
import Foundation

@MainActor
final class UserSettings: ObservableObject {
    private enum Key {
        static let completedOnboarding = "completedOnboarding"
        static let role = "classroomRole"
        static let firstDay = "firstDayOfWeek"
        static let reminder = "reminderLeadTime"
        static let defaultDuration = "defaultClassDuration"
        static let lastColor = "lastClassColor"
        static let calendarEnabled = "appleCalendarEnabled"
        static let dailyDigest = "dailySummaryEnabled"
        static let appearance = "appearancePreference"
    }

    @Published var completedOnboarding: Bool { didSet { defaults.set(completedOnboarding, forKey: Key.completedOnboarding) } }
    @Published var role: ClassroomRole { didSet { defaults.set(role.rawValue, forKey: Key.role) } }
    @Published var firstDay: FirstDayOfWeek { didSet { defaults.set(firstDay.rawValue, forKey: Key.firstDay) } }
    @Published var reminderLead: ReminderLeadTime { didSet { defaults.set(reminderLead.rawValue, forKey: Key.reminder) } }
    @Published var defaultDuration: DefaultClassDuration { didSet { defaults.set(defaultDuration.rawValue, forKey: Key.defaultDuration) } }
    @Published var lastColorHex: String { didSet { defaults.set(lastColorHex, forKey: Key.lastColor) } }
    @Published var calendarEnabled: Bool { didSet { defaults.set(calendarEnabled, forKey: Key.calendarEnabled) } }
    @Published var dailyDigest: Bool { didSet { defaults.set(dailyDigest, forKey: Key.dailyDigest) } }
    @Published var appearance: AppearancePreference { didSet { defaults.set(appearance.rawValue, forKey: Key.appearance) } }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        completedOnboarding = defaults.bool(forKey: Key.completedOnboarding)
        role = ClassroomRole(rawValue: defaults.string(forKey: Key.role) ?? "") ?? .student
        firstDay = FirstDayOfWeek(rawValue: defaults.string(forKey: Key.firstDay) ?? "") ?? .monday
        reminderLead = ReminderLeadTime(rawValue: defaults.object(forKey: Key.reminder) as? Int ?? 10) ?? .ten
        defaultDuration = DefaultClassDuration(rawValue: defaults.object(forKey: Key.defaultDuration) as? Int ?? 45) ?? .fortyFive
        lastColorHex = defaults.string(forKey: Key.lastColor) ?? "6C63E8"
        calendarEnabled = defaults.bool(forKey: Key.calendarEnabled)
        dailyDigest = defaults.bool(forKey: Key.dailyDigest)
        appearance = AppearancePreference(rawValue: defaults.string(forKey: Key.appearance) ?? "") ?? .system
    }
}
