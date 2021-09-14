import SwiftUI
import MapKit

class MapViewModel: ObservableObject {

    // MARK: - Public

    @Published var title: String
    @Published var coordinateRegion = MKCoordinateRegion()
    @Published var annotationItems: [AnnotationItem] = []

    init(dataStore: MapDataStore) {
        self.dataStore = dataStore
        rootFolder = dataStore.fetchRootFolder()
        title = rootFolder?.name ?? ""
        updatePlaces()
        updateAnnotationItems()
        setEnclosingRegion()
    }

    // MARK: - Private

    private let dataStore: MapDataStore
    private var rootFolder: Folder?
    private var places: [Placemark] = []

    /// Update `places` with the flattened list of places from `rootFolder`.
    private func updatePlaces() {
        guard let folder = rootFolder else { return }
        places = flattenedPlaces(in: folder)
    }

    /// Return an array of places contained in the given folder and its subfolders.
    private func flattenedPlaces(in folder: Folder) -> [Placemark] {
        folder.subfoldersArray.reduce(folder.placesArray, { $0 + flattenedPlaces(in: $1) })
    }

    /// Update `annotationItems` with the data in `places`.
    private func updateAnnotationItems() {
        annotationItems = places.compactMap { place -> AnnotationItem? in
            guard let coordinate = place.coordinate else { return nil }
            return AnnotationItem(coordinate: coordinate)
        }
    }

    /// Set `coordinateRegion` so that it encloses all places.
    private func setEnclosingRegion() {
        // TODO: support polygons and paths
        guard annotationItems.count > 0 else { return }
        let allCoordinates = annotationItems.map { $0.coordinate }
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
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }
}
