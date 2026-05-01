import SwiftUI
import MapKit
import CoreData

class MapViewModel: ObservableObject {

    // MARK: - Public

    @Published var path = NavigationPath()
    @Published var title: String = ""
    @Published var cameraPosition = MapCameraPosition.automatic
    @Published var annotationItems: [AnnotationItem] = []
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
        let currentFolderInList = listPath.compactMap { $0.asFolder }.last ?? rootFolder
        if currentFolder != currentFolderInList {
            currentFolder = currentFolderInList
            refreshMapItems()
        }
    }

    func handleTap(at tapCoordinate: CLLocationCoordinate2D, unitPoint: UnitPoint) {
        let tapPoint = MKMapPoint(tapCoordinate)
        for item in annotationItems {
            if let lineString = item.place.lineString {
                let polyline = MKPolyline(coordinates: lineString.coordinates,
                                          count: lineString.coordinates.count)
                guard currentCameraRect.intersects(polyline.boundingMapRect) else { continue }
                // TODO: Determine distance from the point to the polyline and present popover if it's below a certain threshold
            }
            if let polygon = item.place.polygon {
                let mapKitPolygon = MKPolygon(coordinates: polygon.coordinates,
                                              count: polygon.coordinates.count)
                guard currentCameraRect.intersects(mapKitPolygon.boundingMapRect) else { continue }
                if mapKitPolygon.contains(tapPoint) {
                    popoverData = PopoverData(point: unitPoint, place: item.place)
                    return
                }
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
        updatePlaces()
        updateAnnotationItems()
        setEnclosingRegion()
    }

    /// Update `places` with the flattened list of places from `currentFolder`.
    private func updatePlaces() {
        guard let folder = currentFolder else { return }
        places = flattenedPlaces(in: folder)
    }

    /// Return an array of places contained in the given folder and its subfolders.
    private func flattenedPlaces(in folder: Folder) -> [Placemark] {
        folder.subfoldersArray.reduce(folder.placesArray, { $0 + flattenedPlaces(in: $1) })
    }

    /// Update `annotationItems` with the data in `places`.
    private func updateAnnotationItems() {
        annotationItems = places.map { place -> AnnotationItem in
            AnnotationItem(place: place)
        }
    }

    /// Set map camera position so that all places are visible.
    private func setEnclosingRegion() {
        guard places.count > 0 else { return }
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

    struct AnnotationItem: Identifiable {
        let place: Placemark

        var id: NSManagedObjectID {
            place.objectID
        }
    }

    struct PopoverData: Identifiable {
        let point: UnitPoint
        let place: Placemark

        var id: NSManagedObjectID {
            place.objectID
        }
    }
}
