import PremiumKit
import SwiftData
import SwiftUI

@main
struct ClassroomApp: App {
    @UIApplicationDelegateAdaptor(PremiumAppDelegate.self) private var appDelegate

    private let container: ModelContainer
    @StateObject private var appViewModel: AppViewModel

    init() {
        Premium.shared.configure(
            PremiumConfiguration(
                apiKey: "app_jH7T6JxXHS3ztf1GX1gTRHJr8g2dtT",
                supportedLanguages: [.en],
                defaultLanguage: .en,
                forceFallback: false,
                fallbackFileName: "pk_43b0bfe4f1a356da56e64985"
            )
        )

        do {
            let container = try ModelContainer(for: LessonRecord.self, HomeworkRecord.self, AttendanceRecord.self)
            self.container = container
            let repository = SwiftDataScheduleRepository(context: container.mainContext)
            _appViewModel = StateObject(
                wrappedValue: AppViewModel(
                    repository: repository,
                    notificationService: LocalNotificationService(),
                    calendarService: AppleCalendarService()
                )
            )
        } catch {
            fatalError("Unable to create the local schedule store: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(viewModel: appViewModel)
        }
        .modelContainer(container)
    }
}
