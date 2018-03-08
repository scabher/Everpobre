//
//  NoteViewByCodeController.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 8/3/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import UIKit

class NoteViewByCodeController: UIViewController {
    
    let dateLabel = UILabel()
    let expirationDate = UILabel()
    let titleTextField = UITextField()
    let noteTextView = UITextView()
    
    override func loadView() {
        let backView = UIView()
        backView.backgroundColor = .white
        
        // Configure Label
        dateLabel.text = "15/02/2018"
        backView.addSubview(dateLabel)
        
        // Configure Label
        expirationDate.text = "24/12/2018"
        backView.addSubview(expirationDate)
        
        // Configure titleTextField
        titleTextField.placeholder = "Note title"
        backView.addSubview(titleTextField)
        
        // Configure noteTextView
        noteTextView.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        backView.addSubview(noteTextView)
        
        // MARK: Autolayout
        // No traslada las autoresize rules to constraints
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        expirationDate.translatesAutoresizingMaskIntoConstraints = false
        
        
        let viewDict = ["dateLabel": dateLabel, "noteTextView": noteTextView, "titleTextField": titleTextField, "expirationDate": expirationDate]
        
        // Horizontal
        var constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "|-10-[titleTextField]-10-[expirationDate]-10-[dateLabel]-10-|",
            options: [],
            metrics: nil,
            views: viewDict)
        
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "|-10-[noteTextView]-10-|",
            options: [],
            metrics: nil,
            views: viewDict))
        
        // Vertical
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "V:[dateLabel]-10-[noteTextView]-10-|",
            options: [],
            metrics: nil,
            views: viewDict))
        
        constraints.append(NSLayoutConstraint(
            item: dateLabel,
            attribute: .top,
            relatedBy: .equal,
            toItem: backView,
            attribute: .top,
            multiplier: 1,
            constant: 20))
        
        constraints.append(NSLayoutConstraint(
            item: expirationDate,
            attribute: .lastBaseline,
            relatedBy: .equal,
            toItem: dateLabel,
            attribute: .lastBaseline,
            multiplier: 1,
            constant: 0))
        
        constraints.append(NSLayoutConstraint(
            item: titleTextField,
            attribute: .lastBaseline,
            relatedBy: .equal,
            toItem: dateLabel,
            attribute: .lastBaseline,
            multiplier: 1,
            constant: 0))
        
        backView.addConstraints(constraints)
        
        self.view = backView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
