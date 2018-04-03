//
//  AppDelegate.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 8/3/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow()
        
        // let noteVC = NoteViewController()           // Usando la vista definida en el .xib
        // let noteVC = NoteViewByCodeController()  // Con generación de la vista por código
        let noteVC = NotesTableViewController()     // Con vista de tabla
        let navController = UINavigationController(rootViewController: noteVC)
        
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        return true
    }
}

