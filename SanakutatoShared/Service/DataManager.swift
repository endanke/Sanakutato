//
//  DataManager.swift
//  Sanakutato
//
//  Created by Daniel Eke on 2020. 10. 05..
//

import CoreData

class DataManager {

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentCloudKitContainer(name: "SanaModel")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func clearDB() {
        [NSFetchRequest<PersistentTerm>(entityName: "PersistentTerm"),
         NSFetchRequest<PersistentSearch>(entityName: "PersistentSearch")].forEach {
            guard let req = $0 as? NSFetchRequest<NSFetchRequestResult> else { return }
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: req)
            _ = try? persistentContainer.viewContext.execute(batchDeleteRequest)
        }
    }
}
