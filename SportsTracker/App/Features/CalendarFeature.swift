import ComposableArchitecture
import Foundation

struct CalendarFeature: Reducer {
    struct State: Equatable {
        var selectedDate = Date()
        var events: [Day] = []
        var isLoading = false
    }
    
    enum Action: Equatable {
        case onAppear
        case selectDate(Date)
        case loadEvents
        case eventsLoaded([Day])
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadEvents)
                
            case let .selectDate(date):
                state.selectedDate = date
                return .none
                
            case .loadEvents:
                state.isLoading = true
                // Тут буде завантаження подій
                return .send(.eventsLoaded(Day.createSampleData()))
                
            case let .eventsLoaded(events):
                state.events = events
                state.isLoading = false
                return .none
            }
        }
    }
}

// Використовуємо модель Day замість CalendarEvent
