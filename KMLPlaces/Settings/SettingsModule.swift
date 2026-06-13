import Foundation

protocol SettingsDataStore {
    /// Returns nil if the operation was successful.
    func parseKMLFile(at url: URL) -> Error?
    var shouldShowPolygonsOnMap: Bool { get set }
    var shouldShowPolylinesOnMap: Bool { get set }
}

class SettingsModule {

    class func build() -> SettingsView {
        let viewModel = SettingsViewModel(dataStore: SettingsRepository(),
                                          notificationCenter: .default)
        return SettingsView(viewModel: viewModel)
    }
}
