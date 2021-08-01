import SwiftUI

@main
struct KMLPlacesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
