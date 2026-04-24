struct MapPreviews {

    static var viewModel: MapViewModel {
        MapViewModel(listPath: .constant([]),
                     dataStore: MapRepository(controller: .shared),
                     notificationCenter: .default)
    }
}
