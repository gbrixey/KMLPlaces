import SDWebImage
import SwiftUI
import MapKit

class DetailsViewModel: ObservableObject {

    // MARK: - Public

    @Published var name: String
    @Published var mapImage: UIImage?
    @Published var pinImage: UIImage?
    @Published var pinImagePadding: EdgeInsets = .zero
    @Published var pinImageScale: CGFloat = 1
    @Published var kmlDescription: String

    static let mapImageSize = CGSize(width: 280, height: 200)

    init(place: Placemark) {
        self.place = place
        name = place.name ?? String(key: "default.placemark.name")
        kmlDescription = place.kmlDescription ?? String(key: "default.placemark.description")
        if place.type == .point {
            pinImage = UIImage(systemName: "mappin.circle.fill")
            fetchPinImage()
        }
    }

    /// - todo: Handle paths and polygons
    func createMapImage() {
        guard let coordinate = place.point?.coordinate, coordinate != .zero else { return }
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

    private func fetchPinImage() {
        guard let style = StyleManager.shared.style(url: place.styleUrl) else { return }
        SDWebImageManager.shared.loadImage(with: style.iconURL,
                                           options: [],
                                           progress: nil) { [weak self] image, _, _, _, _, _ in
            guard let self = self, let image = image else { return }
            self.pinImage = image
            let hotspot = StyleManager.shared.hotspotCoordinates(style: style, size: image.size)
            self.pinImagePadding = EdgeInsets(top: max(0, image.size.height - (hotspot.y * 2)),
                                              leading: max(0, image.size.width - (hotspot.x * 2)),
                                              bottom: max(0, (hotspot.y * 2) - image.size.height),
                                              trailing: max(0, (hotspot.x * 2) - image.size.width))
            self.pinImageScale = 32 / max(image.size.width, image.size.height)
        }
    }
}
