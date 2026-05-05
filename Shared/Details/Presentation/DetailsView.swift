import SwiftUI

struct DetailsView: View {

    @StateObject var viewModel: DetailsViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ZStack {
                    if let image = viewModel.mapImage {
                        Image(uiImage: image)
                        if let pinImage = viewModel.pinImage {
                            Image(uiImage: pinImage)
                                .padding(viewModel.pinImagePadding)
                                .scaleEffect(viewModel.pinImageScale)
                        }
                    } else {
                        let size = DetailsViewModel.mapImageSize
                        Color(UIColor.secondarySystemBackground)
                            .frame(width: size.width, height: size.height)
                        ProgressView()
                    }
                }
                Text(viewModel.name).bold()
                Text(viewModel.kmlDescription)
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(viewModel.name)
        .onAppear {
            viewModel.createMapImage()
        }
    }
}

// MARK: - Previews

#Preview {
    DetailsView(viewModel: DetailsPreviews.viewModel)
}
