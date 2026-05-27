import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject {

    // MARK: - Public

    @Published var canUseLocation = false
    @Published var location: CLLocationCoordinate2D?

    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - Overrides

    override init() {
        super.init()
        locationManager.delegate = self
    }

    // MARK: - Private

    private let locationManager = CLLocationManager()
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        canUseLocation = (manager.authorizationStatus == .authorizedWhenInUse)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        location = coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        Logger.logError(error)
    }
}
