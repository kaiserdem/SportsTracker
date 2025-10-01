import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: StoreOf<HomeFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Привітання
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text(viewStore.welcomeMessage)
                                .font(Theme.Typography.largeTitle)
                                .foregroundColor(Theme.Palette.text)
                            
                            Text("Відстежуйте свої спортивні досягнення")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Palette.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Theme.Spacing.md)
                        
                        // Швидкі дії
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Text("Швидкі дії")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Palette.text)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: Theme.Spacing.md) {
                                QuickActionCard(
                                    title: "Почати тренування",
                                    icon: "play.circle.fill",
                                    color: Theme.Palette.primary
                                )
                                
                                QuickActionCard(
                                    title: "Додати активність",
                                    icon: "plus.circle.fill",
                                    color: Theme.Palette.accent
                                )
                                
                                QuickActionCard(
                                    title: "Переглянути статистику",
                                    icon: "chart.bar.fill",
                                    color: Theme.Palette.secondary
                                )
                                
                                QuickActionCard(
                                    title: "Маршрути",
                                    icon: "map.fill",
                                    color: Theme.Palette.accent
                                )
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                        
                        // Останні активності
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Text("Останні активності")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Palette.text)
                            
                            if viewStore.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else if viewStore.recentDays.isEmpty {
                                Text("Поки що немає активностей")
                                    .font(Theme.Typography.body)
                                    .foregroundColor(Theme.Palette.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                ForEach(viewStore.recentDays) { day in
                                    DayRow(day: day)
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                    .padding(.vertical, Theme.Spacing.lg)
                }
                .background(Theme.Palette.background)
                .navigationTitle("Головна")
                .navigationBarTitleDisplayMode(.large)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Palette.text)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.md)
        .background(Theme.Palette.surface)
        .cornerRadius(Theme.CornerRadius.medium)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct DayRow: View {
    let day: Day
    
    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: day.sportType.icon)
                    .font(.title3)
                    .foregroundColor(Theme.Palette.primary)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(day.sportType.rawValue)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Palette.text)
                    
                    Text(day.formattedDate)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Palette.textSecondary)
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
            
            if let comment = day.comment, !comment.isEmpty {
                Text(comment)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Palette.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if day.hasSupplements {
                HStack {
                    Image(systemName: "pills.fill")
                        .font(.caption)
                        .foregroundColor(Theme.Palette.accent)
                    
                    Text("\(day.supplementsCount) додатків")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Palette.accent)
                    
                    Spacer()
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Palette.surface)
        .cornerRadius(Theme.CornerRadius.medium)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
