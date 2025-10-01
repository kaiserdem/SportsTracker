import SwiftUI
import ComposableArchitecture

struct StatisticView: View {
    let store: StoreOf<StatisticFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Селектор періоду
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Text("Період")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Palette.text)
                            
                            Picker("Період", selection: viewStore.binding(
                                get: \.selectedPeriod,
                                send: { .selectPeriod($0) }
                            )) {
                                ForEach(StatisticPeriod.allCases, id: \.self) { period in
                                    Text(period.rawValue).tag(period)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                        
                        // Загальна статистика
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Text("Загальна статистика")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Palette.text)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: Theme.Spacing.md) {
                                StatisticCard(
                                    title: "Активність",
                                    value: "5",
                                    subtitle: "днів",
                                    icon: "calendar",
                                    color: Theme.Palette.primary
                                )
                                
                                StatisticCard(
                                    title: "Час",
                                    value: "12:30",
                                    subtitle: "годин",
                                    icon: "clock",
                                    color: Theme.Palette.accent
                                )
                                
                                StatisticCard(
                                    title: "Дистанція",
                                    value: "45.2",
                                    subtitle: "км",
                                    icon: "location",
                                    color: Theme.Palette.secondary
                                )
                                
                                StatisticCard(
                                    title: "Калорії",
                                    value: "2,340",
                                    subtitle: "ккал",
                                    icon: "flame",
                                    color: Theme.Palette.secondary
                                )
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                        
                        // Детальна статистика
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Text("Детальна статистика")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Palette.text)
                            
                            if viewStore.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else if viewStore.statistics.isEmpty {
                                VStack(spacing: Theme.Spacing.sm) {
                                    Image(systemName: "chart.bar.xaxis")
                                        .font(.largeTitle)
                                        .foregroundColor(Theme.Palette.textSecondary)
                                    
                                    Text("Немає даних для відображення")
                                        .font(Theme.Typography.body)
                                        .foregroundColor(Theme.Palette.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(Theme.Spacing.xl)
                                .background(Theme.Palette.surface)
                                .cornerRadius(Theme.CornerRadius.medium)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            } else {
                                ForEach(viewStore.statistics) { statistic in
                                    StatisticDetailRow(statistic: statistic)
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                    .padding(.vertical, Theme.Spacing.lg)
                }
                .background(Theme.Gradients.screenBackground)
                .navigationTitle("Статистика")
                .navigationBarTitleDisplayMode(.large)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(Theme.Typography.title)
                .foregroundColor(Theme.Palette.text)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Palette.textSecondary)
                
                Text(subtitle)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Palette.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.md)
        .background(Theme.Gradients.card)
        .cornerRadius(Theme.CornerRadius.medium)
        .shadow(color: Theme.Palette.darkTeal.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct StatisticDetailRow: View {
    let statistic: StatisticData
    
    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: iconForActivityType(statistic.type))
                    .font(.title3)
                    .foregroundColor(Theme.Palette.primary)
                    .frame(width: 30)
                
                Text(statistic.type.rawValue)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Palette.text)
                
                Spacer()
            }
            
            HStack(spacing: Theme.Spacing.lg) {
                StatisticItem(
                    title: "Час",
                    value: formatDuration(statistic.totalDuration)
                )
                
                StatisticItem(
                    title: "Дистанція",
                    value: String(format: "%.1f км", statistic.totalDistance)
                )
                
                StatisticItem(
                    title: "Швидкість",
                    value: String(format: "%.1f км/год", statistic.averageSpeed)
                )
                
                StatisticItem(
                    title: "Калорії",
                    value: "\(statistic.calories)"
                )
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Gradients.card)
        .cornerRadius(Theme.CornerRadius.medium)
        .shadow(color: Theme.Palette.darkTeal.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func iconForActivityType(_ type: SportType) -> String {
        return type.icon
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        return String(format: "%d:%02d", hours, minutes)
    }
}

struct StatisticItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Palette.text)
            
            Text(title)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Palette.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
