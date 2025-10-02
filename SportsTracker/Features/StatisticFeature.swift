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
        case coreDataError(CoreDataError)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Закоментовано: повертаємо порожні дані щоб уникнути крашу CoreData
                state.statistics = []
                state.isLoading = false
                return .none
                
            case let .selectPeriod(period):
                state.selectedPeriod = period
                // Закоментовано: не завантажуємо нові дані
                state.statistics = []
                state.isLoading = false
                return .none
                
            case .loadStatistics:
                // Закоментовано: повертаємо порожні дані
                state.statistics = []
                state.isLoading = false
                return .none
                
            case let .statisticsLoaded(statistics):
                state.statistics = statistics
                state.isLoading = false
                return .none
                
            case let .coreDataError(error):
                state.isLoading = false
                print("Core Data Error: \(error)")
                return .none
            }
        }
    }
}

enum StatisticPeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

struct StatisticData: Equatable, Identifiable {
    let id = UUID()
    let type: SportType
    let totalDuration: TimeInterval
    let totalDistance: Double
    let averageSpeed: Double
    let calories: Int
}
