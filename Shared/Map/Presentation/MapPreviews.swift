struct MapPreviews {

    static var viewModel: MapViewModel {
        MapViewModel(dataStore: MapRepository(controller: .shared),
                     notificationCenter: .default)
    }
}
