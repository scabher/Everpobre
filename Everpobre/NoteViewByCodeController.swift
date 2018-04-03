//
//  NoteViewByCodeController.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 8/3/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import UIKit

class NoteViewByCodeController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let dateLabel = UILabel()
    let expirationDate = UILabel()
    let titleTextField = UITextField()
    let noteTextView = UITextView()
    
    let imageView = UIImageView()
    var topImgConstraint: NSLayoutConstraint!
    var bottomImgConstraint: NSLayoutConstraint!
    var leftImgConstraint: NSLayoutConstraint!
    var rightImgConstraint: NSLayoutConstraint!
    
    var relativePoint: CGPoint!
    
    var note: Note?
    
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
        
        // Configure imageView
        imageView.backgroundColor = .red
        backView.addSubview(imageView)
        
        // MARK: Autolayout
        // No traslada las autoresize rules to constraints
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        expirationDate.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
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

        // Option A
        // dateLabel.topAnchor.constraint(equalTo: backView.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        
        // Option B
        constraints.append(NSLayoutConstraint(
            item: dateLabel,
            attribute: .top,
            relatedBy: .equal,
            toItem: backView.safeAreaLayoutGuide, // Toma como referencia el safe area (importante para iPhone X)
            attribute: .top,
            multiplier: 1,
            constant: 10))
        
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
        
        // Img View Constraints
        topImgConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .top,
            relatedBy: .equal,
            toItem: noteTextView,
            attribute: .top,
            multiplier: 1,
            constant: 20)
        
        bottomImgConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: noteTextView,
            attribute: .bottom,
            multiplier: 1,
            constant: -20)
        
        leftImgConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .left,
            relatedBy: .equal,
            toItem: noteTextView,
            attribute: .left,
            multiplier: 1,
            constant: 20)
        
        rightImgConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .right,
            relatedBy: .equal,
            toItem: noteTextView,
            attribute: .right,
            multiplier: 1,
            constant: -20)
        
        var imgConstraints = [NSLayoutConstraint(
            item: imageView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0,
            constant: 100)]
        
        imgConstraints.append(NSLayoutConstraint(
            item: imageView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0,
            constant: 150))
        
        imgConstraints.append(contentsOf: [topImgConstraint, bottomImgConstraint, leftImgConstraint, rightImgConstraint])
        
        backView.addConstraints(constraints)
        backView.addConstraints(imgConstraints)
        
        NSLayoutConstraint.deactivate([bottomImgConstraint, rightImgConstraint])
        
        self.view = backView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        
        // MARK: Navigation Controller
        navigationController?.isToolbarHidden = false
        
        let photoBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(pickPhoto))
        
        let mapBarButton = UIBarButtonItem(title: "Map", style: .done, target: self, action: #selector(addMap))

        // Para posicionar botones en el Toolbar
        //let fixSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        self.setToolbarItems([photoBarButton, flexibleSpace, mapBarButton], animated: false)
        
        /*
        // Lo que se puede modificar de una vista en uns animación
         
        imageView.frame = CGRect(x: 15, y: 50, width: 100, height: 150)
        imageView.bounds = CGRect(x: 0, y: 0, width: 100, height: 150)
        imageView.center = CGPoint(x: 15+100/2, y: 50+150/2)
        imageView.transform = CGAffineTransform(rotationAngle: 45)
        */

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeKeyboard))
        swipeGesture.direction = .down
        
        view.addGestureRecognizer(swipeGesture)
        
        imageView.isUserInteractionEnabled = true // Está desactivado por defecto
//        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(moveImage))
//        doubleTapGesture.numberOfTapsRequired = 2
//
//        imageView.addGestureRecognizer(doubleTapGesture)
        
        
        // Se puede hacer con un UIPanGestureRecognizer, aunque en este caso es mejor el LongPress
        // porque se activa cuando lleva pulsado un rato, así se evita moverlo por error.
        let moveViewGesture = UILongPressGestureRecognizer(target: self, action: #selector(userMoveImage))
        imageView.addGestureRecognizer(moveViewGesture)
        
        // MARK: About Note
        if note != nil {
            titleTextField.text = note?.title
            noteTextView.text = note?.content
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
        else {
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
    
    @objc func userMoveImage(longPressGesture: UILongPressGestureRecognizer) {
        let location = longPressGesture.location(in: noteTextView)  // Porque las constraints están respecto a noteTextView
        
        switch longPressGesture.state {
        case .began:
            closeKeyboard()
            relativePoint = longPressGesture.location(in: longPressGesture.view)
            UIView.animate(withDuration: 0.1, animations: {
                self.imageView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            })
        case .changed:
            leftImgConstraint.constant = location.x - relativePoint.x
            topImgConstraint.constant = location.y - relativePoint.y
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.1, animations: {
                self.imageView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            })
        default:
            break
        }
    }
    
    // La vista ha cambiado el layout de una subview
    override func viewDidLayoutSubviews() {
        // Para que el texto del text area rodee el cuadrado, se excluye el cuadrado
        var rect = view.convert(imageView.frame, to: noteTextView)
        rect = rect.insetBy(dx: -15, dy: -15)   // Para agrandar el rectángulo
        
        let paths = UIBezierPath(rect: rect)
        noteTextView.textContainer.exclusionPaths = [paths]
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
    
    @objc func addMap() {
        
    }
    
    // MARK: Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: TextField Delegate
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        note?.title = textField.text
        
        try! note?.managedObjectContext?.save()
    }
    
}
