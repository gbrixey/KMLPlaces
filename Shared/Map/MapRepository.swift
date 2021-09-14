import CoreData

class MapRepository {

    // MARK: - Public

    init(controller: PersistenceController) {
        self.controller = controller
    }

    // MARK: - Private

    private let controller: PersistenceController
}

// MARK: - MapDataStore

extension MapRepository: MapDataStore {

    func fetchRootFolder() -> Folder? {
        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "parentFolder = nil")
        do {
            let context = PersistenceController.shared.context
            let fetchResults = try context.fetch(fetchRequest)
            return fetchResults.first
        } catch {
            Logger.logError(error)
            return nil
        }
    }
}
