import CoreData

class MapRepository {

    // MARK: - Public

    init(controller: PersistenceController) {
        self.controller = controller
        self.locationManager = LocationManager()
    }

    // MARK: - Private

    private let controller: PersistenceController
    private let locationManager: LocationManager
}

// MARK: - MapDataStore

extension MapRepository: MapDataStore {

    func fetchRootFolder() -> Folder? {
        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "parentFolder = nil")
        do {
            let context = controller.context
            let fetchResults = try context.fetch(fetchRequest)
            return fetchResults.first
        } catch {
            Logger.logError(error)
            return nil
        }
    }

    func requestLocationAuthorization() {
        locationManager.requestLocationAuthorization()
    }
}
