//
//  CoreDataManager.swift
//  MapIT
//
//  Created by Mira on 2019/4/18.
//  Copyright © 2019 AppWork. All rights reserved.
//

import CoreData

class CoreDataManager {
    
    enum Entity: String, CaseIterable {
        
        case travel = "Travel"
        
    }
    
    static let shared = CoreDataManager()
    
    struct TravelTime {
        
        static let createTime = "createTimestamp"
    }

    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "MapIT")
        
        container.loadPersistentStores { (_, error) in
            
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext () {
        
        guard viewContext.hasChanges else {
            return
        }

        do {
            try viewContext.save()
            print("Save")
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

    }
    func fetch<T: NSManagedObject>(_ objectType: T.Type) -> [T] {

        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)

        do {
            let fetchObjects = try viewContext.fetch(fetchRequest) as? [T]
            return fetchObjects ?? [T]()
        } catch {
            print(error)
            return [T]()
        }
    }
    //DELETE
    func delete(_ object: NSManagedObject) {
        viewContext.delete(object)
        saveContext()
    }

    typealias AllTravels = (Result<[Travel]>) -> Void

    func getAllTravels(completion: AllTravels) {
        let request = NSFetchRequest<Travel>(entityName: Entity.travel.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: TravelTime.createTime, ascending: true)]
        request.predicate = NSPredicate(format: "isEditting == %@", EdittingStatus.noEditting.rawValue)
        request.fetchLimit = 0

        do {
            let count = try viewContext.count(for: request)
            if count == 0 {
                print("no present")
                completion(Result.nothing)
               
            } else {
                let allTravels = try viewContext.fetch(request)
                completion(Result.success(allTravels))
            }
        } catch {
            completion(Result.failure(error))
        }

    }

}

enum Result<T> {
    
    case success(T)
    
    case nothing
    
    case failure(Error)
}

enum EdittingStatus: String {
    case isEditting = "1"
    case noEditting = "0"
}
