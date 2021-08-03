import SwiftUI

struct ListNavigationView: View {

    // MARK: - Public

    @StateObject var viewModel: ListViewModel

    var body: some View {
        NavigationView {
            ListView(viewModel: viewModel)
        }
    }
}

// MARK: - Previews

struct ListNavigationViewPreviews: PreviewProvider {
    static var previews: some View {
        ListNavigationView(viewModel: ListPreviews.viewModel)
    }
}
