//
//  CoreDataStack.swift
//  UnoloAssignment
//
//  Created by Pratibha Rai on 16/06/26.
//


import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PhotoGallery")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData failed to load: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }
    
    func saveContext(_ context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
}