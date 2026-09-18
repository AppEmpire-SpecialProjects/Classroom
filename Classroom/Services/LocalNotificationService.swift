import Foundation
import UserNotifications

protocol NotificationScheduling {
    func synchronize(lessons: [Lesson], leadTime: ReminderLeadTime) async throws
    func synchronizeDigest(lessons: [Lesson], enabled: Bool) async throws
    func authorizationStatus() async -> IntegrationPermissionStatus
}

final class LocalNotificationService: NotificationScheduling {
    private let center = UNUserNotificationCenter.current()
    private let prefix = "classroom.lesson."
    private let digestIdentifier = "classroom.daily.digest"

    func authorizationStatus() async -> IntegrationPermissionStatus {
        switch await center.notificationSettings().authorizationStatus {
        case .authorized, .provisional, .ephemeral: .authorized
        case .notDetermined: .notRequested
        case .denied: .denied
        @unknown default: .limited
        }
    }

    func synchronize(lessons: [Lesson], leadTime: ReminderLeadTime) async throws {
        let pending = await center.pendingNotificationRequests()
        let identifiers = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
        guard leadTime != .off, !lessons.isEmpty else {
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
            return
        }

        let status = await center.notificationSettings().authorizationStatus
        let granted: Bool
        switch status {
        case .authorized, .provisional, .ephemeral:
            granted = true
        case .notDetermined:
            granted = try await center.requestAuthorization(options: [.alert, .sound])
        default:
            granted = false
        }
        guard granted else {
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
            return
        }

        var desiredIdentifiers = Set<String>()
        for lesson in lessons {
            let lead = lesson.reminderOverride ?? leadTime
            guard lead != .off else { continue }
            for weekday in lesson.weekdays {
                let identifier = "\(prefix)\(lesson.id.uuidString).\(weekday.rawValue)"
                desiredIdentifiers.insert(identifier)
                let content = UNMutableNotificationContent()
                content.title = lesson.subject
                content.body = [lesson.room.isEmpty ? nil : lesson.room, "Starts in \(lead.rawValue) minutes"].compactMap { $0 }.joined(separator: " · ")
                content.sound = .default
                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: content,
                    trigger: UNCalendarNotificationTrigger(
                        dateMatching: reminderComponents(for: lesson.startTime, weekday: weekday, leadMinutes: lead.rawValue),
                        repeats: true
                    )
                )
                try await center.add(request)
            }
        }

        let staleIdentifiers = identifiers.filter { !desiredIdentifiers.contains($0) }
        center.removePendingNotificationRequests(withIdentifiers: staleIdentifiers)
    }

    func synchronizeDigest(lessons: [Lesson], enabled: Bool) async throws {
        let pending = await center.pendingNotificationRequests()
        let identifiers = pending.map(\.identifier).filter { $0.hasPrefix(digestIdentifier) }

        guard enabled, !lessons.isEmpty else {
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
            return
        }

        let status = await center.notificationSettings().authorizationStatus
        let granted: Bool
        switch status {
        case .authorized, .provisional, .ephemeral:
            granted = true
        case .notDetermined:
            granted = try await center.requestAuthorization(options: [.alert, .sound])
        default:
            granted = false
        }
        guard granted else {
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
            return
        }

        let calendar = Calendar.current
        let weekday = Weekday(rawValue: calendar.component(.weekday, from: .now)) ?? .monday
        let todayLessons = lessons
            .filter { $0.occurs(on: weekday) }
            .sorted { $0.startTime < $1.startTime }

        let content = UNMutableNotificationContent()
        content.sound = .default
        if todayLessons.isEmpty {
            content.title = "No classes today"
            content.body = "Your schedule is free. Enjoy the day."
        } else {
            let first = todayLessons[0]
            content.title = todayLessons.count == 1 ? "1 class today" : "\(todayLessons.count) classes today"
            content.body = "First: \(first.subject) at \(first.startTime.formatted(date: .omitted, time: .shortened))"
        }

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.hour = 8
        components.minute = 0

        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        try await center.add(
            UNNotificationRequest(
                identifier: digestIdentifier,
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            )
        )
    }

    private func reminderComponents(for time: Date, weekday: Weekday, leadMinutes: Int) -> DateComponents {
        let calendar = Calendar.current
        let minutesPerDay = 24 * 60
        let minutesPerWeek = 7 * minutesPerDay
        let startMinutes = (weekday.rawValue - 1) * minutesPerDay
            + calendar.component(.hour, from: time) * 60
            + calendar.component(.minute, from: time)
        let reminderMinutes = (startMinutes - leadMinutes + minutesPerWeek) % minutesPerWeek

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.weekday = reminderMinutes / minutesPerDay + 1
        components.hour = reminderMinutes % minutesPerDay / 60
        components.minute = reminderMinutes % 60
        return components
    }
}
