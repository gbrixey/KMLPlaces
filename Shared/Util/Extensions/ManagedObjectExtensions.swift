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

    var coordinate: CLLocationCoordinate2D? {
        point?.coordinate
    }
}

extension Point {

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
