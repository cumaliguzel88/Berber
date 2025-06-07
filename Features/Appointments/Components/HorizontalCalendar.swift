import SwiftUI

struct HorizontalCalendar: View {
    @Binding var selectedDate: Date
    private let daysToShow = 14 // 2 hafta ileri-geri
    
    private var calendar: Calendar { Calendar.current }
    private var today: Date { calendar.startOfDay(for: Date()) }
    private var dates: [Date] {
        let start = calendar.date(byAdding: .day, value: -3, to: today) ?? today
        return (0..<(daysToShow)).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(dates, id: \.self) { date in
                    VStack(spacing: 6) {
                        Text(shortDayString(for: date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(dayString(for: date))
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text(monthString(for: date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 48, height: 64)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.accentColor.opacity(0.18) : Color(.systemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.accentColor : Color.gray.opacity(0.2), lineWidth: 2)
                    )
                    .onTapGesture {
                        withAnimation { selectedDate = date }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
    
    private func shortDayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    private func dayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    private func monthString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}

#if DEBUG
struct HorizontalCalendar_Previews: PreviewProvider {
    @State static var selectedDate = Date()
    static var previews: some View {
        HorizontalCalendar(selectedDate: $selectedDate)
    }
}
#endif 