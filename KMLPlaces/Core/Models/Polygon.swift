import SwiftData
import CoreLocation

@Model
class Polygon {
    @Relationship(deleteRule: .cascade) var placemark: Placemark
    @Relationship(deleteRule: .cascade, inverse: \Point.polygon) var points: [Point] = []

    init(placemark: Placemark, points: [Point]) {
        self.placemark = placemark
        self.points = points
    }
}

// MARK: - Convenience

extension Polygon {

    var coordinates: [CLLocationCoordinate2D] {
        points.sorted(using: SortDescriptor(\Point.index)).map { $0.coordinate }
    }
}
