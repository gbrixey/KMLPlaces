import SwiftData
import CoreLocation

@Model
class Polygon {
    var placemark: Placemark
    @Relationship(inverse: \Point.polygon) var points: [Point] = []

    init(placemark: Placemark) {
        self.placemark = placemark
    }
}

// MARK: - Convenience

extension Polygon {

    var coordinates: [CLLocationCoordinate2D] {
        points.map { $0.coordinate }
    }
}
