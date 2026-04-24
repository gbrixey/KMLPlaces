import SwiftUI
import MapKit
import SDWebImageSwiftUI

// TODO: Present a callout view when an annotation, polygon, or polyline is tapped. The callout should have some UI control that pushes a details view onto the navigation stack.
struct MapView: View {

    // MARK: - Public

    @StateObject var viewModel: MapViewModel

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            Map {
                ForEach(viewModel.annotationItems, id: \.id) { item in
                    if let coordinate = item.place.point?.coordinate {
                        Annotation(coordinate: coordinate) {
                            MapAnnotationView(annotationItem: item)
                        } label: {
                            if let name = item.place.name {
                                Text(name)
                            } else {
                                EmptyView()
                            }
                        }
                    }
                    if let lineString = item.place.lineString {
                        MapPolyline(coordinates: lineString.coordinates)
                            .stroke(
                                .blue,
                                style: StrokeStyle(
                                    lineWidth: 4,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                    }
                    if let polygon = item.place.polygon {
                        MapPolygon(coordinates: polygon.coordinates)
                            .stroke(
                                .black,
                                style: StrokeStyle(
                                    lineWidth: 1,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                            .foregroundStyle(.yellow.opacity(0.3))
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapPitchToggle()
            }
            .navigationTitle(viewModel.title)
            .navigationDestination(for: Placemark.self) { place in
                DetailsModule.build(place: place)
            }
            .ignoresSafeArea(edges: .horizontal)
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
    }
}

// MARK: - Additional views

extension MapView {

    struct MapAnnotationView: View {
        let annotationItem: MapViewModel.AnnotationItem

        var body: some View {
            let defaultImage = Image(systemName: "mappin.circle.fill")
            if let styleURL = annotationItem.place.styleUrl {
                WebImage(url: StyleManager.shared.iconURL(styleURL: styleURL))
                    .placeholder(defaultImage)
                    .resizable()
                    .frame(width: 30, height: 30)
            } else {
                defaultImage
            }
        }
    }
}

// MARK: - Previews

#Preview {
    MapView(viewModel: MapPreviews.viewModel)
}
