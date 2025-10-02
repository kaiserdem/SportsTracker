import Foundation
import ComposableArchitecture
// Import SportType from Models

// MARK: - Distance Unit

enum DistanceUnit: String, CaseIterable {
    case meters = "м"
    case kilometers = "км"
}

struct AddActivityFeature: Reducer {
    struct State: Equatable {
        var selectedSportType: SportType = .running
        var selectedDate: Date = Date()
        var startTime: Date = Date()
        var endTime: Date = Date().addingTimeInterval(3600) // +1 година
        var distance: Double = 0
        var distanceUnit: DistanceUnit = .kilometers
        var calories: Int = 0
        var comment: String = ""
        
        var calculatedDuration: String {
            let duration = endTime.timeIntervalSince(startTime)
            let hours = Int(duration) / 3600
            let minutes = Int(duration) % 3600 / 60
            let seconds = Int(duration) % 60
            
            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, seconds)
            } else if minutes > 0 {
                return String(format: "%d:%02d", minutes, seconds)
            } else {
                return String(format: "%dс", seconds)
            }
        }
        
        var calculatedDurationInSeconds: TimeInterval {
            return endTime.timeIntervalSince(startTime)
        }
        
        var calculatedDistanceInMeters: Double {
            switch distanceUnit {
            case .meters:
                return distance
            case .kilometers:
                return distance * 1000
            }
        }
    }
    
    enum Action: Equatable {
        case selectSportType(SportType)
        case setDate(Date)
        case setStartTime(Date)
        case setEndTime(Date)
        case setDistance(Double)
        case setDistanceUnit(DistanceUnit)
        case setCalories(Int)
        case setComment(String)
        case saveActivity
        case dismiss
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            case let .selectSportType(sportType):
                state.selectedSportType = sportType
                return .none
                
            case let .setDate(date):
                state.selectedDate = date
                return .none
                
            case let .setStartTime(time):
                state.startTime = time
                // Автоматично оновлюємо кінець, якщо він раніше початку
                if state.endTime <= time {
                    state.endTime = time.addingTimeInterval(3600) // +1 година
                }
                return .none
                
            case let .setEndTime(time):
                state.endTime = time
                return .none
                
            case let .setDistance(distance):
                state.distance = distance
                return .none
                
            case let .setDistanceUnit(unit):
                state.distanceUnit = unit
                return .none
                
            case let .setCalories(calories):
                state.calories = calories
                return .none
                
            case let .setComment(comment):
                state.comment = comment
                return .none
                
            case .saveActivity:
                // Тут буде логіка збереження активності
                print("💾 Збереження активності:")
                print("   Спорт: \(state.selectedSportType.rawValue)")
                print("   Дата: \(state.selectedDate)")
                print("   Час: \(state.startTime) - \(state.endTime)")
                print("   Тривалість: \(state.calculatedDuration)")
                print("   Дистанція: \(state.distance) \(state.distanceUnit.rawValue)")
                print("   Калорії: \(state.calories)")
                print("   Коментар: \(state.comment)")
                
                return .send(.dismiss)
                
            case .dismiss:
                return .none
        }
    }
}
