import SwiftData
import CoreLocation

@Model
class Placemark {
    var name: String
    var kmlDescription: String
    var styleURL: String?

    @Relationship var folder: Folder
    @Relationship var point: Point?
    @Relationship var lineString: LineString?
    @Relationship var polygon: Polygon?

    init(
        name: String,
        kmlDescription: String,
        styleURL: String? = nil,
        folder: Folder,
        point: Point? = nil,
        lineString: LineString? = nil,
        polygon: Polygon? = nil
    ) {
        self.name = name
        self.kmlDescription = kmlDescription
        self.styleURL = styleURL
        self.folder = folder
        self.point = point
        self.lineString = lineString
        self.polygon = polygon
    }
}

// MARK: - Convenience

extension Placemark {

    enum PlacemarkType {
        case point
        case lineString
        case polygon
    }

    var type: PlacemarkType {
        if polygon != nil {
            return .polygon
        } else if lineString != nil {
            return .lineString
        } else {
            return .point
        }
    }

    /// Returns an array of all coordinates associated with this Placemark.
    var allCoordinates: [CLLocationCoordinate2D] {
        if let polygon = polygon {
            return polygon.coordinates
        } else if let lineString = lineString {
            return lineString.coordinates
        } else if let coordinate = point?.coordinate {
            return [coordinate]
        }
        return []
    }
}

extension Array where Element == Placemark {

    var sortedByName: [Element] {
        sorted { place1, place2 in
            place1.name < place2.name
        }
    }
}
