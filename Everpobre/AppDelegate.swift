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
        
        window = UIWindow()
        
        // let noteVC = NoteViewController()                    // Usando la vista definida en el .xib
        let noteVC = NoteViewByCodeController(note: nil)     // Con generación de la vista por código
        let notesTVC = NoteTableViewController()                // Con vista de tabla
        
        notesTVC.delegate = noteVC;
        
        // Creamos el view controler para la pantalla partida
        let splitViewController = UISplitViewController()
        splitViewController.viewControllers = [
            notesTVC.wrappedInNavigation(),
            noteVC.wrappedInNavigation()
        ]
        
        window?.rootViewController = splitViewController
        window?.makeKeyAndVisible()
        return true
    }
}

