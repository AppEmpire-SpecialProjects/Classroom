import PremiumKit
import SwiftUI

struct ClassDetailsView: View {
    @ObservedObject var viewModel: AppViewModel
    let lessonID: UUID

    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var confirmingDelete = false
    @State private var isDuplicating = false
    @State private var showDuplicatedConfirmation = false
    @State private var addingHomework = false
    @State private var addingSkipDate = false
    @State private var showPaywall = false
    @ObservedObject private var premium = Premium.shared

    private var lesson: Lesson? {
        viewModel.lessons.first { $0.id == lessonID }
    }

    private var attendanceRecords: [Attendance] {
        viewModel.attendance
            .filter { $0.lessonID == lessonID }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        Group {
            if let lesson {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        hero(for: lesson)
                        scheduleSection(for: lesson)
                        attendanceSection(for: lesson)
                        skipDatesSection(for: lesson)
                        homeworkSection(for: lesson)
                        if !lesson.teacher.isEmpty || !lesson.room.isEmpty {
                            peopleAndPlaceSection(for: lesson)
                        }
                        if !lesson.notes.isEmpty {
                            detailSection(title: "Notes", icon: "note.text", value: lesson.notes)
                        }
                        actionSection(for: lesson)
                    }
                    .padding(20)
                }
                .background(Color.classroomBackground)
                .navigationTitle("Class Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Edit") { isEditing = true }
                            .fontWeight(.semibold)
                    }
                }
                .sheet(isPresented: $isEditing) {
                    NavigationStack {
                        LessonEditorView(viewModel: viewModel, lesson: lesson)
                    }
                }
                .confirmationDialog("Delete \(lesson.subject)?", isPresented: $confirmingDelete, titleVisibility: .visible) {
                    Button("Delete Class", role: .destructive) {
                        delete(lesson)
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This class, its homework and reminders will be removed. This cannot be undone.")
                }
                .alert("Class duplicated", isPresented: $showDuplicatedConfirmation) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("A new copy was added to your schedule.")
                }
                .fullScreenCover(isPresented: $showPaywall) {
                    MainPaywallView()
                }
            } else {
                ContentUnavailableView("Class unavailable", systemImage: "calendar.badge.exclamationmark", description: Text("This class may have been deleted."))
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") { dismiss() }
                        }
                    }
            }
        }
    }

    // MARK: - Hero

    private func hero(for lesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 14) {
                SubjectIconTile(subject: lesson.subject, colorHex: lesson.colorHex, size: 58)
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.subject)
                        .font(.system(.title, design: .rounded, weight: .heavy))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(timeRange(for: lesson))
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.9))
                }
                Spacer(minLength: 0)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if lesson.weekParity != .everyWeek {
                        heroBadge(icon: lesson.weekParity.symbol, text: lesson.weekParity.title)
                    }
                    if !lesson.skipDates.isEmpty {
                        heroBadge(icon: "calendar.badge.minus", text: lesson.skipDates.count == 1 ? "1 skipped date" : "\(lesson.skipDates.count) skipped dates")
                    }
                    let openHomework = viewModel.homework(for: lesson.id).filter { !$0.isCompleted }.count
                    if openHomework > 0 {
                        heroBadge(icon: "checklist", text: "\(openHomework) homework due")
                    }
                    let stats = viewModel.attendanceStats(lessonID: lesson.id)
                    if stats.present + stats.late + stats.absent > 0 {
                        heroBadge(icon: "person.crop.circle.badge.checkmark", text: "\(stats.present + stats.late) attended")
                    }
                }
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [Color(hex: lesson.colorHex), Color.classroomAccent.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .shadow(color: Color(hex: lesson.colorHex).opacity(0.4), radius: 16, y: 8)
        .accessibilityElement(children: .combine)
    }

    private static func dayChipBackground(scheduled: Bool, colorHex: String) -> AnyShapeStyle {
        guard scheduled else { return AnyShapeStyle(Color.secondary.opacity(0.1)) }
        let color = Color(hex: colorHex)
        return AnyShapeStyle(LinearGradient(colors: [color, color.opacity(0.72)], startPoint: .top, endPoint: .bottom))
    }

    private func heroBadge(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2.weight(.bold))
            Text(text)
                .font(.caption.weight(.bold))
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.18), in: Capsule())
    }

    // MARK: - Schedule

    private func scheduleSection(for lesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(icon: "repeat", title: "Weekly schedule")
            HStack(spacing: 7) {
                ForEach(Weekday.ordered(firstDay: viewModel.settings.firstDay)) { day in
                let scheduled = lesson.weekdays.contains(day)
                Text(day.shortTitle)
                    .font(.caption.weight(.heavy))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .foregroundStyle(scheduled ? .white : .secondary)
                    .background(Self.dayChipBackground(scheduled: scheduled, colorHex: lesson.colorHex), in: Circle())
                    .accessibilityLabel(day.shortTitle)
                    .accessibilityValue(scheduled ? "Scheduled" : "Not scheduled")
                }
            }
            if lesson.weekParity != .everyWeek {
                Label(lesson.weekParity == .oddWeeks ? "Happens on odd weeks only" : "Happens on even weeks only", systemImage: lesson.weekParity.symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.classroomSun)
            }
        }
        .padding(20)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // MARK: - Attendance

    @ViewBuilder
    private func attendanceSection(for lesson: Lesson) -> some View {
        if premium.isPremium {
            attendanceContent(for: lesson)
        } else {
            PremiumLockedCard(
                icon: "person.crop.circle.badge.checkmark",
                title: "Attendance & stats",
                message: "Mark presence for every class and see your progress at a glance."
            )
        }
    }

    private func attendanceContent(for lesson: Lesson) -> some View {
        let stats = viewModel.attendanceStats(lessonID: lesson.id)
        let total = stats.present + stats.late + stats.absent
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeaderView(icon: "person.crop.circle.badge.checkmark", title: "Attendance")
                Spacer()
                if lesson.occurrence(on: .now) != nil {
                    Menu {
                        ForEach(AttendanceStatus.allCases) { status in
                            Button {
                                viewModel.setAttendance(lessonID: lesson.id, on: .now, status: status)
                            } label: {
                                Label("Mark \(status.rawValue)", systemImage: status.symbol)
                            }
                        }
                        if viewModel.attendanceStatus(lessonID: lesson.id, on: .now) != nil {
                            Button(role: .destructive) {
                                viewModel.setAttendance(lessonID: lesson.id, on: .now, status: nil)
                            } label: {
                                Label("Clear today", systemImage: "eraser")
                            }
                        }
                    } label: {
                        Text("Today")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.classroomHeroGradient, in: Capsule())
                    }
                }
            }
            if total == 0 {
                Text("Mark attendance from the Today timeline or here — long-press a class, then choose a status.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 8) {
                    attendanceStatChip("\(stats.present)", label: "Present", icon: AttendanceStatus.present.symbol, tint: Color(hex: AttendanceStatus.present.tintHex))
                    attendanceStatChip("\(stats.late)", label: "Late", icon: AttendanceStatus.late.symbol, tint: Color(hex: AttendanceStatus.late.tintHex))
                    attendanceStatChip("\(stats.absent)", label: "Absent", icon: AttendanceStatus.absent.symbol, tint: Color(hex: AttendanceStatus.absent.tintHex))
                }
                ForEach(attendanceRecords.prefix(8)) { record in
                    Menu {
                        ForEach(AttendanceStatus.allCases) { status in
                            Button {
                                viewModel.setAttendance(lessonID: lesson.id, on: record.date, status: status)
                            } label: {
                                Label(status.rawValue, systemImage: status.symbol)
                            }
                        }
                        Button(role: .destructive) {
                            viewModel.setAttendance(lessonID: lesson.id, on: record.date, status: nil)
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: record.status.symbol)
                                .foregroundStyle(Color(hex: record.status.tintHex))
                                .frame(width: 24)
                            Text(record.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline.weight(.medium))
                            Spacer()
                            Text(record.status.rawValue)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color(hex: record.status.tintHex))
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func attendanceStatChip(_ value: String, label: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
            Text("\(value) \(label)")
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(tint)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(tint.opacity(0.12), in: Capsule())
        .accessibilityElement(children: .combine)
    }

    // MARK: - Skip dates

    private func skipDatesSection(for lesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionHeaderView(icon: "calendar.badge.minus", title: "Skipped dates")
                Spacer()
                Button {
                    addingSkipDate = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.classroomAccent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add skipped date")
            }
            if lesson.skipDates.isEmpty {
                Text("Holidays and cancellations: skip specific dates without deleting the class.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(lesson.skipDates, id: \.self) { date in
                    HStack {
                        Label(date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Button {
                            removeSkipDate(date, from: lesson)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Remove skipped date \(date.formatted(date: .abbreviated, time: .omitted))")
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .padding(20)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .sheet(isPresented: $addingSkipDate) {
            AddSkipDateSheet(lesson: lesson) { date in
            addSkipDate(date, to: lesson)
            }
        }
    }

    private func addSkipDate(_ date: Date, to lesson: Lesson) {
        var updated = lesson
        if !updated.skipDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
            updated.skipDates.append(Calendar.current.startOfDay(for: date))
            Task { _ = await viewModel.save(updated) }
        }
    }

    private func removeSkipDate(_ date: Date, from lesson: Lesson) {
        var updated = lesson
        updated.skipDates.removeAll { Calendar.current.isDate($0, inSameDayAs: date) }
        Task { _ = await viewModel.save(updated) }
    }

    // MARK: - Details

    private func peopleAndPlaceSection(for lesson: Lesson) -> some View {
        VStack(spacing: 0) {
            if !lesson.teacher.isEmpty {
                detailRow(icon: "person.fill", title: "Teacher", value: lesson.teacher)
            }
            if !lesson.teacher.isEmpty && !lesson.room.isEmpty {
                Divider().padding(.leading, 48)
            }
            if !lesson.room.isEmpty {
                detailRow(icon: "door.left.hand.open", title: "Room", value: lesson.room)
            }
        }
        .padding(.horizontal, 18)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(Color.classroomAccent)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body.weight(.medium))
            }
            Spacer()
        }
        .padding(.vertical, 15)
    }

    private func detailSection(title: String, icon: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(icon: icon, title: title)
            Text(value)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func actionSection(for lesson: Lesson) -> some View {
        VStack(spacing: 12) {
            Button {
                duplicate(lesson)
            } label: {
                Label(isDuplicating ? "Duplicating…" : "Duplicate Class", systemImage: "plus.square.on.square")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 16))
            .disabled(isDuplicating)

            Button(role: .destructive) {
                confirmingDelete = true
            } label: {
                Label("Delete Class", systemImage: "trash")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 16))
        }
        .padding(.top, 4)
    }

    private func timeRange(for lesson: Lesson) -> String {
        let start = lesson.startTime.formatted(date: .omitted, time: .shortened)
        let end = lesson.endTime.formatted(date: .omitted, time: .shortened)
        return lesson.spansMidnight ? "\(start) – \(end) · next day" : "\(start) – \(end)"
    }

    private func duplicate(_ lesson: Lesson) {
        guard premium.isPremium else {
            showPaywall = true
            return
        }
        isDuplicating = true
        Task {
            if await viewModel.duplicate(lesson) != nil {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                showDuplicatedConfirmation = true
            }
            isDuplicating = false
        }
    }

    private func delete(_ lesson: Lesson) {
        Task {
            if await viewModel.delete(lesson) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                dismiss()
            }
        }
    }

    // MARK: - Homework

    @ViewBuilder
    private func homeworkSection(for lesson: Lesson) -> some View {
        if premium.isPremium {
            homeworkContent(for: lesson)
        } else {
            PremiumLockedCard(
                icon: "checklist",
                title: "Homework tracker",
                message: "Keep every task and deadline for this class in one list."
            )
        }
    }

    private func homeworkContent(for lesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeaderView(icon: "checklist", title: "Homework")
                Spacer()
                Button {
                    addingHomework = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.classroomAccent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add homework")
            }
            let items = viewModel.homework(for: lesson.id)
            if items.isEmpty {
                Text("No homework yet. Tap + to add the first task.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 2) {
                    ForEach(items) { item in
                        HomeworkRowView(
                            item: item,
                            showsDelete: true,
                            onToggle: { viewModel.toggleHomework(item) },
                            onDelete: { viewModel.deleteHomework(item) }
                        )
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
            }
        }
        .padding(20)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .sheet(isPresented: $addingHomework) {
            AddHomeworkSheet(viewModel: viewModel, lesson: lesson)
        }
    }
}

private struct AddSkipDateSheet: View {
    let lesson: Lesson
    let onAdd: (Date) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var date = Date.now

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                } footer: {
                    Text("\(lesson.subject) will not appear and will not remind you on this date.")
                }
            }
            .navigationTitle("Skip a Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Skip Date") {
                        onAdd(date)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

private struct AddHomeworkSheet: View {
    @ObservedObject var viewModel: AppViewModel
    let lesson: Lesson

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var details = ""
    @State private var dueDate = Date.now

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private static func nextOccurrence(of lesson: Lesson) -> Date {
        let calendar = Calendar.current
        for offset in 0..<8 {
            guard let date = calendar.date(byAdding: .day, value: offset, to: .now),
                  let interval = lesson.occurrence(on: date, calendar: calendar),
                  interval.end > .now else { continue }
            return interval.start
        }
        return .now
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("What needs to be done?", text: $title)
                    TextField("Details (optional)", text: $details, axis: .vertical)
                        .lineLimit(2...4)
                }
                Section {
                    DatePicker("Due", selection: $dueDate, displayedComponents: .date)
                } footer: {
                    Text("Defaults to the next \(lesson.subject) class.")
                }
            }
            .navigationTitle("New Homework")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.addHomework(
                            Homework(
                                lessonID: lesson.id,
                                title: title.trimmingCharacters(in: .whitespaces),
                                details: details,
                                dueDate: dueDate
                            )
                        )
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                dueDate = Self.nextOccurrence(of: lesson)
            }
        }
    }
}
