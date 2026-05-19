enum ListItem: Hashable {
    case folder(Folder)
    case place(Placemark)

    // MARK: - Convenience

    var asFolder: Folder? {
        guard case let .folder(folder) = self else { return nil }
        return folder
    }
}
