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
                        
                        HStack {
                            Text("  This Month")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                            
                            
                            Spacer()
                        }
                        
                        // Статистика місяця та календар
                        HStack(spacing: Theme.Spacing.md) {
                            // Статистика місяця
                            MonthlyStatsView(days: viewStore.recentDays)
                                .frame(maxWidth: .infinity)
                            
                            // Календар
                            MonthlyCalendarView(days: viewStore.recentDays)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.top, 0)
                        
                        // Quick Actions
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Text("Quick Actions")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
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
                                ) {
                                    viewStore.send(.showAddActivity)
                                }
                                
                                QuickActionCard(
                                    title: "Переглянути статистику",
                                    icon: "chart.bar.fill",
                                    color: Theme.Palette.secondary
                                )
                                
                                QuickActionCard(
                                    title: "Routes",
                                    icon: "map.fill",
                                    color: Theme.Palette.accent
                                )
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                        
                        // Recent Activities
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Text("Recent Activities")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(Theme.Palette.text)
                            
                            if viewStore.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else if viewStore.recentDays.isEmpty {
                                Text("No activities yet")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
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
            .sheet(isPresented: viewStore.binding(
                get: \.isShowingAddActivity,
                send: HomeFeature.Action.dismissAddActivity
            )) {
                AddActivityView(
                    store: self.store.scope(
                        state: \.addActivity,
                        action: HomeFeature.Action.addActivity
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
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
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
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Theme.Palette.primary)
                    .clipShape(Circle())
                
                // Інформація про тренування
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(workout.sportType.rawValue)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Статус тренування
                        HStack(spacing: 4) {
                            Circle()
                                .fill(.white)
                                .frame(width: 6, height: 6)
                                .scaleEffect(1.0)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: workout.formattedDuration)
                            
                            Text(workout.isPaused ? "Paused" : "Active")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    HStack {
                        Text(workout.formattedDuration)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if workout.totalDistance > 0 {
                            Text(workout.formattedDistance)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                
                // Стрілка
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
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
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Palette.primary)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(day.sportType.rawValue)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(Theme.Palette.text)
                    
                    Text(day.formattedDate)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Palette.textSecondary)
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
            
            if let comment = day.comment, !comment.isEmpty {
                Text(comment)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Palette.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if day.hasSupplements {
                HStack {
                    Image(systemName: "pills.fill")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Palette.accent)
                    
                    Text("\(day.supplementsCount) supplements")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
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

// MARK: - Monthly Stats View

struct MonthlyStatsView: View {
    let days: [Day]
    
    private var currentMonthDays: [Day] {
        let calendar = Calendar.current
        let now = Date()
        
        // Отримуємо початок поточного місяця
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        // Фільтруємо тренування поточного місяця
        let filteredDays = days.filter { day in
            day.date >= startOfMonth
        }
        
        //print("📊 MonthlyStatsView: Знайдено \(filteredDays.count) тренувань в поточному місяці")
        for day in filteredDays {
            print("   - \(day.sportType.rawValue): \(day.duration) секунд, дистанція: \(day.distance ?? 0) м")
        }
        
        return filteredDays
    }
    
    private var monthlyDuration: TimeInterval {
        let totalDuration = currentMonthDays.reduce(0) { $0 + $1.duration }
        //print("📊 MonthlyStatsView: Загальна тривалість: \(totalDuration) секунд")
        return totalDuration
    }
    
    private var monthlyDistance: Double {
        let totalDistance = currentMonthDays.compactMap { $0.distance }.reduce(0, +)
        print("📊 MonthlyStatsView: Загальна дистанція: \(totalDistance) метрів")
        print("📊 MonthlyStatsView: Дні з дистанцією: \(currentMonthDays.compactMap { $0.distance }.count)")
        for day in currentMonthDays {
            if let distance = day.distance {
                print("   - \(day.sportType.rawValue): \(distance) м")
            }
        }
        return totalDistance
    }
    
    private var formattedDuration: String {
        let totalSeconds = Int(monthlyDuration.rounded())
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        //print("📊 MonthlyStatsView: Форматування - totalSeconds: \(totalSeconds), hours: \(hours), minutes: \(minutes), seconds: \(seconds)")
        
        if hours > 0 {
            return "\(hours)г:\(String(format: "%02d", minutes))хв:\(String(format: "%02d", seconds))с"
        } else if minutes > 0 {
            return "\(minutes)хв:\(String(format: "%02d", seconds))с"
        } else {
            return "\(seconds)с"
        }
    }
    
    private var daysCount: Int {
        let totalSeconds = Int(monthlyDuration.rounded())
        return totalSeconds / (24 * 3600) // 24 години = 1 день
    }
    
    private var hoursCount: Int {
        let totalSeconds = Int(monthlyDuration.rounded())
        return (totalSeconds % (24 * 3600)) / 3600 // Залишок годин після днів
    }
    
    private var minutesCount: Int {
        let totalSeconds = Int(monthlyDuration.rounded())
        return (totalSeconds % 3600) / 60
    }
    
    private var secondsCount: Int {
        let totalSeconds = Int(monthlyDuration.rounded())
        return totalSeconds % 60
    }
    
    private var formattedDistance: String {
        let distance = monthlyDistance
        print("📊 MonthlyStatsView: Форматую дистанцію: \(distance) м")
        
        if distance >= 1000 {
            let km = distance / 1000
            // Видаляємо зайві нулі після коми
            if km.truncatingRemainder(dividingBy: 1) == 0 {
                let result = String(format: "%.0f км", km)
                print("📊 MonthlyStatsView: Результат форматування: \(result)")
                return result
            } else {
                let result = String(format: "%.1f км", km)
                print("📊 MonthlyStatsView: Результат форматування: \(result)")
                return result
            }
        } else {
            let result = String(format: "%.0f м", distance)
            print("📊 MonthlyStatsView: Результат форматування: \(result)")
            return result
        }
    }
    
    var body: some View {
        let _ = print("🔄 MonthlyStatsView: Перерендерується body")
        VStack(spacing: Theme.Spacing.md) {
            // 1. Назва
            
            // 2. Горизонтальний стек з елементами
            HStack(spacing: Theme.Spacing.sm) {
                // Дні (показуємо тільки якщо є)
                if daysCount > 0 {
                    VStack(spacing: 4) {
                        Text("\(daysCount)")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.Palette.primary)
                        Text("days")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Palette.textSecondary)
                    }
                }
                
                // Години
                VStack(spacing: 4) {
                    Text("\(hoursCount)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Palette.primary)
                    Text("hrs")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Palette.textSecondary)
                }
                
                // Хвилини
                VStack(spacing: 4) {
                    Text("\(minutesCount)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Palette.primary)
                    Text("min")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Palette.textSecondary)
                }
                
                
                
                // Секунди
                VStack(spacing: 4) {
                    Text("\(secondsCount)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Palette.primary)
                    Text("sec")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Palette.textSecondary)
                }
            }
            
            // 3. Назва "Duration"
            Text("Duration")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.Palette.text)
            
            // 4. Дистанція
            Text(formattedDistance)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Palette.secondary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            // 5. Назва "Distance"
            Text("Distance")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.Palette.text)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding(.vertical, Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(Theme.Gradients.card)
        )
        .shadow(color: Theme.Palette.darkTeal.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Monthly Calendar View

struct MonthlyCalendarView: View {
    let days: [Day]
    
    @State private var displayedDate = Date()
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var currentDate: Date {
        Date()
    }
    
    private var currentMonth: Int {
        calendar.component(.month, from: displayedDate)
    }
    
    private var currentYear: Int {
        calendar.component(.year, from: displayedDate)
    }
    
    private var currentDay: Int {
        calendar.component(.day, from: currentDate)
    }
    
    private var isCurrentMonth: Bool {
        calendar.isDate(displayedDate, equalTo: currentDate, toGranularity: .month)
    }
    
    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: displayedDate)?.count ?? 30
    }
    
    private var firstDayOfMonth: Date {
        calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) ?? displayedDate
    }
    
    private var firstWeekday: Int {
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        // В iOS Calendar: Неділя = 1, Понеділок = 2, ..., Субота = 7
        // Нам потрібно: Понеділок = 0, Вівторок = 1, ..., Неділя = 6
        return (weekday + 5) % 7
    }
    
    private func hasWorkoutOnDay(_ day: Int) -> Bool {
        let targetDate = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: day)) ?? displayedDate
        let hasWorkout = days.contains { workoutDay in
            calendar.isDate(workoutDay.date, inSameDayAs: targetDate)
        }
        return hasWorkout
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            // Заголовок календаря з кнопками навігації
            HStack {
                // Кнопка попереднього місяця
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        displayedDate = calendar.date(byAdding: .month, value: -1, to: displayedDate) ?? displayedDate
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Palette.primary)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(Theme.Palette.primary.opacity(0.1))
                        )
                }
                
                Spacer()
                
                // Назва місяця та року
                HStack(spacing: 3) {
                    Text("\(currentMonth)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Palette.text)
                        .fontWeight(.medium)
                    
                    Text("\(currentYear)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Palette.textSecondary)
                }
                
                Spacer()
                
                // Кнопка наступного місяця
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        displayedDate = calendar.date(byAdding: .month, value: 1, to: displayedDate) ?? displayedDate
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Palette.primary)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(Theme.Palette.primary.opacity(0.1))
                        )
                }
            }
            
            // Дні тижня
            HStack(spacing: 2) {
                ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Palette.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Діагностична інформація
//            let _ = print("📅 Календар: === ПОТОЧНА ДАТА ===")
//            let _ = print("📅 Календар: Сьогодні: \(currentDate)")
//            let _ = print("📅 Календар: Поточний день: \(currentDay)")
//            let _ = print("📅 Календар: Поточний місяць: \(currentMonth)")
//            let _ = print("📅 Календар: Поточний рік: \(currentYear)")
//            let _ = print("📅 Календар: Перший день місяця: \(firstDayOfMonth)")
//            let _ = print("📅 Календар: День тижня першого дня: \(calendar.component(.weekday, from: firstDayOfMonth))")
//            let _ = print("📅 Календар: Відрегульований день: \(firstWeekday)")
//            let _ = print("📅 Календар: Кількість днів у місяці: \(daysInMonth)")
//            let _ = print("📅 Календар: ======================")
            
            // Календарна сітка
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                // Порожні клітинки для першого дня місяця
                ForEach(0..<firstWeekday, id: \.self) { index in
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 24)
                        .id("empty-\(index)")
                }
                
                // Дні місяця
                ForEach(1...daysInMonth, id: \.self) { day in
                    let hasWorkout = hasWorkoutOnDay(day)
                    let isToday = isCurrentMonth && day == currentDay
                    
                    // Діагностика для сьогоднішнього дня
                    if isToday {
                        //let _ = print("📅 Календар: СЬОГОДНІШНІЙ ДЕНЬ: \(day) (isToday: \(isToday), hasWorkout: \(hasWorkout))")
                    }
                    
                    Text("\(day)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor((isToday || hasWorkout) ? .white : Theme.Palette.text)
                        .frame(width: 19, height: 19)
                        .background(
                            Circle()
                                .fill(hasWorkout ? Theme.Palette.primary : (isToday ? .green : Color.clear))
                        )
                        .overlay(
                            Circle()
                                .stroke(hasWorkout ? Theme.Palette.primary : (isToday ? .green : Color.clear), lineWidth: 1)
                        )
                        .id("day-\(day)")
                }
            }
        }
        .frame(minHeight: 200)
        .padding(.vertical, Theme.Spacing.lg)
        .padding(.horizontal, Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(Theme.Gradients.card)
        )
        .shadow(color: Theme.Palette.darkTeal.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
