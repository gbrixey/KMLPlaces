import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    var context: NSManagedObjectContext {
        container.viewContext
    }

    /// Controller for SwiftUI previews.
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        controller.addTestData()
        return controller
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "KMLPlaces")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            guard let error = error else { return }
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

            /*
             Typical reasons for an error here include:
             * The parent directory does not exist, cannot be created, or disallows writing.
             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
             * The device is out of space.
             * The store could not be migrated to the current model version.
             Check the error message to determine what the actual problem was.
             */
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    /// Try to save the managed object context
    func saveContext () {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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

        addTestPlacemark(
            folder: restaurantsFolder,
            name: "Pi Vegan Pizzeria",
            description: "Pi Vegan Pizzeria serves all plant-based pizza, as well as other dishes like macaroni and cheese. They also have beer on draft.",
            singlePoint: addTestPoint(
                latitude: 47.66721259265039,
                longitude: -122.317679013754
            )
        )
        addTestPlacemark(
            folder: restaurantsFolder,
            name: "The Wayward Cafe",
            description: "This used to be an all-vegan restaurant called The Wayward Vegan. However, under new ownership they started serving meat and changed their name to The Wayward Cafe, causing outrage among their regular customers.",
            singlePoint: addTestPoint(
                latitude: 47.67564026657583,
                longitude: -122.3199066054594
            )
        )
        addTestPlacemark(
            folder: businessesFolder,
            name: "Third Place Books",
            description: "Bookstore in the Ravenna neighborhood selling new and used books. It also has a cafe and a pub attached.",
            singlePoint: addTestPoint(
                latitude: 47.67528951264779,
                longitude: -122.3066173231506
            )
        )
        addTestPlacemark(
            folder: parksFolder,
            name: "Cowen Park",
            description: "Cowen Park is a small park in the Ravenna neighborhood, located immediately west of Ravenna Park.",
            polygonPoints: [
                addTestPoint(latitude: 47.67125568050612, longitude: -122.3140680187018),
                addTestPoint(latitude: 47.67127808155655, longitude: -122.3130818223223),
                addTestPoint(latitude: 47.67207664671408, longitude: -122.3120794324226),
                addTestPoint(latitude: 47.67234309272087, longitude: -122.3120165888455),
                addTestPoint(latitude: 47.67390717522208, longitude: -122.3120369612154),
                addTestPoint(latitude: 47.67333973358522, longitude: -122.3142911218931),
                addTestPoint(latitude: 47.67125568050612, longitude: -122.3140680187018)
            ]
        )
        addTestPlacemark(
            folder: streetsFolder,
            name: "Ravenna Boulevard",
            description: "Ravenna Boulevard is a wide avenue with a tree-lined median that travels in a northwest-to-southeast direction, from Green Lake Way in the northwest to the west side of Ravenna Park in the southeast.",
            lineStringPoints: [
                addTestPoint(latitude: 47.67961362930774, longitude: -122.3255349829181),
                addTestPoint(latitude: 47.67253416352224, longitude: -122.3189811528435),
                addTestPoint(latitude: 47.67141983325081, longitude: -122.3142576889294),
                addTestPoint(latitude: 47.67131859985060, longitude: -122.3141203056747),
                addTestPoint(latitude: 47.67101219232286, longitude: -122.3123694988497),
                addTestPoint(latitude: 47.67002769072340, longitude: -122.3096939009431),
                addTestPoint(latitude: 47.67001047242464, longitude: -122.3095215363726),
                addTestPoint(latitude: 47.67014349271658, longitude: -122.3089110282749),
                addTestPoint(latitude: 47.67036549462302, longitude: -122.3085691131595),
                addTestPoint(latitude: 47.67044182382197, longitude: -122.3084537758835),
                addTestPoint(latitude: 47.67047124685979, longitude: -122.3082534529238),
                addTestPoint(latitude: 47.67045016910718, longitude: -122.3080949812418),
                addTestPoint(latitude: 47.67037879440952, longitude: -122.3079514323733),
                addTestPoint(latitude: 47.67029590913219, longitude: -122.3078792645502),
                addTestPoint(latitude: 47.67018514408787, longitude: -122.3078448081831),
                addTestPoint(latitude: 47.67003752813582, longitude: -122.3078535043908),
                addTestPoint(latitude: 47.66991838636466, longitude: -122.3078418180672),
                addTestPoint(latitude: 47.66978439201531, longitude: -122.3077562994881),
                addTestPoint(latitude: 47.66963843886170, longitude: -122.3076071562979),
                addTestPoint(latitude: 47.66952141980192, longitude: -122.3074294653995),
                addTestPoint(latitude: 47.66942363495200, longitude: -122.3072090773943),
                addTestPoint(latitude: 47.66935194166694, longitude: -122.3069886194044),
                addTestPoint(latitude: 47.66930150957545, longitude: -122.3067810304523),
                addTestPoint(latitude: 47.66926492703744, longitude: -122.3065768607970),
                addTestPoint(latitude: 47.66928316655109, longitude: -122.3061855761346),
                addTestPoint(latitude: 47.66938536756454, longitude: -122.3055392381266),
                addTestPoint(latitude: 47.66945131452005, longitude: -122.3050119745598),
                addTestPoint(latitude: 47.66945232903863, longitude: -122.3045269465003),
                addTestPoint(latitude: 47.66943664670067, longitude: -122.3040720269650)
            ]
        )
        saveContext()
    }

    private func addTestFolder(name: String, parentFolder: Folder? = nil) -> Folder {
        let folder = Folder(context: context)
        folder.name = name
        folder.parentFolder = parentFolder
        return folder
    }

    private func addTestPlacemark(
        folder: Folder,
        name: String,
        description: String,
        singlePoint: Point? = nil,
        lineStringPoints: [Point] = [],
        polygonPoints: [Point] = []
    ) {
        let placemark = Placemark(context: context)
        placemark.folder = folder
        placemark.name = name
        placemark.kmlDescription = description
        placemark.point = singlePoint
        if !lineStringPoints.isEmpty {
            placemark.lineString = LineString(context: context)
            placemark.lineString?.points = NSOrderedSet(array: lineStringPoints)
        }
        if !polygonPoints.isEmpty {
            placemark.polygon = Polygon(context: context)
            placemark.polygon?.outerBoundary = LinearRing(context: context)
            placemark.polygon?.outerBoundary?.points = NSOrderedSet(array: polygonPoints)
        }
    }

    private func addTestPoint(latitude: Double, longitude: Double) -> Point {
        let point = Point(context: context)
        point.latitude = latitude
        point.longitude = longitude
        return point
    }
}
