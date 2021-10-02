import CoreLocation

extension CLLocationCoordinate2D {

    static var zero: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
}

extension CLLocationCoordinate2D: Equatable {

    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
