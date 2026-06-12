import SwiftUI

@Observable class SettingsViewModel: NSObject {

    // MARK: - Public

    var showDocumentPicker = false
    var showAlert = false
    var alertTitle = ""
    var alertMessage = ""

    init(dataStore: SettingsDataStore,
         notificationCenter: NotificationCenter) {
        self.dataStore = dataStore
        self.notificationCenter = notificationCenter
    }

    func importDataTapped() {
        showDocumentPicker = true
    }

    func useTestDataTapped() {
        let path = Bundle.main.path(forResource: "Test", ofType: "kml")!
        let testDataURL = URL(fileURLWithPath: path)
        parseKMLFile(at: testDataURL)
    }

    // MARK: - Private

    private let dataStore: SettingsDataStore
    private let notificationCenter: NotificationCenter

    private func parseKMLFile(at url: URL) {
        if let error = dataStore.parseKMLFile(at: url) {
            alertTitle = String(localized: .error)
            alertMessage = String(localized: .dataLoadingError(error.localizedDescription))
        } else {
            alertTitle = String(localized: .success)
            alertMessage = String(localized: .dataLoadedSuccessfully)
            notificationCenter.post(name: .dataChanged, object: nil)
        }
        showAlert = true
    }
}

// MARK: - UIDocumentPickerDelegate

extension SettingsViewModel: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        parseKMLFile(at: urls[0])
    }
}
