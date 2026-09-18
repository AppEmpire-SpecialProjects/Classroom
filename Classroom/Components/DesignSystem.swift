import SwiftUI

extension Color {
    static let classroomAccent = Color(red: 0.38, green: 0.35, blue: 0.91)
    static let classroomPink = Color(red: 0.91, green: 0.44, blue: 0.56)
    static let classroomSun = Color(red: 0.95, green: 0.68, blue: 0.28)
    static let classroomBackground = Color(uiColor: .systemGroupedBackground)

    static var classroomHeroGradient: LinearGradient {
        LinearGradient(colors: [.classroomAccent, .classroomPink], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    init(hex: String) {
        let value = Int(hex, radix: 16) ?? 0x6C63E8
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(.white)
            .background(Color.classroomHeroGradient.opacity(configuration.isPressed ? 0.8 : 1), in: RoundedRectangle(cornerRadius: 18))
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Subject icons

enum SubjectIcon {
    private static let mapping: [(keywords: [String], symbol: String, image: String)] = [
        (["math", "algebra", "geometry", "calculus"], "function", "icon-math"),
        (["physic"], "atom", "icon-physics"),
        (["chem"], "flask", "icon-physics"),
        (["bio", "science"], "leaf", "icon-physics"),
        (["english", "language", "literature", "reading", "spanish", "french", "german"], "text.bubble", "icon-english"),
        (["history"], "book.closed", "icon-history"),
        (["geograph"], "globe.americas", "icon-history"),
        (["computer", "coding", "programming", "software", "informatics", "computer science"], "chevron.left.forwardslash.chevron.right", "icon-cs"),
        (["art", "drawing", "design"], "paintbrush.pointed", "icon-art"),
        (["music", "band", "choir"], "music.note", "icon-art"),
        (["sport", "physical", " gym", "pe "], "figure.run", "icon-pe"),
        (["econom", "finance", "business"], "chart.line.uptrend.xyaxis", "icon-book"),
        (["law"], "scalemass", "icon-book"),
        (["medicine", "health"], "cross.case", "icon-book"),
        (["philosoph", "psycholog"], "brain.head.profile", "icon-book")
    ]

    static func symbol(for subject: String) -> String {
        let name = subject.lowercased()
        for entry in mapping where entry.keywords.contains(where: { name.contains($0) }) {
            return entry.symbol
        }
        return "book"
    }

    static func imageName(for subject: String) -> String {
        let name = subject.lowercased()
        for entry in mapping where entry.keywords.contains(where: { name.contains($0) }) {
            return entry.image
        }
        return "icon-book"
    }
}

struct SubjectIconTile: View {
    let subject: String
    var colorHex: String = "6C63E8"
    var size: CGFloat = 38

    var body: some View {
        Image(SubjectIcon.imageName(for: subject))
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.3, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5)
            )
            .shadow(color: Color(hex: colorHex).opacity(0.4), radius: size * 0.18, y: size * 0.1)
            .accessibilityHidden(true)
    }
}

// MARK: - Cards and chips

struct StatChip: View {
    let icon: String
    let title: String
    var tint: Color = .classroomAccent

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
            Text(title)
                .font(.caption.weight(.bold))
                .lineLimit(1)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(tint.opacity(0.13), in: Capsule())
        .accessibilityElement(children: .combine)
    }
}

struct SectionHeaderView: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Color.classroomHeroGradient, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            Text(title)
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(.primary)
        }
        .accessibilityElement(children: .combine)
    }
}

enum LessonCardStatus {
    case regular
    case current
    case next
}

struct LessonCard: View {
    let lesson: Lesson
    var status: LessonCardStatus = .regular
    var showsConflict = false

    private var highlighted: Bool { status == .current }

    var body: some View {
        HStack(spacing: 14) {
            SubjectIconTile(subject: lesson.subject, colorHex: lesson.colorHex, size: 46)
            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .firstTextBaseline) {
                    Text(lesson.subject)
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(.primary)
                    Spacer()
                    if status != .regular {
                        Text(status == .current ? "NOW" : "UP NEXT")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.classroomHeroGradient, in: Capsule())
                    }
                }
                Text("\(lesson.startTime.formatted(date: .omitted, time: .shortened)) – \(lesson.endTime.formatted(date: .omitted, time: .shortened))")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color(hex: lesson.colorHex))
                if !lesson.teacher.isEmpty || !lesson.room.isEmpty {
                    Label([lesson.teacher, lesson.room].filter { !$0.isEmpty }.joined(separator: " · "), systemImage: lesson.room.isEmpty ? "person.crop.circle" : "door.left.hand.open")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if lesson.weekParity != .everyWeek {
                    Label(lesson.weekParity.title, systemImage: lesson.weekParity.symbol)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.classroomSun)
                }
                if !lesson.skipDates.isEmpty {
                    Label(lesson.skipDates.count == 1 ? "1 skipped date" : "\(lesson.skipDates.count) skipped dates", systemImage: "calendar.badge.minus")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                if lesson.spansMidnight {
                    Label("Ends the next day", systemImage: "moon.stars")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if showsConflict {
                    Label("Overlaps another class", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(18)
        .background(highlighted ? Color.classroomAccent.opacity(0.09) : Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(highlighted ? Color.classroomAccent.opacity(0.45) : .clear, lineWidth: 1.5)
        }
        .shadow(color: .black.opacity(0.045), radius: 12, y: 5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        let state = status == .current ? "Now. " : status == .next ? "Up next. " : ""
        let time = "\(lesson.startTime.formatted(date: .omitted, time: .shortened)) to \(lesson.endTime.formatted(date: .omitted, time: .shortened))"
        let details = [lesson.teacher, lesson.room].filter { !$0.isEmpty }.joined(separator: ", ")
        return ["\(state)\(lesson.subject)", time, details, showsConflict ? "Overlaps another class" : ""].filter { !$0.isEmpty }.joined(separator: ". ")
    }
}

struct ScheduleEmptyState: View {
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image("onboarding-welcome")
                .resizable()
                .scaledToFill()
                .frame(width: 132, height: 132)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .accessibilityHidden(true)
            Text(title)
                .font(.title2.bold())
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(actionTitle, action: action)
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 42)
        .padding(.horizontal, 24)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 28))
    }
}
