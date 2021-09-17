import SwiftUI

@main
struct KMLPlacesApp: App {
    @UIApplicationDelegateAdaptor(KMLPlacesAppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
