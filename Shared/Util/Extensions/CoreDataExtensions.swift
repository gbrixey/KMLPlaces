import CoreLocation
import CoreData

extension Folder {

    var isRootFolder: Bool {
        return parentFolder == nil
    }

    var subfoldersArray: [Folder] {
        return (subfolders?.array as? [Folder]) ?? []
    }

    var placesArray: [Placemark] {
        return (places?.array as? [Placemark]) ?? []
    }
}

extension Placemark {

    enum PlacemarkType {
        case point
        case lineString
        case polygon
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

    var type: PlacemarkType {
        if polygon != nil {
            return .polygon
        } else if lineString != nil {
            return .lineString
        } else {
            return .point
        }
    }
}

extension Point {

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension LineString {

    var coordinates: [CLLocationCoordinate2D] {
        points?.compactMap { ($0 as? Point)?.coordinate } ?? []
    }
}

extension Polygon {

    var coordinates: [CLLocationCoordinate2D] {
        outerBoundary?.points?.compactMap { ($0 as? Point)?.coordinate } ?? []
    }
}
