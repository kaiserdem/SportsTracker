import ComposableArchitecture
import Foundation

struct HomeFeature: Reducer {
    struct State: Equatable {
        var welcomeMessage = "Ласкаво просимо до SportsTracker!"
        var recentDays: [Day] = []
        var isLoading = false
    }
    
    enum Action: Equatable {
        case onAppear
        case loadRecentActivities
        case daysLoaded([Day])
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadRecentActivities)
                
            case .loadRecentActivities:
                state.isLoading = true
                // Тут буде завантаження даних
                return .send(.daysLoaded(Day.createSampleData()))
                
            case let .daysLoaded(days):
                state.recentDays = days
                state.isLoading = false
                return .none
            }
        }
    }
}

// Використовуємо модель Day замість Activity
