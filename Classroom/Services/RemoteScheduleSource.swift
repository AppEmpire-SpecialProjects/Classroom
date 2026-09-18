import Foundation

enum RemoteScheduleError: Error {
    case notConfigured
}

/// A source of classes from an external service.
/// The repository layer stays local-first: implementations map remote
/// courses into `Lesson` values without replacing `ScheduleRepository`.
protocol RemoteScheduleSource: Sendable {
    var title: String { get }
    var isConfigured: Bool { get }
    func fetchAvailableClasses() async throws -> [Lesson]
}

/// Integration slot reserved for Google Classroom. Requires no network
/// access and no credentials until it is explicitly configured.
final class GoogleClassroomService: RemoteScheduleSource, @unchecked Sendable {
    let title = "Google Classroom"

    var isConfigured: Bool { false }

    func fetchAvailableClasses() async throws -> [Lesson] {
        throw RemoteScheduleError.notConfigured
    }
}
