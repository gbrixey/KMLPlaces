protocol ListDataStore {
    func fetchRootFolder() -> Folder?
}

class ListModule {

    class func build(folder: Folder? = nil) -> ListView {
        let dataStore = ListRepository(controller: .shared)
        let viewModel = ListViewModel(folder: folder,
                                      dataStore: dataStore,
                                      notificationCenter: .default)
        return ListView(viewModel: viewModel)
    }
}
