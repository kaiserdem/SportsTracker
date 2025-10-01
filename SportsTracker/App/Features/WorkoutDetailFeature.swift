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
        case notifyWorkoutDeleted
        case notifyWorkoutUpdated
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
                print("📊 WorkoutDetailFeature: Завантажено тренування:")
                print("   - ID: \(workout.id)")
                print("   - SportType: '\(workout.sportType.rawValue)'")
                print("   - Date: \(workout.date)")
                print("   - Duration: \(workout.duration)")
                print("   - Comment: \(workout.comment ?? "nil")")
                print("   - Steps: \(workout.steps ?? 0)")
                print("   - Calories: \(workout.calories ?? 0)")
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
                return .send(.notifyWorkoutUpdated)
                
            case .notifyWorkoutUpdated:
                // Ця дія буде оброблена в AppFeature
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
                // Повідомляємо про видалення, щоб оновити список
                return .send(.notifyWorkoutDeleted)
                
            case .notifyWorkoutDeleted:
                // Ця дія буде оброблена в AppFeature
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

