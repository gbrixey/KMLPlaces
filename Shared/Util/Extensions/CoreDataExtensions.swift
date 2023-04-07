import CoreLocation
import CoreData

extension Folder {

    var isRootFolder: Bool {
        return parentFolder == nil
    }

    var subfoldersArray: [Folder] {
        return (subfolders?.allObjects as? [Folder]) ?? []
    }

    var placesArray: [Placemark] {
        return (places?.allObjects as? [Placemark]) ?? []
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
        switch type {
        case .point:
            guard let coordinate = point?.coordinate else { return [] }
            return [coordinate]
        case .lineString:
            guard let coordinatesString = lineString?.coordinates else { return [] }
            return KMLParser.parseCoordinates(coordinatesString)
        case .polygon:
            guard let coordinatesString = polygon?.outerBoundary?.coordinates else { return [] }
            return KMLParser.parseCoordinates(coordinatesString)
        }
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
