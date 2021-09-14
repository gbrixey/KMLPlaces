import CoreData
import SWXMLHash

/// Class that parses KML files and stores the data in Core Data using the shared `PersistenceController`.
/// - todo: Maybe move this code into `SettingsRepository`
class KMLParser {

    // MARK: - Public

    /// Attempts to parse a KML file at the given URL and store the data in Core Data
    class func parseKMLFile(at url: URL) {
        guard let kmlData = try? Data(contentsOf: url) else {
            Logger.logError("Could not load KML file at URL \(url)")
            return
        }
        do {
            try deleteAllData()
        } catch {
            Logger.logError(error)
        }
        let kml = SWXMLHash.parse(kmlData)
        let documentKML = kml[KMLNames.kml][KMLNames.document]
        let documentHasMultipleFolders = documentKML.children.containsMultiple(where: { $0.element?.name == KMLNames.folder })
        let documentHasPlacemarks = documentKML.children.contains(where: { $0.element?.name == KMLNames.placemark })
        let shouldCreateNewRootFolder = documentHasPlacemarks || documentHasMultipleFolders
        if shouldCreateNewRootFolder {
            let folder = Folder(context: context)
            folder.name = documentKML.documentName
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
        controller.saveContext()
    }

    // MARK: - Private

    private class var controller: PersistenceController {
        .shared
    }

    private class var context: NSManagedObjectContext {
        controller.context
    }

    /// Delete everything in Core Data
    private class func deleteAllData() throws {
        let fetchRequests = [Folder.fetchRequest(),
                             LinearRing.fetchRequest(),
                             LineString.fetchRequest(),
                             Placemark.fetchRequest(),
                             Point.fetchRequest(),
                             Polygon.fetchRequest()]
        for request in fetchRequests {
            try context.execute(NSBatchDeleteRequest(fetchRequest: request))
        }
    }

    // MARK: - Private - Parsing methods

    /// Parse a `<Folder>` KML element
    private class func parseFolder(_ folderKML: XMLIndexer, parentFolder: Folder? = nil) {
        let folder = Folder(context: context)
        folder.name = folderKML.nameText ?? String(key: "default.folder.name")
        folder.parentFolder = parentFolder
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
    private class func parsePlacemark(_ placemarkKML: XMLIndexer, folder: Folder) {
        let placemark = Placemark(context: context)
        placemark.name = placemarkKML.nameText ?? String(key: "default.placemark.name")
        placemark.kmlDescription = placemarkKML.kmlDescription ?? String(key: "default.placemark.description")
        placemark.folder = folder
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
    private class func parsePoint(_ pointKML: XMLIndexer, placemark: Placemark) {
        guard let coordinatesText = pointKML.coordinatesText,
              let coordinate = parseCoordinates(coordinatesText).first else { return }
        let point = Point(context: context)
        point.latitude = coordinate.latitude
        point.longitude = coordinate.longitude
        point.placemark = placemark
    }

    /// Parse a `<LineString>` KML element
    private class func parseLineString(_ lineStringKML: XMLIndexer, placemark: Placemark) {
        guard let coordinatesText = lineStringKML.coordinatesText else { return }
        let coordinates = parseCoordinates(coordinatesText)
        guard coordinates.count >= 2 else { return }
        let lineString = LineString(context: context)
        lineString.coordinates = coordinatesText
        lineString.placemark = placemark
    }

    /// Parse a `<Polygon>` KML element
    private class func parsePolygon(_ polygonKML: XMLIndexer, placemark: Placemark) {
        guard let outerBoundaryKML = polygonKML.firstChildElement(withName: KMLNames.outerBoundaryIs),
              let linearRingKML = outerBoundaryKML.firstChildElement(withName: KMLNames.linearRing),
              let coordinatesText = linearRingKML.coordinatesText else { return }
        let coordinates = parseCoordinates(coordinatesText)
        guard coordinates.count >= 3 else { return }
        let polygon = Polygon(context: context)
        polygon.placemark = placemark
        let linearRing = LinearRing(context: context)
        linearRing.coordinates = coordinatesText
        linearRing.outerPolygon = polygon
    }

    /// Parse text from a `<coordinates>` KML element into an array of coordinate structs
    private class func parseCoordinates(_ coordinatesText: String) -> [CLLocationCoordinate2D] {
        let coordinates = coordinatesText.components(separatedBy: " ")
        return coordinates.compactMap { coordinateText -> CLLocationCoordinate2D? in
            let components = coordinateText.components(separatedBy: ",")
            guard let longitude = Double(components[0]), let latitude = Double(components[1]) else { return nil }
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
}

// MARK: - Convenience

private extension XMLIndexer {

    var documentName: String {
        var documentName = nameText ?? String(key: "default.root.folder.name")
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

// MARK: - KMLNames

struct KMLNames {
    static let coordinates = "coordinates"
    static let description = "description"
    static let document = "Document"
    static let folder = "Folder"
    static let kml = "kml"
    static let linearRing = "LinearRing"
    static let lineString = "LineString"
    static let name = "name"
    static let outerBoundaryIs = "outerBoundaryIs"
    static let placemark = "Placemark"
    static let point = "Point"
    static let polygon = "Polygon"
}
