import UIKit
import CoreData
import SDWebImage

/// Class that is responsible for storing style information from the KML in memory for quick access.
class StyleManager {

    // MARK: - Public

    static let shared = StyleManager()

    func iconURL(styleURL: String?, highlighted: Bool = false) -> URL? {
        style(url: styleURL, highlighted: highlighted)?.iconURL
    }

    func style(url: String?, highlighted: Bool = false) -> Style? {
        guard let url = url else { return nil }
        let styleMapID = url.removingLeadingHash
        guard let styleMap = styleMaps[styleMapID] else { return nil }
        let styleID = (highlighted ? styleMap.highlighted : styleMap.normal).removingLeadingHash
        return styles[styleID]
    }

    /// Get the coordinates of the hotspot of the given style image, in the frame of the image itself.
    /// The `size` parameter needs to be determined by downloading the image first.
    /// Entering an arbitrary size will not work for all styles.
    func hotspotCoordinates(style: Style, size: CGSize) -> CGPoint {
        let hotspot = style.hotspot
        let x: CGFloat
        let y: CGFloat
        switch hotspot.xUnits {
        case .pixels:
            x = hotspot.x
        case .insetPixels:
            x = size.width - hotspot.x
        case .fraction:
            x = size.width * hotspot.x
        }
        switch hotspot.yUnits {
        case .pixels:
            y = size.height - hotspot.y
        case .insetPixels:
            y = hotspot.y
        case .fraction:
            y = size.height * (1 - hotspot.y)
        }
        return CGPoint(x: x, y: y)
    }


    func loadStyles() {
        styles = [:]
        styleMaps = [:]
        SDWebImagePrefetcher.shared.cancelPrefetching()
        let styleFetchRequest: NSFetchRequest<KMLPlaces.Style> = KMLPlaces.Style.fetchRequest()
        let styleMapFetchRequest: NSFetchRequest<KMLPlaces.StyleMap> = KMLPlaces.StyleMap.fetchRequest()
        do {
            let context = PersistenceController.shared.context
            let styleFetchResults = try context.fetch(styleFetchRequest)
            let styleMapFetchResults = try context.fetch(styleMapFetchRequest)
            styleFetchResults.forEach { styleObject in
                guard let id = styleObject.id, let style = styleObject.style else { return }
                styles[id] = style
            }
            prefetchIcons()
            styleMapFetchResults.forEach { styleMapObject in
                guard let id = styleMapObject.id, let styleMap = styleMapObject.styleMap else { return }
                styleMaps[id] = styleMap
            }
        } catch {
            Logger.logError(error)
        }
    }

    // MARK: - Private

    private var styles: [String: Style] = [:]
    private var styleMaps: [String: StyleMap] = [:]

    private func prefetchIcons() {
        let allIconURLs = styles.values.map { $0.iconURL }
        SDWebImagePrefetcher.shared.prefetchURLs(allIconURLs)
    }
}

// MARK: - Subtypes

extension StyleManager {

    struct Style {
        let scale: Double
        let iconURL: URL
        let hotspot: Hotspot
    }

    struct Hotspot {
        let x: Double
        let y: Double
        let xUnits: HotspotUnits
        let yUnits: HotspotUnits
    }

    struct StyleMap {
        let normal: String
        let highlighted: String
    }
}

enum HotspotUnits: String {
    case pixels
    case insetPixels
    case fraction
}

// MARK: - Convenience

private extension Style {

    var style: StyleManager.Style? {
        // This guard statement shouldn't fail since `KMLParser` also makes these checks before creating a Style object.
        guard let icon = icon,
              let iconURL = URL(string: icon),
              let hotspotXUnitsString = hotspotXUnits,
              let hotspotXUnits = HotspotUnits(rawValue: hotspotXUnitsString),
              let hotspotYUnitsString = hotspotYUnits,
              let hotspotYUnits = HotspotUnits(rawValue: hotspotYUnitsString) else {
            return nil
        }
        let hotspot = StyleManager.Hotspot(x: hotspotX,
                                           y: hotspotY,
                                           xUnits: hotspotXUnits,
                                           yUnits: hotspotYUnits)
        return StyleManager.Style(scale: scale,
                                  iconURL: iconURL,
                                  hotspot: hotspot)
    }
}

private extension StyleMap {

    var styleMap: StyleManager.StyleMap? {
        StyleManager.StyleMap(normal: normal ?? "", highlighted: highlighted ?? "")
    }
}

private extension String {

    /// Removes a # character from the front of the string if necessary
    var removingLeadingHash: String {
        guard hasPrefix("#") else { return self }
        return String(self.dropFirst(1))
    }
}
