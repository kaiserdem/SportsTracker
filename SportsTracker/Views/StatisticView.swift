import SwiftUI
import ComposableArchitecture

struct StatisticView: View {
    let store: StoreOf<StatisticFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Period selector
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            
                            Picker("Period", selection: viewStore.binding(
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
                        
                        // General statistics
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Text("General Statistics")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Palette.text)
                            
                            if viewStore.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else if viewStore.statistics.isEmpty {
                                VStack(spacing: Theme.Spacing.lg) {
                                    Image(systemName: "chart.bar.xaxis")
                                        .font(.system(size: 60, weight: .light))
                                        .foregroundColor(.white)
                                        .padding(.bottom, Theme.Spacing.sm)
                                    
                                    VStack(spacing: Theme.Spacing.sm) {
                                        Text("No data yet")
                                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        Text("Start tracking your activities\nto see statistics here")
                                            .font(.system(size: 16, weight: .regular, design: .rounded))
                                            .foregroundColor(.white.opacity(0.8))
                                            .multilineTextAlignment(.center)
                                    }
                                    
                                    Button(action: {
                                        // TODO: Navigate to add activity
                                        print("📊 Натиснуто кнопку додати активність з статистики")
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 20, weight: .medium))
                                            
                                            Text("Add Your First Activity")
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        }
                                        .foregroundColor(Theme.Palette.coral)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 45)
                                        .background(.white)
                                        .cornerRadius(22)
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(Theme.Spacing.xl)
                                .background(Theme.Gradients.tealCoral)
                                .cornerRadius(Theme.CornerRadius.large)
                                .shadow(color: Theme.Palette.coral.opacity(0.3), radius: 12, x: 0, y: 6)
                            } else {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: Theme.Spacing.md) {
                                    StatisticCard(
                                        title: "Activity",
                                        value: "\(viewStore.statistics.count)",
                                        subtitle: "days",
                                        icon: "calendar",
                                        color: Theme.Palette.primary
                                    )
                                    
                                    StatisticCard(
                                        title: "Time",
                                        value: formatTotalDuration(viewStore.statistics),
                                        subtitle: "hours",
                                        icon: "clock",
                                        color: Theme.Palette.accent
                                    )
                                    
                                    StatisticCard(
                                        title: "Distance",
                                        value: String(format: "%.1f", totalDistance(viewStore.statistics) / 1000),
                                        subtitle: "km",
                                        icon: "location",
                                        color: Theme.Palette.secondary
                                    )
                                    
                                    StatisticCard(
                                        title: "Calories",
                                        value: "\(totalCalories(viewStore.statistics))",
                                        subtitle: "kcal",
                                        icon: "flame",
                                        color: Theme.Palette.secondary
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                        
                        // Detailed statistics
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Text("Detailed Statistics")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Palette.text)
                            
                            if viewStore.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else if viewStore.statistics.isEmpty {
                                VStack(spacing: Theme.Spacing.lg) {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .font(.system(size: 60, weight: .light))
                                        .foregroundColor(.white)
                                        .padding(.bottom, Theme.Spacing.sm)
                                    
                                    VStack(spacing: Theme.Spacing.sm) {
                                        Text("Keep going!")
                                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        Text("Detailed statistics will appear\nas you track more activities")
                                            .font(.system(size: 16, weight: .regular, design: .rounded))
                                            .foregroundColor(.white.opacity(0.8))
                                            .multilineTextAlignment(.center)
                                    }
                                    
                                    Button(action: {
                                        // TODO: Navigate to add activity
                                        print("📊 Натиснуто кнопку з детальної статистики")
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 20, weight: .medium))
                                            
                                            Text("Track Another Activity")
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        }
                                        .foregroundColor(Theme.Palette.coral)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 45)
                                        .background(.white)
                                        .cornerRadius(22)
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(Theme.Spacing.xl)
                                .background(Theme.Gradients.tealCoral)
                                .cornerRadius(Theme.CornerRadius.large)
                                .shadow(color: Theme.Palette.coral.opacity(0.3), radius: 12, x: 0, y: 6)
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
                .navigationTitle("Statistics")
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
                    title: "Time",
                    value: formatDuration(statistic.totalDuration)
                )
                
                StatisticItem(
                    title: "Distance",
                    value: String(format: "%.1f km", statistic.totalDistance / 1000)
                )
                
                StatisticItem(
                    title: "Speed",
                    value: String(format: "%.1f km/h", statistic.averageSpeed)
                )
                
                StatisticItem(
                    title: "Calories",
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
        print("📊 formatDuration: duration = \(duration) секунд")
        
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        print("📊 formatDuration: hours=\(hours), minutes=\(minutes), seconds=\(seconds)")
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "0:%02d", seconds)
        }
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

// MARK: - Helper Functions

private func formatTotalDuration(_ statistics: [StatisticData]) -> String {
    let totalDuration = statistics.reduce(0) { $0 + $1.totalDuration }
    print("📊 formatTotalDuration: totalDuration = \(totalDuration) секунд")
    
    let hours = Int(totalDuration) / 3600
    let minutes = Int(totalDuration) % 3600 / 60
    let seconds = Int(totalDuration) % 60
    
    print("📊 formatTotalDuration: hours=\(hours), minutes=\(minutes), seconds=\(seconds)")
    
    if hours > 0 {
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    } else if minutes > 0 {
        return String(format: "%d:%02d", minutes, seconds)
    } else {
        return String(format: "0:%02d", seconds)
    }
}

private func totalDistance(_ statistics: [StatisticData]) -> Double {
    return statistics.reduce(0) { $0 + $1.totalDistance }
}

private func totalCalories(_ statistics: [StatisticData]) -> Int {
    return statistics.reduce(0) { $0 + $1.calories }
}

