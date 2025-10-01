import Foundation
import ComposableArchitecture
import CoreData

struct WorkoutDetailFeature: Reducer {
    struct State: Equatable, Identifiable {
        let id = UUID()
        let workoutId: UUID
        var workout: Day?
        var isLoading = false
        var isShowingDeleteAlert = false
        var isShowingEditSheet = false
        var errorMessage: String?
    }
    
    enum Action: Equatable {
        case onAppear
        case workoutLoaded(Day)
        case loadError(String)
        case editWorkout
        case showEditSheet
        case hideEditSheet
        case updateWorkout(Day)
        case workoutUpdated
        case deleteWorkout
        case showDeleteAlert
        case hideDeleteAlert
        case confirmDelete
        case workoutDeleted
        case hideActiveWorkout
        case dismissError
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                print("🚀 WorkoutDetailFeature: onAppear з workoutId: \(state.workoutId)")
                state.isLoading = true
                return CoreDataEffects.fetchDayById(state.workoutId)
                    .map(Action.workoutLoaded)
                
            case let .workoutLoaded(workout):
                print("📊 WorkoutDetailFeature: Завантажено тренування: \(workout.sportType.rawValue)")
                state.workout = workout
                state.isLoading = false
                return .none
                
            case let .loadError(error):
                state.errorMessage = error
                state.isLoading = false
                return .none
                
            case .editWorkout:
                state.isShowingEditSheet = true
                return .none
                
            case .showEditSheet:
                state.isShowingEditSheet = true
                return .none
                
            case .hideEditSheet:
                state.isShowingEditSheet = false
                return .none
                
            case let .updateWorkout(updatedWorkout):
                state.workout = updatedWorkout
                state.isShowingEditSheet = false
                return CoreDataEffects.updateDay(updatedWorkout)
                    .map { _ in .workoutUpdated }
                
            case .workoutUpdated:
                return .none
                
            case .deleteWorkout:
                state.isShowingDeleteAlert = true
                return .none
                
            case .showDeleteAlert:
                state.isShowingDeleteAlert = true
                return .none
                
            case .hideDeleteAlert:
                state.isShowingDeleteAlert = false
                return .none
                
            case .confirmDelete:
                guard let workout = state.workout else { return .none }
                state.isShowingDeleteAlert = false
                return CoreDataEffects.deleteDay(workout)
                    .map { _ in .workoutDeleted }
                
            case .workoutDeleted:
                return .none
                
            case .hideActiveWorkout:
                return .none
                
            case .dismissError:
                state.errorMessage = nil
                return .none
            }
        }
    }
}

// MARK: - Core Data Effects Extension

extension CoreDataEffects {
    static func fetchDayById(_ id: UUID) -> Effect<Day> {
        @Dependency(\.coreDataManager) var coreDataManager
        return coreDataManager.fetchDayById(id)
    }
}

// MARK: - Core Data Manager Extension

extension CoreDataManager {
    var fetchDayById: (UUID) -> Effect<Day> {
        { id in
            .run { send in
                do {
                    let context = await MainActor.run { PersistenceController.shared.container.viewContext }
                    let request = NSFetchRequest<DayEntity>(entityName: "DayEntity")
                    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                    
                    let entities = try context.fetch(request)
                    if let entity = entities.first {
                        let entityId = entity.objectID
                        let day = await MainActor.run {
                            let context = PersistenceController.shared.container.viewContext
                            guard let entity = try? context.existingObject(with: entityId) as? DayEntity else {
                                return Day(
                                    date: Date(),
                                    sportType: .running,
                                    comment: nil,
                                    duration: 0,
                                    steps: nil,
                                    calories: nil,
                                    supplements: nil
                                )
                            }
                            return Self.convertEntityToDay(entity)
                        }
                        await send(day)
                    } else {
                        await send(Day(
                            date: Date(),
                            sportType: .running,
                            comment: nil,
                            duration: 0,
                            steps: nil,
                            calories: nil,
                            supplements: nil
                        ))
                    }
                } catch {
                    await send(Day(
                        date: Date(),
                        sportType: .running,
                        comment: nil,
                        duration: 0,
                        steps: nil,
                        calories: nil,
                        supplements: nil
                    ))
                }
            }
        }
    }
    
    private static func convertEntityToDay(_ entity: DayEntity) -> Day {
        guard let sportType = SportType(rawValue: entity.sportType) else {
            print("⚠️ WorkoutDetailFeature: Невідомий sportType: '\(entity.sportType)', використовую .hiking")
            return Day(
                date: entity.date,
                sportType: .hiking, // Використовуємо .hiking замість .running
                comment: entity.comment,
                duration: entity.duration,
                steps: entity.steps > 0 ? Int(entity.steps) : nil,
                calories: entity.calories > 0 ? Int(entity.calories) : nil,
                supplements: nil
            )
        }
        
        let supplements = entity.supplements?.compactMap { (supplementEntity: Any) -> Supplement? in
            guard let supplement = supplementEntity as? SupplementEntity else { return nil }
            return Supplement(
                name: supplement.name,
                amount: supplement.amount,
                time: supplement.time
            )
        }
        
        return Day(
            date: entity.date,
            sportType: sportType,
            comment: entity.comment,
            duration: entity.duration,
            steps: entity.steps > 0 ? Int(entity.steps) : nil,
            calories: entity.calories > 0 ? Int(entity.calories) : nil,
            supplements: supplements
        )
    }
}
