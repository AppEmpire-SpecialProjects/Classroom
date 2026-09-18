import PremiumKit
import SwiftUI

struct OnboardingView: View {
    @Binding var role: ClassroomRole
    let completion: () -> Void

    var body: some View {
        OnboardingBuilder(
            screens: screens,
            paywallImages: AdaptiveResources(iphone: Image("onboarding-paywall")),
            style: Self.style,
            linksConfig: LinksConfiguration(
                termsTitle: "Terms of Use",
                privacyTitle: "Privacy Policy",
                restoreTitle: "Restore",
                order: [.privacy, .restore, .terms]),
            termsView: { LegalDocumentView(document: .terms) },
            privacyView: { LegalDocumentView(document: .privacy) },
            paywallBackgroundView: AnyView(OnboardingBackdropView(iconName: nil)),
            paywallMiddleView: AnyView(PaywallFeaturesView()),
            onLimitedTapped: {},
            onComplete: { completion() }
        )
    }

    private var screens: [OnboardingScreen] {
        [
            OnboardingScreen(
                id: 1,
                title1: "Your schedule,",
                title2: "levelled up.",
                subtitle: "Every class, deadline and reminder in one colorful place.",
                message: "Smart reminders keep you on time, every time.",
                buttonTitle: "Continue",
                images: AdaptiveResources(iphone: Image("onboarding-welcome")),
                backgroundView: AnyView(OnboardingBackdropView(iconName: "onboarding-welcome"))
            ),
            OnboardingScreen(
                id: 2,
                title1: "",
                title2: "",
                subtitle: "",
                buttonTitle: "Continue",
                images: AdaptiveResources(iphone: Image("onboarding-welcome")),
                backgroundView: AnyView(RoleScreenBackground(role: $role)),
                hideContent: [.title, .subtitle, .message]
            ),
            OnboardingScreen(
                id: 3,
                title1: "Made for",
                title2: "your week.",
                subtitle: "A live Today timeline, homework tracking, smart reminders and a week grid.",
                message: "Homework, attendance and stats — all in one tap.",
                buttonTitle: "Continue",
                images: AdaptiveResources(iphone: Image("onboarding-features")),
                backgroundView: AnyView(OnboardingBackdropView(iconName: "onboarding-features"))
            )
        ]
    }

    private static let style: OnboardingStyle = OnboardingStyle(
        limitedButtonColor: Color.classroomAccent,
        toggleColor: .classroomAccent,
        backgroundColor: Color.white,
        titleFont: .system(size: 32, weight: .heavy, design: .rounded),
        title1Color: Color(red: 0.13, green: 0.09, blue: 0.25),
        title2Color: Color.classroomAccent,
        subtitleFont: .system(size: 16, weight: .medium),
        subtitleColor: Color.secondary,
        messageFont: .system(size: 14, weight: .medium),
        messageColor: Color(red: 0.13, green: 0.09, blue: 0.25),
        messageBackgroundColor: Color.classroomAccent.opacity(0.08),
        messageHeight: 48,
        messageCornerRadius: 16,
        buttonFont: .system(size: 19, weight: .bold, design: .rounded),
        buttonTextColor: Color.white,
        buttonBackgroundColor: LinearGradient(colors: [.classroomAccent, .classroomPink], startPoint: .leading, endPoint: .trailing),
        buttonCornerRadius: 24,
        buttonHeight: 58,
        linksColor: Color.secondary.opacity(0.6),
        bottomPadding: 0,
        indicatorActiveColor: LinearGradient(colors: [.classroomAccent, .classroomPink], startPoint: .leading, endPoint: .trailing),
        indicatorInactiveColor: Color.classroomAccent.opacity(0.25),
        indicatorFutureColor: Color.classroomAccent.opacity(0.18),
        showNewToggle: true,
        toggleType: .checkmark,
        checkmarkSize: 26,
        checkmarkActiveBGColor: LinearGradient(colors: [.classroomAccent, .classroomPink], startPoint: .leading, endPoint: .trailing),
        checkmarkActiveColor: Color.white,
        checkmarkActiveBorderColor: Color.clear,
        checkmarkInactiveBorderColor: Color(red: 0.78, green: 0.78, blue: 0.84),
        checkmarkIconSize: 15,
        checkmarkIconWeight: .bold
    )
}

/// White backdrop shared by every onboarding screen and the main paywall.
/// The decoration is composed around the screen center so it never crowds
/// the bottom-pinned text; the icon sits top-center without an extra card.
struct OnboardingBackdropView: View {
    let iconName: String?
    var iconSize: CGFloat = 176
    var clipIcon: Bool = true

    var body: some View {
        ZStack(alignment: .top) {
            Color.white
            decor
            if let iconName {
                iconView(named: iconName)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var decor: some View {
        ZStack {
            Circle()
                .fill(Color.classroomAccent.opacity(0.12))
                .frame(width: 300, height: 300)
                .blur(radius: 44)
                .offset(x: -120, y: 40)
            Circle()
                .fill(Color.classroomPink.opacity(0.14))
                .frame(width: 260, height: 260)
                .blur(radius: 40)
                .offset(x: 130, y: -40)
            Circle()
                .strokeBorder(Color.classroomAccent.opacity(0.10), lineWidth: 1.5)
                .frame(width: 330, height: 330)
                .offset(x: -150, y: 140)
            Circle()
                .strokeBorder(Color.classroomPink.opacity(0.12), lineWidth: 1.5)
                .frame(width: 210, height: 210)
                .offset(x: 155, y: 150)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func iconView(named name: String) -> some View {
        let base = Image(name)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: iconSize, height: iconSize)
        Group {
            if clipIcon {
                base.clipShape(RoundedRectangle(cornerRadius: iconSize * 0.23, style: .continuous))
            } else {
                base
            }
        }
        .shadow(color: Color.classroomAccent.opacity(0.18), radius: 24, x: 0, y: 12)
        .padding(.top, 104)
    }
}

/// Role screen background: the backdrop plus the student/teacher picker
/// centered on the screen while the builder keeps only the button at the bottom.
private struct RoleScreenBackground: View {
    @Binding var role: ClassroomRole

    var body: some View {
        ZStack {
            OnboardingBackdropView(iconName: nil)
            RolePickerView(role: $role)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct RolePickerView: View {
    @Binding var role: ClassroomRole
    @State private var selection: ClassroomRole = .student

    var body: some View {
        VStack(spacing: 18) {
            Text("Who are you?")
                .font(.system(size: 27, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 0.13, green: 0.09, blue: 0.25))
            ForEach(ClassroomRole.allCases) { option in
                RoleCard(option: option, isSelected: selection == option) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selection = option
                    }
                    role = option
                }
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: 520)
        .onAppear { selection = role }
    }
}

private struct RoleCard: View {
    let option: ClassroomRole
    let isSelected: Bool
    let action: () -> Void

    private var description: String {
        option == .student
            ? "Track classes, homework and grades-ready reminders."
            : "Manage lessons, rooms and your teaching week."
    }

    private var tileBackground: some ShapeStyle {
        isSelected
            ? AnyShapeStyle(LinearGradient(colors: [.classroomAccent, .classroomPink], startPoint: .topLeading, endPoint: .bottomTrailing))
            : AnyShapeStyle(Color.classroomAccent.opacity(0.1))
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: option.symbol)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? Color.white : Color.classroomAccent)
                    .frame(width: 52, height: 52)
                    .background(tileBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.rawValue)
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(Color(red: 0.13, green: 0.09, blue: 0.25))
                    Text(description)
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.classroomPink : Color(red: 0.85, green: 0.85, blue: 0.9))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(isSelected ? Color.classroomAccent.opacity(0.1) : Color(red: 0.96, green: 0.955, blue: 0.98))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(
                        isSelected ? Color.classroomAccent.opacity(0.75) : Color.classroomAccent.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(option.rawValue) role")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Top block of the onboarding paywall step: the Unlimited Access headline
/// and the premium feature list that unlocks with the subscription.
struct PaywallFeaturesView: View {
    private struct Feature {
        let icon: String
        let title: String
        let subtitle: String
    }

    private let features: [Feature] = [
        Feature(icon: "calendar.badge.plus", title: "Unlimited classes", subtitle: "Build your whole week, not just one class"),
        Feature(icon: "checklist", title: "Homework tracker", subtitle: "Every task and deadline in one list"),
        Feature(icon: "chart.bar.fill", title: "Attendance & stats", subtitle: "Mark presence and see your progress"),
        Feature(icon: "square.grid.3x3.fill", title: "Week grid & backups", subtitle: "Full-week overview, JSON backup, calendar export")
    ]

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.classroomAccent, .classroomPink], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                (
                    Text("Unlimited ")
                        .foregroundStyle(Color(red: 0.13, green: 0.09, blue: 0.25))
                    + Text("Access")
                        .foregroundStyle(
                            LinearGradient(colors: [.classroomAccent, .classroomPink], startPoint: .leading, endPoint: .trailing)
                        )
                )
                .font(.system(size: 30, weight: .heavy, design: .rounded))
            }
            VStack(spacing: 12) {
                ForEach(Array(features.enumerated()), id: \.offset) { _, feature in
                    HStack(spacing: 12) {
                        Image(systemName: feature.icon)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 38, height: 38)
                            .background(
                                LinearGradient(colors: [.classroomAccent, .classroomPink], startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            Text(feature.title)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 0.13, green: 0.09, blue: 0.25))
                            Text(feature.subtitle)
                                .font(.system(size: 12.5, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 14)
        .frame(maxWidth: 520)
    }
}
