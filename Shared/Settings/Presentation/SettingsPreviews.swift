import Foundation

struct SettingsPreviews {

    class DataStore: SettingsDataStore {
        func parseKMLFile(at url: URL) { }
    }

    static var viewModel: SettingsViewModel {
        SettingsViewModel(dataStore: DataStore(), notificationCenter: .default)
    }
}
