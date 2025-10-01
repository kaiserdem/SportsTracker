import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: StoreOf<HomeFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Індикатор активного тренування
                        if let workout = viewStore.workout.currentWorkout {
                            ActiveWorkoutBanner(workout: workout) {
                                viewStore.send(.workout(.showActiveWorkout))
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                        }
                        
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
                                ) {
                                    viewStore.send(.workout(.showQuickStart))
                                }
                                
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
                                    DayRow(day: day) {
                                        print("🔍 Натиснуто на активність: \(day.sportType.rawValue) - \(day.id)")
                                        viewStore.send(.showWorkoutDetail(day.id))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                    .padding(.vertical, Theme.Spacing.lg)
                }
                .background(Theme.Gradients.screenBackground)
                .navigationTitle("Головна")
                .navigationBarTitleDisplayMode(.large)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .sheet(isPresented: viewStore.binding(
                get: \.workout.isShowingQuickStart,
                send: { $0 ? .workout(.showQuickStart) : .workout(.hideQuickStart) }
            )) {
                QuickStartView(
                    store: self.store.scope(
                        state: \.workout,
                        action: { .workout($0) }
                    )
                )
            }
            .fullScreenCover(isPresented: viewStore.binding(
                get: \.workout.isShowingActiveWorkout,
                send: { $0 ? .workout(.showActiveWorkout) : .workout(.hideActiveWorkout) }
            )) {
                ActiveWorkoutView(
                    store: self.store.scope(
                        state: \.workout,
                        action: { .workout($0) }
                    )
                )
            }
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: (() -> Void)?
    
    init(title: String, icon: String, color: Color, action: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action ?? {}) {
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
            .background(Theme.Gradients.card)
            .cornerRadius(Theme.CornerRadius.medium)
            .shadow(color: Theme.Palette.darkTeal.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

struct ActiveWorkoutBanner: View {
    let workout: ActiveWorkout
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.md) {
                // Іконка тренування
                Image(systemName: workout.sportType.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Theme.Palette.primary)
                    .clipShape(Circle())
                
                // Інформація про тренування
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(workout.sportType.rawValue)
                            .font(Theme.Typography.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Статус тренування
                        HStack(spacing: 4) {
                            Circle()
                                .fill(.white)
                                .frame(width: 6, height: 6)
                                .scaleEffect(1.0)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: workout.formattedDuration)
                            
                            Text(workout.isPaused ? "Пауза" : "Активне")
                                .font(Theme.Typography.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    HStack {
                        Text(workout.formattedDuration)
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if workout.totalDistance > 0 {
                            Text(workout.formattedDistance)
                                .font(Theme.Typography.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                
                // Стрілка
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(Theme.Spacing.md)
            .background(
                LinearGradient(
                    colors: [Theme.Palette.primary, Theme.Palette.accent],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(Theme.CornerRadius.medium)
            .shadow(color: Theme.Palette.primary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DayRow: View {
    let day: Day
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
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
        .background(Theme.Gradients.card)
        .cornerRadius(Theme.CornerRadius.medium)
        .shadow(color: Theme.Palette.darkTeal.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
