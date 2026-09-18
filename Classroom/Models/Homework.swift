import Foundation
import SwiftData

struct Homework: Identifiable, Hashable {
    enum DueBucket { case overdue, today, tomorrow, upcoming, completed }

    let id: UUID
    var lessonID: UUID
    var title: String
    var details: String
    var dueDate: Date
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        lessonID: UUID,
        title: String,
        details: String = "",
        dueDate: Date,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.lessonID = lessonID
        self.title = title
        self.details = details
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.createdAt = createdAt
    }

    func bucket(asOf reference: Date = .now, calendar: Calendar = .current) -> DueBucket {
        if isCompleted { return .completed }
        if calendar.isDate(dueDate, inSameDayAs: reference) { return .today }
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: reference),
           calendar.isDate(dueDate, inSameDayAs: tomorrow) {
            return .tomorrow
        }
        return dueDate < reference ? .overdue : .upcoming
    }

    func isOverdue(asOf reference: Date = .now, calendar: Calendar = .current) -> Bool {
        bucket(asOf: reference, calendar: calendar) == .overdue
    }
}

@Model
final class HomeworkRecord {
    @Attribute(.unique) var id: UUID
    var lessonID: UUID
    var title: String
    var details: String
    var dueDate: Date
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date = Date()

    init(homework: Homework) {
        id = homework.id
        lessonID = homework.lessonID
        title = homework.title
        details = homework.details
        dueDate = homework.dueDate
        isCompleted = homework.isCompleted
        completedAt = homework.completedAt
        createdAt = homework.createdAt
    }

    var homework: Homework {
        Homework(
            id: id,
            lessonID: lessonID,
            title: title,
            details: details,
            dueDate: dueDate,
            isCompleted: isCompleted,
            completedAt: completedAt,
            createdAt: createdAt
        )
    }

    func update(from homework: Homework) {
        title = homework.title
        details = homework.details
        dueDate = homework.dueDate
        isCompleted = homework.isCompleted
        completedAt = homework.completedAt
    }
}
