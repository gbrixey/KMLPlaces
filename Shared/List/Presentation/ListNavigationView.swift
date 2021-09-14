import SwiftUI

// - todo: Pop navigation view to root when a new data set is uploaded
struct ListNavigationView: View {

    // MARK: - Public

    @StateObject var viewModel: ListViewModel

    var body: some View {
        NavigationView {
            ListView(viewModel: viewModel)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Previews

struct ListNavigationViewPreviews: PreviewProvider {
    static var previews: some View {
        ListNavigationView(viewModel: ListPreviews.viewModel)
    }
}
