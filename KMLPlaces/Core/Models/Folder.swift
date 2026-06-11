import SwiftData

@Model
class Folder {
    var name: String

    @Relationship(deleteRule: .cascade) var parentFolder: Folder?
    @Relationship(deleteRule: .cascade, inverse: \Folder.parentFolder) var subfolders: [Folder] = []
    @Relationship(deleteRule: .cascade, inverse: \Placemark.folder) var places: [Placemark] = []

    init(name: String, parentFolder: Folder? = nil) {
        self.name = name
        self.parentFolder = parentFolder
    }
}

// MARK: - Convenience

extension Folder {

    var isRootFolder: Bool {
        parentFolder == nil
    }

    var flattenedSubfolders: [Folder] {
        subfolders.reduce(subfolders, { $0 + $1.flattenedSubfolders })
    }

    var flattenedPlaces: [Placemark] {
        subfolders.reduce(places, { $0 + $1.flattenedPlaces })
    }
}

extension Array where Element == Folder {

    var sortedByName: [Element] {
        sorted { folder1, folder2 in
            folder1.name < folder2.name
        }
    }
}
