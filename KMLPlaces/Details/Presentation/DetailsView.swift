import SwiftUI
import SDWebImageSwiftUI
import MapKit

struct DetailsView: View {

    // MARK: - Public

    @StateObject var viewModel: DetailsViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let mapData = viewModel.mapData {
                    mapView(mapData: mapData)
                }
                Text(viewModel.name).bold()
                Text(viewModel.kmlDescription)
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(viewModel.name)
    }

    // MARK: - Private

    private func mapView(mapData: DetailsViewModel.MapData) -> some View {
        Map(position: .constant(mapData.cameraPosition), interactionModes: []) {
            switch mapData.mapType {
            case .annotation(let annotation):
                Annotation(coordinate: annotation.coordinate) {
                    WebImage(url: annotation.iconURL)
                        .placeholder(Image(systemName: "mappin.circle.fill"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                } label: {
                    EmptyView()
                }
            case .polyline(let polyline):
                MapPolyline(coordinates: polyline.coordinates)
                    .stroke(
                        polyline.strokeColor,
                        style: StrokeStyle(
                            lineWidth: polyline.strokeWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
            case .polygon(let polygon):
                MapPolygon(coordinates: polygon.coordinates)
                    .stroke(
                        polygon.strokeColor,
                        style: StrokeStyle(
                            lineWidth: polygon.strokeWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .foregroundStyle(polygon.fillColor)
            }
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Previews

#Preview {
    DetailsView(viewModel: DetailsPreviews.viewModel)
}
