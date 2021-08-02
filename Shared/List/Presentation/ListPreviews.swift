struct ListPreviews {

    static var viewModel: ListViewModel {
        let dataStore = ListRepository(controller: .preview)
        return ListViewModel(folder: nil, dataStore: dataStore, notificationCenter: .default)
    }
}
