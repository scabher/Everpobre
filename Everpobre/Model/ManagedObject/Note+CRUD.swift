//
//  ManagedObjects.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 13/3/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import Foundation
import CoreData


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
    
    static func add(name: String, in notebookName: String, using moc: NSManagedObjectContext) {
        // Asíncrono
        moc.perform {
            // KVC
            // Se busca el notebook según el nombre
            let nb = Notebook.named(name: notebookName, in: moc)
            
            guard let notebook = nb else {
                NSLog("Notebook name not found. Note not created.")
                return
            }
            
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: moc) as! Note
            let dict = [
                "main_title": name,
                "createdAtTI": Date().timeIntervalSince1970,
                "expiredAtTI": Date().timeIntervalSince1970 + EXPIRATION_DELTA,
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
}


