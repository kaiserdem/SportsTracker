
import SwiftUI
import CoreData
import ComposableArchitecture

@main
struct SportsTrackerApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            AppView(store: Store(initialState: AppFeature.State()) {
                AppFeature()
            })
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
