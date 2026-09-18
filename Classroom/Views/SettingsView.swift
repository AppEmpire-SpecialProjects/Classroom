import PremiumKit
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject var viewModel: AppViewModel
    @ObservedObject private var settings: UserSettings
    @State private var confirmingReset = false
    @State private var updatingCalendar = false
    @State private var backupURL: URL?
    @State private var importPresented = false
    @State private var confirmingImport = false
    @State private var importedURL: URL?
    @State private var showPaywall = false
    @State private var legalDocument: LegalDocumentView.Document?
    @State private var isPremiumActive = false

    private let shareURL = URL(string: "https://apps.apple.com/apps/id6813565320")!

    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
        settings = viewModel.settings
    }

    var body: some View {
        Form {
            premiumBannerSection
            appLinksSection
            scheduleSection
            notificationsSection
            calendarSection
            appearanceSection
            generalSection
            dataSection
        }
        .navigationTitle("Settings")
        .confirmationDialog("Reset your entire schedule?", isPresented: $confirmingReset, titleVisibility: .visible) {
            Button("Reset Schedule", role: .destructive) {
                Task {
                    if await viewModel.resetSchedule() {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Every class, reminder, and exported Calendar event will be removed. This cannot be undone.")
        }
        .fileImporter(isPresented: $importPresented, allowedContentTypes: [.json]) { result in
            if case .success(let url) = result {
                importedURL = url
                confirmingImport = true
            }
        }
        .confirmationDialog("Replace your current schedule?", isPresented: $confirmingImport, titleVisibility: .visible) {
            Button("Replace Schedule", role: .destructive) {
                if let importedURL, viewModel.importSchedule(from: importedURL) {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
                importedURL = nil
            }
            Button("Cancel", role: .cancel) {
                importedURL = nil
            }
        } message: {
            Text("Importing a backup removes the current classes and homework and restores the saved data.")
        }
        .fullScreenCover(isPresented: $showPaywall) {
            MainPaywallView()
        }
        .sheet(item: $legalDocument) { document in
            LegalDocumentView(document: document)
        }
        .task {
            await viewModel.refreshPermissionStatuses()
            backupURL = viewModel.makeBackupURL()
            isPremiumActive = Premium.shared.isPremium
        }
        .onReceive(Premium.shared.$isPremium) { value in
            isPremiumActive = value
        }
        .onChange(of: viewModel.lessons.count) { _, _ in
            backupURL = viewModel.makeBackupURL()
        }
        .onChange(of: viewModel.homework.count) { _, _ in
            backupURL = viewModel.makeBackupURL()
        }
    }

    // MARK: - Premium banner

    @ViewBuilder
    private var premiumBannerSection: some View {
        Section {
            if !isPremiumActive {
                Button {
                    showPaywall = true
                } label: {
                    PremiumBannerView()
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                .listRowBackground(Color.clear)
                .accessibilityLabel("Classroom Premium subscription")
            }
        }
    }

    private var appLinksSection: some View {
        Section {
            ShareLink(item: shareURL) {
                Label("Share App", systemImage: "square.and.arrow.up")
            }
            Button {
                openAppStoreReview()
            } label: {
                Label("Rate App", systemImage: "star.fill")
            }
            LabeledContent {
                Text(appVersion)
                    .foregroundStyle(.secondary)
            } label: {
                Label("App Version", systemImage: "app.badge")
            }
            Button {
                contactSupport()
            } label: {
                Label("Contact Us", systemImage: "envelope")
            }
            Button {
                legalDocument = .privacy
            } label: {
                Label("Privacy Policy", systemImage: "hand.raised.fill")
            }
            Button {
                legalDocument = .terms
            } label: {
                Label("Terms of Use", systemImage: "doc.text.fill")
            }
        } header: {
            Label("About", systemImage: "info.circle")
        }
    }

    // MARK: - Core settings

    private var scheduleSection: some View {
        Section("Schedule") {
            Picker("First day of week", selection: $settings.firstDay) {
                ForEach(FirstDayOfWeek.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            Picker("Default class duration", selection: $settings.defaultDuration) {
                ForEach(DefaultClassDuration.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            Picker("Default reminder", selection: $settings.reminderLead) {
                ForEach(ReminderLeadTime.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .onChange(of: settings.reminderLead) { _, _ in
                Task { await viewModel.updateReminders() }
            }
        }
    }

    private var notificationsSection: some View {
        Section {
            Toggle("Daily summary", isOn: $settings.dailyDigest)
                .onChange(of: settings.dailyDigest) { _, _ in
                    Task { await viewModel.updateReminders() }
                }
            LabeledContent("Notification access", value: viewModel.notificationPermission.rawValue)
                .foregroundStyle(viewModel.notificationPermission == .denied ? Color.red : Color.primary)
        } header: {
            Label("Notifications", systemImage: "bell.badge")
        } footer: {
            Text("Reminders are scheduled locally and automatically update when classes change. Turn on Daily summary for a morning overview of your day at 8:00. You can change system access in the Settings app.")
        }
    }

    private var calendarSection: some View {
        Section {
            if isPremiumActive {
                Toggle("Add schedule to Apple Calendar", isOn: calendarBinding)
                    .disabled(updatingCalendar)
                LabeledContent("Calendar access", value: viewModel.calendarPermission.rawValue)
                    .foregroundStyle(viewModel.calendarPermission == .denied ? Color.red : Color.primary)
                if updatingCalendar {
                    HStack {
                        ProgressView()
                        Text("Updating Calendar…")
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                PremiumLockedRow(icon: "calendar.badge.plus", title: "Add schedule to Apple Calendar")
            }
        } header: {
            Label("Apple Calendar", systemImage: "calendar.badge.plus")
        } footer: {
            if isPremiumActive {
                Text("Permission is requested only when you turn this on. Weekly events are stored in a separate Classroom Schedule calendar and removed when you turn it off.")
            } else {
                Text("Exporting your weekly classes to a separate Apple Calendar is part of Classroom Premium.")
            }
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: $settings.appearance) {
                ForEach(AppearancePreference.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var generalSection: some View {
        Section("General") {
            Picker("Role", selection: $settings.role) {
                ForEach(ClassroomRole.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            Button("Reset schedule", role: .destructive) {
                confirmingReset = true
            }
            .disabled(viewModel.lessons.isEmpty)
        }
    }

    private var dataSection: some View {
        Section {
            if isPremiumActive {
                if let backupURL {
                    ShareLink(item: backupURL) {
                        Label("Export backup", systemImage: "square.and.arrow.up")
                    }
                }
                Button {
                    importPresented = true
                } label: {
                    Label("Import backup", systemImage: "square.and.arrow.down")
                }
                Button {
                    viewModel.seedSampleSchedule()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } label: {
                    Label("Load sample schedule", systemImage: "wand.and.stars")
                }
                .disabled(!viewModel.lessons.isEmpty)
            } else {
                PremiumLockedRow(icon: "externaldrive", title: "Backups")
            }
        } header: {
            Label("Data", systemImage: "externaldrive")
        } footer: {
            if isPremiumActive {
                Text("Backups include classes and homework as a shareable JSON file. Importing replaces the current schedule. Use the sample to explore the app with demo classes.")
            } else {
                Text("JSON backup export, import and the sample schedule are part of Classroom Premium.")
            }
        }
    }

    // MARK: - Actions

    private func restorePurchases() {
        Task { @MainActor in
            let result = await Premium.shared.restore()
            switch result {
            case .success:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                viewModel.alertMessage = "Purchases restored successfully."
            case .failure(let error):
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                viewModel.alertMessage = error.localizedDescription
            }
        }
    }

    private func openAppStoreReview() {
        let url = URL(string: "itms-apps://itunes.apple.com/app/id6813565320?action=write-review")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            viewModel.alertMessage = "Couldn't open the App Store."
        }
    }

    private func contactSupport() {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "admin@gccyltd.com"
        components.queryItems = [URLQueryItem(name: "subject", value: "Classroom Feedback")]
        if let url = components.url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            viewModel.alertMessage = "Email us anytime at admin@gccyltd.com"
        }
    }

    private var calendarBinding: Binding<Bool> {
        Binding(
            get: { settings.calendarEnabled },
            set: { enabled in
                updatingCalendar = true
                Task {
                    let didUpdate = await viewModel.setCalendarEnabled(enabled)
                    if didUpdate {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                    updatingCalendar = false
                }
            }
        )
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        return build.map { "\(version) (\($0))" } ?? version
    }
}

// MARK: - Premium banner

private struct PremiumBannerView: View {
    var body: some View {
        HStack(spacing: 14) {
            Image("crown-premium")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 52, height: 52)
            VStack(alignment: .leading, spacing: 3) {
                Text("Classroom Premium")
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("Unlock the full experience and support the app")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Text("Try")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.classroomAccent)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.white, in: Capsule())
        }
        .padding(16)
        .background(
            LinearGradient(colors: [.classroomAccent, .classroomPink], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .shadow(color: Color.classroomAccent.opacity(0.35), radius: 14, x: 0, y: 6)
    }
}

// MARK: - Main paywall

struct MainPaywallView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PaywallBuilder(
            images: AdaptiveResources(iphone: Image("crown-premium")),
            style: Self.style,
            linksConfig: LinksConfiguration(
                termsTitle: "Terms of Use",
                privacyTitle: "Privacy Policy",
                restoreTitle: "Restore",
                order: [.terms, .restore, .privacy]
            ),
            showCloseButton: true,
            termsView: { LegalDocumentView(document: .terms) },
            privacyView: { LegalDocumentView(document: .privacy) },
            backgroundView: AnyView(OnboardingBackdropView(iconName: nil)),
            middleView: AnyView(PaywallFeaturesView()),
            onDismiss: { dismiss() },
            onSuccess: { dismiss() }
        )
    }

    private static let style: PaywallStyle = PaywallStyle(
        accentColor: .classroomAccent,
        buttonFont: .system(size: 19, weight: .bold, design: .rounded),
        buttonBackgroundColor: LinearGradient(colors: [.classroomAccent, .classroomPink], startPoint: .leading, endPoint: .trailing),
        buttonCornerRadius: 24,
        buttonHeight: 58,
        linksFont: .system(size: 13, weight: .medium),
        linksColor: Color.secondary.opacity(0.65),
        bottomPadding: 0,
        offerBorderColor: Color.classroomAccent.opacity(0.35),
        offerSelectedBorderColor: Color.classroomAccent,
        offerBorderWidth: 1.5,
        offerSelectedBorderWidth: 1.5,
        offerSelectedBackgroundColor: Color.classroomAccent.opacity(0.08),
        offerCheckmarkActiveBGColor: LinearGradient(colors: [.classroomAccent, .classroomPink], startPoint: .leading, endPoint: .trailing),
        offerCheckmarkActiveBorderColor: Color.clear,
        offerCheckmarkInactiveBorderColor: Color(red: 0.78, green: 0.78, blue: 0.84),
        closeButtonIcon: "xmark",
        closeButtonColor: Color(red: 0.25, green: 0.2, blue: 0.4),
        closeButtonPlacement: .topBarTrailing
    )
}

// MARK: - Legal documents

/// Loads the bundled Markdown legal documents: the first level-1 heading is
/// the document title, a "Last updated:" line carries the effective date,
/// the paragraphs before the first section form the introduction, and every
/// level-2 heading starts a section.
enum LegalMarkdown {
    struct Content {
        let updated: String
        let introduction: String
        let sections: [(heading: String, body: String)]
    }

    static func load(_ name: String) -> Content {
        guard
            let url = Bundle.main.url(forResource: name, withExtension: "md"),
            let text = try? String(contentsOf: url, encoding: .utf8)
        else {
            return Content(updated: "", introduction: "", sections: [])
        }

        var updated = ""
        var introductionBlocks: [String] = []
        var sectionBlocks: [(heading: String, body: [String])] = []
        var paragraphLines: [String] = []

        func closeParagraph() {
            guard !paragraphLines.isEmpty else { return }
            let paragraph = paragraphLines.joined(separator: "\n")
            if sectionBlocks.isEmpty {
                introductionBlocks.append(paragraph)
            } else {
                sectionBlocks[sectionBlocks.count - 1].body.append(paragraph)
            }
            paragraphLines = []
        }

        for rawLine in text.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            if line.hasPrefix("## ") {
                closeParagraph()
                sectionBlocks.append((heading: String(line.dropFirst(3)), body: []))
            } else if line.hasPrefix("# ") {
                continue
            } else if line.isEmpty {
                closeParagraph()
            } else if sectionBlocks.isEmpty && line.hasPrefix("Last updated:") {
                updated = line
            } else {
                paragraphLines.append(line.hasPrefix("- ") ? String(line.dropFirst(2)) : line)
            }
        }
        closeParagraph()

        return Content(
            updated: updated,
            introduction: introductionBlocks.joined(separator: "\n\n"),
            sections: sectionBlocks.map { (heading: $0.heading, body: $0.body.joined(separator: "\n\n")) }
        )
    }
}


struct LegalDocumentView: View {
    enum Document: String, Identifiable {
        case privacy = "PrivacyPolicy"
        case terms = "TermsOfUse"

        var id: String { rawValue }

        var title: String {
            switch self {
            case .privacy: "Privacy Policy"
            case .terms: "Terms of Use"
            }
        }

        /// The document text is loaded from Classroom/Resources/<rawValue>.md,
        /// so the legal copy lives outside of view code.
        var content: LegalMarkdown.Content {
            LegalMarkdown.load(rawValue)
        }
    }

    let document: Document
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(document.content.updated)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                    Text(document.content.introduction)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(Array(document.content.sections.enumerated()), id: \.offset) { _, section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.0)
                                .font(.headline)
                                .foregroundStyle(Color.classroomAccent)
                            Text(section.1)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.classroomBackground)
            .navigationTitle(document.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color(red: 0.13, green: 0.09, blue: 0.25))
                            .frame(width: 30, height: 30)
                            .background(Color.classroomAccent.opacity(0.12), in: Circle())
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }
}
