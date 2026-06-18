import Foundation
import SwiftData
import CoreLocation
import SWXMLHash

class SettingsRepository {

    // MARK: - Private

    private let clearABGRHexString = "00000000"

    private var controller: PersistenceController {
        .shared
    }

    private var userDefaults: UserDefaults {
        .standard
    }

    private var modelContext: ModelContext {
        controller.modelContext
    }

    /// Delete everything in Core Data
    private func deleteAllData() throws {
        try modelContext.delete(model: Point.self)
        try modelContext.delete(model: LineString.self)
        try modelContext.delete(model: Polygon.self)
        try modelContext.delete(model: Placemark.self)
        try modelContext.delete(model: Folder.self)
        try modelContext.delete(model: Style.self)
        try modelContext.delete(model: StyleMap.self)
    }

    // MARK: - Private - Parsing methods

    /// Parse the root `<Document>` KML element
    private func parseDocument(_ documentKML: XMLIndexer) {
        // Parse style elements
        for child in documentKML.children {
            guard let element = child.element else { continue }
            switch element.name {
            case KMLNames.style:
                parseStyle(child)
            case KMLNames.styleMap:
                parseStyleMap(child)
            default:
                break
            }
        }
        let children = documentKML.children
        let documentHasMultipleFolders = children.containsMultiple(where: { $0.element?.name == KMLNames.folder })
        let documentHasPlacemarks = children.contains(where: { $0.element?.name == KMLNames.placemark })
        let shouldCreateNewRootFolder = documentHasPlacemarks || documentHasMultipleFolders
        if shouldCreateNewRootFolder {
            let folder = Folder(name: documentKML.documentName)
            modelContext.insert(folder)
            for child in documentKML.children {
                guard let element = child.element else { continue }
                switch element.name {
                case KMLNames.folder:
                    parseFolder(child, parentFolder: folder)
                case KMLNames.placemark:
                    parsePlacemark(child, folder: folder)
                default:
                    break
                }
            }
        } else {
            let rootFolderKML = documentKML[KMLNames.folder]
            parseFolder(rootFolderKML)
        }
    }

    /// Parse a `<Style>` KML element
    private func parseStyle(_ styleKML: XMLIndexer) {
        guard let element = styleKML.element,
              let id = element.attribute(by: KMLAttributes.id)?.text,
              !id.isEmpty,
              let iconStyleKML = styleKML.firstChildElement(withName: KMLNames.iconStyle),
              let iconKML = iconStyleKML.firstChildElement(withName: KMLNames.icon),
              let iconURLString = iconKML.firstChildElement(withName: KMLNames.href)?.text,
              let iconURL = URL(string: iconURLString) else {
            return
        }
        let style = Style(id: id, icon: iconURL.absoluteString)
        modelContext.insert(style)
        if let scaleText = iconStyleKML.firstChildElement(withName: KMLNames.scale)?.text,
           let scale = Double(scaleText) {
            style.scale = scale
        }
        if let hotspot = iconStyleKML.firstChildElement(withName: KMLNames.hotSpot)?.element,
           let hotspotXString = hotspot.attribute(by: KMLAttributes.x)?.text,
           let hotspotX = Double(hotspotXString),
           let hotspotYString = hotspot.attribute(by: KMLAttributes.y)?.text,
           let hotspotY = Double(hotspotYString),
           let hotspotXUnitsString = hotspot.attribute(by: KMLAttributes.xUnits)?.text,
           let hotspotXUnits = HotspotUnits(rawValue: hotspotXUnitsString),
           let hotspotYUnitsString = hotspot.attribute(by: KMLAttributes.yUnits)?.text,
           let hotspotYUnits = HotspotUnits(rawValue: hotspotYUnitsString) {
            style.hotspotX = hotspotX
            style.hotspotY = hotspotY
            style.hotspotXUnits = hotspotXUnits.rawValue
            style.hotspotYUnits = hotspotYUnits.rawValue
        }
        if let lineStyle = styleKML.firstChildElement(withName: KMLNames.lineStyle) {
            if let colorHexString = lineStyle.firstChildElement(withName: KMLNames.color)?.text {
                style.strokeColorHexString = colorHexString
            }
            if let widthString = lineStyle.firstChildElement(withName: KMLNames.width)?.text,
               let width = Double(widthString) {
                style.strokeWidth = width
            }
        }
        if let polyStyle = styleKML.firstChildElement(withName: KMLNames.polyStyle) {
            if let colorHexString = polyStyle.firstChildElement(withName: KMLNames.color)?.text {
                style.fillColorHexString = colorHexString
            }
            // If the PolyStyle has <fill>0</fill> it means the polygon fill is disabled,
            // and if it has <outline>0</outline> it means the polygon stroke is disabled.
            // This can be handled by just setting the stroke or fill color to clear.
            if let fillString = polyStyle.firstChildElement(withName: KMLNames.fill)?.text,
               let fill = Int(fillString),
               fill == 0 {
                style.fillColorHexString = clearABGRHexString
            }
            if let outlineString = polyStyle.firstChildElement(withName: KMLNames.outline)?.text,
               let outline = Int(outlineString),
               outline == 0 {
                style.strokeColorHexString = clearABGRHexString
            }
        }
    }

    /// Parse a `<StyleMap>` KML element
    private func parseStyleMap(_ styleMapKML: XMLIndexer) {
        guard let element = styleMapKML.element,
              let id = element.attribute(by: KMLAttributes.id)?.text,
              !id.isEmpty else {
            return
        }
        let styleMap = StyleMap(id: id)
        modelContext.insert(styleMap)
        let pairs = styleMapKML.children.filter { $0.element?.name.lowercased() == KMLNames.pair.lowercased() }
        pairs.forEach { pair in
            guard let key = pair.firstChildElement(withName: KMLNames.key)?.text,
                  !key.isEmpty,
                  let styleURL = pair.firstChildElement(withName: KMLNames.styleURL)?.text,
                  !styleURL.isEmpty else {
                return
            }
            switch key {
            case "normal":
                styleMap.normal = styleURL
            case "highlight":
                styleMap.highlighted = styleURL
            default:
                return
            }
        }
    }

    /// Parse a `<Folder>` KML element
    private func parseFolder(_ folderKML: XMLIndexer, parentFolder: Folder? = nil) {
        let folder = Folder(
            name: folderKML.nameText ?? String(localized: .untitledFolder),
            parentFolder: parentFolder
        )
        modelContext.insert(folder)
        for child in folderKML.children {
            guard let elementName = child.element?.name else { continue }
            switch elementName {
            case KMLNames.folder:
                parseFolder(child, parentFolder: folder)
            case KMLNames.placemark:
                parsePlacemark(child, folder: folder)
            default:
                break
            }
        }
    }

    /// Parse a `<Placemark>` KML element
    private func parsePlacemark(_ placemarkKML: XMLIndexer, folder: Folder) {
        let placemark = Placemark(
            name: placemarkKML.nameText ?? String(localized: .untitledPlace),
            kmlDescription: placemarkKML.kmlDescription ?? String(localized: .noDescription),
            styleURL: placemarkKML.firstChildElement(withName: KMLNames.styleURL)?.text,
            folder: folder
        )
        modelContext.insert(placemark)
        for child in placemarkKML.children {
            guard let elementName = child.element?.name else { continue }
            switch elementName {
            case KMLNames.point:
                parsePoint(child, placemark: placemark)
            case KMLNames.lineString:
                parseLineString(child, placemark: placemark)
            case KMLNames.polygon:
                parsePolygon(child, placemark: placemark)
            default:
                continue
            }
        }
    }

    /// Parse a `<Point>` KML element
    private func parsePoint(_ pointKML: XMLIndexer, placemark: Placemark) {
        guard let coordinatesText = pointKML.coordinatesText,
              let coordinate = parseCoordinates(coordinatesText).first else { return }
        let point = Point(latitude: coordinate.latitude, longitude: coordinate.longitude, placemark: placemark)
        modelContext.insert(point)
    }

    /// Parse a `<LineString>` KML element
    private func parseLineString(_ lineStringKML: XMLIndexer, placemark: Placemark) {
        guard let coordinatesText = lineStringKML.coordinatesText else { return }
        let coordinates = parseCoordinates(coordinatesText)
        guard coordinates.count >= 2 else { return }
        let lineString = LineString(placemark: placemark, points: points(from: coordinates))
        modelContext.insert(lineString)
    }

    /// Parse a `<Polygon>` KML element
    private func parsePolygon(_ polygonKML: XMLIndexer, placemark: Placemark) {
        guard let outerBoundaryKML = polygonKML.firstChildElement(withName: KMLNames.outerBoundaryIs),
              let linearRingKML = outerBoundaryKML.firstChildElement(withName: KMLNames.linearRing),
              let coordinatesText = linearRingKML.coordinatesText else { return }
        let coordinates = parseCoordinates(coordinatesText)
        guard coordinates.count >= 3 else { return }
        let polygon = Polygon(placemark: placemark, points: points(from: coordinates))
        modelContext.insert(polygon)
    }

    /// Parse text from a `<coordinates>` KML element into an array of coordinate structs
    private func parseCoordinates(_ coordinatesText: String) -> [CLLocationCoordinate2D] {
        let coordinates = coordinatesText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
        return coordinates.compactMap { coordinateText -> CLLocationCoordinate2D? in
            let components = coordinateText.components(separatedBy: ",")
            guard let longitude = Double(components[0]), let latitude = Double(components[1]) else { return nil }
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }

    private func points(from coordinates: [CLLocationCoordinate2D]) -> [Point] {
        coordinates.enumerated().map { (index, coordinate) -> Point in
            let point = Point(index: index, latitude: coordinate.latitude, longitude: coordinate.longitude)
            modelContext.insert(point)
            return point
        }
    }
}

// MARK: - SettingsDataStore

extension SettingsRepository: SettingsDataStore {

    var shouldShowPolygonsOnMap: Bool {
        get { userDefaults.shouldShowPolygonsOnMap }
        set { userDefaults.shouldShowPolygonsOnMap = newValue }
    }

    var shouldShowPolylinesOnMap: Bool {
        get { userDefaults.shouldShowPolylinesOnMap }
        set { userDefaults.shouldShowPolylinesOnMap = newValue }
    }

    func parseKMLFile(at url: URL) -> Error? {
        let kmlData: Data
        do {
            kmlData = try Data(contentsOf: url)
            try deleteAllData()
        } catch {
            Logger.logError(error)
            return error
        }
        let kml = SWXMLHash.parse(kmlData)
        let documentKML = kml[KMLNames.kml][KMLNames.document]
        parseDocument(documentKML)
        controller.saveContext()
        StyleManager.shared.loadStyles(persistenceController: controller)
        return nil
    }
}

// MARK: - Convenience

private extension XMLIndexer {

    var documentName: String {
        var documentName = nameText ?? String(localized: .myPlaces)
        if documentName.hasSuffix(".kml") {
            documentName = String(documentName.dropLast(4))
        }
        return documentName
    }

    var nameText: String? {
        firstChildElement(withName: KMLNames.name)?.text
    }

    var kmlDescription: String? {
        firstChildElement(withName: KMLNames.description)?.text
    }

    var coordinatesText: String? {
        firstChildElement(withName: KMLNames.coordinates)?.text
    }

    var text: String? {
        element?.text
    }

    func firstChildElement(withName name: String) -> XMLIndexer? {
        return children.first(where: { $0.element?.name.lowercased() == name.lowercased() })
    }
}

// MARK: - KML strings

private struct KMLNames {
    static let color = "color"
    static let coordinates = "coordinates"
    static let description = "description"
    static let document = "Document"
    static let fill = "fill"
    static let folder = "Folder"
    static let hotSpot = "hotSpot"
    static let href = "href"
    static let icon = "Icon"
    static let iconStyle = "IconStyle"
    static let key = "key"
    static let kml = "kml"
    static let linearRing = "LinearRing"
    static let lineString = "LineString"
    static let lineStyle = "LineStyle"
    static let name = "name"
    static let outerBoundaryIs = "outerBoundaryIs"
    static let outline = "outline"
    static let pair = "Pair"
    static let placemark = "Placemark"
    static let point = "Point"
    static let polygon = "Polygon"
    static let polyStyle = "PolyStyle"
    static let scale = "scale"
    static let style = "Style"
    static let styleMap = "StyleMap"
    static let styleURL = "styleUrl"
    static let width = "width"
}

private struct KMLAttributes {
    static let id = "id"
    static let x = "x"
    static let xUnits = "xunits"
    static let y = "y"
    static let yUnits = "yunits"
}
