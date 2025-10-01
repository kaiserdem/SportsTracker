import ComposableArchitecture
import Foundation

struct AppFeature: Reducer {
    struct State: Equatable {
        enum Tab: Hashable { case home, calendar, statistic, map  }
        var selectedTab: Tab = .home
        var home = HomeFeature.State()
        var calendar = CalendarFeature.State()
        var statistic = StatisticFeature.State()
        var map = MapFeature.State()
    }

    enum Action: Equatable {
        case selectTab(State.Tab)
        case home(HomeFeature.Action)
        case calendar(CalendarFeature.Action)
        case statistic(StatisticFeature.Action)
        case map(MapFeature.Action)
        case onAppear
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.home, action: /Action.home) { HomeFeature() }
        Scope(state: \.calendar, action: /Action.calendar) { CalendarFeature() }
        Scope(state: \.statistic, action: /Action.statistic) { StatisticFeature() }
        Scope(state: \.map, action: /Action.map) { MapFeature() }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case let .selectTab(tab):
                state.selectedTab = tab
                return .none
         
            case .home:
                return .none
                
                case .calendar:
                    return .none
                    
                case .statistic:
                    return .none
                    
                case .map:
                    return .none
            }
        }
    }
}
