//
//  ManagedObjects.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 13/3/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import Foundation
import CoreData

struct NoteMapping {
    var title: String
    var content: String
    var createdAtTI: Double
    var expiredAtTI: Double
}

extension Note {
    // 2ª opción si viene una clave que no está como propiedad en la clase
    // Sustituye main_title por title
    override public func setValue(_ value: Any?, forUndefinedKey key: String) {
        let keyToIgnore = ["date", "content", "ps"]
        
        if keyToIgnore.contains(key) {
            return
        }
        
        if key == "main_title" {
            self.setValue(value, forKey: "title")
        }
    }
    
    // Obligatorio implementar ambos métodos
    public override func value(forUndefinedKey key: String) -> Any? {
        if key == "main_title" {
            return "main_title"
        }
        
        return super.value(forKey: key)
    }
    
    static func add(noteMapping: NoteMapping, in notebookId: NSManagedObjectID?) {
        let moc = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        // Asíncrono
        moc.perform {
            // KVC
            // Se busca el notebook según el ID o el default
            let nb = notebookId != nil ? moc.object(with: notebookId!) as? Notebook : Notebook.currentDefault(in: moc)
            guard let notebook = nb else {
                NSLog("Notebook id not found. Note not created.")
                return
            }
            
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: moc) as! Note
            let dict = [
                "main_title": noteMapping.title,
                "content": noteMapping.content,
                "createdAtTI": noteMapping.createdAtTI,
                "expiredAtTI": noteMapping.expiredAtTI,
                "notebook": notebook
                ] as [String : Any]
            note.setValuesForKeys(dict)
            
            // Se guarda en Core Data
            do {
                try moc.save()
            } catch {
                NSLog("Error creating note: \(error)")
            }
        }
    }
    
    static func update(id: NSManagedObjectID, noteMapping: NoteMapping) {
        let moc = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        moc.perform {
            let n = moc.object(with: id) as? Note
            guard let note = n else {
                NSLog("Note to update not found")
                return
            }
            
            note.title = noteMapping.title
            note.content = noteMapping.content
            note.expiredAtTI = noteMapping.expiredAtTI
            
            // Se guarda en Core Data
            do {
                try moc.save()
            }
            catch {
                NSLog("Error updating note: \(error)")
            }
        }
    }
}


