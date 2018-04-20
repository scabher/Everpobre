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
    static func notebooks(in moc: NSManagedObjectContext?) -> NSFetchedResultsController<Notebook> {
        let moc = moc ?? DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
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
    
    static func named(name: String) -> Notebook? {
        let moc = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        var notebooks: [Notebook] = []
        
        // Se busca el notebook según el nombre
        let fetchRequest = NSFetchRequest<Notebook>(entityName: "Notebook")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        try! notebooks = moc.fetch(fetchRequest)
        
        return notebooks.count == 0 ? nil : notebooks.first
    }
    
    static func currentDefault(in moc: NSManagedObjectContext?) -> Notebook? {
        let moc = moc ?? DataManager.sharedManager.persistentContainer.newBackgroundContext()
        var notebooks: [Notebook] = []
        
        // Se busca el notebook que está marcado por defecto
        let fetchRequest = NSFetchRequest<Notebook>(entityName: "Notebook")
        fetchRequest.predicate = NSPredicate(format: "isDefault == %@", NSNumber(value: true))
        
        try! notebooks = moc.fetch(fetchRequest)
        
        return notebooks.count == 0 ? nil : notebooks.first
    }
    
    static func add(name: String, isDefault: Bool) {
        let moc = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        moc.perform {
            // KVC
            let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into: moc) as! Notebook
            let dictNoteBook = [
                "name": name,
                "isDefault": isDefault
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
    
    static func update(id: NSManagedObjectID, name: String, isDefault: Bool) {
        let moc = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        moc.perform {
            let nb = moc.object(with: id) as? Notebook
            guard let notebook = nb else {
                NSLog("Notebook to remove not found")
                return
            }
            
            notebook.name = name
            notebook.isDefault = isDefault
            
            // Se guarda en Core Data
            do {
                try moc.save()
            }
            catch {
                NSLog("Error updating notebook: \(error)")
            }
        }
    }
    
    static func remove(id: NSManagedObjectID, in moc: NSManagedObjectContext?) {
        let moc = moc ?? DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        moc.perform {
            let nb = moc.object(with: id) as? Notebook
            
            guard let notebook = nb else {
                NSLog("Notebook to remove not found")
                return
            }
            
            // Se elimina en Core Data
            moc.delete(notebook)
            
            // Se guarda en Core Data
            do {
                try moc.save()
            }
            catch {
                NSLog("Error deleting notebook: \(error)")
            }
        }
    }
    
    static func setAsDefault(with id: NSManagedObjectID) {
        let moc = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        let currentDefaultNotebook = currentDefault(in: moc)
        
        moc.perform {
            let nb = moc.object(with: id) as? Notebook
            guard let notebook = nb else {
                NSLog("Notebook to remove not found")
                return
            }
            
            if (currentDefaultNotebook != nil) {
                currentDefaultNotebook?.isDefault = false
            }
            
            notebook.isDefault = true
            
            // Se guarda en Core Data
            do {
                try moc.save()
            }
            catch {
                NSLog("Error updating notebook: \(error)")
            }
        }
    }
    
    static func moveNotes(from sourceId: NSManagedObjectID, to targetId: NSManagedObjectID, in moc: NSManagedObjectContext?) {
        let moc = moc ?? DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        moc.perform {
            let nbSource = moc.object(with: sourceId) as? Notebook
            let nbTarget = moc.object(with: targetId) as? Notebook
            guard let notebookSource = nbSource,
                let notebookTarget = nbTarget else {
                NSLog("Notebook to move from/to notes not found")
                return
            }
            
            for note in notebookSource.notes as! Set<Note>{
                note.notebook = nbTarget
                notebookTarget.addToNotes(note)
                notebookSource.removeFromNotes(note)
            }
            
            // Se guarda en Core Data
            do {
                try moc.save()
            }
            catch {
                NSLog("Error updating notebook: \(error)")
            }
        }
    }
}
