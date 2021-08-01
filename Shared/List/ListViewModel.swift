import SwiftUI

class ListViewModel: ObservableObject {

    @Published var title = "My Places"
    @Published var items: [ListItem] = [
        .allPlaces,
        .folder(Folder(name: "Skyscrapers")),
        .place(Place(name: "My House"))
    ]

    func itemTapped(at index: Int) {
        
    }
}

// MARK: - Data types

extension ListViewModel {

    enum ListItem: Identifiable {
        case allPlaces
        case folder(Folder)
        case place(Place)

        var id: String {
            name
        }

        var systemIcon: String {
            switch self {
            case .allPlaces, .folder:
                return "folder"
            case .place:
                return "mappin"
            }
        }

        var name: String {
            switch self {
            case .allPlaces:
                return NSLocalizedString("list.all.places", comment: "")
            case let .folder(folder):
                return folder.name
            case let .place(place):
                return place.name
            }
        }

        var nameColor: Color {
            switch self {
            case .allPlaces, .folder:
                return .blue
            case .place:
                return .primary
            }
        }
    }

    struct Folder {
        let name: String
    }

    struct Place {
        let name: String
    }
}
