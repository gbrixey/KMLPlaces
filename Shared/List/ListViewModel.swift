import SwiftUI

class ListViewModel: ObservableObject {

    @Published var title = "My Places"
    @Published var items: [ListItem] = [
        .allPlaces,
        .folder(Folder(name: "Skyscrapers", colors: [.blue, .black])),
        .place(Place(icon: "house", name: "My House", color: .blue))
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

        var icon: String {
            switch self {
            case .allPlaces, .folder:
                return "folder"
            case let .place(place):
                return place.icon
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

        var colors: [Color] {
            switch self {
            case .allPlaces:
                return []
            case let .folder(folder):
                return folder.colors
            case let .place(place):
                return [place.color]
            }
        }
    }

    struct Folder {
        let name: String
        let colors: [Color]
    }

    struct Place {
        let icon: String
        let name: String
        let color: Color
    }
}
