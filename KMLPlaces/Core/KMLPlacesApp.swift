import SwiftUI
import SwiftData

@main
struct KMLPlacesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootModule.build()
        }
        .modelContainer(persistenceController.modelContainer)
    }

    init() {
        UserDefaults.standard.registerDefaults()
        StyleManager.shared.loadStyles()
    }
}
