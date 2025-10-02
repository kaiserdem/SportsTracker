import SwiftUI
import ComposableArchitecture

struct WorkoutDetailView: View {
    let store: StoreOf<WorkoutDetailFeature>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        if let workout = viewStore.workout {
                            // Заголовок тренування
                            VStack(spacing: Theme.Spacing.md) {
                                HStack {
                                    Image(systemName: workout.sportType.icon)
                                        .font(.largeTitle)
                                        .foregroundColor(Theme.Palette.primary)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(workout.sportType.rawValue)
                                            .font(Theme.Typography.title)
                                            .foregroundColor(Theme.Palette.text)
                                        
                                        Text(workout.formattedDate)
                                            .font(Theme.Typography.body)
                                            .foregroundColor(Theme.Palette.textSecondary)
                                    }
                                    
                                    Spacer()
                                }
                                
                                // Основна статистика
                                HStack(spacing: Theme.Spacing.lg) {
                                    DetailStatisticItem(
                                        title: "Тривалість",
                                        value: workout.formattedDuration,
                                        icon: "clock"
                                    )
                                    
                                    DetailStatisticItem(
                                        title: "Дистанція",
                                        value: formatDistance(workout),
                                        icon: "location"
                                    )
                                    
                                    if let calories = workout.calories {
                                        DetailStatisticItem(
                                            title: "Калорії",
                                            value: "\(calories)",
                                            icon: "flame"
                                        )
                                    }
                                }
                            }
                            .padding(Theme.Spacing.lg)
                            .background(Theme.Gradients.card)
                            .cornerRadius(Theme.CornerRadius.medium)
                            .shadow(color: Theme.Palette.darkTeal.opacity(0.1), radius: 2, x: 0, y: 1)
                            
                            // Детальна статистика
                            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                                Text("Детальна статистика")
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Palette.text)
                                
                                VStack(spacing: Theme.Spacing.sm) {
                                    if let steps = workout.steps, !workout.sportType.hasSteps {
                                        DetailRow(
                                            title: "Кроки",
                                            value: "\(steps)",
                                            icon: "figure.walk"
                                        )
                                    }
                                    
                                    DetailRow(
                                        title: "Дата початку",
                                        value: formatStartTime(workout),
                                        icon: "calendar"
                                    )
                                    
                                    DetailRow(
                                        title: "Час закінчення",
                                        value: formatEndTime(workout),
                                        icon: "clock.badge.checkmark"
                                    )
                                }
                            }
                            .padding(Theme.Spacing.lg)
                            .background(Theme.Gradients.card)
                            .cornerRadius(Theme.CornerRadius.medium)
                            .shadow(color: Theme.Palette.darkTeal.opacity(0.1), radius: 2, x: 0, y: 1)
                            
                            // Коментар
                            if let comment = workout.comment, !comment.isEmpty {
                                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                                    Text("Коментар")
                                        .font(Theme.Typography.headline)
                                        .foregroundColor(Theme.Palette.text)
                                    
                                    Text(comment)
                                        .font(Theme.Typography.body)
                                        .foregroundColor(Theme.Palette.text)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(Theme.Spacing.md)
                                        .background(Theme.Palette.surface)
                                        .cornerRadius(Theme.CornerRadius.small)
                                }
                                .padding(Theme.Spacing.lg)
                                .background(Theme.Gradients.card)
                                .cornerRadius(Theme.CornerRadius.medium)
                                .shadow(color: Theme.Palette.darkTeal.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                            
                            // Додатки
                            if workout.hasSupplements {
                                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                                    Text("Додатки")
                                        .font(Theme.Typography.headline)
                                        .foregroundColor(Theme.Palette.text)
                                    
                                    ForEach(workout.supplements ?? []) { supplement in
                                        SupplementRow(supplement: supplement)
                                    }
                                }
                                .padding(Theme.Spacing.lg)
                                .background(Theme.Gradients.card)
                                .cornerRadius(Theme.CornerRadius.medium)
                                .shadow(color: Theme.Palette.darkTeal.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                            
                            // Кнопки дій
                            VStack(spacing: Theme.Spacing.md) {
                                Button("Редагувати тренування") {
                                    print("🔘 WorkoutDetailView: Натиснуто 'Редагувати тренування'")
                                    viewStore.send(.editWorkout)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Theme.Palette.primary)
                                .frame(maxWidth: .infinity)
                                
                                Button("Видалити тренування") {
                                    print("🗑️ WorkoutDetailView: Натиснуто 'Видалити тренування'")
                                    dismiss()
                                    viewStore.send(.deleteWorkout)
                                }
                                .buttonStyle(.bordered)
                                .tint(Theme.Palette.accent)
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.top, Theme.Spacing.lg)
                        } else {
                            // Помилка завантаження
                            VStack(spacing: Theme.Spacing.md) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundColor(Theme.Palette.accent)
                                
                                Text("Не вдалося завантажити тренування")
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Palette.text)
                                
                                Text("Спробуйте пізніше")
                                    .font(Theme.Typography.body)
                                    .foregroundColor(Theme.Palette.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(Theme.Spacing.xl)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.lg)
                }
                .background(Theme.Gradients.screenBackground)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        CustomBackButton {
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .alert(
                "Видалити тренування?",
                isPresented: viewStore.binding(
                    get: \.isShowingDeleteAlert,
                    send: { $0 ? .showDeleteAlert : .hideDeleteAlert }
                )
            ) {
                Button("Видалити", role: .destructive) {
                    print("🗑️ WorkoutDetailView: Підтверджено видалення в алерті")
                    viewStore.send(.confirmDelete)
                }
                Button("Скасувати", role: .cancel) {
                    viewStore.send(.hideDeleteAlert)
                }
            } message: {
                Text("Цю дію неможливо скасувати")
            }
            .sheet(isPresented: viewStore.binding(
                get: \.isShowingEditSheet,
                send: { $0 ? .showEditSheet : .hideEditSheet }
            )) {
                if let workout = viewStore.workout {
                    let _ = print("📱 WorkoutDetailView: Відкриваю EditWorkoutView")
                    EditWorkoutView(
                        workout: workout,
                        onSave: { updatedWorkout in
                            print("📤 WorkoutDetailView: onSave викликано, відправляю updateWorkout")
                            print("   - ID: \(updatedWorkout.id)")
                            print("   - Distance: \(updatedWorkout.distance ?? 0) м")
                            viewStore.send(.updateWorkout(updatedWorkout))
                        },
                        onCancel: {
                            print("❌ WorkoutDetailView: onCancel викликано")
                            viewStore.send(.hideEditSheet)
                        }
                    )
                }
            }
        }
    }
}

struct DetailStatisticItem: View {
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
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Theme.Palette.primary)
                .frame(width: 24)
            
            Text(title)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Palette.text)
            
            Spacer()
            
            Text(value)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Palette.textSecondary)
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}

struct SupplementRow: View {
    let supplement: Supplement
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: "pills.fill")
                .font(.title3)
                .foregroundColor(Theme.Palette.accent)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(supplement.name)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Palette.text)
                
                Text("\(supplement.amount) - \(supplement.time)")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Palette.textSecondary)
            }
            
            Spacer()
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}

struct EditWorkoutView: View {
    let workout: Day
    let onSave: (Day) -> Void
    let onCancel: () -> Void
    
    @State private var comment: String
    @State private var calories: String
    @State private var steps: String
    @State private var distance: String
    @State private var distanceUnit: DistanceUnit = .kilometers
    
    init(workout: Day, onSave: @escaping (Day) -> Void, onCancel: @escaping () -> Void) {
        print("🏗️ EditWorkoutView: Ініціалізую з тренуванням:")
        print("   - ID: \(workout.id)")
        print("   - Distance: \(workout.distance ?? 0) м")
        
        self.workout = workout
        self.onSave = onSave
        self.onCancel = onCancel
        self._comment = State(initialValue: workout.comment ?? "")
        self._calories = State(initialValue: workout.calories.map(String.init) ?? "")
        self._steps = State(initialValue: workout.steps.map(String.init) ?? "")
        
        // Ініціалізація дистанції
        if let distanceValue = workout.distance {
            if distanceValue >= 1000 {
                let kmValue = String(format: "%.2f", distanceValue / 1000)
                self._distance = State(initialValue: kmValue)
                self._distanceUnit = State(initialValue: .kilometers)
                print("   - Ініціалізую дистанцію: \(kmValue) км")
            } else {
                let mValue = String(format: "%.0f", distanceValue)
                self._distance = State(initialValue: mValue)
                self._distanceUnit = State(initialValue: .meters)
                print("   - Ініціалізую дистанцію: \(mValue) м")
            }
        } else {
            self._distance = State(initialValue: "")
            self._distanceUnit = State(initialValue: .kilometers)
            print("   - Дистанція порожня, встановлюю порожній рядок")
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Заголовок
                    VStack(spacing: Theme.Spacing.sm) {
                        Text("Редагувати тренування")
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.Palette.text)
                        
                        Text(workout.sportType.rawValue)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Palette.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.lg)
                    
                    // Форма редагування
                    VStack(spacing: Theme.Spacing.md) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Коментар")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Palette.text)
                        
                        TextField("Додайте коментар...", text: $comment, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }
                    
                    HStack(spacing: Theme.Spacing.md) {
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("Калорії")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Palette.text)
                            
                            TextField("0", text: $calories)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                        }
                        
                        if workout.sportType.hasSteps {
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Кроки")
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Palette.text)
                                
                                TextField("0", text: $steps)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                            }
                        }
                    }
                    
                    // Дистанція (тільки для спорту з дистанцією)
                    if workout.sportType.hasDistance {
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("Дистанція")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Palette.text)
                            
                            HStack(spacing: Theme.Spacing.sm) {
                                TextField("0.0", text: $distance)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                                
                                Picker("Одиниця", selection: $distanceUnit) {
                                    Text("м").tag(DistanceUnit.meters)
                                    Text("км").tag(DistanceUnit.kilometers)
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 80)
                            }
                        }
                    }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    
                    // Кнопки
                    VStack(spacing: Theme.Spacing.md) {
                        Button("Зберегти зміни") {
                            saveChanges()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.Palette.primary)
                        .frame(maxWidth: .infinity)
                        
                        Button("Скасувати") {
                            onCancel()
                        }
                        .buttonStyle(.bordered)
                        .tint(Theme.Palette.secondary)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.bottom, Theme.Spacing.lg)
                }
            }
            .background(Theme.Gradients.screenBackground)
            .navigationTitle("Редагування")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CustomBackButton {
                        onCancel()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        print("💾 EditWorkoutView: Зберігаю зміни...")
        print("   - Distance input: '\(distance)' \(distanceUnit.rawValue)")
        
        // Конвертація дистанції в метри
        let distanceInMeters: Double?
        if !distance.isEmpty, let distanceValue = Double(distance) {
            switch distanceUnit {
            case .meters:
                distanceInMeters = distanceValue
                print("   - Конвертую метри: \(distanceValue) м")
            case .kilometers:
                distanceInMeters = distanceValue * 1000
                print("   - Конвертую кілометри: \(distanceValue) км = \(distanceValue * 1000) м")
            }
        } else {
            distanceInMeters = nil
            print("   - Дистанція порожня, встановлюю nil")
        }
        
        let updatedWorkout = Day(
            id: workout.id,
            date: workout.date,
            sportType: workout.sportType,
            comment: comment.isEmpty ? nil : comment,
            duration: workout.duration,
            distance: distanceInMeters,
            steps: Int(steps),
            calories: Int(calories),
            supplements: workout.supplements
        )
        
        print("💾 EditWorkoutView: Створено оновлене тренування:")
        print("   - ID: \(updatedWorkout.id)")
        print("   - Distance: \(updatedWorkout.distance ?? 0) м")
        print("   - Викликаю onSave...")
        
        onSave(updatedWorkout)
    }
}

// MARK: - Custom Back Button

struct CustomBackButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.Palette.primary)
                
                Text("Назад")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.Palette.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Theme.Palette.primary.opacity(isPressed ? 0.2 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Theme.Palette.primary.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Helper Functions

private func formatDistance(_ workout: Day) -> String {
    // Спочатку перевіряємо збережену дистанцію
    if let distance = workout.distance, distance > 0 {
        if distance >= 1000 {
            let km = distance / 1000
            // Видаляємо зайві нулі після коми
            if km.truncatingRemainder(dividingBy: 1) == 0 {
                return String(format: "%.0f км", km)
            } else {
                return String(format: "%.1f км", km)
            }
        } else {
            return String(format: "%.0f м", distance)
        }
    }
    
    // Якщо немає збереженої дистанції, використовуємо приблизний розрахунок на основі кроків
    if let steps = workout.steps, workout.sportType.hasSteps {
        let distance = Double(steps) * 0.0008 // Приблизно 0.8м на крок
        if distance >= 1000 {
            let km = distance / 1000
            // Видаляємо зайві нулі після коми
            if km.truncatingRemainder(dividingBy: 1) == 0 {
                return String(format: "%.0f км", km)
            } else {
                return String(format: "%.1f км", km)
            }
        } else {
            return String(format: "%.0f м", distance)
        }
    }
    
    return "—"
}

private func formatStartTime(_ workout: Day) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "uk_UA")
    return formatter.string(from: workout.date)
}

private func formatEndTime(_ workout: Day) -> String {
    let endTime = workout.date.addingTimeInterval(workout.duration)
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "uk_UA")
    return formatter.string(from: endTime)
}

#Preview {
    WorkoutDetailView(
        store: Store(initialState: WorkoutDetailFeature.State(workoutId: UUID())) {
            WorkoutDetailFeature()
        }
    )
}
