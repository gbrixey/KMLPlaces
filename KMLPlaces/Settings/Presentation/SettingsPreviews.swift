import Foundation

struct SettingsPreviews {

    class DataStore: SettingsDataStore {
        func parseKMLFile(at url: URL) -> Error? { return nil }
        var shouldShowPolygonsOnMap = true
        var shouldShowPolylinesOnMap = true
    }

    static var viewModel: SettingsViewModel {
        SettingsViewModel(dataStore: DataStore(), notificationCenter: .default)
    }
}
