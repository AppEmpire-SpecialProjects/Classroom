import SwiftUI

struct HomeworkRowView: View {
    let item: Homework
    var subjectName: String = ""
    var colorHex: String = "6C63E8"
    var showsDelete = false
    let onToggle: () -> Void
    var onDelete: (() -> Void)?

    private var dueLabel: String {
        switch item.bucket() {
        case .overdue: "Overdue"
        case .today: "Due today"
        case .tomorrow: "Due tomorrow"
        case .upcoming: "Due \(item.dueDate.formatted(date: .abbreviated, time: .omitted))"
        case .completed: "Done"
        }
    }

    private var dueColor: Color {
        switch item.bucket() {
        case .overdue: .red
        case .today: .classroomAccent
        default: .secondary
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(item.isCompleted ? Color.classroomAccent : Color.secondary)
                    .frame(width: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.isCompleted ? "Mark as not done" : "Mark as done")

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .strikethrough(item.isCompleted, color: .secondary)
                    .foregroundStyle(item.isCompleted ? Color.secondary : Color.primary)
                if !item.details.isEmpty {
                    Text(item.details)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                HStack(spacing: 6) {
                    if !subjectName.isEmpty {
                        Text(subjectName)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color(hex: colorHex))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(hex: colorHex).opacity(0.14), in: Capsule())
                    }
                    Label(dueLabel, systemImage: "calendar")
                        .font(.caption2)
                        .foregroundStyle(dueColor)
                }
            }
            Spacer(minLength: 0)

            if showsDelete, let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .frame(width: 30)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Delete homework")
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .contain)
    }
}
