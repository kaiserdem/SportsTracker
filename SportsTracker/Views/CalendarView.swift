import SwiftUI
import ComposableArchitecture

struct CalendarView: View {
    let store: StoreOf<CalendarFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { state in state }) { viewStore in
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Add Workout Button
                    Button(action: {
                        print("🔘 CalendarView: Натиснуто 'Add Workout' кнопку")
                        viewStore.send(.showAddActivity)
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                            
                            Text("Add Workout")
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.Gradients.tealCoral)
                        .cornerRadius(25)
                        .shadow(color: Theme.Palette.coral.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    // Calendar
                    VStack(spacing: Theme.Spacing.md) {
                        MonthlyCalendarView(
                            days: viewStore.events,
                            titleFontSize: 22,
                            dayFontSize: 18,
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
                            Text("Workouts on \(formatDate(viewStore.selectedDate))")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(Theme.Palette.text)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Segmented Control
                        Picker("Filter Events", selection: viewStore.binding(
                            get: \.selectedEventFilter,
                            send: CalendarFeature.Action.selectEventFilter
                        )) {
                            Text("Future").tag(CalendarFeature.EventFilter.future)
                            Text("Past").tag(CalendarFeature.EventFilter.past)
                        }
                        .pickerStyle(.segmented)
                        
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
                                    // Action to add workout
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
                            let allEvents = viewStore.events
                            
                            // Filter events based on selected filter first
                            let filteredEvents = allEvents.filter { day in
                                let today = Calendar.current.startOfDay(for: Date())
                                let eventDate = Calendar.current.startOfDay(for: day.date)
                                
                                switch viewStore.selectedEventFilter {
                                case .future:
                                    return eventDate > today
                                case .past:
                                    return eventDate <= today
                                }
                            }
                            
                            // Then filter directly with filteredEvents - видаляємо фільтр по даті
                            let selectedDateEvents = filteredEvents
                            
                            if selectedDateEvents.isEmpty {
                                VStack(spacing: Theme.Spacing.sm) {
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.largeTitle)
                                        .foregroundColor(Theme.Palette.textSecondary)
                                    
                                    Text("No \( viewStore.selectedEventFilter.rawValue.lowercased()) workouts")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundColor(Theme.Palette.textSecondary)
                                    
                                    Button("Add Workout") {
                                        // Action to add workout
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
                                    if viewStore.selectedEventFilter == .future {
                                        FutureEventRow(day: day)
                                    } else {
                                        EventRow(day: day)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    Spacer(minLength: 25)
                }
                .padding(.bottom, 25)
                .background(Theme.Gradients.screenBackground)
                .navigationTitle("Calendar")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}

struct EventRow: View {
    let day: Day
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            VStack(spacing: 2) {
                Text(formatTime(day.date))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.Palette.coral)
                
                Text("time")
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
                Text(day.formattedDurationSimple)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Theme.Palette.coral)
                
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
        .shadow(color: Theme.Palette.coral.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}

struct FutureEventRow: View {
    let day: Day
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            VStack(spacing: 2) {
                Text(formatTime(day.date))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.Palette.coral)
                
                Text("scheduled")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Palette.textSecondary)
            }
            .frame(width: 80)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(day.sportType.rawValue)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
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
                Text(formatFutureDate(day.date))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Palette.coral)
                
                Text("Upcoming")
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundColor(Theme.Palette.textSecondary)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Gradients.card.opacity(0.8))
        .cornerRadius(Theme.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .stroke(Theme.Palette.coral.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Theme.Palette.coral.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    private func formatFutureDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}
