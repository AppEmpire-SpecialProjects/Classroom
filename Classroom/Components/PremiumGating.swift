import PremiumKit
import SwiftUI

/// Functional free-tier limits mirroring the premium feature list shown on
/// the onboarding paywall (one class for free; homework, attendance, week
/// grid, backups and calendar export unlock with Classroom Premium).
enum PremiumGating {
    static let freeClassLimit = 1

    static func canAddClass(currentCount: Int, isPremium: Bool) -> Bool {
        isPremium || currentCount < freeClassLimit
    }
}

// MARK: - Locked card (content screens)

/// Lock card shown in place of a premium-gated section on content screens.
/// Tapping it opens the main paywall.
struct PremiumLockedCard: View {
    let icon: String
    let title: String
    let message: String

    @State private var showPaywall = false

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
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
            Text(title)
                .font(.headline.weight(.heavy))
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                showPaywall = true
            } label: {
                Label("Unlock with Premium", systemImage: "crown.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 2)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .fullScreenCover(isPresented: $showPaywall) {
            MainPaywallView()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title), premium feature")
        .accessibilityHint("Opens the Classroom Premium paywall")
    }
}

// MARK: - Locked row (Settings form)

/// Lock row shown inside Settings sections in place of premium-gated rows.
/// Tapping it opens the main paywall.
struct PremiumLockedRow: View {
    let icon: String
    let title: String

    @State private var showPaywall = false

    var body: some View {
        Button {
            showPaywall = true
        } label: {
            HStack {
                Label(title, systemImage: icon)
                    .foregroundStyle(.primary)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.caption2.weight(.bold))
                    Text("Premium")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(Color.classroomAccent)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Color.classroomAccent.opacity(0.12), in: Capsule())
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            MainPaywallView()
        }
        .accessibilityHint("Opens the Classroom Premium paywall")
    }
}
