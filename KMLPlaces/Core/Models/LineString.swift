import SwiftData
import CoreLocation

@Model
class LineString {
    var placemark: Placemark
    @Relationship(inverse: \Point.lineString) var points: [Point] = []

    init(placemark: Placemark) {
        self.placemark = placemark
    }
}

// MARK: - Convenience

extension LineString {

    var coordinates: [CLLocationCoordinate2D] {
        points.map { $0.coordinate }
    }
}
