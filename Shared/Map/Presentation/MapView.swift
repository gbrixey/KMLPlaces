import SwiftUI
import MapKit

struct MapView: View {

    // MARK: - Public

    @StateObject var viewModel: MapViewModel

    var body: some View {
        NavigationView {
            Map(coordinateRegion: $viewModel.coordinateRegion,
                showsUserLocation: true,
                annotationItems: viewModel.annotationItems) { annotationItem in
                MapPin(coordinate: annotationItem.coordinate)
            }
            .navigationTitle(viewModel.title)
            .ignoresSafeArea(edges: .horizontal)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Previews

struct MapViewPreviews: PreviewProvider {
    static var previews: some View {
        MapView(viewModel: MapPreviews.viewModel)
    }
}
