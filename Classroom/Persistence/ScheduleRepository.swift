import Foundation
import SwiftData

@MainActor
protocol ScheduleRepository: AnyObject {
    func fetchAll() throws -> [Lesson]
    func fetch(on weekday: Weekday) throws -> [Lesson]
    func save(_ lesson: Lesson) throws
    func duplicate(_ lesson: Lesson) throws -> Lesson
    func delete(id: UUID) throws
    func deleteAll() throws

    func fetchHomework() throws -> [Homework]
    func save(_ homework: Homework) throws
    func deleteHomework(id: UUID) throws
    func deleteHomework(forLesson lessonID: UUID) throws
    func deleteAllHomework() throws

    func fetchAttendance() throws -> [Attendance]
    func save(_ attendance: Attendance) throws
    func deleteAttendance(id: UUID) throws
    func deleteAttendance(forLesson lessonID: UUID) throws
    func deleteAllAttendance() throws
}

@MainActor
final class SwiftDataScheduleRepository: ScheduleRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [Lesson] {
        let descriptor = FetchDescriptor<LessonRecord>(sortBy: [SortDescriptor(\.startTime)])
        return try context.fetch(descriptor).map(\.lesson)
    }

    func fetch(on weekday: Weekday) throws -> [Lesson] {
        try fetchAll().filter { $0.occurs(on: weekday) }
    }

    func save(_ lesson: Lesson) throws {
        let id = lesson.id
        let descriptor = FetchDescriptor<LessonRecord>(predicate: #Predicate { $0.id == id })
        if let existing = try context.fetch(descriptor).first {
            existing.update(from: lesson)
        } else {
            context.insert(LessonRecord(lesson: lesson))
        }
        try context.save()
    }

    func duplicate(_ lesson: Lesson) throws -> Lesson {
        let copy = lesson.duplicate()
        context.insert(LessonRecord(lesson: copy))
        try context.save()
        return copy
    }

    func delete(id: UUID) throws {
        let descriptor = FetchDescriptor<LessonRecord>(predicate: #Predicate { $0.id == id })
        try context.fetch(descriptor).forEach(context.delete)
        try context.save()
    }

    func deleteAll() throws {
        try context.delete(model: LessonRecord.self)
        try context.save()
    }

    func fetchHomework() throws -> [Homework] {
        let descriptor = FetchDescriptor<HomeworkRecord>(sortBy: [SortDescriptor(\.dueDate)])
        return try context.fetch(descriptor).map(\.homework)
    }

    func save(_ homework: Homework) throws {
        let id = homework.id
        let descriptor = FetchDescriptor<HomeworkRecord>(predicate: #Predicate { $0.id == id })
        if let existing = try context.fetch(descriptor).first {
            existing.update(from: homework)
        } else {
            context.insert(HomeworkRecord(homework: homework))
        }
        try context.save()
    }

    func deleteHomework(id: UUID) throws {
        let descriptor = FetchDescriptor<HomeworkRecord>(predicate: #Predicate { $0.id == id })
        try context.fetch(descriptor).forEach(context.delete)
        try context.save()
    }

    func deleteHomework(forLesson lessonID: UUID) throws {
        let descriptor = FetchDescriptor<HomeworkRecord>(predicate: #Predicate { $0.lessonID == lessonID })
        try context.fetch(descriptor).forEach(context.delete)
        try context.save()
    }

    func deleteAllHomework() throws {
        try context.delete(model: HomeworkRecord.self)
        try context.save()
    }

    func fetchAttendance() throws -> [Attendance] {
        let descriptor = FetchDescriptor<AttendanceRecord>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return try context.fetch(descriptor).map(\.attendance)
    }

    func save(_ attendance: Attendance) throws {
        let id = attendance.id
        let descriptor = FetchDescriptor<AttendanceRecord>(predicate: #Predicate { $0.id == id })
        if let existing = try context.fetch(descriptor).first {
            existing.update(from: attendance)
        } else {
            context.insert(AttendanceRecord(attendance: attendance))
        }
        try context.save()
    }

    func deleteAttendance(id: UUID) throws {
        let descriptor = FetchDescriptor<AttendanceRecord>(predicate: #Predicate { $0.id == id })
        try context.fetch(descriptor).forEach(context.delete)
        try context.save()
    }

    func deleteAttendance(forLesson lessonID: UUID) throws {
        let descriptor = FetchDescriptor<AttendanceRecord>(predicate: #Predicate { $0.lessonID == lessonID })
        try context.fetch(descriptor).forEach(context.delete)
        try context.save()
    }

    func deleteAllAttendance() throws {
        try context.delete(model: AttendanceRecord.self)
        try context.save()
    }
}
