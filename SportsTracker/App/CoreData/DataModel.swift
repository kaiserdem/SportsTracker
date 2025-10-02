import Foundation
import CoreData

// MARK: - Core Data Stack

class DataModel {
    static let shared = DataModel()
    
    lazy var persistentContainer: NSPersistentContainer = {
        // Створюємо модель програмно
        let model = createDataModel()
        let container = NSPersistentContainer(name: "SportsTrackerModel", managedObjectModel: model)
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    private func createDataModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // DayEntity
        let dayEntity = NSEntityDescription()
        dayEntity.name = "DayEntity"
        dayEntity.managedObjectClassName = "DayEntity"
        
        // Атрибути для DayEntity
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false
        
        let dateAttribute = NSAttributeDescription()
        dateAttribute.name = "date"
        dateAttribute.attributeType = .dateAttributeType
        dateAttribute.isOptional = false
        
        let sportTypeAttribute = NSAttributeDescription()
        sportTypeAttribute.name = "sportType"
        sportTypeAttribute.attributeType = .stringAttributeType
        sportTypeAttribute.isOptional = false
        
        let commentAttribute = NSAttributeDescription()
        commentAttribute.name = "comment"
        commentAttribute.attributeType = .stringAttributeType
        commentAttribute.isOptional = true
        
        let durationAttribute = NSAttributeDescription()
        durationAttribute.name = "duration"
        durationAttribute.attributeType = .doubleAttributeType
        durationAttribute.isOptional = false
        
        let stepsAttribute = NSAttributeDescription()
        stepsAttribute.name = "steps"
        stepsAttribute.attributeType = .integer32AttributeType
        stepsAttribute.isOptional = true
        
        let caloriesAttribute = NSAttributeDescription()
        caloriesAttribute.name = "calories"
        caloriesAttribute.attributeType = .integer32AttributeType
        caloriesAttribute.isOptional = true
        
        let distanceAttribute = NSAttributeDescription()
        distanceAttribute.name = "distance"
        distanceAttribute.attributeType = .doubleAttributeType
        distanceAttribute.isOptional = true
        
        dayEntity.properties = [
            idAttribute,
            dateAttribute,
            sportTypeAttribute,
            commentAttribute,
            durationAttribute,
            stepsAttribute,
            caloriesAttribute,
            distanceAttribute
        ]
        
        // SupplementEntity
        let supplementEntity = NSEntityDescription()
        supplementEntity.name = "SupplementEntity"
        supplementEntity.managedObjectClassName = "SupplementEntity"
        
        // Атрибути для SupplementEntity
        let supplementIdAttribute = NSAttributeDescription()
        supplementIdAttribute.name = "id"
        supplementIdAttribute.attributeType = .UUIDAttributeType
        supplementIdAttribute.isOptional = false
        
        let nameAttribute = NSAttributeDescription()
        nameAttribute.name = "name"
        nameAttribute.attributeType = .stringAttributeType
        nameAttribute.isOptional = false
        
        let amountAttribute = NSAttributeDescription()
        amountAttribute.name = "amount"
        amountAttribute.attributeType = .stringAttributeType
        amountAttribute.isOptional = false
        
        let timeAttribute = NSAttributeDescription()
        timeAttribute.name = "time"
        timeAttribute.attributeType = .stringAttributeType
        timeAttribute.isOptional = false
        
        supplementEntity.properties = [
            supplementIdAttribute,
            nameAttribute,
            amountAttribute,
            timeAttribute
        ]
        
        // Зв'язки
        let supplementsRelationship = NSRelationshipDescription()
        supplementsRelationship.name = "supplements"
        supplementsRelationship.destinationEntity = supplementEntity
        supplementsRelationship.maxCount = 0 // one-to-many
        supplementsRelationship.deleteRule = .cascadeDeleteRule
        
        let dayRelationship = NSRelationshipDescription()
        dayRelationship.name = "day"
        dayRelationship.destinationEntity = dayEntity
        dayRelationship.maxCount = 1 // many-to-one
        dayRelationship.deleteRule = .nullifyDeleteRule
        
        // Додаємо зв'язки
        dayEntity.properties.append(supplementsRelationship)
        supplementEntity.properties.append(dayRelationship)
        
        // Встановлюємо зворотні зв'язки
        supplementsRelationship.inverseRelationship = dayRelationship
        dayRelationship.inverseRelationship = supplementsRelationship
        
        model.entities = [dayEntity, supplementEntity]
        return model
    }
    
    func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// MARK: - NSManagedObject Extensions

@objc(DayEntity)
public class DayEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var sportType: String
    @NSManaged public var comment: String?
    @NSManaged public var duration: Double
    @NSManaged public var steps: Int32
    @NSManaged public var calories: Int32
    @NSManaged public var distance: Double
    @NSManaged public var supplements: NSSet?
}

@objc(SupplementEntity)
public class SupplementEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var amount: String
    @NSManaged public var time: String
    @NSManaged public var day: DayEntity?
}

// MARK: - Core Data Generated accessors for DayEntity

extension DayEntity {
    @objc(addSupplementsObject:)
    @NSManaged public func addToSupplements(_ value: SupplementEntity)
    
    @objc(removeSupplementsObject:)
    @NSManaged public func removeFromSupplements(_ value: SupplementEntity)
    
    @objc(addSupplements:)
    @NSManaged public func addToSupplements(_ values: NSSet)
    
    @objc(removeSupplements:)
    @NSManaged public func removeFromSupplements(_ values: NSSet)
}

// MARK: - Core Data Generated accessors for SupplementEntity

extension SupplementEntity {
    @objc(addDayObject:)
    @NSManaged public func addToDay(_ value: DayEntity)
    
    @objc(removeDayObject:)
    @NSManaged public func removeFromDay(_ value: DayEntity)
}
