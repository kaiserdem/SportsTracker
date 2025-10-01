import ComposableArchitecture
import Foundation

struct HomeFeature: Reducer {
    struct State: Equatable {
        var welcomeMessage = "Ласкаво просимо до SportsTracker!"
        var recentDays: [Day] = []
        var isLoading = false
        var workout = WorkoutFeature.State()
    }
    
    enum Action: Equatable {
        case onAppear
        case loadRecentActivities
        case daysLoaded([Day])
        case saveDay(Day)
        case deleteDay(Day)
        case updateDay(Day)
        case coreDataError(CoreDataError)
        case workout(WorkoutFeature.Action)
        case showWorkoutDetail(UUID)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.workout, action: /Action.workout) {
            WorkoutFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadRecentActivities)
                
            case .loadRecentActivities:
                state.isLoading = true
                return CoreDataEffects.fetchDays()
                    .map(Action.daysLoaded)
                
            case let .daysLoaded(days):
                print("📋 HomeFeature: Завантажено \(days.count) тренувань:")
                for (index, day) in days.enumerated() {
                    print("   \(index + 1). ID: \(day.id)")
                    print("      SportType: '\(day.sportType.rawValue)'")
                    print("      Date: \(day.date)")
                    print("      Duration: \(day.duration)")
                    print("      Comment: \(day.comment ?? "nil")")
                    print("      Steps: \(day.steps ?? 0)")
                    print("      Calories: \(day.calories ?? 0)")
                }
                state.recentDays = days
                state.isLoading = false
                return .none
                
            case let .saveDay(day):
                return CoreDataEffects.saveDay(day)
                    .map { _ in .loadRecentActivities }
                
            case let .deleteDay(day):
                return CoreDataEffects.deleteDay(day)
                    .map { _ in .loadRecentActivities }
                
            case let .updateDay(day):
                return CoreDataEffects.updateDay(day)
                    .map { _ in .loadRecentActivities }
                
            case let .coreDataError(error):
                state.isLoading = false
                // Тут можна додати обробку помилок
                print("Core Data Error: \(error)")
                return .none
                
            case .workout(.notifyWorkoutCompleted):
                print("🔄 HomeFeature: Отримав повідомлення про завершення тренування, оновлюю список")
                return .send(.loadRecentActivities)
                
            case .workout:
                return .none
                
            case let .showWorkoutDetail(workoutId):
                // Передаємо дію вгору до AppFeature
                print("📤 HomeFeature: Передаю showWorkoutDetail з ID: \(workoutId)")
                return .none
            }
        }
    }
}

// Використовуємо модель Day замість Activity
