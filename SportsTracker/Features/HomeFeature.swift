import ComposableArchitecture
import Foundation
import CoreData

struct HomeFeature: Reducer {
    struct State: Equatable {
        var welcomeMessage = "Welcome to SportsTracker!"
        var recentDays: [Day] = []
        var allDays: [Day] = [] // Всі події для календаря
        var isLoading = false
        var workout = WorkoutFeature.State()
        var addActivity = AddActivityFeature.State()
        var isShowingAddActivity = false
    }
    
    enum Action: Equatable {
        case onAppear
        case loadRecentActivities
        case daysLoaded([Day])
        case saveDay(Day)
        case deleteDay(Day)
        case updateDay(Day)
        case coreDataError(CoreDataError)
        case workout(WorkoutFeature.Action)
        case showWorkoutDetail(UUID)
        case showAddActivity
        case showStatistics
        case addActivity(AddActivityFeature.Action)
        case dismissAddActivity
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.workout, action: /Action.workout) {
            WorkoutFeature()
        }
        
        Scope(state: \.addActivity, action: /Action.addActivity) {
            AddActivityFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadRecentActivities)
                
            case .loadRecentActivities:
                print("🔄 HomeFeature: Завантажую останні активності...")
                state.isLoading = true
                return CoreDataEffects.fetchDays()
                    .map(Action.daysLoaded)
                
            case let .daysLoaded(days):
                print("📋 HomeFeature: Завантажено \(days.count) тренувань:")
                
                // Зберігаємо всі події для календаря
                state.allDays = days
                
                // Фільтруємо тільки минулі та сьогоднішні активності для списку
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let filteredDays = days.filter { day in
                    let dayDate = calendar.startOfDay(for: day.date)
                    return dayDate <= today
                }
                
                print("📋 HomeFeature: Після фільтрації залишилось \(filteredDays.count) тренувань:")
                for (index, day) in filteredDays.enumerated() {
                    print("   \(index + 1). ID: \(day.id)")
                    print("      SportType: '\(day.sportType.rawValue)'")
                    print("      Date: \(day.date)")
                    print("      Duration: \(day.duration)")
                    print("      Comment: \(day.comment ?? "nil")")
                    print("      Steps: \(day.steps ?? 0)")
                    print("      Calories: \(day.calories ?? 0)")
                    print("      Distance: \(day.distance ?? 0) м")
                }
                state.recentDays = filteredDays
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
                        print("✅ HomeFeature: Успішно збережено тренування")
                        await send(.loadRecentActivities)
                    } catch {
                        print("❌ HomeFeature: Помилка збереження: \(error)")
                    }
                }
                
            case let .deleteDay(day):
                return CoreDataEffects.deleteDay(day)
                    .map { _ in .loadRecentActivities }
                
            case let .updateDay(day):
                return CoreDataEffects.updateDay(day)
                    .map { _ in .loadRecentActivities }
                
            case let .coreDataError(error):
                state.isLoading = false
                // Тут можна додати обробку помилок
                print("Core Data Error: \(error)")
                return .none
                
            case .workout(.notifyWorkoutCompleted):
                print("🔄 HomeFeature: Отримав повідомлення про завершення тренування, оновлюю список")
                return .send(.loadRecentActivities)
                
            case .workout:
                return .none
                
            case let .showWorkoutDetail(workoutId):
                // Передаємо дію вгору до AppFeature
                print("📤 HomeFeature: Передаю showWorkoutDetail з ID: \(workoutId)")
                return .none
                
            case .showAddActivity:
                state.isShowingAddActivity = true
                return .none
                
            case .showStatistics:
                print("📤 HomeFeature: Показую статистику")
                return .none
                
            case .addActivity(.dismiss), .dismissAddActivity:
                state.isShowingAddActivity = false
                return .none
                
            case .addActivity(.saveActivity):
                // Створюємо новий Day з даних форми
                let calendar = Calendar.current
                let combinedDate = calendar.date(bySettingHour: calendar.component(.hour, from: state.addActivity.startTime),
                                               minute: calendar.component(.minute, from: state.addActivity.startTime),
                                               second: 0,
                                               of: state.addActivity.selectedDate) ?? state.addActivity.selectedDate
                
                let newDay = Day(
                    date: combinedDate,
                    sportType: state.addActivity.selectedSportType,
                    comment: state.addActivity.comment.isEmpty ? nil : state.addActivity.comment,
                    duration: state.addActivity.calculatedDurationInSeconds,
                    distance: state.addActivity.calculatedDistanceInMeters > 0 ? state.addActivity.calculatedDistanceInMeters : nil,
                    steps: nil,
                    calories: state.addActivity.calories,
                    supplements: nil
                )
                
                print("💾 HomeFeature: Створюю нову активність:")
                print("   Спорт: \(newDay.sportType.rawValue)")
                print("   Дата: \(newDay.date)")
                print("   Тривалість: \(newDay.duration) секунд")
                print("   Дистанція: \(newDay.distance ?? 0) метрів")
                print("   Калорії: \(newDay.calories ?? 0)")
                
                state.isShowingAddActivity = false
                return .send(.saveDay(newDay))
                
            case .addActivity:
                return .none
            }
        }
    }
}

// Використовуємо модель Day замість Activity
