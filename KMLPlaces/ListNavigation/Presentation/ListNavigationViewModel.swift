import SwiftUI
import CoreLocation

class ListNavigationViewModel: NSObject, ObservableObject {

    // MARK: - Public

    @Binding var path: [ListItem]
    @Published private(set) var rootFolder: Folder?
    @Published var shouldShowLocationButton: Bool
    @Published var isRequestingLocation = false
    @Published var shouldShowLocationPermissionDeniedAlert = false

    init(path: Binding<[ListItem]>,
         dataStore: ListNavigationDataStore,
         notificationCenter: NotificationCenter) {
        self._path = path
        self.dataStore = dataStore
        self.rootFolder = dataStore.fetchRootFolder()
        self.locationManager = CLLocationManager()
        self.shouldShowLocationButton = (locationManager.authorizationStatus != .restricted)
        super.init()
        self.locationManager.delegate = self
        notificationCenter.addObserver(self, selector: #selector(dataChanged), name: .dataChanged, object: nil)
    }

    func locationButtonTapped() {
        guard !isRequestingLocation else { return }
        isRequestingLocation = true
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            shouldShowLocationPermissionDeniedAlert = true
            isRequestingLocation = false
        }
    }

    func goToSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }

    // MARK: - Actions

    @objc private func dataChanged() {
        path.removeAll()
        rootFolder = dataStore.fetchRootFolder()
    }

    // MARK: - Private

    private let dataStore: ListNavigationDataStore
    private let locationManager: CLLocationManager

    /// - todo: Calculate distance to polygons and polylines
    private func filterPlacesByDistance(to userCoordinate: CLLocationCoordinate2D) {
        guard let places = rootFolder?.flattenedPlaces else { return }
        let placesWithDistance = places.compactMap { place -> PlacemarkWithDistance? in
            guard let placeCoordinate = place.point?.coordinate else { return nil }
            let distance = placeCoordinate.distance(from: userCoordinate)
            return PlacemarkWithDistance(placemark: place, distance: distance)
        }
            .sorted { $0.distance < $1.distance }
            .prefix(10)

        path.append(.nearbyPlaces(Array(placesWithDistance)))
    }
}

// MARK: - CLLocationManagerDelegate

extension ListNavigationViewModel: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard isRequestingLocation else { return }
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.requestLocation()
        } else {
            isRequestingLocation = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        filterPlacesByDistance(to: coordinate)
        isRequestingLocation = false
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        Logger.logError(error)
        isRequestingLocation = false
    }
}
