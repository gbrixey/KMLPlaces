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
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(viewModel.name)
        .onAppear {
            viewModel.createMapImage()
        }
    }
}

// MARK: - Previews

struct DetailsViewPreviews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailsView(viewModel: DetailsPreviews.viewModel)
        }
    }
}
