//
//  CoreDataStack.swift
//  MapIT
//
//  Created by Mira on 2019/4/18.
//  Copyright © 2019 AppWork. All rights reserved.
//

import CoreData

class CoreDataStack {

    static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MapIT")
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    static var context: NSManagedObjectContext { return persistentContainer.viewContext }

    class func saveContext () {
        let context = persistentContainer.viewContext

        guard context.hasChanges else {
            return
        }

        do {
            try context.save()
            print("Save")
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

    }
    class func fetch<T: NSManagedObject>(_ objectType: T.Type) -> [T] {

        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)

        do {
            let fetchObjects = try context.fetch(fetchRequest) as? [T]
            return fetchObjects ?? [T]()
        } catch {
            print(error)
            return [T]()
        }
    }

}
