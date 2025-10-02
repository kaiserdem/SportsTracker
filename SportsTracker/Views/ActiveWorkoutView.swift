import SwiftUI
import ComposableArchitecture

struct ActiveWorkoutView: View {
    let store: StoreOf<WorkoutFeature>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack(spacing: Theme.Spacing.lg) {
                    if let workout = viewStore.currentWorkout {
                        // Заголовок
                        VStack(spacing: Theme.Spacing.sm) {
                            Text(workout.sportType.rawValue)
                                .font(Theme.Typography.title)
                                .foregroundColor(Theme.Palette.text)
                                .onAppear {
                                    print("📱 ActiveWorkoutView: Відображаю спорт: \(workout.sportType.rawValue)")
                                }
                            
                            Text(workout.sportType.category.rawValue)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Palette.textSecondary)
                        }
                        .padding(.top, Theme.Spacing.lg)
                        
                        // Таймер
                        VStack(spacing: Theme.Spacing.sm) {
                            Text(workout.formattedDuration)
                                .font(.system(size: 60, weight: .bold, design: .monospaced))
                                .foregroundColor(Theme.Palette.primary)
                                .animation(.easeInOut(duration: 0.1), value: workout.formattedDuration)
                            
                            if case .paused = viewStore.workoutState {
                                Text("Пауза")
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Palette.secondary)
                                    .padding(.horizontal, Theme.Spacing.md)
                                    .padding(.vertical, Theme.Spacing.xs)
                                    .background(Theme.Palette.secondary.opacity(0.1))
                                    .cornerRadius(Theme.CornerRadius.small)
                            } else if case .active = viewStore.workoutState {
                                HStack(spacing: Theme.Spacing.xs) {
                                    Circle()
                                        .fill(Theme.Palette.accent)
                                        .frame(width: 8, height: 8)
                                        .scaleEffect(1.0)
                                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: workout.formattedDuration)
                                    
                                    Text("Активне тренування")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Palette.textSecondary)
                                }
                            }
                        }
                        .padding(.vertical, Theme.Spacing.lg)
                        
                        // Статистика
                        VStack(spacing: Theme.Spacing.md) {
                            // Основна статистика
                            HStack(spacing: Theme.Spacing.lg) {
                                WorkoutStatisticItem(
                                    title: "Дистанція",
                                    value: workout.formattedDistance,
                                    icon: "location"
                                )
                                
                                WorkoutStatisticItem(
                                    title: "Темп",
                                    value: workout.formattedCurrentPace,
                                    icon: "timer"
                                )
                            }
                            
                            // Швидкість та активність
                            HStack(spacing: Theme.Spacing.lg) {
                                WorkoutStatisticItem(
                                    title: "Поточна швидкість",
                                    value: workout.formattedCurrentSpeed,
                                    icon: "speedometer"
                                )
                                
                                WorkoutStatisticItem(
                                    title: "Середня швидкість",
                                    value: workout.formattedAverageSpeed,
                                    icon: "chart.line.uptrend.xyaxis"
                                )
                            }
                            
                            // Активні хвилини
                            if workout.locations.count > 0 {
                                HStack(spacing: Theme.Spacing.lg) {
                                    WorkoutStatisticItem(
                                        title: "Активний час",
                                        value: workout.formattedActiveTime,
                                        icon: "figure.run"
                                    )
                                    
                                    WorkoutStatisticItem(
                                        title: "Активність",
                                        value: String(format: "%.0f%%", workout.activeTimePercentage),
                                        icon: "percent"
                                    )
                                }
                            }
                            
                            // GPS інформація
                            if workout.locations.count > 0 {
                                WorkoutStatisticItem(
                                    title: "GPS точок",
                                    value: "\(workout.locations.count)",
                                    icon: "dot.radiowaves.up.forward"
                                )
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                        
                        Spacer()
                        
                        // Кнопки управління
                        VStack(spacing: Theme.Spacing.md) {
                            HStack(spacing: Theme.Spacing.md) {
                                if case .active = viewStore.workoutState {
                                    Button("Пауза") {
                                        viewStore.send(.pauseWorkout)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(Theme.Palette.secondary)
                                    .frame(maxWidth: .infinity)
                                } else if case .paused = viewStore.workoutState {
                                    Button("Продовжити") {
                                        viewStore.send(.resumeWorkout)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(Theme.Palette.primary)
                                    .frame(maxWidth: .infinity)
                                }
                                
                                Button("Завершити") {
                                    viewStore.send(.finishWorkout)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Theme.Palette.accent)
                                .frame(maxWidth: .infinity)
                            }
                            
                            // GPS статус
                            HStack {
                                Image(systemName: viewStore.isLocationTracking ? "location.fill" : "location.slash")
                                    .foregroundColor(viewStore.isLocationTracking ? Theme.Palette.accent : Theme.Palette.textSecondary)
                                
                                Text(viewStore.isLocationTracking ? "GPS активне" : "GPS неактивне")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Palette.textSecondary)
                                
                                if let workout = viewStore.currentWorkout, workout.isCurrentlyMoving {
                                    Spacer()
                                    Image(systemName: "figure.run")
                                        .foregroundColor(Theme.Palette.primary)
                                    Text("Рух")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Palette.primary)
                                }
                            }
                            .padding(.top, Theme.Spacing.sm)
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.bottom, Theme.Spacing.lg)
                    }
                }
                .background(Theme.Gradients.screenBackground)
                //.navigationTitle("Тренування")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        CustomBackButton {
                            viewStore.send(.hideActiveWorkout)
                        }
                    }
                }
            }
        }
    }
}

struct WorkoutStatisticItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Theme.Palette.primary)
            
            Text(value)
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Palette.text)
            
            Text(title)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Palette.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.md)
        .background(Theme.Gradients.card)
        .cornerRadius(Theme.CornerRadius.medium)
        .shadow(color: Theme.Palette.darkTeal.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Workout Summary View

struct WorkoutSummaryView: View {
    let workout: ActiveWorkout
    let onSave: () -> Void
    let onDiscard: () -> Void
    
    @State private var comment: String = ""
    @State private var calories: String = ""
    @State private var steps: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: Theme.Spacing.lg) {
                // Заголовок
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Тренування завершено!")
                        .font(Theme.Typography.title)
                        .foregroundColor(Theme.Palette.text)
                    
                    Text(workout.sportType.rawValue)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Palette.textSecondary)
                }
                .padding(.top, Theme.Spacing.lg)
                
                // Підсумок
                VStack(spacing: Theme.Spacing.md) {
                    SummaryRow(title: "Тривалість", value: workout.formattedDuration)
                    SummaryRow(title: "Дистанція", value: workout.formattedDistance)
                    SummaryRow(title: "Середня швидкість", value: workout.formattedAverageSpeed)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                
                // Додаткова інформація
                VStack(spacing: Theme.Spacing.md) {
                    Text("Додаткова інформація")
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Palette.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: Theme.Spacing.md) {
                        TextField("Коментар (необов'язково)", text: $comment)
                            .textFieldStyle(.roundedBorder)
                        
                        HStack(spacing: Theme.Spacing.md) {
                            TextField("Калорії", text: $calories)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                            
                            TextField("Кроки", text: $steps)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
                
                Spacer()
                
                // Кнопки
                VStack(spacing: Theme.Spacing.md) {
                    Button("Зберегти тренування") {
                        onSave()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.Palette.primary)
                    .frame(maxWidth: .infinity)
                    
                    Button("Видалити") {
                        onDiscard()
                    }
                    .buttonStyle(.bordered)
                    .tint(Theme.Palette.secondary)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.lg)
            }
            .background(Theme.Gradients.screenBackground)
            .navigationTitle("Підсумок")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Palette.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Palette.text)
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}

