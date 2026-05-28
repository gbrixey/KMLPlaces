import SwiftUI

struct ListPreviews {

    static var viewModel: ListViewModel {
        let repository = ListNavigationRepository(controller: .preview)
        let folder = repository.fetchRootFolder()!
        return ListViewModel(mode: .folder(folder), path: .constant([]))
    }
}
