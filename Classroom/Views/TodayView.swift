import PremiumKit
import SwiftUI

struct TodayView: View {
    @ObservedObject var viewModel: AppViewModel
    @Binding var selectedTab: AppTab
    @State private var editingLesson: Lesson?
    @State private var now = Date()
    @State private var showPaywall = false
    @ObservedObject private var premium = Premium.shared

    private var calendar: Calendar { Calendar.current }

    private var lessons: [Lesson] {
        viewModel.lessons
            .filter { $0.occurrence(on: now) != nil }
            .sorted { $0.startTime < $1.startTime }
    }

    private var currentLesson: Lesson? {
        viewModel.lessons.first { $0.isActive(at: now) }
    }

    private var displayedLessons: [Lesson] {
        guard let currentLesson, !lessons.contains(where: { $0.id == currentLesson.id }) else { return lessons }
        return ([currentLesson] + lessons).sorted { $0.startTime < $1.startTime }
    }

    private var nextLesson: Lesson? {
        lessons.first { lesson in
            guard let occurrence = lesson.occurrence(on: now) else { return false }
            return occurrence.start > now
        }
    }

    private var homeworkDue: [(item: Homework, lesson: Lesson?)] {
        viewModel.homework
            .filter { !$0.isCompleted && $0.bucket() != .upcoming }
            .sorted { $0.dueDate < $1.dueDate }
            .map { item in (item, viewModel.lessons.first { $0.id == item.lessonID }) }
    }

    private var tomorrowLessons: [Lesson] {
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else { return [] }
        return viewModel.lessons
            .filter { $0.occurrence(on: tomorrow) != nil }
            .sorted { $0.startTime < $1.startTime }
    }

    private var totalMinutes: Int {
        displayedLessons.reduce(0) { $0 + Int($1.endTime.timeIntervalSince($1.startTime) / 60) }
    }

    private var greeting: String {
        switch calendar.component(.hour, from: now) {
        case 5..<12: "Good morning"
        case 12..<18: "Good afternoon"
        default: "Good evening"
        }
    }

    private var roleTagline: String {
        viewModel.settings.role == .student
            ? "Ready to learn. Here's your day."
            : "Ready to teach. Here's your day."
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                heroHeader
                statusSummary
                if displayedLessons.isEmpty {
                    ScheduleEmptyState(title: "Nothing scheduled", message: "Enjoy your free time.", actionTitle: "Add a class") { selectedTab = .add }
                } else {
                    SectionHeaderView(icon: "sun.max.fill", title: "Your day")
                        .padding(.top, 8)
                    ForEach(Array(displayedLessons.enumerated()), id: \.element.id) { index, lesson in
                        TimelineRow(
                            lesson: lesson,
                            isCurrent: currentLesson?.id == lesson.id,
                            isNext: nextLesson?.id == lesson.id,
                            occurrence: lesson.occurrence(on: now),
                            now: now,
                            attendanceStatus: viewModel.attendanceStatus(lessonID: lesson.id, on: now),
                            isLast: index == displayedLessons.count - 1,
                            canMarkAttendance: premium.isPremium,
                            onMark: { status in
                                viewModel.setAttendance(lessonID: lesson.id, on: now, status: status)
                            },
                            onUnlockAttendance: { showPaywall = true }
                        ) {
                            editingLesson = lesson
                        }
                    }
                }
                if !homeworkDue.isEmpty {
                    if premium.isPremium {
                        homeworkSection
                    } else {
                        PremiumLockedCard(
                            icon: "checklist",
                            title: "Homework tracker",
                            message: "Every task and deadline in one list — locked while on the free plan."
                        )
                        .padding(.top, 8)
                    }
                }
                if !tomorrowLessons.isEmpty {
                    tomorrowSection
                        .padding(.top, 8)
                }
            }
            .padding(20)
        }
        .background(Color.classroomBackground)
        .navigationBarHidden(true)
        .sheet(item: $editingLesson) { lesson in
            NavigationStack { ClassDetailsView(viewModel: viewModel, lessonID: lesson.id) }
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                now = .now
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            MainPaywallView()
        }
    }

    // MARK: - Hero

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(greeting.uppercased())
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Color.white.opacity(0.75))
                        .tracking(1.2)
                    Text("Today")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text(roleTagline)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.white.opacity(0.85))
                }
                Spacer()
                Text(now.formatted(.dateTime.day()))
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 68, height: 68)
                    .background(Color.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    }
                    .accessibilityLabel(now.formatted(.dateTime.weekday(.wide).month().day()))
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    heroChip(
                        icon: "calendar",
                        text: displayedLessons.isEmpty ? "Free day" : "\(displayedLessons.count) \(displayedLessons.count == 1 ? "class" : "classes")"
                    )
                    if totalMinutes > 0 {
                        heroChip(icon: "clock", text: "\(totalMinutes / 60)h \(totalMinutes % 60)m")
                    }
                    if !homeworkDue.isEmpty {
                        heroChip(icon: "checklist", text: "\(homeworkDue.count) due")
                    }
                    heroChip(
                        icon: "sparkles",
                        text: viewModel.settings.role.rawValue
                    )
                }
            }
        }
        .padding(22)
        .background(Color.classroomHeroGradient, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color.classroomAccent.opacity(0.35), radius: 18, y: 10)
    }

    private func heroChip(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
            Text(text)
                .font(.caption.weight(.bold))
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.18), in: Capsule())
        .accessibilityElement(children: .combine)
    }

    // MARK: - Summary

    @ViewBuilder
    private var statusSummary: some View {
        if let currentLesson {
            summaryCard(eyebrow: "HAPPENING NOW", title: currentLesson.subject, detail: currentLesson.room.isEmpty ? "Ends at \(currentLesson.endTime.formatted(date: .omitted, time: .shortened))" : "\(currentLesson.room) · Ends at \(currentLesson.endTime.formatted(date: .omitted, time: .shortened))", icon: "waveform.path.ecg", lesson: currentLesson)
        } else if let nextLesson, let occurrence = nextLesson.occurrence(on: now) {
            summaryCard(eyebrow: "UP NEXT", title: nextLesson.subject, detail: occurrence.start.formatted(.relative(presentation: .named, unitsStyle: .wide)), icon: "arrow.right.circle.fill", lesson: nextLesson)
        } else if !lessons.isEmpty {
            summaryCard(eyebrow: "ALL FINISHED", title: "You're done for today", detail: "Your next class will appear here.", icon: "checkmark.circle.fill", lesson: lessons.last)
        }
    }

    private func summaryCard(eyebrow: String, title: String, detail: String, icon: String, lesson: Lesson?) -> some View {
        HStack(spacing: 14) {
            if let lesson {
                SubjectIconTile(subject: lesson.subject, colorHex: lesson.colorHex, size: 48)
            } else {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Color.classroomAccent)
                    .frame(width: 48, height: 48)
                    .background(Color.classroomAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 15))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(eyebrow)
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(Color.classroomAccent)
                    .tracking(0.8)
                Text(title)
                    .font(.headline.weight(.heavy))
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    // MARK: - Homework

    private var homeworkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(icon: "checklist", title: "Homework due")
                .padding(.top, 8)
            VStack(spacing: 2) {
                ForEach(homeworkDue, id: \.item.id) { entry in
                    HomeworkRowView(
                        item: entry.item,
                        subjectName: entry.lesson?.subject ?? "Class removed",
                        colorHex: entry.lesson?.colorHex ?? "6C63E8",
                        onToggle: { viewModel.toggleHomework(entry.item) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }

    // MARK: - Tomorrow

    private var tomorrowSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                SectionHeaderView(icon: "sunrise.fill", title: "Tomorrow")
                Text("\(tomorrowLessons.count) \(tomorrowLessons.count == 1 ? "class" : "classes")")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            VStack(spacing: 12) {
                ForEach(tomorrowLessons.prefix(3)) { lesson in
                    HStack(spacing: 12) {
                        SubjectIconTile(subject: lesson.subject, colorHex: lesson.colorHex, size: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(lesson.subject)
                                .font(.subheadline.weight(.bold))
                            Text("\(lesson.startTime.formatted(date: .omitted, time: .shortened)) · \(lesson.room.isEmpty ? lesson.teacher : lesson.room)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(hex: lesson.colorHex))
                            .accessibilityHidden(true)
                    }
                }
                if tomorrowLessons.count > 3 {
                    Text("+ \(tomorrowLessons.count - 3) more")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.classroomAccent)
                }
            }
            .padding(16)
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
}

// MARK: - Timeline row

private struct TimelineRow: View {
    let lesson: Lesson
    let isCurrent: Bool
    let isNext: Bool
    let occurrence: DateInterval?
    let now: Date
    let attendanceStatus: AttendanceStatus?
    let isLast: Bool
    let canMarkAttendance: Bool
    let onMark: (AttendanceStatus?) -> Void
    let onUnlockAttendance: () -> Void
    let onTap: () -> Void

    private var progress: Double? {
        guard isCurrent, let occurrence else { return nil }
        let total = occurrence.end.timeIntervalSince(occurrence.start)
        guard total > 0 else { return nil }
        return min(1, max(0, now.timeIntervalSince(occurrence.start) / total))
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .trailing, spacing: 2) {
                Text(lesson.startTime.formatted(date: .omitted, time: .shortened))
                    .font(.caption.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(Color(hex: lesson.colorHex))
                Text(lesson.endTime.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .frame(width: 48, alignment: .trailing)
            .padding(.top, 19)

            VStack(spacing: 0) {
                Circle()
                    .fill(Color(hex: lesson.colorHex))
                    .frame(width: isCurrent ? 12 : 9, height: isCurrent ? 12 : 9)
                    .overlay {
                        if isCurrent {
                            Circle()
                                .stroke(Color(hex: lesson.colorHex).opacity(0.25), lineWidth: 5)
                        }
                    }
                    .padding(.top, 24)
                if !isLast {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.15))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 14)

            Button(action: onTap) {
                LessonCard(
                    lesson: lesson,
                    status: isCurrent ? .current : isNext ? .next : .regular
                )
                .overlay(alignment: .topTrailing) {
                    if let attendanceStatus {
                        Image(systemName: attendanceStatus.symbol)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(hex: attendanceStatus.tintHex))
                            .padding(6)
                            .background(Color(hex: attendanceStatus.tintHex).opacity(0.15), in: Circle())
                            .padding(.trailing, 8)
                            .padding(.top, -6)
                            .accessibilityLabel("Marked \(attendanceStatus.rawValue)")
                    }
                }
                .overlay(alignment: .bottom) {
                    if let progress {
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.classroomAccent.opacity(0.15))
                                Capsule()
                                    .fill(Color.classroomHeroGradient)
                                    .frame(width: max(6, proxy.size.width * progress))
                            }
                        }
                        .frame(height: 4)
                        .padding(.horizontal, 18)
                        .padding(.bottom, 9)
                        .allowsHitTesting(false)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens class details")
            .contextMenu {
                if canMarkAttendance {
                    ForEach(AttendanceStatus.allCases) { status in
                        Button {
                            onMark(status)
                        } label: {
                            Label("Mark \(status.rawValue)", systemImage: status.symbol)
                        }
                    }
                    if attendanceStatus != nil {
                        Button(role: .destructive) {
                            onMark(nil)
                        } label: {
                            Label("Clear attendance", systemImage: "eraser")
                        }
                    }
                } else {
                    Button {
                        onUnlockAttendance()
                    } label: {
                        Label("Attendance & stats — Premium", systemImage: "lock.fill")
                    }
                }
            }
        }
    }
}
