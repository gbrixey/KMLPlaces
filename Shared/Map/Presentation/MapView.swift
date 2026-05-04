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
                        ForEach(viewModel.annotationModels, id: \.id) { annotationModel in
                            annotation(model: annotationModel)
                        }
                        ForEach(viewModel.polylineModels, id: \.id) { polylineModel in
                            mapPolyline(model: polylineModel)
                        }
                        ForEach(viewModel.polygonModels, id: \.id) { polygonModel in
                            mapPolygon(model: polygonModel)
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
                        PopoverView(
                            shouldShowIcon: false,
                            iconURL: nil,
                            title: data.title,
                            description: data.description
                        )
                    }
                }
            }
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
    }

    // MARK: - Private

    private func annotation(model: MapViewModel.Annotation) -> some MapContent {
        Annotation(coordinate: model.coordinate) {
            MapAnnotationView(model: model)
        } label: {
            Text(model.title ?? "")
        }
    }

    private func mapPolyline(model: MapViewModel.Polyline) -> some MapContent {
        MapPolyline(coordinates: model.coordinates)
            .stroke(
                model.strokeColor,
                style: StrokeStyle(
                    lineWidth: model.strokeWidth,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
    }

    private func mapPolygon(model: MapViewModel.Polygon) -> some MapContent {
        MapPolygon(coordinates: model.coordinates)
            .stroke(
                model.strokeColor,
                style: StrokeStyle(
                    lineWidth: model.strokeWidth,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .foregroundStyle(model.fillColor)
    }
}

// MARK: - Additional views

extension MapView {

    struct MapAnnotationView: View {

        // MARK: - Public

        let model: MapViewModel.Annotation

        var body: some View {
            Button(action: {
                showPopover.toggle()
            }) {
                MapPinImage(iconURL: model.iconURL)
            }
            .popover(isPresented: $showPopover, arrowEdge: .bottom) {
                PopoverView(
                    shouldShowIcon: true,
                    iconURL: model.iconURL, title: model.title,
                    description: model.description
                )
            }
        }

        // MARK: - Private

        @State private var showPopover = false
    }

    struct PopoverView: View {
        let shouldShowIcon: Bool
        let iconURL: URL?
        let title: String?
        let description: String?

        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    if shouldShowIcon {
                        MapPinImage(iconURL: iconURL)
                    }
                    Text(title ?? "")
                        .font(.headline)
                }
                // TODO: This needs a width constraint in order to wrap the text on iPad/Mac
                // TODO: Maybe also a scroll view
                Text(description ?? "")
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(horizontal: 20, vertical: 40)
        }
    }

    struct MapPinImage: View {
        let iconURL: URL?

        var body: some View {
            WebImage(url: iconURL)
                .placeholder(Image(systemName: "mappin.circle.fill"))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
        }
    }
}

// MARK: - Previews

#Preview {
    MapView(viewModel: MapPreviews.viewModel)
}
