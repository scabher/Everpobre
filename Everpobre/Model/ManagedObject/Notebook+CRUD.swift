//
//  Notebook+CRUD.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 18/4/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import Foundation
import CoreData

extension Notebook {
    static func notebooks(in moc: NSManagedObjectContext) -> NSFetchedResultsController<Notebook> {
        let fetchRequest = NSFetchRequest<Notebook>(entityName: "Notebook")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameSort]
        fetchRequest.fetchBatchSize = 25
        
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: moc,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        try! fetchedResultController.performFetch()
        return fetchedResultController
    }
    
    static func named(name: String, in moc: NSManagedObjectContext) -> Notebook? {
        var notebooks: [Notebook] = []
        
        // Se busca el notebook según el nombre
        let fetchRequest = NSFetchRequest<Notebook>(entityName: "Notebook")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        try! notebooks = moc.fetch(fetchRequest)
        
        return notebooks.count == 0 ? nil : notebooks.first
    }
    
    static func add(name: String, in moc: NSManagedObjectContext) {
        moc.perform {
            // KVC
            let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into: moc) as! Notebook
            let dictNoteBook = [
                "name": name,
                "isDefault": false
                ] as [String : Any]
            notebook.setValuesForKeys(dictNoteBook)
            
            // Se guarda en Core Data
            do {
                try moc.save()
            }
            catch {
                NSLog("Error adding new notebook: \(error)")
            }
        }
    }
    
    static func remove(name: String, in moc: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<Notebook>(entityName: "Notebook")
        let notebooks: [Notebook]
        
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        try! notebooks = moc.fetch(fetchRequest)
        
        if notebooks.count > 0 {            
            // Finalmente se elimina el notebook - Asíncrono
            moc.perform {
                // Se elimina en Core Data
                moc.delete(notebooks.first!)
                try! moc.save()
            }
        }
        else {
            NSLog("Notebook with name \(name) not found")
        }
    }
}
