import SwiftUI
import ComposableArchitecture

struct CalendarView: View {
    let store: StoreOf<CalendarFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Calendar
                    VStack(spacing: Theme.Spacing.md) {
                        MonthlyCalendarView(
                            days: viewStore.events,
                            titleFontSize: 22,
                            dayFontSize: 16,
                            circleSize: 28,
                            buttonSize: 40,
                            weekdayFontSize: 16
                        )
                        .padding()
                        .background(Theme.Palette.surface)
                        .cornerRadius(Theme.CornerRadius.medium)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    // Events list for selected date
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("Events on \(formatDate(viewStore.selectedDate))")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(Theme.Palette.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if viewStore.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if viewStore.events.isEmpty {
                            VStack(spacing: Theme.Spacing.sm) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.largeTitle)
                                    .foregroundColor(Theme.Palette.textSecondary)
                                
                                Text("No scheduled workouts")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(Theme.Palette.textSecondary)
                                
                                Button("Add Workout") {
                                    // Дія для додавання тренування
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Theme.Palette.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(Theme.Spacing.xl)
                            .background(Theme.Palette.surface)
                            .cornerRadius(Theme.CornerRadius.medium)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        } else {
                            let selectedDateEvents = viewStore.events.filter { day in
                                Calendar.current.isDate(day.date, inSameDayAs: viewStore.selectedDate)
                            }
                            
                            if selectedDateEvents.isEmpty {
                                VStack(spacing: Theme.Spacing.sm) {
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.largeTitle)
                                        .foregroundColor(Theme.Palette.textSecondary)
                                    
                                    Text("No workouts on this date")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundColor(Theme.Palette.textSecondary)
                                    
                                    Button("Add Workout") {
                                        // Дія для додавання тренування
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(Theme.Palette.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(Theme.Spacing.xl)
                                .background(Theme.Palette.surface)
                                .cornerRadius(Theme.CornerRadius.medium)
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            } else {
                                ForEach(selectedDateEvents) { day in
                                    EventRow(day: day)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    Spacer()
                }
                .background(Theme.Gradients.screenBackground)
                .navigationTitle("Calendar")
                .navigationBarTitleDisplayMode(.large)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}

struct CalendarMonthlyCalendarView: View {
    @Binding var selectedDate: Date
    let events: [Day]
    
    @State private var displayedDate: Date = Date()
    
    private var calendar: Calendar { Calendar.current }
    private var currentDate: Date { Date() }
    
    private var currentDay: Int { calendar.component(.day, from: currentDate) }
    private var currentMonth: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "uk_UA")
        df.dateFormat = "LLLL"
        return df.string(from: displayedDate).capitalized
    }
    private var currentYear: Int { calendar.component(.year, from: displayedDate) }
    private var isCurrentMonth: Bool { calendar.isDate(displayedDate, equalTo: currentDate, toGranularity: .month) }
    private var daysInMonth: Int { calendar.range(of: .day, in: .month, for: displayedDate)?.count ?? 30 }
    private var firstDayOfMonth: Date { calendar.date(from: calendar.dateComponents([.year, .month], from: displayedDate)) ?? displayedDate }
    private var firstWeekday: Int {
        // iOS: Sunday=1..Saturday=7 -> Make Monday=0..Sunday=6
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        return (weekday + 5) % 7
    }
    
    private func hasWorkoutOnDay(_ day: Int) -> Bool {
        guard let target = calendar.date(bySetting: .day, value: day, of: displayedDate) else { return false }
        return events.contains { ev in calendar.isDate(ev.date, inSameDayAs: target) }
    }
    
    var body: some View {
        VStack(spacing: 14) {
            // Header with month navigation
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        displayedDate = calendar.date(byAdding: .month, value: -1, to: displayedDate) ?? displayedDate
                        if let firstDay = calendar.date(from: DateComponents(year: calendar.component(.year, from: displayedDate), month: calendar.component(.month, from: displayedDate), day: 1)) {
                            selectedDate = firstDay
                        }
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Palette.primary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Theme.Palette.primary.opacity(0.08)))
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text(currentMonth)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.Palette.text)
                    Text("\(currentYear)")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Palette.textSecondary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        displayedDate = calendar.date(byAdding: .month, value: 1, to: displayedDate) ?? displayedDate
                        if let firstDay = calendar.date(from: DateComponents(year: calendar.component(.year, from: displayedDate), month: calendar.component(.month, from: displayedDate), day: 1)) {
                            selectedDate = firstDay
                        }
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Palette.primary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Theme.Palette.primary.opacity(0.08)))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Weekday headers
            HStack(spacing: 4) {
                ForEach(["Пн","Вт","Ср","Чт","Пт","Сб","Нд"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.Palette.textSecondary)
                        .frame(maxWidth: .infinity)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
            }
            
            // Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                // leading blanks
                ForEach(0..<firstWeekday, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 30)
                }
                
                ForEach(1...daysInMonth, id: \.self) { day in
                    let has = hasWorkoutOnDay(day)
                    let isToday = isCurrentMonth && day == currentDay
                    let isFuture = isCurrentMonth && day > currentDay
                    let isPast = isCurrentMonth && day < currentDay
                    
                    let dayColor: Color = {
                        if isToday { return has ? .yellow : .red }
                        if isFuture { return has ? Theme.Palette.accent : Color.clear }
                        if isPast { return has ? .green : Color.clear }
                        return has ? Theme.Palette.primary : Color.clear
                    }()
                    let textColor: Color = {
                        if isToday { return .black }
                        if has { return .white }
                        return Theme.Palette.text
                    }()
                    
                    Button(action: {
                        if let newDate = calendar.date(bySetting: .day, value: day, of: displayedDate) {
                            selectedDate = newDate
                        }
                    }) {
                        Text("\(day)")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(textColor)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(dayColor))
                            .overlay(Circle().stroke(dayColor, lineWidth: 1))
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct EventRow: View {
    let day: Day
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            VStack(spacing: 2) {
                Text(formatTime(day.date))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.Palette.primary)
                
                Text("min")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Palette.textSecondary)
            }
            .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(day.sportType.rawValue)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Theme.Palette.text)
                
                if let comment = day.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Palette.textSecondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(day.formattedDuration)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Theme.Palette.text)
                
                if let calories = day.calories {
                    Text("\(calories) kcal")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Palette.textSecondary)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Gradients.card)
        .cornerRadius(Theme.CornerRadius.medium)
        .shadow(color: Theme.Palette.darkTeal.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
