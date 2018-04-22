//
//  NoteViewByCodeController.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 8/3/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import UIKit
import MapKit

class NoteViewByCodeController: UIViewController, UINavigationControllerDelegate {
    
    // Mark: - Properties
    let creationDateLabel = UILabel()
    let expirationDateTextField = UITextField()
    let titleTextField = UITextField()
    let noteTextView = UITextView()
    var noteImageViewControllers = [NoteImageViewController]()
    var noteMapViewControllers = [NoteMapViewController]()
    
    var topImgConstraint: NSLayoutConstraint!
    var bottomImgConstraint: NSLayoutConstraint!
    var leftImgConstraint: NSLayoutConstraint!
    var rightImgConstraint: NSLayoutConstraint!
    
    var relativePoint: CGPoint!
    
    var note: Note?
    
    override func loadView() {
        let backView = UIView()
        self.title = "Note Details"
        backView.backgroundColor = .white
        
        // Configure Label
        creationDateLabel.text = "15/02/2018"
        backView.addSubview(creationDateLabel)
        
        // Configure Expiration Date field
        expirationDateTextField.placeholder = "Expired at"
        expirationDateTextField.text = "24/12/2018"
        backView.addSubview(expirationDateTextField)
        
        // Configure titleTextField
        titleTextField.placeholder = "Note title"
        backView.addSubview(titleTextField)
        
        // Configure noteTextView
        noteTextView.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        backView.addSubview(noteTextView)
        
     
        
        // MARK: Autolayout
        // No traslada las autoresize rules to constraints
        creationDateLabel.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        expirationDateTextField.translatesAutoresizingMaskIntoConstraints = false
        
        let viewDict = ["dateLabel": creationDateLabel, "noteTextView": noteTextView, "titleTextField": titleTextField, "expirationDate": expirationDateTextField]
        
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
            item: creationDateLabel,
            attribute: .top,
            relatedBy: .equal,
            toItem: backView.safeAreaLayoutGuide, // Toma como referencia el safe area (importante para iPhone X)
            attribute: .top,
            multiplier: 1,
            constant: 10))
        
        constraints.append(NSLayoutConstraint(
            item: expirationDateTextField,
            attribute: .lastBaseline,
            relatedBy: .equal,
            toItem: creationDateLabel,
            attribute: .lastBaseline,
            multiplier: 1,
            constant: 0))
        
        constraints.append(NSLayoutConstraint(
            item: titleTextField,
            attribute: .lastBaseline,
            relatedBy: .equal,
            toItem: creationDateLabel,
            attribute: .lastBaseline,
            multiplier: 1,
            constant: 0))
        

        
        backView.addConstraints(constraints)
        self.view = backView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        
        // MARK: Navigation Controller
        navigationController?.isToolbarHidden = false
        
        let photoBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(pickPhoto))
        let mapBarButton = UIBarButtonItem(title: "Map", style: .done, target: self, action: #selector(addLocation))

        // Para posicionar botones en el Toolbar
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        self.setToolbarItems([photoBarButton, flexibleSpace, mapBarButton], animated: false)
        
        /*
        // Lo que se puede modificar de una vista en una animación
         
        imageView.frame = CGRect(x: 15, y: 50, width: 100, height: 150)
        imageView.bounds = CGRect(x: 0, y: 0, width: 100, height: 150)
        imageView.center = CGPoint(x: 15+100/2, y: 50+150/2)
        imageView.transform = CGAffineTransform(rotationAngle: 45)
        */

        // MARK: Gestures
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeKeyboard))
        swipeGesture.direction = .down
        
        view.addGestureRecognizer(swipeGesture)
        
        // MARK: About Note
        if note != nil {
            syncModelWithView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleTextField.becomeFirstResponder()
    }

    @objc func closeKeyboard()  {
        if noteTextView.isFirstResponder {      // Es la vista que está como primer respondedor
            noteTextView.resignFirstResponder() // Deja de ser el primer respondedor al gesto
        }
        else if titleTextField.isFirstResponder {
            titleTextField.resignFirstResponder()
        }
    }
    
    @objc func moveImage(tapGesture: UITapGestureRecognizer) {
        if (topImgConstraint.isActive) {
            if (leftImgConstraint.isActive) {
                leftImgConstraint.isActive = false
                rightImgConstraint.isActive = true
            }
            else {
                topImgConstraint.isActive = false
                bottomImgConstraint.isActive = true
            }
        }
        else {
            if (leftImgConstraint.isActive) {
                bottomImgConstraint.isActive = false
                topImgConstraint.isActive = true
            }
            else {
                rightImgConstraint.isActive = false
                leftImgConstraint.isActive = true
            }
        }
        
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func moveNote()  {
        // Modal para seleccionar el notebook
        let sourceId = note!.notebook!.objectID
        let actionSheetAlert = UIAlertController(title: NSLocalizedString("Choose Notebook", comment: "Choose notebook to move notes"), message: nil, preferredStyle: .actionSheet)
        let notebooks = Notebook.notebooks(in: nil)
        
        if (notebooks.fetchedObjects != nil && notebooks.fetchedObjects!.count > 0) {
            for notebook in notebooks.fetchedObjects! {
                if (notebook.objectID != sourceId) {
                    let notebookAction = UIAlertAction(title: notebook.name, style: .default) { (alertAction) in
                        Notebook.moveNote(with: self.note!.objectID, from: sourceId, to: notebook.objectID, in: nil)
                        let notebookButtton = self.navigationItem.rightBarButtonItem?.customView as! UIButton
                        notebookButtton.setTitle(alertAction.title!, for: UIControlState.normal)
                    }
                    actionSheetAlert.addAction(notebookAction)
                }
            }
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .default, handler: nil)
        actionSheetAlert.addAction(cancel)
        
        present(actionSheetAlert, animated: true, completion: nil)
    }
    
   
    // La vista ha cambiado el layout de una subview
    override func viewDidLayoutSubviews() {
        var paths = [UIBezierPath]()
        
        // Para que el texto del text area rodee las imágenes, se excluye el cuadrado
        for imageController in noteImageViewControllers {
            var rect = view.convert(imageController.imageView.frame, to: noteTextView)
            rect = rect.insetBy(dx: -15, dy: -15)   // Para agrandar el rectángulo
            paths.append(UIBezierPath(rect: rect))
            
        }

        noteTextView.textContainer.exclusionPaths = paths
    }
    
    
    // MARK: Toolbar Buttons actions
    @objc func pickPhoto() {
        let actionSheetAlert = UIAlertController(title: NSLocalizedString("Add Photo", comment: "Add Photo"), message: nil, preferredStyle: .actionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        let useCamera = UIAlertAction(title: "Camera", style: .default) { (alertAction) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }

        let usePhotoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (alertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }

        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)

        actionSheetAlert.addAction(useCamera)
        actionSheetAlert.addAction(usePhotoLibrary)
        actionSheetAlert.addAction(cancel)

        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    @objc func addLocation() {

        let coord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let mapView = SelectionMapViewController(coord)
        mapView.delegate = self
        
        present(mapView.wrappedInNavigation(), animated: true, completion: nil)
    }
    
    // Mark: - Sync
    func syncModelWithView() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let creationDate = Date(timeIntervalSince1970: TimeInterval(note?.createdAtTI ?? 0))
        let expirationDate = Date(timeIntervalSince1970: TimeInterval(note?.expiredAtTI ?? 0))
        
        // Botón para cambiar de notebook
        if (note != nil && note?.notebook != nil) {
            let notebookButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(moveNote))
            let notebookButton = UIButton(type: UIButtonType.custom)
            notebookButton.setTitle(note!.notebook!.name, for: UIControlState.normal)
            notebookButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
            notebookButton.addGestureRecognizer(notebookButtonTapGesture)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: notebookButton)
        }
        
        // Model -> View
        titleTextField.text = note?.title
        noteTextView.text = note?.content
        creationDateLabel.text = dateFormatter.string(from: creationDate)
        expirationDateTextField.text =  dateFormatter.string(from: expirationDate)
        
        noteImageViewControllers = [NoteImageViewController]()
        noteMapViewControllers = [NoteMapViewController]()
        
        if note?.images != nil && (note?.images?.count)! > 0 {
            for noteImage in note?.images as! Set<NoteImage> {
                let image = UIImage(data: noteImage.data!)
                let noteImageViewController = NoteImageViewController(image: image!,
                                                                      position: CGPoint(x: Int(noteImage.positionX),
                                                                                        y: Int(noteImage.positionY)),
                                                                      scale: CGFloat(noteImage.scale),
                                                                      rotation: CGFloat(noteImage.rotation),
                                                                      relatedToView: noteTextView,
                                                                      parentController: self)
                noteImageViewController.managedObject = noteImage
                noteImageViewController.showInNoteView()
            }
        }
        
        if note?.maps != nil && (note?.maps?.count)! > 0 {
            for noteMap in note?.maps as! Set<NoteMap> {
                let noteMapViewController = NoteMapViewController(position: CGPoint(x: Int(noteMap.positionX),
                                                                                        y: Int(noteMap.positionY)),
                                                                  latitude: CGFloat(noteMap.latitude),
                                                                  longitude: CGFloat(noteMap.longitude),                                                                                                                    relatedToView: noteTextView,
                                                                      parentController: self)
                noteMapViewController.managedObject = noteMap
                noteMapViewController.showInNoteView()
            }
        }
    }
}

//MARK: NotesTableViewController Delegate
extension NoteViewByCodeController: NoteTableViewControllerDelegate {
    func notesTableViewController(_ vc: NoteTableViewController, didSelectNote note: Note) {
        let collapsed = splitViewController?.isCollapsed ?? true
        
        self.note = note
        syncModelWithView()
        
        if (collapsed) {
            navigationController?.popToViewController(self, animated: true)
        }
    }
}

// MARK: Image Picker Delegate
extension NoteViewByCodeController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {

        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        guard UIImageJPEGRepresentation(image, 1) != nil else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        let imgPadding = CGFloat(20 + (5 * noteImageViewControllers.count + 1))
        let noteImageViewController = NoteImageViewController(image: image,
                                                              position: CGPoint(x: imgPadding, y: imgPadding),
                                                              scale: CGFloat(1),
                                                              rotation: CGFloat(0),
                                                              relatedToView: noteTextView,
                                                              parentController: self)
        NoteImage.add(noteImageMap: noteImageViewController.noteImageMapping, to: note!.objectID) { noteImageManaged in
            noteImageViewController.managedObject = noteImageManaged
            noteImageViewController.showInNoteView()
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: Map Delegates
extension NoteViewByCodeController: SelectionMapViewControllerDelegate {
    func selectionMapViewControl(_ viewControl: SelectionMapViewController, didSelectionLocation: CLLocationCoordinate2D) {
        let mapPadding = CGFloat(50 + (5 * noteImageViewControllers.count + 1))
        let noteMapViewController = NoteMapViewController(position: CGPoint(x: mapPadding, y: mapPadding),
                                                          latitude: CGFloat(didSelectionLocation.latitude),
                                                          longitude: CGFloat(didSelectionLocation.longitude),
                                                          relatedToView: noteTextView,
                                                          parentController: self)
        
        NoteMap.add(noteMapMapping: noteMapViewController.noteMapMapping, to: note!.objectID) { noteMapManaged in
            noteMapViewController.managedObject = noteMapManaged
            noteMapViewController.showInNoteView()
        }
    }
}

// MARK: TextField Delegate
extension NoteViewByCodeController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        note?.title = textField.text
        try! note?.managedObjectContext?.save()
    }
}

