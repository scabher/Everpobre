//
//  DataManager.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 12/3/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import UIKit
import CoreData

// Singleton
class DataManager: NSObject {
    
    static let sharedManager = DataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Everpobre")
        container.loadPersistentStores(completionHandler: { (storeDescription,error) in
            
            if let err = error {
                // Error to handle.
                print(err)
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        })
        return container
    }()
}
