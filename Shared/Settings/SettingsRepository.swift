import Foundation

class SettingsRepository: SettingsDataStore {

    func parseKMLFile(at url: URL) {
        KMLParser.parseKMLFile(at: url)
    }
}
