import Combine
import Foundation

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var lessons: [Lesson] = []
    @Published private(set) var homework: [Homework] = []
    @Published private(set) var attendance: [Attendance] = []
    @Published var alertMessage: String?
    @Published private(set) var calendarPermission: IntegrationPermissionStatus = .notRequested
    @Published private(set) var notificationPermission: IntegrationPermissionStatus = .notRequested
    let settings = UserSettings()

    private let repository: ScheduleRepository
    private let notificationService: NotificationScheduling
    private let calendarService: CalendarExporting

    init(repository: ScheduleRepository, notificationService: NotificationScheduling, calendarService: CalendarExporting) {
        self.repository = repository
        self.notificationService = notificationService
        self.calendarService = calendarService
        load()
        if ProcessInfo.processInfo.arguments.contains("-seedSampleSchedule"), lessons.isEmpty {
            seedSampleSchedule()
        }
    }

    func load() {
        do {
            lessons = try repository.fetchAll()
            homework = try repository.fetchHomework()
            attendance = try repository.fetchAttendance()
        } catch { alertMessage = error.localizedDescription }
    }

    func save(_ lesson: Lesson) async -> Bool {
        do {
            var updatedLesson = lesson
            updatedLesson.updatedAt = .now
            try repository.save(updatedLesson)
            settings.lastColorHex = updatedLesson.colorHex
            lessons = try repository.fetchAll()
            await synchronizeIntegrations()
            return true
        } catch {
            alertMessage = error.localizedDescription
            return false
        }
    }

    func duplicate(_ lesson: Lesson) async -> Lesson? {
        do {
            let copy = try repository.duplicate(lesson)
            lessons = try repository.fetchAll()
            await synchronizeIntegrations()
            return copy
        } catch {
            alertMessage = error.localizedDescription
            return nil
        }
    }

    func lessons(on weekday: Weekday) -> [Lesson] {
        lessons.filter { $0.occurs(on: weekday) }.sorted { $0.startTime < $1.startTime }
    }

    func delete(_ lesson: Lesson) async -> Bool {
        do {
            try repository.delete(id: lesson.id)
            try repository.deleteHomework(forLesson: lesson.id)
            try repository.deleteAttendance(forLesson: lesson.id)
            lessons = try repository.fetchAll()
            homework = try repository.fetchHomework()
            attendance = try repository.fetchAttendance()
            await synchronizeIntegrations()
            return true
        } catch {
            alertMessage = error.localizedDescription
            return false
        }
    }

    func resetSchedule() async -> Bool {
        do {
            try repository.deleteAll()
            try repository.deleteAllHomework()
            try repository.deleteAllAttendance()
            lessons = []
            homework = []
            attendance = []
            await synchronizeIntegrations()
            return true
        } catch {
            alertMessage = error.localizedDescription
            return false
        }
    }

    func synchronizeIntegrations() async {
        await updateReminders()
        guard settings.calendarEnabled else { return }
        do {
            try await calendarService.synchronize(lessons: lessons)
        } catch { alertMessage = error.localizedDescription }
    }

    func updateReminders() async {
        do {
            try await notificationService.synchronize(lessons: lessons, leadTime: settings.reminderLead)
            try await notificationService.synchronizeDigest(lessons: lessons, enabled: settings.dailyDigest)
            notificationPermission = await notificationService.authorizationStatus()
        } catch { alertMessage = error.localizedDescription }
    }

    func refreshPermissionStatuses() async {
        calendarPermission = calendarService.authorizationStatus()
        notificationPermission = await notificationService.authorizationStatus()
    }

    func setCalendarEnabled(_ enabled: Bool) async -> Bool {
        let previousValue = settings.calendarEnabled
        do {
            if enabled { try await calendarService.synchronize(lessons: lessons) }
            else { try await calendarService.removeExportedSchedule() }
            settings.calendarEnabled = enabled
            calendarPermission = calendarService.authorizationStatus()
            return true
        } catch {
            alertMessage = error.localizedDescription
            settings.calendarEnabled = previousValue
            calendarPermission = calendarService.authorizationStatus()
            return false
        }
    }

    // MARK: - Homework

    func homework(for lessonID: UUID) -> [Homework] {
        homework
            .filter { $0.lessonID == lessonID }
            .sorted { left, right in
                if left.isCompleted != right.isCompleted { return !left.isCompleted }
                if left.isCompleted {
                    return (left.completedAt ?? .distantPast) > (right.completedAt ?? .distantPast)
                }
                return left.dueDate < right.dueDate
            }
    }

    func addHomework(_ item: Homework) {
        do {
            try repository.save(item)
            homework = try repository.fetchHomework()
        } catch { alertMessage = error.localizedDescription }
    }

    func toggleHomework(_ item: Homework) {
        var updated = item
        updated.isCompleted.toggle()
        updated.completedAt = updated.isCompleted ? .now : nil
        do {
            try repository.save(updated)
            homework = try repository.fetchHomework()
        } catch { alertMessage = error.localizedDescription }
    }

    func deleteHomework(_ item: Homework) {
        do {
            try repository.deleteHomework(id: item.id)
            homework = try repository.fetchHomework()
        } catch { alertMessage = error.localizedDescription }
    }

    // MARK: - Attendance

    func setAttendance(lessonID: UUID, on date: Date, status: AttendanceStatus?) {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        let existing = attendance.first {
            $0.lessonID == lessonID && calendar.isDate($0.date, inSameDayAs: day)
        }
        do {
            if let status {
                var record: Attendance
                if let existing {
                    record = existing
                    record.date = day
                    record.status = status
                } else {
                    record = Attendance(lessonID: lessonID, date: day, status: status)
                }
                try repository.save(record)
            } else if let existing {
                try repository.deleteAttendance(id: existing.id)
            }
            attendance = try repository.fetchAttendance()
        } catch { alertMessage = error.localizedDescription }
    }

    func attendance(on date: Date) -> [Attendance] {
        let calendar = Calendar.current
        return attendance.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func attendanceStatus(lessonID: UUID, on date: Date) -> AttendanceStatus? {
        let calendar = Calendar.current
        return attendance.first {
            $0.lessonID == lessonID && calendar.isDate($0.date, inSameDayAs: date)
        }?.status
    }

    func attendanceStats(lessonID: UUID) -> (present: Int, late: Int, absent: Int) {
        let records = attendance.filter { $0.lessonID == lessonID }
        return (
            records.filter { $0.status == .present }.count,
            records.filter { $0.status == .late }.count,
            records.filter { $0.status == .absent }.count
        )
    }

    // MARK: - Backup

    private struct ScheduleBackup: Codable {
        struct BackupLesson: Codable {
            var id: UUID
            var subject: String
            var teacher: String
            var room: String
            var startMinutes: Int
            var endMinutes: Int
            var weekdays: [Int]
            var colorHex: String
            var notes: String
        }

        struct BackupHomework: Codable {
            var lessonID: UUID
            var title: String
            var details: String
            var dueDate: Date
            var isCompleted: Bool
            var completedAt: Date?
            var createdAt: Date
        }

        var version: Int = 1
        var exportedAt: Date
        var lessons: [BackupLesson]
        var homework: [BackupHomework]
    }

    func makeBackupURL() -> URL? {
        let backup = ScheduleBackup(
            exportedAt: .now,
            lessons: lessons.map { lesson in
                ScheduleBackup.BackupLesson(
                    id: lesson.id,
                    subject: lesson.subject,
                    teacher: lesson.teacher,
                    room: lesson.room,
                    startMinutes: Self.minutes(of: lesson.startTime),
                    endMinutes: Self.minutes(of: lesson.endTime),
                    weekdays: lesson.weekdays.map(\.rawValue).sorted(),
                    colorHex: lesson.colorHex,
                    notes: lesson.notes
                )
            },
            homework: homework.map { item in
                ScheduleBackup.BackupHomework(
                    lessonID: item.lessonID,
                    title: item.title,
                    details: item.details,
                    dueDate: item.dueDate,
                    isCompleted: item.isCompleted,
                    completedAt: item.completedAt,
                    createdAt: item.createdAt
                )
            }
        )
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(backup)
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("Classroom-Backup-\(Int(Date.now.timeIntervalSince1970))")
                .appendingPathExtension("json")
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            alertMessage = error.localizedDescription
            return nil
        }
    }

    func importSchedule(from url: URL) -> Bool {
        let secured = url.startAccessingSecurityScopedResource()
        defer { if secured { url.stopAccessingSecurityScopedResource() } }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let backup = try decoder.decode(ScheduleBackup.self, from: try Data(contentsOf: url))
            try repository.deleteAll()
            try repository.deleteAllHomework()
            var importedIDs = Set<UUID>()
            for backupLesson in backup.lessons {
                let lesson = Lesson(
                    id: backupLesson.id,
                    subject: backupLesson.subject,
                    teacher: backupLesson.teacher,
                    room: backupLesson.room,
                    startTime: Self.date(fromMinutes: backupLesson.startMinutes),
                    endTime: Self.date(fromMinutes: backupLesson.endMinutes),
                    weekdays: Set(backupLesson.weekdays.compactMap(Weekday.init(rawValue:))),
                    colorHex: backupLesson.colorHex,
                    notes: backupLesson.notes
                )
                try repository.save(lesson)
                importedIDs.insert(lesson.id)
            }
            for backupHomework in backup.homework where importedIDs.contains(backupHomework.lessonID) {
                try repository.save(
                    Homework(
                        lessonID: backupHomework.lessonID,
                        title: backupHomework.title,
                        details: backupHomework.details,
                        dueDate: backupHomework.dueDate,
                        isCompleted: backupHomework.isCompleted,
                        completedAt: backupHomework.completedAt,
                        createdAt: backupHomework.createdAt
                    )
                )
            }
            load()
            Task { await synchronizeIntegrations() }
            return true
        } catch {
            alertMessage = "Could not import this backup: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Sample schedule

    func seedSampleSchedule() {
        guard lessons.isEmpty else { return }
        let calendar = Calendar.current
        func at(_ hour: Int, _ minute: Int) -> Date {
            calendar.date(bySettingHour: hour, minute: minute, second: 0, of: .now) ?? .now
        }
        let samples: [(subject: String, teacher: String, room: String, start: (Int, Int), end: (Int, Int), days: Set<Weekday>, color: String, notes: String)] = [
            ("Mathematics", "Ms. Carter", "Room 204", (8, 30), (9, 15), [.monday, .wednesday, .friday], "4A78D9", "Bring the workbook."),
            ("Physics", "Mr. Lee", "Lab 3", (10, 0), (11, 0), [.tuesday, .thursday], "6C63E8", ""),
            ("English", "Ms. Rivera", "Room 112", (13, 0), (13, 45), [.monday, .thursday], "D94F6C", ""),
            ("History", "Mr. Novak", "Room 301", (11, 15), (12, 0), [.tuesday, .friday], "C9A64A", ""),
            ("Computer Science", "Ms. Chen", "Lab 1", (15, 0), (16, 30), [.wednesday], "4FA3A3", ""),
            ("Art", "Ms. Duras", "Studio 2", (14, 0), (15, 30), [.friday], "B76AC9", ""),
            ("Physical Education", "Coach Diaz", "Gym", (16, 0), (17, 0), [.monday, .wednesday], "58B368", "Sport kit required.")
        ]
        var idsBySubject: [String: UUID] = [:]
        for sample in samples {
            let lesson = Lesson(
                subject: sample.subject,
                teacher: sample.teacher,
                room: sample.room,
                startTime: at(sample.start.0, sample.start.1),
                endTime: at(sample.end.0, sample.end.1),
                weekdays: sample.days,
                colorHex: sample.color,
                notes: sample.notes
            )
            idsBySubject[sample.subject] = lesson.id
            try? repository.save(lesson)
        }
        let today = calendar.startOfDay(for: .now)
        func day(_ offset: Int) -> Date {
            calendar.date(byAdding: .day, value: offset, to: today) ?? today
        }
        let homeworkSamples: [(subject: String, title: String, details: String, due: Date, done: Bool)] = [
            ("Mathematics", "Problem set 12", "Exercises 1–20, page 84.", day(1), false),
            ("English", "Essay draft “My City”", "300 words, printed or handwritten.", day(0), false),
            ("Physics", "Lab report: pendulum", "Measurements from Tuesday's class.", day(2), false),
            ("History", "Cold War timeline", "Ten key events with dates.", day(4), true)
        ]
        for item in homeworkSamples {
            guard let lessonID = idsBySubject[item.subject] else { continue }
            try? repository.save(
                Homework(
                    lessonID: lessonID,
                    title: item.title,
                    details: item.details,
                    dueDate: item.due,
                    isCompleted: item.done,
                    completedAt: item.done ? .now : nil
                )
            )
        }
        load()
        Task { await synchronizeIntegrations() }
    }

    private static func minutes(of date: Date) -> Int {
        let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
    }

    private static func date(fromMinutes minutes: Int) -> Date {
        Calendar.current.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: .now) ?? .now
    }
}
