import SwiftUI

class ListViewModel: ObservableObject {

    // MARK: - Public

    let title: String
    let folders: [Folder]
    let places: [Placemark]

    init(folder: Folder?, path: Binding<[ListItem]>) {
        _path = path
        title = folder?.name ?? ""
        folders = folder?.subfoldersArray.sorted(by: { folder1, folder2 in
            (folder1.name ?? "") < (folder2.name ?? "")
        }) ?? []
        places = folder?.placesArray.sorted(by: { place1, place2 in
            (place1.name ?? "") < (place2.name ?? "")
        }) ?? []
    }

    func placemarkTapped(_ placemark: Placemark) {
        path.append(.place(placemark))
    }

    func folderTapped(_ folder: Folder) {
        path.append(.folder(folder))
    }

    /// Style URL to use for the given place. For certain placemarks we don't want to use the style URL.
    func styleURL(for place: Placemark) -> String? {
        guard case .point = place.type else { return nil }
        return place.styleUrl
    }

    /// System name of the image to use as a backup icon if we are not using the style icon for the given placemark.
    func defaultIconName(for place: Placemark) -> String {
        switch place.type {
        case .point:
            return "mappin"
        case .lineString:
            return "point.bottomleft.forward.to.point.topright.scurvepath"
        case .polygon:
            return "square.dashed"
        }
    }

    // MARK: - Private

    @Binding private var path: [ListItem]
}
