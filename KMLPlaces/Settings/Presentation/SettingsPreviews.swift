import Foundation

struct SettingsPreviews {

    class DataStore: SettingsDataStore {
        func parseKMLFile(at url: URL) -> Error? { return nil }
    }

    static var viewModel: SettingsViewModel {
        SettingsViewModel(dataStore: DataStore(), notificationCenter: .default)
    }
}
