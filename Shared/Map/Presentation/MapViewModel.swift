import SwiftUI
import MapKit
import CoreData

class MapViewModel: ObservableObject {

    // MARK: - Public

    @Published var path = NavigationPath()
    @Published var title: String = ""
    @Published var coordinateRegion = MKCoordinateRegion()
    @Published var annotationItems: [AnnotationItem] = []

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

    /// Set `coordinateRegion` so that it encloses all places.
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
        self.coordinateRegion = MKCoordinateRegion(center: center, span: span)
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
}
