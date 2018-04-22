//
//  NoteImage+CRUD.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 21/4/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import Foundation
import CoreData

extension NoteImage {
    static func add(noteImageMap: NoteImageMapping, to noteId: NSManagedObjectID, completion: @escaping (NoteImage)->Void) {
        let moc = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        // Asíncrono
        moc.perform {
            let noteImage = NSEntityDescription.insertNewObject(forEntityName: "NoteImage", into: moc) as! NoteImage
            let note = moc.object(with: noteId)
            
            let dict = [
                "data": noteImageMap.imageRawData,
                "positionX": noteImageMap.position.x,
                "positionY": noteImageMap.position.y,
                "rotation": noteImageMap.rotation,
                "scale": noteImageMap.scale,
                "note": note
                ] as [String : Any]
            noteImage.setValuesForKeys(dict)
            
            // Se guarda en Core Data
            do {
                try moc.save()
            } catch {
                NSLog("Error creating note: \(error)")
            }
    
            DispatchQueue.main.async {
                completion(noteImage)
            }
        }
    }
    
    static func update(id: NSManagedObjectID, noteImageMap: NoteImageMapping) {
        let moc = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        moc.perform {
            let nimg = moc.object(with: id) as? NoteImage
            guard let noteImage = nimg else {
                NSLog("Note image to update not found")
                return
            }
            
            // noteImage.data = noteImageMap.imageRawData  // no se necesita porque la aplicación no permite cambiar la imagen
            noteImage.positionX = Int64(noteImageMap.position.x)
            noteImage.positionY = Int64(noteImageMap.position.y)
            noteImage.rotation = Float(noteImageMap.rotation)
            noteImage.scale = Float(noteImageMap.scale)
            
            // Se guarda en Core Data
            do {
                try moc.save()
            }
            catch {
                NSLog("Error updating note image: \(error)")
            }
        }
    }
}
