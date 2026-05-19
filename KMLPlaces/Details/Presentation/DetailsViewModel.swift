import SDWebImage
import SwiftUI
import MapKit

class DetailsViewModel: ObservableObject {

    // MARK: - Public

    @Published var name: String
    @Published var kmlDescription: String
    @Published var mapData: MapData?

    init(place: Placemark) {
        name = place.name ?? String(localized: .untitledPlace)
        kmlDescription = place.kmlDescription ?? String(localized: .noDescription)
        mapData = Self.mapData(for: place)
    }

    // MARK: - Private

    private static func mapData(for place: Placemark) -> MapData? {
        guard let mapType = mapType(for: place) else { return nil }
        return MapData(mapType: mapType, cameraPosition: cameraPosition(for: place))
    }

    private static func mapType(for place: Placemark) -> MapType? {
        let style = StyleManager.shared.style(url: place.styleUrl)
        if let coordinate = place.point?.coordinate {
            let annotation = Annotation(
                coordinate: coordinate,
                iconURL: style?.iconURL,
                title: place.name,
                description: place.kmlDescription
            )
            return .annotation(annotation)
        } else if let lineString = place.lineString {
            let polylineModel = Polyline(
                coordinates: lineString.coordinates,
                strokeColor: style?.strokeColor ?? StyleManager.defaultPolylineStrokeColor,
                strokeWidth: style?.strokeWidth.nilIfZero ?? StyleManager.defaultPolylineStrokeWidth,
                title: place.name,
                description: place.kmlDescription
            )
            return .polyline(polylineModel)
        } else if let polygon = place.polygon {
            let polygonModel = Polygon(
                coordinates: polygon.coordinates,
                strokeColor: style?.strokeColor ?? StyleManager.defaultPolygonStrokeColor,
                strokeWidth: style?.strokeWidth.nilIfZero ?? StyleManager.defaultPolygonStrokeWidth,
                fillColor: style?.fillColor ?? StyleManager.defaultPolygonFillColor,
                title: place.name,
                description: place.kmlDescription
            )
            return .polygon(polygonModel)
        }
        return nil
    }

    private static func cameraPosition(for place: Placemark) -> MapCameraPosition {
        let allCoordinates = place.allCoordinates
        if allCoordinates.isEmpty {
            return .automatic
        }
        if allCoordinates.count == 1, let center = allCoordinates.first {
            return .region(MKCoordinateRegion(center: center, latitudinalMeters: 500, longitudinalMeters: 500))
        }
        let allLatitudes = allCoordinates.map { $0.latitude }
        let allLongitudes = allCoordinates.map { $0.longitude }
        let minLatitude = allLatitudes.min()!
        let maxLatitude = allLatitudes.max()!
        let minLongitude = allLongitudes.min()!
        let maxLongitude = allLongitudes.max()!
        let center = CLLocationCoordinate2D(latitude: (minLatitude + maxLatitude) / 2,
                                            longitude: (minLongitude + maxLongitude) / 2)
        let paddingMultiplier = 1.2
        let span = MKCoordinateSpan(latitudeDelta: (maxLatitude - minLatitude) * paddingMultiplier,
                                    longitudeDelta: (maxLongitude - minLongitude) * paddingMultiplier)
        return .region(MKCoordinateRegion(center: center, span: span))
    }
}

// MARK: - Subtypes

extension DetailsViewModel {

    struct MapData {
        var mapType: MapType
        var cameraPosition: MapCameraPosition
    }

    enum MapType {
        case annotation(Annotation)
        case polyline(Polyline)
        case polygon(Polygon)
    }

    struct Annotation {
        let coordinate: CLLocationCoordinate2D
        let iconURL: URL?
        let title: String?
        let description: String?
    }

    struct Polyline {
        let coordinates: [CLLocationCoordinate2D]
        let strokeColor: Color
        let strokeWidth: CGFloat
        let title: String?
        let description: String?
    }

    struct Polygon {
        let coordinates: [CLLocationCoordinate2D]
        let strokeColor: Color
        let strokeWidth: CGFloat
        let fillColor: Color
        let title: String?
        let description: String?
    }
}
