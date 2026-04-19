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
        let context = controller.context
        let rootFolder = Folder(context: context)
        rootFolder.name = "My Places"
        let folder = Folder(context: context)
        folder.name = "My Folder"
        folder.parentFolder = rootFolder
        let placemark1 = Placemark(context: context)
        placemark1.name = "My House"
        placemark1.folder = rootFolder
        let point = Point(context: context)
        point.latitude = 40.78318
        point.longitude = -73.95403
        point.placemark = placemark1
        let placemark2 = Placemark(context: context)
        placemark2.name = "My Street"
        placemark2.folder = rootFolder
        let lineString = LineString(context: context)
        let lineStringPoint1 = Point(context: context)
        lineStringPoint1.latitude = 40.781961
        lineStringPoint1.longitude = -73.951523
        let lineStringPoint2 = Point(context: context)
        lineStringPoint2.latitude = 40.784706
        lineStringPoint2.longitude = -73.958012
        lineString.points = [lineStringPoint1, lineStringPoint2]
        lineString.placemark = placemark2
        let placemark3 = Placemark(context: context)
        placemark3.name = "My Neighborhood"
        placemark3.folder = rootFolder
        let polygon = Polygon(context: context)
        polygon.placemark = placemark3
        let linearRing = LinearRing(context: context)
        let linearRingPoint1 = Point(context: context)
        linearRingPoint1.latitude = 40.787880
        linearRingPoint1.longitude = -73.955780
        let linearRingPoint2 = Point(context: context)
        linearRingPoint2.latitude = 40.785194
        linearRingPoint2.longitude = -73.949308
        let linearRingPoint3 = Point(context: context)
        linearRingPoint3.latitude = 40.778803
        linearRingPoint3.longitude = -73.953953
        let linearRingPoint4 = Point(context: context)
        linearRingPoint4.latitude = 40.781546
        linearRingPoint4.longitude = -73.960404
        let linearRingPoint5 = Point(context: context)
        linearRingPoint5.latitude = 40.787880
        linearRingPoint5.longitude = -73.955780
        linearRing.points = [linearRingPoint1,
                             linearRingPoint2,
                             linearRingPoint3,
                             linearRingPoint4,
                             linearRingPoint5]
        linearRing.outerPolygon = polygon
        controller.saveContext()
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
