//
//  NoteMap+CRUD.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 22/4/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import Foundation
import CoreData

extension NoteMap {
    static func add(noteMapMapping: NoteMapMapping, to noteId: NSManagedObjectID, completion: @escaping (NoteMap)->Void) {
        let moc = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        // Asíncrono
        moc.perform {
            let noteMap = NSEntityDescription.insertNewObject(forEntityName: "NoteMap", into: moc) as! NoteMap
            let note = moc.object(with: noteId)
            
            let dict = [
                "positionX": noteMapMapping.position.x,
                "positionY": noteMapMapping.position.y,
                "latitude": noteMapMapping.latitude,
                "longitude": noteMapMapping.logntitude,
                "note": note
                ] as [String : Any]
            noteMap.setValuesForKeys(dict)
            
            // Se guarda en Core Data
            do {
                try moc.save()
            } catch {
                NSLog("Error creating note: \(error)")
            }
            
            DispatchQueue.main.async {
                completion(noteMap)
            }
        }
    }
    
    static func update(id: NSManagedObjectID, noteMapMapping: NoteMapMapping) {
        let moc = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        moc.perform {
            let nmap = moc.object(with: id) as? NoteMap
            guard let noteMap = nmap else {
                NSLog("Note map to update not found")
                return
            }
            
            noteMap.positionX = Int64(noteMapMapping.position.x)
            noteMap.positionY = Int64(noteMapMapping.position.y)
            noteMap.latitude = Double(noteMapMapping.latitude)
            noteMap.longitude = Double(noteMapMapping.logntitude)
            
            // Se guarda en Core Data
            do {
                try moc.save()
            }
            catch {
                NSLog("Error updating note map: \(error)")
            }
        }
    }
}
