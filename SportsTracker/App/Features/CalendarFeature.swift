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
        case saveDay(Day)
        case deleteDay(Day)
        case updateDay(Day)
        case coreDataError(CoreDataError)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadEvents)
                
            case let .selectDate(date):
                state.selectedDate = date
                return .send(.loadEvents)
                
            case .loadEvents:
                state.isLoading = true
                return CalendarEffects.fetchDaysForDate(state.selectedDate)
                    .map(Action.eventsLoaded)
                
            case let .eventsLoaded(events):
                state.events = events
                state.isLoading = false
                return .none
                
            case let .saveDay(day):
                return CoreDataEffects.saveDay(day)
                    .map { _ in .loadEvents }
                
            case let .deleteDay(day):
                return CoreDataEffects.deleteDay(day)
                    .map { _ in .loadEvents }
                
            case let .updateDay(day):
                return CoreDataEffects.updateDay(day)
                    .map { _ in .loadEvents }
                
            case let .coreDataError(error):
                state.isLoading = false
                print("Core Data Error: \(error)")
                return .none
            }
        }
    }
}

// Використовуємо модель Day замість CalendarEvent
