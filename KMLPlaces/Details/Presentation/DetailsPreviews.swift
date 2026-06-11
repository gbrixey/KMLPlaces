struct DetailsPreviews {

    static var viewModel: DetailsViewModel {
        let placemark = Placemark(
            name: "123 Fake Street",
            kmlDescription: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            folder: Folder(name: "Preview", parentFolder: nil),
            point: Point(latitude: 40.78318, longitude: -73.95403)
        )
        return DetailsViewModel(place: placemark)
    }
}
