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
        let calendar = Calendar.current
        let now = Date()
        
        let (startDate, endDate): (Date, Date) = {
            switch period {
            case .week:
                let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
                let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
                return (startOfWeek, endOfWeek)
            case .month:
                let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
                let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now
                return (startOfMonth, endOfMonth)
            case .year:
                let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
                let endOfYear = calendar.dateInterval(of: .year, for: now)?.end ?? now
                return (startOfYear, endOfYear)
            }
        }()
        
        return CoreDataEffects.fetchDaysInRange(startDate, endDate)
            .map { days in
                // Групуємо по типах спорту
                let groupedDays = Dictionary(grouping: days) { $0.sportType }
                
                return groupedDays.map { (sportType, days) in
                    let totalDuration = days.reduce(0) { $0 + $1.duration }
                    let totalCalories = days.reduce(0) { $0 + ($1.calories ?? 0) }
                    let totalSteps = days.reduce(0) { $0 + ($1.steps ?? 0) }
                    let averageSpeed = totalDuration > 0 ? Double(totalSteps) / (totalDuration / 3600) : 0
                    
                    return StatisticData(
                        type: sportType,
                        totalDuration: totalDuration,
                        totalDistance: Double(totalSteps) * 0.0008, // Приблизно 0.8м на крок
                        averageSpeed: averageSpeed,
                        calories: totalCalories
                    )
                }
            }
    }
    
    static func fetchTotalStatistics() -> Effect<TotalStatistics> {
        CoreDataEffects.fetchDays()
            .map { days in
                let totalDays = days.count
                let totalDuration = days.reduce(0) { $0 + $1.duration }
                let totalCalories = days.reduce(0) { $0 + ($1.calories ?? 0) }
                let totalSteps = days.reduce(0) { $0 + ($1.steps ?? 0) }
                let uniqueSportTypes = Set(days.map { $0.sportType }).count
                
                return TotalStatistics(
                    totalDays: totalDays,
                    totalDuration: totalDuration,
                    totalCalories: totalCalories,
                    totalSteps: totalSteps,
                    uniqueSportTypes: uniqueSportTypes
                )
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
        CoreDataEffects.fetchDays()
            .map { days in
                let totalWorkouts = days.count
                let totalDuration = days.reduce(0) { $0 + $1.duration }
                let totalDistance = days.reduce(0) { $0 + Double($1.steps ?? 0) * 0.0008 } // Приблизно 0.8м на крок
                let totalCalories = days.reduce(0) { $0 + ($1.calories ?? 0) }
                
                let sportTypeCounts = Dictionary(grouping: days) { $0.sportType }
                let favoriteSport = sportTypeCounts.max { $0.value.count < $1.value.count }?.key
                
                let averageWorkoutDuration = totalWorkouts > 0 ? totalDuration / Double(totalWorkouts) : 0
                let longestWorkout = days.map { $0.duration }.max() ?? 0
                
                // Простий розрахунок streak (дні підряд з тренуваннями)
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
                
                return WorkoutStatistics(
                    totalWorkouts: totalWorkouts,
                    totalDuration: totalDuration,
                    totalDistance: totalDistance,
                    totalCalories: totalCalories,
                    favoriteSport: favoriteSport,
                    averageWorkoutDuration: averageWorkoutDuration,
                    longestWorkout: longestWorkout,
                    currentStreak: currentStreak
                )
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
