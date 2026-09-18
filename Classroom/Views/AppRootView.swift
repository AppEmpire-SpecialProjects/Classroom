import SwiftUI
import PremiumKit

enum AppTab: Hashable { case today, schedule, add, settings }

struct AppRootView: View {
    @ObservedObject private var premiumService = Premium.shared
    @ObservedObject var viewModel: AppViewModel
    @ObservedObject private var settings: UserSettings
    @State private var selectedTab: AppTab = .today
    @State private var showPaywall = false

    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
        settings = viewModel.settings
    }

    var body: some View {
        Group {
            if settings.completedOnboarding {
                mainTabs
                    .taskOnce {
                        await Premium.shared.loadPaywall(.main)
                    }
            } else {
                OnboardingView(role: $settings.role) {
                    settings.completedOnboarding = true
                    selectedTab = .today
                }
                .taskOnce {
                    await Premium.shared.loadPaywall(.onboarding)
                }
            }
        }
        .overlay {
            if premiumService.isShowingSplash {
                splashView
            }
        }
        .preferredColorScheme(settings.appearance.colorScheme)
        .tint(.classroomAccent)
        .fullScreenCover(isPresented: $showPaywall) {
            MainPaywallView()
        }
        .alert("Classroom", isPresented: Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.alertMessage = nil } }
        )) { Button("OK", role: .cancel) {} } message: { Text(viewModel.alertMessage ?? "") }
    }

    private var mainTabs: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { TodayView(viewModel: viewModel, selectedTab: $selectedTab) }
                .tabItem { Label("Today", systemImage: "sun.max.fill") }
                .tag(AppTab.today)
            NavigationStack { ScheduleView(viewModel: viewModel, selectedTab: $selectedTab) }
                .tabItem { Label("Schedule", systemImage: "calendar") }
                .tag(AppTab.schedule)
            addTab
                .tabItem { Label("Add", systemImage: "plus.circle.fill") }
                .tag(AppTab.add)
            NavigationStack { SettingsView(viewModel: viewModel) }
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(AppTab.settings)
        }
    }

    /// The free plan includes a single class: once the limit is reached the
    /// Add tab shows a locked stub that opens the paywall on tap. The stub
    /// disappears as soon as premium is active or the limit frees up.
    @ViewBuilder
    private var addTab: some View {
        if PremiumGating.canAddClass(currentCount: viewModel.lessons.count, isPremium: premiumService.isPremium) {
            NavigationStack {
                LessonEditorView(viewModel: viewModel) { selectedTab = .today }
            }
        } else {
            AddTabLockedView { showPaywall = true }
        }
    }

    @ViewBuilder
    var splashView: some View {
        ZStack {
            Color.white
            
            Image(.launchIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
        }
        .ignoresSafeArea()
    }
}

/// Locked stub shown inside the Add tab while the free single-class limit is
/// reached. It disappears once premium is active; tapping opens the paywall.
private struct AddTabLockedView: View {
    let onUpgrade: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.classroomHeroGradient)
                .frame(width: 52, height: 52)
                .background(Color.classroomAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(Color.classroomPink, in: Circle())
                        .offset(x: 5, y: -5)
                }
                .accessibilityHidden(true)
            Text("Free plan limit reached")
                .font(.headline.weight(.heavy))
            Text("The free plan includes one class. Upgrade to create unlimited classes with homework, attendance and the week grid.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 36)
            Button {
                onUpgrade()
            } label: {
                Label("Unlock with Premium", systemImage: "crown.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 2)
            .padding(.horizontal, 36)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.classroomBackground)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Free plan limit reached, premium feature")
        .accessibilityHint("Opens the Classroom Premium paywall")
    }
}
