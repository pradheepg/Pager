//
//  CoreDataManager.swift
//  Pager
//
//  Created by Pradheep G on 21/11/25.
//

import UIKit
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Pager")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error: \(error), \(error.userInfo)")
            }
        }
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveContext() throws {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                try context.save()
        }
    }

    func delete(_ object: NSManagedObject) throws {
        context.delete(object)
        try saveContext()
    }
}
