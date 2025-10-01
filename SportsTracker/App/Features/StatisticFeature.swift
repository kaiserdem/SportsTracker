import ComposableArchitecture
import Foundation

struct StatisticFeature: Reducer {
    struct State: Equatable {
        var selectedPeriod: StatisticPeriod = .week
        var statistics: [StatisticData] = []
        var isLoading = false
    }
    
    enum Action: Equatable {
        case onAppear
        case selectPeriod(StatisticPeriod)
        case loadStatistics
        case statisticsLoaded([StatisticData])
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadStatistics)
                
            case let .selectPeriod(period):
                state.selectedPeriod = period
                return .send(.loadStatistics)
                
            case .loadStatistics:
                state.isLoading = true
                // Тут буде завантаження статистики
                return .send(.statisticsLoaded([]))
                
            case let .statisticsLoaded(statistics):
                state.statistics = statistics
                state.isLoading = false
                return .none
            }
        }
    }
}

enum StatisticPeriod: String, CaseIterable {
    case week = "Тиждень"
    case month = "Місяць"
    case year = "Рік"
}

struct StatisticData: Equatable, Identifiable {
    let id = UUID()
    let type: SportType
    let totalDuration: TimeInterval
    let totalDistance: Double
    let averageSpeed: Double
    let calories: Int
}
