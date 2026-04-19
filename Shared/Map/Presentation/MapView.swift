import SwiftUI
import MapKit
import SDWebImageSwiftUI

struct MapView: View {

    // MARK: - Public

    @StateObject var viewModel: MapViewModel

    var body: some View {
        NavigationView {
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
            .ignoresSafeArea(edges: .horizontal)
        }
        .navigationViewStyle(StackNavigationViewStyle())
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

struct MapViewPreviews: PreviewProvider {
    static var previews: some View {
        MapView(viewModel: MapPreviews.viewModel)
    }
}
