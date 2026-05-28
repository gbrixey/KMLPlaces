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

    var flattenedSubfoldersArray: [Folder] {
        subfoldersArray.reduce(subfoldersArray, { $0 + $1.flattenedSubfoldersArray })
    }

    var flattenedPlacesArray: [Placemark] {
        subfoldersArray.reduce(placesArray, { $0 + $1.flattenedPlacesArray })
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

extension Array where Element == Folder {

    var sortedByName: [Element] {
        sorted { folder1, folder2 in
            let name1 = folder1.name ?? ""
            let name2 = folder2.name ?? ""
            return name1.compare(name2, options: [.numeric, .caseInsensitive]) == .orderedAscending
        }
    }
}

extension Array where Element == Placemark {

    var sortedByName: [Element] {
        sorted { place1, place2 in
            let name1 = place1.name ?? ""
            let name2 = place2.name ?? ""
            return name1.compare(name2, options: [.numeric, .caseInsensitive]) == .orderedAscending
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
