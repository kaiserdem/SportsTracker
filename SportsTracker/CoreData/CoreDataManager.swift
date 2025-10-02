import Foundation
import CoreData
import ComposableArchitecture

struct CoreDataManager {
    var saveDay: (Day) -> Effect<CoreDataError>
    var fetchDays: () -> Effect<[Day]>
    var deleteDay: (Day) -> Effect<CoreDataError>
    var updateDay: (Day) -> Effect<CoreDataError>
    var fetchDaysInRange: (Date, Date) -> Effect<[Day]>
    var fetchDaysBySportType: (SportType) -> Effect<[Day]>
    var fetchDayById: (UUID) -> Effect<Day>
}

enum CoreDataError: Error, Equatable {
    case saveError(String)
    case fetchError(String)
    case deleteError(String)
    case updateError(String)
    case contextError(String)
}

extension CoreDataManager: DependencyKey {
    static let liveValue = CoreDataManager(
        saveDay: { day in
            .run { send in
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
                    
                    // Додаємо додатки
                    if let supplements = day.supplements {
                        for supplement in supplements {
                            let supplementEntity = SupplementEntity(context: context)
                            supplementEntity.id = supplement.id
                            supplementEntity.name = supplement.name
                            supplementEntity.amount = supplement.amount
                            supplementEntity.time = supplement.time
                            supplementEntity.day = dayEntity
                        }
                    }
                    
                    try context.save()
                    print("✅ CoreDataManager: Успішно збережено тренування")
                } catch {
                    print("❌ CoreDataManager: Помилка збереження: \(error)")
                    await send(.saveError(error.localizedDescription))
                }
            }
        },
        
        fetchDays: {
            .run { send in
                do {
                    let context = await MainActor.run { PersistenceController.shared.container.viewContext }
                    let request = NSFetchRequest<DayEntity>(entityName: "DayEntity")
                    request.sortDescriptors = [NSSortDescriptor(keyPath: \DayEntity.date, ascending: false)]
                    
                    let entities = try context.fetch(request)
                    let days = await withTaskGroup(of: Day?.self) { group in
                        var results: [Day] = []
                        
                        for entity in entities {
                            let entityId = entity.objectID
                            group.addTask { @Sendable in
                                return await MainActor.run {
                                    let context = PersistenceController.shared.container.viewContext
                                    guard let entity = try? context.existingObject(with: entityId) as? DayEntity else {
                                        return nil
                                    }
                                    return Self.convertEntityToDay(entity)
                                }
                            }
                        }
                        
                        for await result in group {
                            if let day = result {
                                results.append(day)
                            }
                        }
                        
                        return results
                    }
                    
                    await send(days)
                } catch {
                    // Для fetchDays не повертаємо помилку, повертаємо порожній масив
                    await send([])
                }
            }
        },
        
        deleteDay: { day in
            .run { send in
                do {
                    print("🗑️ CoreDataManager: Видаляю тренування:")
                    print("   - ID: \(day.id)")
                    print("   - SportType: \(day.sportType.rawValue)")
                    
                    let context = await MainActor.run { PersistenceController.shared.container.viewContext }
                    let request = NSFetchRequest<DayEntity>(entityName: "DayEntity")
                    request.predicate = NSPredicate(format: "id == %@", day.id as CVarArg)
                    
                    if let entity = try context.fetch(request).first {
                        print("✅ CoreDataManager: Знайдено entity для видалення")
                        context.delete(entity)
                        try context.save()
                        print("✅ CoreDataManager: Успішно видалено тренування з Core Data")
                        print("✅ CoreDataManager: Ефект завершується успішно")
                        // Ефект завершується успішно автоматично
                    } else {
                        print("❌ CoreDataManager: Тренування з ID \(day.id) не знайдено для видалення")
                        await send(.deleteError("Day not found"))
                    }
                } catch {
                    print("❌ CoreDataManager: Помилка видалення тренування: \(error)")
                    await send(.deleteError(error.localizedDescription))
                }
            }
        },
        
        updateDay: { day in
            .run { send in
                do {
                    print("🔄 CoreDataManager: Оновлюю тренування:")
                    print("   - ID: \(day.id)")
                    print("   - SportType: '\(day.sportType.rawValue)'")
                    print("   - Date: \(day.date)")
                    print("   - Duration: \(day.duration)")
                    print("   - Comment: \(day.comment ?? "nil")")
                    print("   - Steps: \(day.steps ?? 0)")
                    print("   - Calories: \(day.calories ?? 0)")
                    print("   - Distance: \(day.distance ?? 0) м")
                    
                    let context = await MainActor.run { PersistenceController.shared.container.viewContext }
                    let request = NSFetchRequest<DayEntity>(entityName: "DayEntity")
                    request.predicate = NSPredicate(format: "id == %@", day.id as CVarArg)
                    
                    if let entity = try context.fetch(request).first {
                        print("✅ CoreDataManager: Знайдено entity для оновлення")
                        entity.date = day.date
                        entity.sportType = day.sportType.rawValue
                        entity.comment = day.comment
                        entity.duration = day.duration
                        entity.steps = Int32(day.steps ?? 0)
                        entity.calories = Int32(day.calories ?? 0)
                        entity.distance = day.distance ?? 0
                        print("✅ CoreDataManager: Оновлено entity з новими даними")
                        
                        // Видаляємо старі додатки
                        if let supplements = entity.supplements {
                            for supplement in supplements {
                                if let supplementEntity = supplement as? SupplementEntity {
                                    context.delete(supplementEntity)
                                }
                            }
                        }
                        
                        // Додаємо нові додатки
                        if let supplements = day.supplements {
                            for supplement in supplements {
                                let supplementEntity = SupplementEntity(context: context)
                                supplementEntity.id = supplement.id
                                supplementEntity.name = supplement.name
                                supplementEntity.amount = supplement.amount
                                supplementEntity.time = supplement.time
                                supplementEntity.day = entity
                            }
                        }
                        
                        try context.save()
                        print("✅ CoreDataManager: Успішно збережено оновлення в Core Data")
                    } else {
                        print("❌ CoreDataManager: Тренування з ID \(day.id) не знайдено для оновлення")
                        await send(.updateError("Day not found"))
                    }
                } catch {
                    print("❌ CoreDataManager: Помилка оновлення тренування: \(error)")
                    await send(.updateError(error.localizedDescription))
                }
            }
        },
        
        fetchDaysInRange: { startDate, endDate in
            .run { send in
                do {
                    let context = await MainActor.run { PersistenceController.shared.container.viewContext }
                    let request = NSFetchRequest<DayEntity>(entityName: "DayEntity")
                    request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
                    request.sortDescriptors = [NSSortDescriptor(keyPath: \DayEntity.date, ascending: false)]
                    
                    let entities = try context.fetch(request)
                    let days = await withTaskGroup(of: Day?.self) { group in
                        var results: [Day] = []
                        
                        for entity in entities {
                            let entityId = entity.objectID
                            group.addTask { @Sendable in
                                return await MainActor.run {
                                    let context = PersistenceController.shared.container.viewContext
                                    guard let entity = try? context.existingObject(with: entityId) as? DayEntity else {
                                        return nil
                                    }
                                    return Self.convertEntityToDay(entity)
                                }
                            }
                        }
                        
                        for await result in group {
                            if let day = result {
                                results.append(day)
                            }
                        }
                        
                        return results
                    }
                    
                    await send(days)
                } catch {
                    await send([])
                }
            }
        },
        
        fetchDaysBySportType: { sportType in
            .run { send in
                do {
                    let context = await MainActor.run { PersistenceController.shared.container.viewContext }
                    let request = NSFetchRequest<DayEntity>(entityName: "DayEntity")
                    request.predicate = NSPredicate(format: "sportType == %@", sportType.rawValue)
                    request.sortDescriptors = [NSSortDescriptor(keyPath: \DayEntity.date, ascending: false)]
                    
                    let entities = try context.fetch(request)
                    let days = await withTaskGroup(of: Day?.self) { group in
                        var results: [Day] = []
                        
                        for entity in entities {
                            let entityId = entity.objectID
                            group.addTask { @Sendable in
                                return await MainActor.run {
                                    let context = PersistenceController.shared.container.viewContext
                                    guard let entity = try? context.existingObject(with: entityId) as? DayEntity else {
                                        return nil
                                    }
                                    return Self.convertEntityToDay(entity)
                                }
                            }
                        }
                        
                        for await result in group {
                            if let day = result {
                                results.append(day)
                            }
                        }
                        
                        return results
                    }
                    
                    await send(days)
                } catch {
                    await send([])
                }
            }
        },
        
        fetchDayById: { id in
            .run { send in
                do {
                    let context = await MainActor.run { PersistenceController.shared.container.viewContext }
                    let request = NSFetchRequest<DayEntity>(entityName: "DayEntity")
                    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                    request.fetchLimit = 1
                    
                    let entities = try context.fetch(request)
                    if let entity = entities.first {
                        print("🔍 CoreDataManager: Знайдено тренування в БД:")
                        print("   - Entity ID: \(entity.id)")
                        print("   - Entity SportType: '\(entity.sportType)'")
                        print("   - Entity Date: \(entity.date)")
                        print("   - Entity Duration: \(entity.duration)")
                        print("   - Entity Comment: \(entity.comment ?? "nil")")
                        print("   - Entity Steps: \(entity.steps)")
                        print("   - Entity Calories: \(entity.calories)")
                        print("   - Entity Distance: \(entity.distance)")
                        
                        if let day = Self.convertEntityToDay(entity) {
                            print("✅ CoreDataManager: Конвертовано в Day:")
                            print("   - Day ID: \(day.id)")
                            print("   - Day SportType: '\(day.sportType.rawValue)'")
                            print("   - Day Date: \(day.date)")
                            print("   - Day Duration: \(day.duration)")
                            print("   - Day Comment: \(day.comment ?? "nil")")
                            print("   - Day Steps: \(day.steps ?? 0)")
                            print("   - Day Calories: \(day.calories ?? 0)")
                            print("   - Day Distance: \(day.distance ?? 0) м")
                            await send(day)
                        } else {
                            print("❌ CoreDataManager: Не вдалося конвертувати entity в Day")
                            // Повертаємо пустий Day як fallback
                            let fallbackDay = Day(
                                id: id,
                                date: Date(),
                                sportType: .hiking,
                                comment: nil,
                                duration: 0,
                                distance: nil,
                                steps: nil,
                                calories: nil,
                                supplements: nil
                            )
                            await send(fallbackDay)
                        }
                    } else {
                        print("❌ CoreDataManager: Тренування з ID \(id) не знайдено в БД")
                        // Повертаємо пустий Day як fallback
                        let fallbackDay = Day(
                            id: id,
                            date: Date(),
                            sportType: .hiking,
                            comment: nil,
                            duration: 0,
                            distance: nil,
                            steps: nil,
                            calories: nil,
                            supplements: nil
                        )
                        await send(fallbackDay)
                    }
                } catch {
                    print("❌ CoreDataManager: Помилка завантаження тренування: \(error)")
                    // Повертаємо пустий Day як fallback
                    let fallbackDay = Day(
                        id: id,
                        date: Date(),
                        sportType: .hiking,
                        comment: nil,
                        duration: 0,
                        distance: nil,
                        steps: nil,
                        calories: nil,
                        supplements: nil
                    )
                    await send(fallbackDay)
                }
            }
        }
    )
    
    // MARK: - Helper Methods
    
    private static func convertEntityToDay(_ entity: DayEntity) -> Day? {
        guard let sportType = SportType(rawValue: entity.sportType) else { return nil }
        
        let supplements = entity.supplements?.compactMap { (supplementEntity: Any) -> Supplement? in
            guard let supplement = supplementEntity as? SupplementEntity else { return nil }
            return Supplement(
                name: supplement.name,
                amount: supplement.amount,
                time: supplement.time
            )
        }
        
        return Day(
            id: entity.id,
            date: entity.date,
            sportType: sportType,
            comment: entity.comment,
            duration: entity.duration,
            distance: entity.distance > 0 ? entity.distance : nil,
            steps: entity.steps > 0 ? Int(entity.steps) : nil,
            calories: entity.calories > 0 ? Int(entity.calories) : nil,
            supplements: supplements
        )
    }
}

extension DependencyValues {
    var coreDataManager: CoreDataManager {
        get { self[CoreDataManager.self] }
        set { self[CoreDataManager.self] = newValue }
    }
}
