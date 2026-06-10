import SwiftUI

class RootModule {

    class func build() -> some View {
        RootView(viewModel: RootViewModel())
    }
}
