import SwiftUI
import ComposableArchitecture

struct CalendarView: View {
    let store: StoreOf<CalendarFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Календар
                    VStack(spacing: Theme.Spacing.md) {
//                        Text("Календар тренувань")
//                            .font(Theme.Typography.headline)
//                            .foregroundColor(Theme.Palette.text)
//                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        DatePicker(
                            "Оберіть дату",
                            selection: viewStore.binding(
                                get: \.selectedDate,
                                send: { .selectDate($0) }
                            ),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding()
                        .background(Theme.Palette.surface)
                        .cornerRadius(Theme.CornerRadius.medium)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    // Події на вибрану дату
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("Події на \(formatDate(viewStore.selectedDate))")
                            .font(Theme.Typography.headline)
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
                                    .font(Theme.Typography.body)
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
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        } else {
                            ForEach(viewStore.events) { day in
                                EventRow(day: day)
                            }
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    Spacer()
                }
                .background(Theme.Gradients.screenBackground)
                .navigationTitle("Календар")
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
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: date)
    }
}

struct EventRow: View {
    let day: Day
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            VStack(spacing: 2) {
                Text(formatTime(day.date))
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Palette.primary)
                
                Text("хв")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Palette.textSecondary)
            }
            .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(day.sportType.rawValue)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Palette.text)
                
                if let comment = day.comment, !comment.isEmpty {
                    Text(comment)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Palette.textSecondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(day.formattedDuration)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Palette.text)
                
                if let calories = day.calories {
                    Text("\(calories) ккал")
                        .font(Theme.Typography.caption)
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
