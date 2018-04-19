//
//  ManagedObjects.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 13/3/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import Foundation


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
    
    static func add(name: String, notebookName: String) {
    
    }
}


