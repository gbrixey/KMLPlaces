import Foundation
import SwiftData

class MapRepository {

    // MARK: - Public

    init(controller: PersistenceController) {
        self.controller = controller
    }

    // MARK: - Private

    private let controller: PersistenceController
    private var userDefaults: UserDefaults { .standard }
}

// MARK: - MapDataStore

extension MapRepository: MapDataStore {

    var shouldShowPolygons: Bool {
        userDefaults.shouldShowPolygonsOnMap
    }

    var shouldShowPolylines: Bool {
        userDefaults.shouldShowPolylinesOnMap
    }

    func fetchRootFolder() -> Folder? {
        let predicate = #Predicate<Folder> { $0.parentFolder == nil }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        do {
            let rootFolder = try controller.modelContext.fetch(fetchDescriptor).first
            return rootFolder
        } catch {
            Logger.logError(error)
            return nil
        }
    }
}
