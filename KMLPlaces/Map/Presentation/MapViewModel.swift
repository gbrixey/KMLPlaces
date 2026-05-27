import SwiftUI
import MapKit
import CoreData

class MapViewModel: ObservableObject {

    // MARK: - Public

    @Published var title: String = ""
    @Published var cameraPosition = MapCameraPosition.automatic
    @Published var annotationModels: [Annotation] = []
    @Published var polylineModels: [Polyline] = []
    @Published var polygonModels: [Polygon] = []
    @Published var popoverData: PopoverData?

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
        dataStore.requestLocationAuthorization()
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
            // TODO: Determine distance from the point to the polyline and present popover if it's below a certain threshold
        }
        for polygon in polygonModels {
            let mapKitPolygon = MKPolygon(coordinates: polygon.coordinates,
                                          count: polygon.coordinates.count)
            guard currentCameraRect.intersects(mapKitPolygon.boundingMapRect) else { continue }
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

    @Binding var listPath: [ListItem]
    private let dataStore: MapDataStore
    private var rootFolder: Folder?
    private var currentFolder: Folder?
    private var places: [Placemark] = []

    private func refreshMapItems() {
        title = currentFolder?.name ?? ""
        places = currentFolder?.flattenedPlacesArray ?? []
        updateAnnotationItems()
        setEnclosingRegion()
    }

    /// Update `annotationItems` with the data in `places`.
    private func updateAnnotationItems() {
        annotationModels.removeAll()
        polylineModels.removeAll()
        polygonModels.removeAll()
        for place in places {
            let style = StyleManager.shared.style(url: place.styleUrl)
            if let coordinate = place.point?.coordinate {
                let annotation = Annotation(
                    id: place.objectID,
                    coordinate: coordinate,
                    iconURL: style?.iconURL,
                    title: place.name,
                    description: place.kmlDescription
                )
                annotationModels.append(annotation)
            } else if let lineString = place.lineString {
                let polylineModel = Polyline(
                    id: place.objectID,
                    coordinates: lineString.coordinates,
                    strokeColor: style?.strokeColor ?? StyleManager.defaultPolylineStrokeColor,
                    strokeWidth: style?.strokeWidth.nilIfZero ?? StyleManager.defaultPolylineStrokeWidth,
                    title: place.name,
                    description: place.kmlDescription
                )
                polylineModels.append(polylineModel)
            } else if let polygon = place.polygon {
                let polygonModel = Polygon(
                    id: place.objectID,
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
        cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
    }
}

// MARK: - Subtypes

extension MapViewModel {

    struct Annotation: Identifiable {
        let id: NSManagedObjectID
        let coordinate: CLLocationCoordinate2D
        let iconURL: URL?
        let title: String?
        let description: String?
    }

    struct Polyline: Identifiable {
        let id: NSManagedObjectID
        let coordinates: [CLLocationCoordinate2D]
        let strokeColor: Color
        let strokeWidth: CGFloat
        let title: String?
        let description: String?
    }

    struct Polygon: Identifiable {
        let id: NSManagedObjectID
        let coordinates: [CLLocationCoordinate2D]
        let strokeColor: Color
        let strokeWidth: CGFloat
        let fillColor: Color
        let title: String?
        let description: String?
    }

    struct PopoverData: Identifiable {
        let id: NSManagedObjectID
        let point: UnitPoint
        let title: String?
        let description: String?
    }
}
