import PremiumKit
import SwiftUI

enum ScheduleDisplayMode: String, CaseIterable, Identifiable {
    case list = "List"
    case grid = "Grid"

    var id: String { rawValue }

    var symbol: String {
        self == .list ? "list.bullet.rectangle" : "calendar.day.timeline.left"
    }
}

struct ScheduleView: View {
    @ObservedObject var viewModel: AppViewModel
    @Binding var selectedTab: AppTab
    @ObservedObject private var settings: UserSettings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedDate = Date.now
    @State private var editingLesson: Lesson?
    @State private var searchText = ""
    @State private var displayMode: ScheduleDisplayMode = .list
    @State private var showPaywall = false
    @ObservedObject private var premium = Premium.shared

    init(viewModel: AppViewModel, selectedTab: Binding<AppTab>) {
        self.viewModel = viewModel
        _selectedTab = selectedTab
        settings = viewModel.settings
    }

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = settings.firstDay == .monday ? 2 : 1
        return calendar
    }

    private var weekStart: Date {
        calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? calendar.startOfDay(for: selectedDate)
    }

    private var weekDates: [Date] {
        (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    private var lessonOccurrences: [(lesson: Lesson, interval: DateInterval)] {
        let dayStart = calendar.startOfDay(for: selectedDate)
        let previousDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate

        return viewModel.lessons.compactMap { lesson in
            if let interval = lesson.occurrence(on: selectedDate, calendar: calendar) {
                return (lesson, interval)
            }
            if let interval = lesson.occurrence(on: previousDate, calendar: calendar), interval.end > dayStart {
                return (lesson, interval)
            }
            return nil
        }
        .sorted { $0.interval.start < $1.interval.start }
    }

    private var lessons: [Lesson] {
        lessonOccurrences.map { $0.lesson }
    }

    private var conflictingIDs: Set<UUID> {
        var conflicts = Set<UUID>()
        for firstIndex in lessonOccurrences.indices {
            for secondIndex in lessonOccurrences.indices where secondIndex > firstIndex {
                guard lessonOccurrences[firstIndex].interval.intersects(lessonOccurrences[secondIndex].interval) else { continue }
                conflicts.insert(lessonOccurrences[firstIndex].lesson.id)
                conflicts.insert(lessonOccurrences[secondIndex].lesson.id)
            }
        }
        return conflicts
    }

    private var searchResults: [Lesson] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return [] }
        return viewModel.lessons.filter {
            $0.subject.lowercased().contains(query)
                || $0.teacher.lowercased().contains(query)
                || $0.room.lowercased().contains(query)
                || $0.notes.lowercased().contains(query)
        }
    }

    private func weekdayOf(_ date: Date) -> Weekday? {
        Weekday(rawValue: calendar.component(.weekday, from: date))
    }

    private func occurrences(on date: Date) -> [Lesson] {
        viewModel.lessons
            .filter { $0.occurrence(on: date, calendar: calendar) != nil }
            .sorted { $0.startTime < $1.startTime }
    }

    private func minutes(on date: Date) -> Int {
        occurrences(on: date).reduce(0) { $0 + Int($1.endTime.timeIntervalSince($1.startTime) / 60) }
    }

    private var weekOccurrenceCount: Int {
        weekDates.reduce(0) { $0 + occurrences(on: $1).count }
    }

    private var weekMinutes: Int {
        weekDates.reduce(0) { $0 + minutes(on: $1) }
    }

    private var weekParity: WeekParity {
        let weekNumber = calendar.component(.weekOfYear, from: selectedDate)
        return weekNumber % 2 == 1 ? .oddWeeks : .evenWeeks
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                if !searchText.isEmpty {
                    searchSection
                } else {
                    weekHero
                    dayPicker
                    modePicker

                    if displayMode == .grid {
                        WeekGridView(
                            lessons: viewModel.lessons,
                            weekDates: weekDates,
                            calendar: calendar,
                            onSelect: { lesson in editingLesson = lesson }
                        )
                    } else if lessons.isEmpty {
                        ScheduleEmptyState(
                            title: viewModel.lessons.isEmpty ? "Your schedule is empty" : "No classes",
                            message: viewModel.lessons.isEmpty ? "Add your first class to get started." : "This day is all yours.",
                            actionTitle: viewModel.lessons.isEmpty ? "Add first class" : "Add a class"
                        ) { selectedTab = .add }
                        .padding(.top, 24)
                    } else {
                        HStack {
                            Text(selectedDate.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                                .font(.title3.weight(.heavy))
                            Spacer()
                            Text("\(lessons.count) \(lessons.count == 1 ? "class" : "classes")")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        ForEach(lessons) { lesson in
                            Button { editingLesson = lesson } label: {
                                LessonCard(lesson: lesson, showsConflict: conflictingIDs.contains(lesson.id))
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint("Opens class details")
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.classroomBackground)
        .navigationTitle("Schedule")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search classes, teachers, rooms")
        .sheet(item: $editingLesson) { lesson in
            NavigationStack { ClassDetailsView(viewModel: viewModel, lessonID: lesson.id) }
        }
        .onChange(of: premium.isPremium) { _, isPremium in
            if !isPremium { displayMode = .list }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            MainPaywallView()
        }
    }

    // MARK: - Week hero

    private var weekHero: some View {
        HStack(spacing: 12) {
            Button { moveWeek(by: -1) } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.16), in: Circle())
            }
            .accessibilityLabel("Previous week")

            VStack(spacing: 4) {
                Text(weekRangeTitle)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(.white)
                HStack(spacing: 6) {
                    Text("\(weekOccurrenceCount) \(weekOccurrenceCount == 1 ? "class" : "classes")")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.white.opacity(0.9))
                    if weekMinutes > 0 {
                        Text("\(weekMinutes / 60)h \(weekMinutes % 60)m")
                                                       .font(.caption.weight(.bold))
                            .foregroundStyle(Color.white.opacity(0.9))
                    }
                    Text("\(weekParity == .oddWeeks ? "Odd" : "Even") week")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.18), in: Capsule())
                }
            }
            .frame(maxWidth: .infinity)

            HStack(spacing: 8) {
                if !calendar.isDate(selectedDate, equalTo: .now, toGranularity: .weekOfYear) {
                    Button(action: goToToday) {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.16), in: Circle())
                    }
                    .accessibilityLabel("Jump to this week")
                }
                Button { moveWeek(by: 1) } label: {
                    Image(systemName: "chevron.right")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.16), in: Circle())
                }
                .accessibilityLabel("Next week")
            }
        }
        .padding(18)
        .background(Color.classroomHeroGradient, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Color.classroomAccent.opacity(0.3), radius: 14, y: 8)
        .accessibilityElement(children: .contain)
    }

    /// The week grid is a premium feature: for free users the Grid segment
    /// opens the paywall instead of switching the display mode.
    private var displayModeBinding: Binding<ScheduleDisplayMode> {
        Binding(
            get: { displayMode },
            set: { mode in
                if mode == .grid && !premium.isPremium {
                    showPaywall = true
                    return
                }
                displayMode = mode
            }
        )
    }

    private var modePicker: some View {
        Picker("Display mode", selection: displayModeBinding) {
            ForEach(ScheduleDisplayMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.top, -6)
    }

    // MARK: - Search

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(searchResults.count) \(searchResults.count == 1 ? "result" : "results")")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            if searchResults.isEmpty {
                Text("No classes match \(searchText).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 24)
            } else {
                ForEach(searchResults.sorted { $0.subject < $1.subject }) { lesson in
                    Button { editingLesson = lesson } label: {
                        LessonCard(lesson: lesson)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Opens class details")
                }
            }
        }
    }

    // MARK: - Day picker

    private var dayPicker: some View {
        HStack(spacing: 6) {
            ForEach(weekDates, id: \.self) { date in
                dayCell(for: date)
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let dayCount = occurrences(on: date).count
        return Button {
            if !reduceMotion {
                withAnimation(.snappy(duration: 0.22)) { selectedDate = date }
            } else {
                selectedDate = date
            }
            UISelectionFeedbackGenerator().selectionChanged()
        } label: {
            VStack(spacing: 5) {
                Text(weekday(for: date).shortTitle)
                    .font(.caption2.weight(.bold))
                Text(date.formatted(.dateTime.day()))
                    .font(.headline)
                Text(dayCount > 0 ? "\(dayCount)" : "·")
                    .font(.system(size: 10, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(isSelected ? Color.white.opacity(0.85) : Color.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .foregroundStyle(isSelected ? .white : isToday ? Color.classroomAccent : .primary)
            .background(
                isSelected
                    ? AnyShapeStyle(Color.classroomHeroGradient)
                    : AnyShapeStyle(Color(uiColor: .secondarySystemGroupedBackground)),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(date.formatted(.dateTime.weekday(.wide).month().day()))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var weekRangeTitle: String {
        guard let end = weekDates.last else { return "This week" }
        if calendar.component(.month, from: weekStart) == calendar.component(.month, from: end) {
            return "\(weekStart.formatted(.dateTime.month(.wide).day())) – \(end.formatted(.dateTime.day()))"
        }
        return "\(weekStart.formatted(.dateTime.month(.abbreviated).day())) – \(end.formatted(.dateTime.month(.abbreviated).day()))"
    }

    private func moveWeek(by value: Int) {
        guard let date = calendar.date(byAdding: .weekOfYear, value: value, to: selectedDate) else { return }
        if reduceMotion {
            selectedDate = date
        } else {
            withAnimation(.snappy(duration: 0.22)) { selectedDate = date }
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    private func goToToday() {
        selectedDate = .now
        UISelectionFeedbackGenerator().selectionChanged()
    }

    private func weekday(for date: Date) -> Weekday {
        Weekday(rawValue: calendar.component(.weekday, from: date)) ?? .monday
    }
}
