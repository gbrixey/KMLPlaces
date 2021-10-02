import CoreLocation

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

    var coordinate: CLLocationCoordinate2D? {
        point?.coordinate
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
