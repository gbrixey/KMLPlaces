import SwiftUI
import MapKit
import SDWebImageSwiftUI

struct MapView: View {

    // MARK: - Public

    @State var viewModel: MapViewModel

    var body: some View {
        @Bindable var viewModel = viewModel
        ZStack(alignment: .topLeading) {
            GeometryReader { geometryProxy in
                MapReader { mapProxy in
                    Map(position: $viewModel.cameraPosition) {
                        ForEach(viewModel.annotationModels, id: \.id) { annotationModel in
                            annotation(model: annotationModel)
                        }
                        if viewModel.shouldShowPolylines {
                            ForEach(viewModel.polylineModels, id: \.id) { polylineModel in
                                mapPolyline(model: polylineModel)
                            }
                        }
                        if viewModel.shouldShowPolygons {
                            ForEach(viewModel.polygonModels, id: \.id) { polygonModel in
                                mapPolygon(model: polygonModel)
                            }
                        }
                        UserAnnotation()
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
            if !viewModel.title.isEmpty {
                Text(viewModel.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .accessibilityAddTraits(.isHeader)
                    .padding(horizontal: 20, vertical: 8)
                    .glassEffect()
                    .padding(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 80))
            }
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
    }

    // MARK: - Private

    @Namespace private var namespace

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
            .accessibilityIdentifier("Map annotation view button")
            .matchedTransitionSource(id: "map-popover", in: namespace)
            .popover(isPresented: $showPopover, arrowEdge: .bottom) {
                PopoverView(
                    shouldShowIcon: horizontalSizeClass == .compact,
                    iconURL: model.iconURL, title: model.title,
                    description: model.description
                )
                .navigationTransition(.zoom(sourceID: "map-popover", in: namespace))
            }
        }

        // MARK: - Private

        @Namespace private var namespace
        @State private var showPopover = false
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    }

    struct PopoverView: View {
        let shouldShowIcon: Bool
        let iconURL: URL?
        let title: String?
        let description: String?

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(description ?? "")
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .accessibilityIdentifier("Map popover description")
                        Spacer(minLength: 40)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(horizontal: 20)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            if shouldShowIcon {
                                MapPinImage(iconURL: iconURL)
                                    .accessibilityIdentifier("Map popover icon")
                                    .accessibilityHidden(true)
                            }
                            Text(title ?? "")
                                .font(.headline)
                                .accessibilityIdentifier("Map popover title")
                                .accessibilityAddTraits(.isHeader)
                        }
                    }
                }
                .frame(maxWidth: 500)
            }
            .presentationDetents([.medium, .large])
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
