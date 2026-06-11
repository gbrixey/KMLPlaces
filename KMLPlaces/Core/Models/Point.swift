import SwiftData
import CoreLocation

@Model
class Point {
    /// Index is needed to keep the points in a `LineString` or `Polygon`
    /// in the correct order when stored and fetched later.
    var index: Int?
    var latitude: Double
    var longitude: Double

    @Relationship(deleteRule: .cascade) var placemark: Placemark?
    @Relationship(deleteRule: .cascade) var lineString: LineString?
    @Relationship(deleteRule: .cascade) var polygon: Polygon?

    init(
        index: Int? = nil,
        latitude: Double,
        longitude: Double,
        placemark: Placemark? = nil,
        lineString: LineString? = nil,
        polygon: Polygon? = nil
    ) {
        self.index = index
        self.latitude = latitude
        self.longitude = longitude
        self.placemark = placemark
        self.lineString = lineString
        self.polygon = polygon
    }
}

// MARK: - Convenience

extension Point {

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
