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
                print("   - Distance: \(workout.distance ?? 0) м")
                state.workout = workout
                state.isLoading = false
                return .none
                
            case let .loadError(error):
                state.errorMessage = error
                state.isLoading = false
                return .none
                
            case .editWorkout:
                print("📝 WorkoutDetailFeature: editWorkout - показую EditWorkoutView")
                state.isShowingEditSheet = true
                return .none
                
            case .showEditSheet:
                print("📝 WorkoutDetailFeature: showEditSheet - показую EditWorkoutView")
                state.isShowingEditSheet = true
                return .none
                
            case .hideEditSheet:
                print("📝 WorkoutDetailFeature: hideEditSheet - приховую EditWorkoutView")
                state.isShowingEditSheet = false
                return .none
                
            case let .updateWorkout(updatedWorkout):
                print("🔄 WorkoutDetailFeature: Оновлюю тренування:")
                print("   - ID: \(updatedWorkout.id)")
                print("   - Distance: \(updatedWorkout.distance ?? 0) м")
                state.workout = updatedWorkout
                state.isShowingEditSheet = false
                return CoreDataEffects.updateDay(updatedWorkout)
                    .map { _ in 
                        print("✅ WorkoutDetailFeature: Тренування оновлено в БД, відправляю workoutUpdated")
                        return .workoutUpdated 
                    }
                
            case .workoutUpdated:
                print("📤 WorkoutDetailFeature: Відправляю notifyWorkoutUpdated")
                return .send(.notifyWorkoutUpdated)
                
            case .notifyWorkoutUpdated:
                print("📤 WorkoutDetailFeature: notifyWorkoutUpdated отримано, передаю в AppFeature")
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
                print("🗑️ WorkoutDetailFeature: Підтверджую видалення тренування:")
                print("   - ID: \(workout.id)")
                print("   - SportType: \(workout.sportType.rawValue)")
                state.isShowingDeleteAlert = false
                return CoreDataEffects.deleteDay(workout)
                    .map { _ in 
                        print("✅ WorkoutDetailFeature: Тренування видалено з БД, відправляю workoutDeleted")
                        return .workoutDeleted 
                    }
                
            case .workoutDeleted:
                print("📤 WorkoutDetailFeature: Відправляю notifyWorkoutDeleted")
                // Повідомляємо про видалення, щоб оновити список
                return .send(.notifyWorkoutDeleted)
                
            case .notifyWorkoutDeleted:
                print("📤 WorkoutDetailFeature: notifyWorkoutDeleted отримано, передаю в AppFeature")
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

