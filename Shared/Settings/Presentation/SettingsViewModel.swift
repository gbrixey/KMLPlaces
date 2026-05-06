import SwiftUI

class SettingsViewModel: NSObject, ObservableObject {

    // MARK: - Public

    @Published var showDocumentPicker = false
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

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
            alertTitle = String(key: "Error")
            let alertMessageFormat = String(key: "The data could not be loaded.\n\n%@")
            alertMessage = String(format: alertMessageFormat, error.localizedDescription)
        } else {
            alertTitle = String(key: "Success")
            alertMessage = String(key: "Data loaded successfully.")
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
