import SwiftUI

class RootViewModel: ObservableObject {

    // MARK: - Public

    @Published var listPath: [ListItem] = []
}
