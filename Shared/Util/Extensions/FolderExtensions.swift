extension Folder {

    var isRootFolder: Bool {
        return parentFolder == nil
    }

    var subfoldersArray: [Folder] {
        return (subfolders?.allObjects as? [Folder]) ?? []
    }

    var placesArray: [Placemark] {
        return (places?.allObjects as? [Placemark]) ?? []
    }
}
