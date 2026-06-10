import MapKit

extension MKCoordinateRegion {

    var minLatitude: CLLocationDegrees { center.latitude - (span.latitudeDelta / 2.0) }
    var maxLatitude: CLLocationDegrees { center.latitude + (span.latitudeDelta / 2.0) }
    var minLongitude: CLLocationDegrees { center.longitude - (span.longitudeDelta / 2.0) }
    var maxLongitude: CLLocationDegrees { center.longitude + (span.longitudeDelta / 2.0) }

    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        (coordinate.latitude >= minLatitude &&
         coordinate.latitude <= maxLatitude &&
         coordinate.longitude >= minLongitude &&
         coordinate.longitude <= maxLongitude)
    }
}

extension MKPolygon {

    func contains(_ point: MKMapPoint) -> Bool {
        let vertices = self.points()
        var isInsidePolygon = false

        for i in 0..<pointCount {
            let vertex1 = vertices[i]
            let vertex2 = vertices[(i + 1) % pointCount]
            if ((vertex1.y <= point.y) && (vertex2.y > point.y) ||
                (vertex2.y <= point.y) && (vertex1.y > point.y))
            {
                let cross = (vertex2.x - vertex1.x) * (point.y - vertex1.y) / (vertex2.y - vertex1.y) + vertex1.x
                if cross < point.x {
                    isInsidePolygon = !isInsidePolygon
                }
            }
        }
        return isInsidePolygon
    }
}
