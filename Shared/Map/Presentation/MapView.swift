import SwiftUI
import MapKit
import SDWebImageSwiftUI

struct MapView: View {

    // MARK: - Public

    @StateObject var viewModel: MapViewModel

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            GeometryReader { geometryProxy in
                MapReader { mapProxy in
                    Map(position: $viewModel.cameraPosition) {
                        ForEach(viewModel.annotationItems, id: \.id) { item in
                            if let coordinate = item.place.point?.coordinate {
                                annotation(place: item.place, coordinate: coordinate)
                            }
                            if let lineString = item.place.lineString {
                                mapPolyline(lineString: lineString)
                            }
                            if let polygon = item.place.polygon {
                                mapPolygon(polygon: polygon)
                            }
                        }
                    }
                    .mapControls {
                        MapUserLocationButton()
                        MapCompass()
                        MapPitchToggle()
                    }
                    .onMapCameraChange(frequency: .continuous) { context in
                        viewModel.currentCameraRect = context.rect
                    }
                    .onTapGesture { point in
                        guard let coordinate = mapProxy.convert(point, from: .local) else { return }
                        let size = geometryProxy.size
                        let unitPoint = UnitPoint(x: point.x / size.width, y: point.y / size.height)
                        viewModel.handleTap(at: coordinate, unitPoint: unitPoint)
                    }
                    .navigationTitle(viewModel.title)
                    .navigationDestination(for: Placemark.self) { place in
                        DetailsModule.build(place: place)
                    }
                    .ignoresSafeArea(edges: .horizontal)
                    .popover(item: $viewModel.popoverData,
                             attachmentAnchor: .point(viewModel.popoverData?.point ?? .center),
                             arrowEdge: .bottom) { data in
                        PopoverView(place: data.place)
                    }
                }
            }
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
    }

    // MARK: - Private

    private func annotation(place: Placemark, coordinate: CLLocationCoordinate2D) -> some MapContent {
        Annotation(coordinate: coordinate) {
            MapAnnotationView(place: place)
        } label: {
            Text(place.name ?? "")
        }
    }

    private func mapPolyline(lineString: LineString) -> some MapContent {
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

    private func mapPolygon(polygon: Polygon) -> some MapContent {
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

// MARK: - Additional views

extension MapView {

    struct MapAnnotationView: View {

        // MARK: - Public

        let place: Placemark

        var body: some View {
            Button(action: {
                showPopover.toggle()
            }) {
                MapPinImage(place: place)
            }
            .popover(isPresented: $showPopover, arrowEdge: .bottom) {
                PopoverView(place: place)
            }
        }

        // MARK: - Private

        @State private var showPopover = false
    }

    struct PopoverView: View {
        let place: Placemark

        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    MapPinImage(place: place)
                    Text(place.name ?? "")
                        .font(.headline)
                }
                // TODO: This needs a width constraint in order to wrap the text on iPad/Mac
                // TODO: Maybe also a scroll view
                Text(place.kmlDescription ?? "")
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(horizontal: 20, vertical: 40)
        }
    }

    struct MapPinImage: View {
        let place: Placemark

        var body: some View {
            if place.point == nil {
                EmptyView()
            } else {
                WebImage(url: StyleManager.shared.iconURL(styleURL: place.styleUrl))
                    .placeholder(Image(systemName: "mappin.circle.fill"))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }
        }
    }
}

// MARK: - Previews

#Preview {
    MapView(viewModel: MapPreviews.viewModel)
}
