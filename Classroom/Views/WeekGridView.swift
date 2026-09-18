import SwiftUI

struct WeekGridView: View {
    let lessons: [Lesson]
    let weekDates: [Date]
    let calendar: Calendar
    let onSelect: (Lesson) -> Void

    private let hourHeight: CGFloat = 52
    private let gutterWidth: CGFloat = 44

    private var displayHours: Range<Int> {
        var startHour = 8
        var endHour = 19
        var hasLessons = false
        for date in weekDates {
            for lesson in lessons {
                guard let interval = lesson.occurrence(on: date, calendar: calendar) else { continue }
                hasLessons = true
                startHour = min(startHour, calendar.component(.hour, from: interval.start))
                let endMinutes = calendar.component(.hour, from: interval.end) * 60 + calendar.component(.minute, from: interval.end)
                endHour = max(endHour, (endMinutes + 59) / 60)
            }
        }
        if !hasLessons { return 8..<19 }
        startHour = max(0, startHour)
        endHour = min(24, endHour)
        guard endHour > startHour else { return 8..<19 }
        return startHour..<endHour
    }

    private var gridHeight: CGFloat { CGFloat(displayHours.count) * hourHeight }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(icon: "calendar.day.timeline.left", title: "Week grid")
            HStack(alignment: .top, spacing: 0) {
                hourGutter
                ForEach(Array(weekDates.enumerated()), id: \.element) { index, date in
                    dayColumn(for: date, isLeadingSpacing: index > 0)
                }
            }
            .padding(EdgeInsets(top: 10, leading: 6, bottom: 12, trailing: 6))
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }

    private var hourGutter: some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach(Array(displayHours), id: \.self) { hour in
                Text(Self.hourLabel(hour))
                    .font(.system(size: 10, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .frame(width: gutterWidth - 10, height: hourHeight, alignment: .top)
                    .padding(.top, 2)
                    .accessibilityHidden(true)
            }
        }
        .padding(.top, 26)
    }

    private func dayColumn(for date: Date, isLeadingSpacing: Bool) -> some View {
        let isToday = calendar.isDateInToday(date)
        let dayOcc = lessons.compactMap { lesson -> (Lesson, DateInterval)? in
            guard let interval = lesson.occurrence(on: date, calendar: calendar) else { return nil }
            return (lesson, interval)
        }
        return VStack(spacing: 4) {
            VStack(spacing: 2) {
                Text(weekday(for: date).shortTitle)
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(isToday ? Color.classroomAccent : .secondary)
                Text(date.formatted(.dateTime.day()))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isToday ? Color.classroomAccent : .primary)
            }
            .frame(height: 24)
            ZStack(alignment: .top) {
                hourLines
                if isToday {
                    nowLine
                }
                ForEach(dayOcc, id: \.0.id) { lesson, interval in
                    gridBlock(for: lesson, interval: interval)
                }
            }
            .frame(height: gridHeight)
        }
        .padding(.leading, isLeadingSpacing ? 3 : 0)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(weekday(for: date).rawValue), \(dayOcc.count) classes")
    }

    private var hourLines: some View {
        VStack(spacing: 0) {
            ForEach(Array(displayHours), id: \.self) { _ in
                Rectangle()
                    .fill(Color.secondary.opacity(0.09))
                    .frame(height: 0.5)
                    .frame(maxHeight: hourHeight, alignment: .top)
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var nowLine: some View {
        let minutes = calendar.component(.hour, from: .now) * 60 + calendar.component(.minute, from: .now)
        let startMinutes = displayHours.lowerBound * 60
        let endMinutes = displayHours.upperBound * 60
        if minutes > startMinutes, minutes < endMinutes {
            let offset = CGFloat(minutes - startMinutes) / 60 * hourHeight
            ZStack(alignment: .top) {
                Capsule()
                    .fill(Color.classroomPink)
                    .frame(width: 3)
                Circle()
                    .fill(Color.classroomPink)
                    .frame(width: 7, height: 7)
                    .offset(y: -2)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 4)
            .offset(y: offset)
            .allowsHitTesting(false)
            .accessibilityLabel("Current time")
        }
    }

    private func gridBlock(for lesson: Lesson, interval: DateInterval) -> some View {
        let startMinutes = calendar.component(.hour, from: interval.start) * 60 + calendar.component(.minute, from: interval.start)
        let endMinutes = calendar.component(.hour, from: interval.end) * 60 + calendar.component(.minute, from: interval.end)
        let baseMinutes = displayHours.lowerBound * 60
        let top = CGFloat(startMinutes - baseMinutes) / 60 * hourHeight
        let height = max(28, CGFloat(endMinutes - startMinutes) / 60 * hourHeight - 3)
        let showsTime = height >= 34
        let color = Color(hex: lesson.colorHex)
        return Button { onSelect(lesson) } label: {
            VStack(alignment: .leading, spacing: 1) {
                Text(lesson.subject)
                    .font(.system(size: 10, weight: .heavy))
                    .lineLimit(height >= 46 ? 2 : 1)
                    .minimumScaleFactor(0.6)
                if showsTime {
                    Text(interval.start.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 9, weight: .semibold))
                        .monospacedDigit()
                        .opacity(0.85)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: height, alignment: .topLeading)
            .padding(4)
            .clipped()
            .frame(height: height, alignment: .top)
            .background(
                LinearGradient(colors: [color, color.opacity(0.72)], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 9, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 0.5)
            }
        }
        .buttonStyle(.plain)
        .offset(y: top)
        .accessibilityLabel("\(lesson.subject), \(interval.start.formatted(date: .omitted, time: .shortened))")
        .accessibilityHint("Opens class details")
    }

    private func weekday(for date: Date) -> Weekday {
        Weekday(rawValue: calendar.component(.weekday, from: date)) ?? .monday
    }

    private static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("ha")
        return formatter
    }()

    private static func hourLabel(_ hour: Int) -> String {
        var components = DateComponents()
        components.hour = hour
        let date = Calendar.current.date(from: components) ?? .now
        return hourFormatter.string(from: date)
    }
}
