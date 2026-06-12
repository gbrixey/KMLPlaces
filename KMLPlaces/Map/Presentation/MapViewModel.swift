import SwiftUI
import SwiftData
import MapKit
import CoreLocation

@Observable class MapViewModel {

    // MARK: - Public

    var title: String = ""
    var cameraPosition = MapCameraPosition.automatic
    var annotationModels: [Annotation] = []
    var polylineModels: [Polyline] = []
    var polygonModels: [Polygon] = []
    var popoverData: PopoverData?

    /// The view updates this property when the map is moved.
    var currentCameraRect = MKMapRect()

    init(listPath: Binding<[ListItem]>,
         dataStore: MapDataStore,
         notificationCenter: NotificationCenter) {
        self._listPath = listPath
        self.dataStore = dataStore
        self.rootFolder = dataStore.fetchRootFolder()
        self.currentFolder = self.rootFolder
        refreshMapItems()
        notificationCenter.addObserver(self, selector: #selector(dataChanged), name: .dataChanged, object: nil)
    }

    func viewDidAppear() {
        if !didRequestLocationAuthorization {
            locationManager.requestWhenInUseAuthorization()
            didRequestLocationAuthorization = true
        }
        let currentFolderInList = listPath.compactMap { $0.asFolder }.last ?? rootFolder
        if currentFolder != currentFolderInList {
            currentFolder = currentFolderInList
            refreshMapItems()
        }
    }

    func handleTap(at tapCoordinate: CLLocationCoordinate2D, unitPoint: UnitPoint) {
        let tapPoint = MKMapPoint(tapCoordinate)
        for polyline in polylineModels {
            let mapKitPolyline = MKPolyline(coordinates: polyline.coordinates,
                                            count: polyline.coordinates.count)
            guard currentCameraRect.intersects(mapKitPolyline.boundingMapRect) else { continue }
            // TODO: This threshold is kind of arbitrary and may need to be adjusted.
            let threshold = min(currentCameraRect.size.width, currentCameraRect.size.height) / 25
            if mapKitPolyline.mapDistance(to: tapPoint, isLessThanThreshold: threshold) {
                popoverData = PopoverData(
                    id: polyline.id,
                    point: unitPoint,
                    title: polyline.title,
                    description: polyline.description
                )
            }
        }
        for polygon in polygonModels {
            let mapKitPolygon = MKPolygon(coordinates: polygon.coordinates,
                                          count: polygon.coordinates.count)
            let polygonEnclosingRegion = MKCoordinateRegion(enclosingCoordinates: polygon.coordinates)
            guard polygonEnclosingRegion.contains(tapPoint.coordinate) else { continue }
            if mapKitPolygon.contains(tapPoint) {
                popoverData = PopoverData(
                    id: polygon.id,
                    point: unitPoint,
                    title: polygon.title,
                    description: polygon.description
                )
                return
            }
        }
    }

    // MARK: - Actions

    @objc private func dataChanged() {
        rootFolder = dataStore.fetchRootFolder()
        currentFolder = rootFolder
        refreshMapItems()
    }

    // MARK: - Private

    @ObservationIgnored @Binding var listPath: [ListItem]
    private let dataStore: MapDataStore
    private let locationManager = CLLocationManager()
    private var rootFolder: Folder?
    private var currentFolder: Folder?
    private var places: [Placemark] = []
    private var didRequestLocationAuthorization = false

    private func refreshMapItems() {
        title = currentFolder?.name ?? ""
        places = currentFolder?.flattenedPlaces ?? []
        updateAnnotationItems()
        setEnclosingRegion()
    }

    /// Update `annotationItems` with the data in `places`.
    private func updateAnnotationItems() {
        annotationModels.removeAll()
        polylineModels.removeAll()
        polygonModels.removeAll()
        for place in places {
            let style = StyleManager.shared.style(url: place.styleURL)
            if let coordinate = place.point?.coordinate {
                let annotation = Annotation(
                    id: place.id,
                    coordinate: coordinate,
                    iconURL: style?.iconURL,
                    title: place.name,
                    description: place.kmlDescription
                )
                annotationModels.append(annotation)
            } else if let lineString = place.lineString {
                let polylineModel = Polyline(
                    id: place.id,
                    coordinates: lineString.coordinates,
                    strokeColor: style?.strokeColor ?? StyleManager.defaultPolylineStrokeColor,
                    strokeWidth: style?.strokeWidth.nilIfZero ?? StyleManager.defaultPolylineStrokeWidth,
                    title: place.name,
                    description: place.kmlDescription
                )
                polylineModels.append(polylineModel)
            } else if let polygon = place.polygon {
                let polygonModel = Polygon(
                    id: place.id,
                    coordinates: polygon.coordinates,
                    strokeColor: style?.strokeColor ?? StyleManager.defaultPolygonStrokeColor,
                    strokeWidth: style?.strokeWidth.nilIfZero ?? StyleManager.defaultPolygonStrokeWidth,
                    fillColor: style?.fillColor ?? StyleManager.defaultPolygonFillColor,
                    title: place.name,
                    description: place.kmlDescription
                )
                polygonModels.append(polygonModel)
            }
        }
    }

    /// Set map camera position so that all places are visible.
    private func setEnclosingRegion() {
        guard !places.isEmpty else { return }
        let allCoordinates = places.flatMap { $0.allCoordinates }
        let region = MKCoordinateRegion(enclosingCoordinates: allCoordinates)
        cameraPosition = .region(region)
    }
}

// MARK: - Subtypes

extension MapViewModel {

    struct Annotation: Identifiable {
        let id: PersistentIdentifier
        let coordinate: CLLocationCoordinate2D
        let iconURL: URL?
        let title: String?
        let description: String?
    }

    struct Polyline: Identifiable {
        let id: PersistentIdentifier
        let coordinates: [CLLocationCoordinate2D]
        let strokeColor: Color
        let strokeWidth: CGFloat
        let title: String?
        let description: String?
    }

    struct Polygon: Identifiable {
        let id: PersistentIdentifier
        let coordinates: [CLLocationCoordinate2D]
        let strokeColor: Color
        let strokeWidth: CGFloat
        let fillColor: Color
        let title: String?
        let description: String?
    }

    struct PopoverData: Identifiable {
        let id: PersistentIdentifier
        let point: UnitPoint
        let title: String?
        let description: String?
    }
}
