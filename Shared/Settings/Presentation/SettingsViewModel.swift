import SwiftUI

class SettingsViewModel: NSObject, ObservableObject {

    // MARK: - Public

    @Published var showDocumentPicker = false

    init(dataStore: SettingsDataStore,
         notificationCenter: NotificationCenter) {
        self.dataStore = dataStore
        self.notificationCenter = notificationCenter
    }

    func importDataTapped() {
        showDocumentPicker = true
    }

    // MARK: - Private

    private let dataStore: SettingsDataStore
    private let notificationCenter: NotificationCenter
}

// MARK: - UIDocumentPickerDelegate

extension SettingsViewModel: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        dataStore.parseKMLFile(at: urls[0])
        notificationCenter.post(name: .dataChanged, object: nil)
    }
}
