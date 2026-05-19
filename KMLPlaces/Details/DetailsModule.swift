import SwiftUI

class DetailsModule {

    class func build(place: Placemark) -> some View {
        let viewModel = DetailsViewModel(place: place)
        return DetailsView(viewModel: viewModel)
    }
}
