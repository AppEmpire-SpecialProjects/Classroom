import SwiftUI

struct LessonEditorView: View {
    @ObservedObject var viewModel: AppViewModel
    let existingLesson: Lesson?
    let completion: () -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    @State private var subject: String
    @State private var teacher: String
    @State private var room: String
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var endsNextDay: Bool
    @State private var selectedDays: Set<Weekday>
    @State private var colorHex: String
    @State private var notes: String
    @State private var weekParity: WeekParity
    @State private var reminderTag: Int
    @State private var showValidation = false
    @State private var isSaving = false

    private enum Field {
        case subject
        case teacher
        case room
        case notes
    }

    private let colors = ["6C63E8", "4B8BF5", "52B69A", "F4A261", "E76F8A", "E05A5A", "2AA7A1", "E9C46A"]

    init(viewModel: AppViewModel, lesson: Lesson? = nil, completion: @escaping () -> Void = {}) {
        self.viewModel = viewModel
        existingLesson = lesson
        self.completion = completion

        let start = lesson?.startTime ?? Self.suggestedStartTime()
        let end = lesson?.endTime ?? Calendar.current.date(
            byAdding: .minute,
            value: viewModel.settings.defaultDuration.rawValue,
            to: start
        ) ?? start.addingTimeInterval(2_700)
        let today = Weekday(rawValue: Calendar.current.component(.weekday, from: .now)) ?? .monday

        _subject = State(initialValue: lesson?.subject ?? "")
        _teacher = State(initialValue: lesson?.teacher ?? "")
        _room = State(initialValue: lesson?.room ?? "")
        _startTime = State(initialValue: start)
        _endTime = State(initialValue: end)
        _endsNextDay = State(initialValue: lesson?.spansMidnight ?? false)
        _selectedDays = State(initialValue: lesson?.weekdays ?? [today])
        _colorHex = State(initialValue: lesson?.colorHex ?? viewModel.settings.lastColorHex)
        _notes = State(initialValue: lesson?.notes ?? "")
        _weekParity = State(initialValue: lesson?.weekParity ?? .everyWeek)
        _reminderTag = State(initialValue: lesson?.reminderLeadMinutes ?? -1)
    }

    var body: some View {
        editorForm
    }

    private var editorForm: some View {
        Form {
            Section {
                TextField("Subject", text: $subject)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .subject)
                    .onSubmit { focusedField = .teacher }
                TextField("Teacher (optional)", text: $teacher)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .teacher)
                    .onSubmit { focusedField = .room }
                TextField("Room (optional)", text: $room)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .room)
            } header: {
                Text("Class")
            } footer: {
                Text("Only the subject, time, and at least one day are required.")
            }

            Section("Time") {
                DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                    .onChange(of: startTime) { oldValue, newValue in
                        guard existingLesson == nil else { return }
                        endTime = newValue.addingTimeInterval(TimeInterval(viewModel.settings.defaultDuration.rawValue * 60))
                    }
                DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)
                Toggle("Ends next day", isOn: $endsNextDay)
            }

            Section("Repeats") {
                daySelector
                Picker("Frequency", selection: $weekParity) {
                    ForEach(WeekParity.allCases) { parity in
                        Text(parity.title).tag(parity)
                    }
                }
                .pickerStyle(.segmented)
                if !selectedDays.isEmpty {
                    Text(selectedDays.sorted { $0.rawValue < $1.rawValue }.map(\.shortTitle).joined(separator: ", "))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Color") {
                colorSelector
            }

            Section {
                Picker("Reminder", selection: $reminderTag) {
                    Text("Default (\(viewModel.settings.reminderLead.title))").tag(-1)
                    ForEach(ReminderLeadTime.allCases) { lead in
                        Text(lead.title).tag(lead.rawValue)
                    }
                }
            } header: {
                Text("Reminder")
            } footer: {
                Text("Overrides the default reminder time for this class only.")
            }

            Section("Notes") {
                TextField("Anything to remember?", text: $notes, axis: .vertical)
                    .lineLimit(3...7)
                    .focused($focusedField, equals: .notes)
            }

            Section {
                Button {
                    save()
                } label: {
                    HStack {
                        Spacer()
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(existingLesson == nil ? "Add Class" : "Save Changes")
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.classroomAccent)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .disabled(isSaving)
                .accessibilityHint("Validates and saves this class")
            }
        }
        .navigationTitle(existingLesson == nil ? "New Class" : "Edit Class")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if existingLesson != nil {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .alert("Check the class details", isPresented: $showValidation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
    }

    private var daySelector: some View {
        HStack(spacing: 6) {
            ForEach(Weekday.ordered(firstDay: viewModel.settings.firstDay)) { day in
                let isSelected = selectedDays.contains(day)
                Button {
                    if isSelected {
                        selectedDays.remove(day)
                    } else {
                        selectedDays.insert(day)
                    }
                    UISelectionFeedbackGenerator().selectionChanged()
                } label: {
                    Text(day.shortTitle)
                        .font(.caption.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(isSelected ? Color.classroomAccent : Color.secondary.opacity(0.12), in: Circle())
                        .foregroundStyle(isSelected ? .white : .primary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(day.shortTitle)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(.vertical, 4)
    }

    private var colorSelector: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
            ForEach(colors, id: \.self) { hex in
                let isSelected = colorHex == hex
                Button {
                    colorHex = hex
                    UISelectionFeedbackGenerator().selectionChanged()
                } label: {
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 32, height: 32)
                        .overlay {
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Class color")
                .accessibilityValue(isSelected ? "Selected" : "Not selected")
            }
        }
    }

    private var validationMessage: String {
        if subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Enter a subject name."
        }
        if selectedDays.isEmpty {
            return "Select at least one weekday."
        }
        return endsNextDay ? "The class must be shorter than 24 hours." : "End time must be later than start time, or turn on Ends next day."
    }

    private func save() {
        let trimmedSubject = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSubject.isEmpty, !selectedDays.isEmpty,
              let normalizedTimes = normalizedTimes() else {
            showValidation = true
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }

        isSaving = true
        let now = Date.now
        let lesson = Lesson(
            id: existingLesson?.id ?? UUID(),
            subject: trimmedSubject,
            teacher: teacher.trimmingCharacters(in: .whitespacesAndNewlines),
            room: room.trimmingCharacters(in: .whitespacesAndNewlines),
            startTime: normalizedTimes.start,
            endTime: normalizedTimes.end,
            weekdays: selectedDays,
            colorHex: colorHex,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            weekParity: weekParity,
            skipDates: existingLesson?.skipDates ?? [],
            reminderLeadMinutes: reminderTag < 0 ? nil : reminderTag,
            createdAt: existingLesson?.createdAt ?? now,
            updatedAt: now
        )

        Task {
            if await viewModel.save(lesson) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                completion()
                if existingLesson != nil {
                    dismiss()
                } else {
                    resetForm()
                }
            }
            isSaving = false
        }
    }

    private func normalizedTimes() -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        let reference = calendar.startOfDay(for: .now)
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        guard let start = calendar.date(bySettingHour: startComponents.hour ?? 0, minute: startComponents.minute ?? 0, second: 0, of: reference),
              var end = calendar.date(bySettingHour: endComponents.hour ?? 0, minute: endComponents.minute ?? 0, second: 0, of: reference) else { return nil }

        if endsNextDay {
            end = calendar.date(byAdding: .day, value: 1, to: end) ?? end
        }
        guard end > start, end.timeIntervalSince(start) < 86_400 else { return nil }
        return (start, end)
    }

    private func resetForm() {
        let start = Self.suggestedStartTime()
        subject = ""
        teacher = ""
        room = ""
        notes = ""
        startTime = start
        endTime = Calendar.current.date(byAdding: .minute, value: viewModel.settings.defaultDuration.rawValue, to: start) ?? start.addingTimeInterval(2_700)
        endsNextDay = false
        selectedDays = [Weekday(rawValue: Calendar.current.component(.weekday, from: .now)) ?? .monday]
        weekParity = .everyWeek
        reminderTag = -1
        focusedField = .subject
    }

    private static func suggestedStartTime(now: Date = .now) -> Date {
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: now)
        let minutesToQuarter = minute.isMultiple(of: 15) ? 0 : 15 - (minute % 15)
        return calendar.date(byAdding: .minute, value: minutesToQuarter, to: now) ?? now
    }
}
