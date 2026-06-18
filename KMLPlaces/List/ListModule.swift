import SwiftUI

class ListModule {

    class func build(mode: ListMode,
                     notificationCenter: NotificationCenter = .default,
                     path: Binding<[ListNavigationPathElement]>) -> some View {
        let viewModel = ListViewModel(mode: mode, notificationCenter: notificationCenter, path: path)
        return ListView(viewModel: viewModel)
    }
}
