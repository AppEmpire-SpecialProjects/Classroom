import Foundation
import SwiftData

enum AttendanceStatus: String, CaseIterable, Identifiable {
    case present = "Present"
    case late = "Late"
    case absent = "Absent"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .present: "checkmark.circle.fill"
        case .late: "clock.badge.exclamationmark.fill"
        case .absent: "xmark.circle.fill"
        }
    }

    var tintHex: String {
        switch self {
        case .present: "34B76F"
        case .late: "F0A02C"
        case .absent: "E76F8A"
        }
    }
}

struct Attendance: Identifiable, Hashable {
    let id: UUID
    var lessonID: UUID
    var date: Date
    var status: AttendanceStatus
    var createdAt: Date

    init(
        id: UUID = UUID(),
        lessonID: UUID,
        date: Date,
        status: AttendanceStatus,
        createdAt: Date = .now
    ) {
        self.id = id
        self.lessonID = lessonID
        self.date = date
        self.status = status
        self.createdAt = createdAt
    }
}

@Model
final class AttendanceRecord {
    @Attribute(.unique) var id: UUID
    var lessonID: UUID
    var date: Date
    var statusRaw: String
    var createdAt: Date = Date()

    init(attendance: Attendance) {
        id = attendance.id
        lessonID = attendance.lessonID
        date = attendance.date
        statusRaw = attendance.status.rawValue
        createdAt = attendance.createdAt
    }

    var attendance: Attendance {
        Attendance(
            id: id,
            lessonID: lessonID,
            date: date,
            status: AttendanceStatus(rawValue: statusRaw) ?? .present,
            createdAt: createdAt
        )
    }

    func update(from attendance: Attendance) {
        lessonID = attendance.lessonID
        date = attendance.date
        statusRaw = attendance.status.rawValue
    }
}
