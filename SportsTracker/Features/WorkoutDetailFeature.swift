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
        case deleteWorkout
        case showDeleteAlert
        case hideDeleteAlert
        case confirmDelete
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
                
                return .run { send in
                    do {
                        let context = await MainActor.run { PersistenceController.shared.container.viewContext }
                        let request = NSFetchRequest<DayEntity>(entityName: "DayEntity")
                        request.predicate = NSPredicate(format: "id == %@", updatedWorkout.id as CVarArg)
                        
                        if let entity = try context.fetch(request).first {
                            print("✅ WorkoutDetailFeature: Знайдено entity для оновлення")
                            entity.distance = updatedWorkout.distance ?? 0
                            entity.comment = updatedWorkout.comment
                            entity.calories = Int32(updatedWorkout.calories ?? 0)
                            entity.steps = Int32(updatedWorkout.steps ?? 0)
                            
                            try context.save()
                            print("✅ WorkoutDetailFeature: Успішно оновлено тренування в Core Data")
                            await send(.notifyWorkoutUpdated)
                        } else {
                            print("❌ WorkoutDetailFeature: Тренування з ID \(updatedWorkout.id) не знайдено")
                        }
                    } catch {
                        print("❌ WorkoutDetailFeature: Помилка оновлення: \(error)")
                    }
                }
                
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
                guard let workout = state.workout else { 
                    print("❌ WorkoutDetailFeature: confirmDelete - workout is nil")
                    return .none 
                }
                print("🗑️ WorkoutDetailFeature: Підтверджую видалення тренування:")
                print("   - ID: \(workout.id)")
                print("   - SportType: \(workout.sportType.rawValue)")
                state.isShowingDeleteAlert = false
                
                // Просто видаляємо з Core Data і відправляємо повідомлення
                return .run { send in
                    do {
                        let context = await MainActor.run { PersistenceController.shared.container.viewContext }
                        let request = NSFetchRequest<DayEntity>(entityName: "DayEntity")
                        request.predicate = NSPredicate(format: "id == %@", workout.id as CVarArg)
                        
                        if let entity = try context.fetch(request).first {
                            print("✅ WorkoutDetailFeature: Знайдено entity для видалення")
                            context.delete(entity)
                            try context.save()
                            print("✅ WorkoutDetailFeature: Успішно видалено тренування з Core Data")
                            await send(.notifyWorkoutDeleted)
                        } else {
                            print("❌ WorkoutDetailFeature: Тренування з ID \(workout.id) не знайдено")
                        }
                    } catch {
                        print("❌ WorkoutDetailFeature: Помилка видалення: \(error)")
                    }
                }
                
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

