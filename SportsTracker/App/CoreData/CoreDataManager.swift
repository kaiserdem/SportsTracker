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
                } catch {
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
                    let context = await MainActor.run { PersistenceController.shared.container.viewContext }
                    let request = NSFetchRequest<DayEntity>(entityName: "DayEntity")
                    request.predicate = NSPredicate(format: "id == %@", day.id as CVarArg)
                    
                    if let entity = try context.fetch(request).first {
                        context.delete(entity)
                        try context.save()
                    } else {
                        await send(.deleteError("Day not found"))
                    }
                } catch {
                    await send(.deleteError(error.localizedDescription))
                }
            }
        },
        
        updateDay: { day in
            .run { send in
                do {
                    let context = await MainActor.run { PersistenceController.shared.container.viewContext }
                    let request = NSFetchRequest<DayEntity>(entityName: "DayEntity")
                    request.predicate = NSPredicate(format: "id == %@", day.id as CVarArg)
                    
                    if let entity = try context.fetch(request).first {
                        entity.date = day.date
                        entity.sportType = day.sportType.rawValue
                        entity.comment = day.comment
                        entity.duration = day.duration
                        entity.steps = Int32(day.steps ?? 0)
                        entity.calories = Int32(day.calories ?? 0)
                        
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
                    } else {
                        await send(.updateError("Day not found"))
                    }
                } catch {
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

extension DependencyValues {
    var coreDataManager: CoreDataManager {
        get { self[CoreDataManager.self] }
        set { self[CoreDataManager.self] = newValue }
    }
}
