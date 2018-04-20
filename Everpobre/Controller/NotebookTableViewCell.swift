//
//  NotebookTableViewCell.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 19/4/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import UIKit

class NotebookTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var isDefaultSwitch: UISwitch!
    
    // MARK: - Properties
    var notebook: Notebook?

    // MARK: - Initialization
    init() {
        super.init(style: .default, reuseIdentifier: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    // MARK: UI Actions
    @IBAction func defaultChanged(_ sender: Any) {
        let defaultSwitch = sender as! UISwitch
        
        guard let nb = notebook else {
            return
        }
        
        // Sólo se puede activar un nuevo default, no desactivarlo
        if (!defaultSwitch.isOn) {
            defaultSwitch.isOn = true
            return
        }
        
        Notebook.setAsDefault(with: nb.objectID)
    }
    
    @IBAction func nameEndEdit(_ sender: Any) {
        let textField = sender as! UITextField
        
        guard let nb = notebook else {
            return
        }
        
        if (nb.name == textField.text) {
            return
        }
        
        nb.name = textField.text
        Notebook.update(id: nb.objectID, name: textField.text!, isDefault: nb.isDefault)
    }
}

