import ComposableArchitecture
import Foundation
import CoreData

struct CalendarFeature: Reducer {
    enum EventFilter: String, CaseIterable, Equatable {
        case future = "Future"
        case past = "Past"
    }
    
    struct State: Equatable {
        var selectedDate = Date()
        var events: [Day] = []
        var isLoading = false
        var selectedEventFilter: EventFilter = .future
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
        case showAddActivity
        case selectEventFilter(EventFilter)
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
                print("🔄 CalendarFeature: Завантажую події...")
                state.isLoading = true
                return CoreDataEffects.fetchDays()
                    .map(Action.eventsLoaded)
                
            case let .eventsLoaded(days):
                print("📋 Завантажено активностей: \(days.count)")
                
                // Розділяємо на майбутні і минулі
                let calendar = Calendar.current
                let today = Date()
                let futureDays = days.filter { day in
                    calendar.startOfDay(for: day.date) > calendar.startOfDay(for: today)
                }
                let pastDays = days.filter { day in
                    calendar.startOfDay(for: day.date) <= calendar.startOfDay(for: today)
                }
                
                print("🔮 Майбутні (\(futureDays.count)):")
                for (index, day) in futureDays.enumerated() {
                    print("\(index + 1). \(day.sportType.rawValue) - \(day.date)")
                }
                
                print("📜 Минулі (\(pastDays.count)):")
                for (index, day) in pastDays.enumerated() {
                    print("\(index + 1). \(day.sportType.rawValue) - \(day.date)")
                }
                
                state.events = days
                state.isLoading = false
                return .none
                
            case let .saveDay(day):
                return .run { send in
                    do {
                        let context = await MainActor.run { PersistenceController.shared.container.viewContext }
                        let dayEntity = DayEntity(context: context)
                        
                        dayEntity.id = day.id
                        dayEntity.date = day.date
                        dayEntity.sportType = day.sportType.rawValue
                        dayEntity.comment = day.comment
                        dayEntity.duration = day.duration
                        dayEntity.steps = Int32(day.steps ?? 0)
                        dayEntity.calories = Int32(day.calories ?? 0)
                        dayEntity.distance = day.distance ?? 0
                        
                        try context.save()
                        print("✅ CalendarFeature: Успішно збережено тренування")
                        await send(.loadEvents)
                    } catch {
                        print("❌ CalendarFeature: Помилка збереження: \(error)")
                    }
                }
                
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
                
            case .showAddActivity:
                print("📊 CalendarFeature: Показати екран додавання активності")
                return .none
                
            case let .selectEventFilter(filter):
                state.selectedEventFilter = filter
                return .none
            }
        }
    }
}

// Using Day model instead of CalendarEvent
