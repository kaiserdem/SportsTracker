import Foundation
import ComposableArchitecture

// MARK: - Core Data Effects

struct CoreDataEffects {
    static func saveDay(_ day: Day) -> Effect<CoreDataError> {
        @Dependency(\.coreDataManager) var coreDataManager
        return coreDataManager.saveDay(day)
    }
    
    static func fetchDays() -> Effect<[Day]> {
        @Dependency(\.coreDataManager) var coreDataManager
        return coreDataManager.fetchDays()
    }
    
    static func deleteDay(_ day: Day) -> Effect<CoreDataError> {
        @Dependency(\.coreDataManager) var coreDataManager
        return coreDataManager.deleteDay(day)
    }
    
    static func updateDay(_ day: Day) -> Effect<CoreDataError> {
        @Dependency(\.coreDataManager) var coreDataManager
        return coreDataManager.updateDay(day)
    }
    
    static func fetchDaysInRange(_ startDate: Date, _ endDate: Date) -> Effect<[Day]> {
        @Dependency(\.coreDataManager) var coreDataManager
        return coreDataManager.fetchDaysInRange(startDate, endDate)
    }
    
    static func fetchDaysBySportType(_ sportType: SportType) -> Effect<[Day]> {
        @Dependency(\.coreDataManager) var coreDataManager
        return coreDataManager.fetchDaysBySportType(sportType)
    }
    
    static func fetchDayById(_ id: UUID) -> Effect<Day> {
        @Dependency(\.coreDataManager) var coreDataManager
        return coreDataManager.fetchDayById(id)
    }
}

// MARK: - Batch Operations

struct BatchCoreDataEffects {
    static func saveMultipleDays(_ days: [Day]) -> Effect<CoreDataError> {
        .merge(days.map { day in
            CoreDataEffects.saveDay(day)
        })
    }
    
    static func deleteMultipleDays(_ days: [Day]) -> Effect<CoreDataError> {
        .merge(days.map { day in
            CoreDataEffects.deleteDay(day)
        })
    }
}

// MARK: - Statistics Effects

struct StatisticsEffects {
    static func fetchStatisticsForPeriod(_ period: StatisticPeriod) -> Effect<[StatisticData]> {
        print("📈 StatisticsEffects: Отримую статистику для періоду \(period)...")
        
        let calendar = Calendar.current
        let now = Date()
        
        let (startDate, endDate): (Date, Date) = {
            switch period {
            case .week:
                let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
                let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
                print("📈 Період тижня: \(startOfWeek) - \(endOfWeek)")
                return (startOfWeek, endOfWeek)
            case .month:
                let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
                let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now
                print("📈 Період місяця: \(startOfMonth) - \(endOfMonth)")
                return (startOfMonth, endOfMonth)
            case .year:
                let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
                let endOfYear = calendar.dateInterval(of: .year, for: now)?.end ?? now
                print("📈 Період року: \(startOfYear) - \(endOfYear)")
                return (startOfYear, endOfYear)
            }
        }()
        
        return CoreDataEffects.fetchDaysInRange(startDate, endDate)
            .map { days in
                print("📈 StatisticsEffects: Знайдено \(days.count) тренувань для періоду")
                
                // Групуємо по типах спорту
                print("📈 Групую тренування по типах спорту...")
                let groupedDays = Dictionary(grouping: days) { $0.sportType }
                
                let statisticsData = groupedDays.map { (sportType, days) in
                    print("📈 Обробляю \(sportType.rawValue): \(days.count) тренувань...")
                    
                    let totalDuration = days.reduce(0) { $0 + $1.duration }
                    let totalCalories = days.reduce(0) { $0 + ($1.calories ?? 0) }
                    let totalSteps = days.reduce(0) { $0 + ($1.steps ?? 0) }
                    let averageSpeed = totalDuration > 0 ? Double(totalSteps) / (totalDuration / 3600) : 0
                    
                    let data = StatisticData(
                        type: sportType,
                        totalDuration: totalDuration,
                        totalDistance: Double(totalSteps) * 0.0008, // Приблизно 0.8м на крок
                        averageSpeed: averageSpeed,
                        calories: totalCalories
                    )
                    
                    print("📈 \(sportType.rawValue): тривалість=\(data.totalDuration), дистанція=\(data.totalDistance)")
                    return data
                }
                
                print("✅ StatisticsEffects: Згенеровано \(statisticsData.count) записів статистики")
                return statisticsData
            }
    }
    
    static func fetchTotalStatistics() -> Effect<TotalStatistics> {
        print("📊 StatisticsEffects: Отримую загальну статистику...")
        
        return CoreDataEffects.fetchDays()
            .map { days in
                print("📊 StatisticsEffects: Обробляю \(days.count) тренувань...")
                
                let totalDays = days.count
                let totalDuration = days.reduce(0) { $0 + $1.duration }
                let totalCalories = days.reduce(0) { $0 + ($1.calories ?? 0) }
                let totalSteps = days.reduce(0) { $0 + ($1.steps ?? 0) }
                let uniqueSportTypes = Set(days.map { $0.sportType }).count
                
                let stats = TotalStatistics(
                    totalDays: totalDays,
                    totalDuration: totalDuration,
                    totalCalories: totalCalories,
                    totalSteps: totalSteps,
                    uniqueSportTypes: uniqueSportTypes
                )
                
                print("✅ StatisticsEffects: Статистика обчислена:")
                print("   - Загальна кількість: \(stats.totalDays)")
                print("   - Загальна тривалість: \(stats.totalDuration)")
                print("   - Загальні калорії: \(stats.totalCalories)")
                print("   - Загальні кроки: \(stats.totalSteps)")
                print("   - Унікальні види спорту: \(stats.uniqueSportTypes)")
                
                return stats
            }
    }
}

// MARK: - Supporting Types

struct TotalStatistics: Equatable {
    let totalDays: Int
    let totalDuration: TimeInterval
    let totalCalories: Int
    let totalSteps: Int
    let uniqueSportTypes: Int
}

// MARK: - Calendar Effects

struct CalendarEffects {
    static func fetchDaysForDate(_ date: Date) -> Effect<[Day]> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        return CoreDataEffects.fetchDaysInRange(startOfDay, endOfDay)
    }
    
    static func fetchDaysForMonth(_ date: Date) -> Effect<[Day]> {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
        let endOfMonth = calendar.dateInterval(of: .month, for: date)?.end ?? date
        
        return CoreDataEffects.fetchDaysInRange(startOfMonth, endOfMonth)
    }
}

// MARK: - Workout Effects

struct WorkoutEffects {
    static func saveWorkout(_ workout: ActiveWorkout) -> Effect<CoreDataError> {
        let day = workout.toDay()
        return CoreDataEffects.saveDay(day)
    }
    
    static func getWorkoutStatistics() -> Effect<WorkoutStatistics> {
        print("🏃 WorkoutEffects: Отримую статистику тренувань...")
        
        return CoreDataEffects.fetchDays()
            .map { days in
                print("🏃 WorkoutEffects: Обробляю \(days.count) тренувань для статистики...")
                
                let totalWorkouts = days.count
                print("🏃 Рахую загальну тривалість...")
                let totalDuration = days.reduce(0) { $0 + $1.duration }
                
                print("🏃 Рахую загальну дистанцію...")
                let totalDistance = days.reduce(0) { $0 + Double($1.steps ?? 0) * 0.0008 } // Приблизно 0.8м на крок
                
                print("🏃 Рахую калорії та групування...")
                let totalCalories = days.reduce(0) { $0 + ($1.calories ?? 0) }
                
                let sportTypeCounts = Dictionary(grouping: days) { $0.sportType }
                let favoriteSport = sportTypeCounts.max { $0.value.count < $1.value.count }?.key
                
                print("🏃 Обчислюю середню тривалість та найдовше тренування...")
                let averageWorkoutDuration = totalWorkouts > 0 ? totalDuration / Double(totalWorkouts) : 0
                let longestWorkout = days.map { $0.duration }.max() ?? 0
                
                // Простий розрахунок streak (дні підряд з тренуваннями)
                print("🏃 Розрахунок streak...")
                let sortedDays = days.sorted { $0.date > $1.date }
                var currentStreak = 0
                let calendar = Calendar.current
                var currentDate = Date()
                
                for day in sortedDays {
                    if calendar.isDate(day.date, inSameDayAs: currentDate) {
                        currentStreak += 1
                        currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                    } else {
                        break
                    }
                }
                
                let stats = WorkoutStatistics(
                    totalWorkouts: totalWorkouts,
                    totalDuration: totalDuration,
                    totalDistance: totalDistance,
                    totalCalories: totalCalories,
                    favoriteSport: favoriteSport,
                    averageWorkoutDuration: averageWorkoutDuration,
                    longestWorkout: longestWorkout,
                    currentStreak: currentStreak
                )
                
                print("✅ WorkoutEffects: Статистика тренувань готова:")
                print("   - Загальна кількість: \(stats.totalWorkouts)")
                print("   - Загальна тривалість: \(stats.totalDuration)")
                print("   - Загальна дистанція: \(stats.totalDistance)")
                print("   - Загальні калорії: \(stats.totalCalories)")
                print("   - Улюблений спорт: \(stats.favoriteSport?.rawValue ?? "немає")")
                print("   - Середня тривалість: \(stats.averageWorkoutDuration)")
                print("   - Найдовше тренування: \(stats.longestWorkout)")
                print("   - Поточна серія: \(stats.currentStreak)")
                
                return stats
            }
    }
}

// MARK: - Search Effects

struct SearchEffects {
    static func searchDays(query: String) -> Effect<[Day]> {
        CoreDataEffects.fetchDays()
            .map { days in
                if query.isEmpty {
                    return days
                }
                
                return days.filter { day in
                    day.sportType.rawValue.localizedCaseInsensitiveContains(query) ||
                    (day.comment?.localizedCaseInsensitiveContains(query) ?? false)
                }
            }
    }
    
    static func filterDaysBySportType(_ sportType: SportType) -> Effect<[Day]> {
        CoreDataEffects.fetchDaysBySportType(sportType)
    }
    
    static func filterDaysByDateRange(_ startDate: Date, _ endDate: Date) -> Effect<[Day]> {
        CoreDataEffects.fetchDaysInRange(startDate, endDate)
    }
}
