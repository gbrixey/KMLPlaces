import SwiftUI
import MapKit

class DetailsViewModel: ObservableObject {

    // MARK: - Public

    @Published var name: String
    @Published var mapImage: UIImage?
    @Published var pinImage: UIImage?
    @Published var kmlDescription: String

    static let mapImageSize = CGSize(width: 280, height: 200)

    init(place: Placemark) {
        self.place = place
        name = place.name ?? String(key: "default.placemark.name")
        pinImage = UIImage(systemName: "mappin.circle.fill")
        kmlDescription = place.kmlDescription ?? String(key: "default.placemark.description")
    }

    /// - todo: Handle paths and polygons
    func createMapImage() {
        guard let coordinate = place.coordinate, coordinate != .zero else { return }
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(center: coordinate,
                                            latitudinalMeters: 500,
                                            longitudinalMeters: 500)
        options.mapType = .standard
        options.showsBuildings = false
        options.pointOfInterestFilter = .excludingAll
        options.size = Self.mapImageSize
        let mapSnapshotter = MKMapSnapshotter(options: options)
        mapSnapshotter.start { [weak self] (snapshot, error) in
            guard let self = self, let snapshot = snapshot else { return }
            self.mapImage = snapshot.image
        }
    }

    // MARK: - Private

    private let place: Placemark
}
