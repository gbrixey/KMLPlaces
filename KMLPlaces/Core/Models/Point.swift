import SwiftData
import CoreLocation

@Model
class Point {
    var latitude: Double
    var longitude: Double

    var placemark: Placemark?
    var lineString: LineString?
    var polygon: Polygon?

    init(
        latitude: Double,
        longitude: Double,
        placemark: Placemark? = nil,
        lineString: LineString? = nil,
        polygon: Polygon? = nil
    ) {
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
