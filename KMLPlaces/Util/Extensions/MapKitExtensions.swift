import MapKit

extension MKCoordinateRegion {

    var minLatitude: CLLocationDegrees { center.latitude - (span.latitudeDelta / 2.0) }
    var maxLatitude: CLLocationDegrees { center.latitude + (span.latitudeDelta / 2.0) }
    var minLongitude: CLLocationDegrees { center.longitude - (span.longitudeDelta / 2.0) }
    var maxLongitude: CLLocationDegrees { center.longitude + (span.longitudeDelta / 2.0) }

    init(enclosingCoordinates coordinages: [CLLocationCoordinate2D]) {
        let allLatitudes = coordinages.map { $0.latitude }
        let allLongitudes = coordinages.map { $0.longitude }
        let minLatitude = allLatitudes.min()!
        let maxLatitude = allLatitudes.max()!
        let minLongitude = allLongitudes.min()!
        let maxLongitude = allLongitudes.max()!
        let center = CLLocationCoordinate2D(latitude: (minLatitude + maxLatitude) / 2,
                                            longitude: (minLongitude + maxLongitude) / 2)
        let paddingMultiplier = 1.2
        let span = MKCoordinateSpan(latitudeDelta: (maxLatitude - minLatitude) * paddingMultiplier,
                                    longitudeDelta: (maxLongitude - minLongitude) * paddingMultiplier)
        self.init(center: center, span: span)
    }

    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        (coordinate.latitude >= minLatitude &&
         coordinate.latitude <= maxLatitude &&
         coordinate.longitude >= minLongitude &&
         coordinate.longitude <= maxLongitude)
    }
}

extension MKMapPoint {

    /// - parameter inMeters: If this is false, the distance is returned in MKMapPoint units.
    func distanceToLineSegment(point1: MKMapPoint, point2: MKMapPoint, inMeters: Bool) -> Double {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y

        if dx == 0 && dy == 0 {
            return distance(to: point1)
        }

        // Calculate the t parameter (projection of target onto line segment)
        let t = ((x - point1.x) * dx + (y - point1.y) * dy) / (dx * dx + dy * dy)
        let clampedT = max(0, min(1, t))

        // Closest point on the segment
        let closestX = point1.x + clampedT * dx
        let closestY = point1.y + clampedT * dy
        let closestPoint = MKMapPoint(x: closestX, y: closestY)

        if inMeters {
            return distance(to: closestPoint)
        } else {
            return sqrt(powl(closestX - x, 2) + powl(closestY - y, 2))
        }
    }
}

extension MKPolygon {

    func distance(to point: MKMapPoint) -> Double {
        if contains(point) {
            return 0
        }
        var minDistance = Double.greatestFiniteMagnitude
        let vertices = self.points()
        for i in 0..<pointCount {
            let vertex1 = vertices[i]
            let vertex2 = vertices[(i + 1) % pointCount]
            let distance = point.distanceToLineSegment(point1: vertex1, point2: vertex2, inMeters: true)
            minDistance = min(minDistance, distance)
        }
        return minDistance
    }

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

extension MKPolyline {

    /// Returns the shortest distance in meters between the polyline and the given point.
    func distance(to point: MKMapPoint) -> Double {
        var minDistance = Double.greatestFiniteMagnitude
        let vertices = self.points()
        for i in 0..<(pointCount - 1) {
            let vertex1 = vertices[i]
            let vertex2 = vertices[i + 1]
            let distance = point.distanceToLineSegment(point1: vertex1, point2: vertex2, inMeters: true)
            minDistance = min(minDistance, distance)
        }
        return minDistance
    }

    /// Returns `true` if the distance from the polyline to the given point
    /// is less than a given threshold in MapKit units (not meters).
    func mapDistance(to point: MKMapPoint, isLessThanThreshold threshold: Double) -> Bool {
        let vertices = self.points()
        for i in 0..<(pointCount - 1) {
            let vertex1 = vertices[i]
            let vertex2 = vertices[i + 1]
            let distance = point.distanceToLineSegment(point1: vertex1, point2: vertex2, inMeters: false)
            if distance <= threshold {
                return true
            }
        }
        return false
    }
}
