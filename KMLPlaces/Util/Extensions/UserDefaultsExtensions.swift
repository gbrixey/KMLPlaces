import Foundation

extension UserDefaults {

    func registerDefaults() {
        register(defaults: [
            Keys.shouldShowPolygonsOnMap: true,
            Keys.shouldShowPolylinesOnMap: true,
        ])
    }

    var shouldShowPolygonsOnMap: Bool {
        get { bool(forKey: Keys.shouldShowPolygonsOnMap) }
        set { set(newValue, forKey: Keys.shouldShowPolygonsOnMap) }
    }

    var shouldShowPolylinesOnMap: Bool {
        get { bool(forKey: Keys.shouldShowPolylinesOnMap) }
        set { set(newValue, forKey: Keys.shouldShowPolylinesOnMap) }
    }

    private enum Keys {
        static let shouldShowPolygonsOnMap = "shouldShowPolygonsOnMap"
        static let shouldShowPolylinesOnMap = "shouldShowPolylinesOnMap"
    }
}
