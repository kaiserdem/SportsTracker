import SwiftUI
import ComposableArchitecture

struct CalendarView: View {
    let store: StoreOf<CalendarFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Add Workout Button
                    Button(action: {
                        // Action to add workout
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                            
                            Text("Add Workout")
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(
                                colors: [
                                    Theme.Palette.primary,
                                    Theme.Palette.primary.opacity(0.8),
                                    Theme.Palette.accent
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: Theme.Palette.primary.opacity(0.4), radius: 8, x: 0, y: 4)
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
                    .foregroundColor(Theme.Palette.primary)
                
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
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}
