//
//  UIViewController+Additions.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 7/4/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func wrappedInNavigation() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
}
