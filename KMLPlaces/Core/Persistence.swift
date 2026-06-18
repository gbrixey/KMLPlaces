import SwiftData

struct PersistenceController {
    static let shared = PersistenceController()

    let modelContainer: ModelContainer
    let modelContext: ModelContext

    /// Controller for SwiftUI previews.
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        controller.addTestData()
        return controller
    }()

    init(inMemory: Bool = false) {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
            modelContainer = try ModelContainer(
                for: Folder.self, LineString.self, Placemark.self, Point.self, Polygon.self, Style.self, StyleMap.self,
                configurations: configuration
            )
            modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
    }

    /// Try to save the managed object context
    func saveContext () {
        guard modelContext.hasChanges else { return }
        do {
            try modelContext.save()
        } catch {
            fatalError("Failed to save model context: \(error)")
        }
    }
}

// MARK: - Test data

extension PersistenceController {

    /// Add test data for use in SwiftUI Previews, unit tests, and UI tests
    func addTestData() {
        let rootFolder = addTestFolder(name: "Seattle Places")
        let businessesFolder = addTestFolder(name: "Businesses", parentFolder: rootFolder)
        let restaurantsFolder = addTestFolder(name: "Restaurants", parentFolder: businessesFolder)
        let parksFolder = addTestFolder(name: "Parks", parentFolder: rootFolder)
        let streetsFolder = addTestFolder(name: "Streets", parentFolder: rootFolder)

        let pushpinStyleID = addTestStyle(
            id: "pushpin",
            icon: "http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png"
        )
        let diningStyleID = addTestStyle(
            id: "dining",
            icon: "http://maps.google.com/mapfiles/kml/shapes/dining.png"
        )

        addTestPlacemark(
            folder: rootFolder,
            name: "5260 11th Avenue NE",
            description: "This is an Airbnb that I once stayed in.",
            styleURL: pushpinStyleID,
            singlePoint: addTestPoint(
                latitude: 47.66821560184484,
                longitude: -122.3157768181883
            )
        )
        addTestPlacemark(
            folder: restaurantsFolder,
            name: "Pi Vegan Pizzeria",
            description: "Pi Vegan Pizzeria serves all plant-based pizza, as well as other dishes like macaroni and cheese. They also have beer on draft.",
            styleURL: diningStyleID,
            singlePoint: addTestPoint(
                latitude: 47.66721259265039,
                longitude: -122.317679013754
            )
        )
        addTestPlacemark(
            folder: restaurantsFolder,
            name: "The Wayward Cafe",
            description: "This used to be an all-vegan restaurant called The Wayward Vegan. However, under new ownership they started serving meat and changed their name to The Wayward Cafe, causing outrage among their regular customers.",
            styleURL: diningStyleID,
            singlePoint: addTestPoint(
                latitude: 47.67564026657583,
                longitude: -122.3199066054594
            )
        )
        addTestPlacemark(
            folder: businessesFolder,
            name: "Third Place Books",
            description: "Bookstore in the Ravenna neighborhood selling new and used books. It also has a cafe and a pub attached.",
            styleURL: pushpinStyleID,
            singlePoint: addTestPoint(
                latitude: 47.67528951264779,
                longitude: -122.3066173231506
            )
        )
        addTestPlacemark(
            folder: parksFolder,
            name: "Cowen Park",
            description: "Cowen Park is a small park in the Ravenna neighborhood, located immediately west of Ravenna Park.",
            styleURL: pushpinStyleID,
            polygonPoints: [
                addTestPoint(index: 1, latitude: 47.67125568050612, longitude: -122.3140680187018),
                addTestPoint(index: 2, latitude: 47.67127808155655, longitude: -122.3130818223223),
                addTestPoint(index: 3, latitude: 47.67207664671408, longitude: -122.3120794324226),
                addTestPoint(index: 4, latitude: 47.67234309272087, longitude: -122.3120165888455),
                addTestPoint(index: 5, latitude: 47.67390717522208, longitude: -122.3120369612154),
                addTestPoint(index: 6, latitude: 47.67333973358522, longitude: -122.3142911218931),
                addTestPoint(index: 7, latitude: 47.67125568050612, longitude: -122.3140680187018)
            ]
        )
        addTestPlacemark(
            folder: streetsFolder,
            name: "Ravenna Boulevard",
            description: "Ravenna Boulevard is a wide avenue with a tree-lined median that travels in a northwest-to-southeast direction, from Green Lake Way in the northwest to the west side of Ravenna Park in the southeast.",
            styleURL: pushpinStyleID,
            lineStringPoints: [
                addTestPoint(index: 1, latitude: 47.67961362930774, longitude: -122.3255349829181),
                addTestPoint(index: 2, latitude: 47.67253416352224, longitude: -122.3189811528435),
                addTestPoint(index: 3, latitude: 47.67141983325081, longitude: -122.3142576889294),
                addTestPoint(index: 4, latitude: 47.67131859985060, longitude: -122.3141203056747),
                addTestPoint(index: 5, latitude: 47.67101219232286, longitude: -122.3123694988497),
                addTestPoint(index: 6, latitude: 47.67002769072340, longitude: -122.3096939009431),
                addTestPoint(index: 7, latitude: 47.67001047242464, longitude: -122.3095215363726),
                addTestPoint(index: 8, latitude: 47.67014349271658, longitude: -122.3089110282749),
                addTestPoint(index: 9, latitude: 47.67036549462302, longitude: -122.3085691131595),
                addTestPoint(index: 10, latitude: 47.67044182382197, longitude: -122.3084537758835),
                addTestPoint(index: 11, latitude: 47.67047124685979, longitude: -122.3082534529238),
                addTestPoint(index: 12, latitude: 47.67045016910718, longitude: -122.3080949812418),
                addTestPoint(index: 13, latitude: 47.67037879440952, longitude: -122.3079514323733),
                addTestPoint(index: 14, latitude: 47.67029590913219, longitude: -122.3078792645502),
                addTestPoint(index: 15, latitude: 47.67018514408787, longitude: -122.3078448081831),
                addTestPoint(index: 16, latitude: 47.67003752813582, longitude: -122.3078535043908),
                addTestPoint(index: 17, latitude: 47.66991838636466, longitude: -122.3078418180672),
                addTestPoint(index: 18, latitude: 47.66978439201531, longitude: -122.3077562994881),
                addTestPoint(index: 19, latitude: 47.66963843886170, longitude: -122.3076071562979),
                addTestPoint(index: 20, latitude: 47.66952141980192, longitude: -122.3074294653995),
                addTestPoint(index: 21, latitude: 47.66942363495200, longitude: -122.3072090773943),
                addTestPoint(index: 22, latitude: 47.66935194166694, longitude: -122.3069886194044),
                addTestPoint(index: 23, latitude: 47.66930150957545, longitude: -122.3067810304523),
                addTestPoint(index: 24, latitude: 47.66926492703744, longitude: -122.3065768607970),
                addTestPoint(index: 25, latitude: 47.66928316655109, longitude: -122.3061855761346),
                addTestPoint(index: 26, latitude: 47.66938536756454, longitude: -122.3055392381266),
                addTestPoint(index: 27, latitude: 47.66945131452005, longitude: -122.3050119745598),
                addTestPoint(index: 28, latitude: 47.66945232903863, longitude: -122.3045269465003),
                addTestPoint(index: 29, latitude: 47.66943664670067, longitude: -122.3040720269650)
            ]
        )
        saveContext()
    }

    private func addTestFolder(name: String, parentFolder: Folder? = nil) -> Folder {
        let folder = Folder(name: name, parentFolder: parentFolder)
        modelContext.insert(folder)
        return folder
    }

    private func addTestStyle(id: String, icon: String) -> String {
        let style = Style(
            id: id,
            icon: icon,
            hotspotX: 0.5,
            hotspotXUnits: HotspotUnits.fraction.rawValue,
            hotspotY: 0,
            hotspotYUnits: HotspotUnits.fraction.rawValue
        )
        let styleMap = StyleMap(id: "\(id)_map", normal: id, highlighted: id)
        modelContext.insert(style)
        modelContext.insert(styleMap)
        return styleMap.id
    }

    private func addTestPlacemark(
        folder: Folder,
        name: String,
        description: String,
        styleURL: String,
        singlePoint: Point? = nil,
        lineStringPoints: [Point] = [],
        polygonPoints: [Point] = []
    ) {
        let placemark = Placemark(name: name, kmlDescription: description, styleURL: styleURL, folder: folder, point: singlePoint)
        modelContext.insert(placemark)
        if !lineStringPoints.isEmpty {
            let lineString = LineString(placemark: placemark, points: lineStringPoints)
            modelContext.insert(lineString)
        }
        if !polygonPoints.isEmpty {
            let polygon = Polygon(placemark: placemark, points: polygonPoints)
            modelContext.insert(polygon)
        }
    }

    private func addTestPoint(index: Int? = nil, latitude: Double, longitude: Double) -> Point {
        let point = Point(index: index, latitude: latitude, longitude: longitude)
        modelContext.insert(point)
        return point
    }
}
