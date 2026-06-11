import Foundation
import SwiftData

class ListNavigationRepository {

    // MARK: - Public

    init(controller: PersistenceController) {
        self.controller = controller
    }

    // MARK: - Private

    private let controller: PersistenceController
}

// MARK: - ListNavigationDataStore

extension ListNavigationRepository: ListNavigationDataStore {

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
