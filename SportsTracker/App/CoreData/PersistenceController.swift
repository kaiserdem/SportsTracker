import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // Використовуємо DataModel для створення контейнера
        let dataModel = DataModel.shared
        container = dataModel.persistentContainer
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Preview Helper
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Створюємо тестові дані для превью
        let sampleDay = DayEntity(context: viewContext)
        sampleDay.id = UUID()
        sampleDay.date = Date()
        sampleDay.sportType = SportType.running.rawValue
        sampleDay.comment = "Тестове тренування"
        sampleDay.duration = 2700
        sampleDay.steps = 6500
        sampleDay.calories = 320
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return result
    }()
}
