import CoreData

class ListRepository {

    // MARK: - Public

    init(controller: PersistenceController) {
        self.controller = controller
    }

    // MARK: - Private

    private let controller: PersistenceController
}

// MARK: - ListDataStore

extension ListRepository: ListDataStore {

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
}
