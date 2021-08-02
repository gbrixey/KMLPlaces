import Foundation

protocol SettingsDataStore {
    func parseKMLFile(at url: URL)
}

class SettingsModule {

    class func build() -> SettingsView {
        let viewModel = SettingsViewModel(dataStore: SettingsRepository(),
                                          notificationCenter: .default)
        return SettingsView(viewModel: viewModel)
    }
}
