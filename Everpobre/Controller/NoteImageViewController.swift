//
//  NoteImageView.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 21/4/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//
import UIKit


struct NoteImageMapping {
    var imageRawData: Data
    var scale: CGFloat
    var rotation: CGFloat
    var position: CGPoint!
}

class NoteImageViewController {
    let imageView: UIImageView
    let relatedToView: UIView
    var topImgConstraint: NSLayoutConstraint!
    var leftImgConstraint: NSLayoutConstraint!
    var constraints: [NSLayoutConstraint]!
    var relativePoint: CGPoint!
    let parentController: NoteViewByCodeController
    var noteImageMapping: NoteImageMapping
    

    var managedObject: NoteImage?

    init(image: UIImage, position: CGPoint, scale: CGFloat, rotation:  CGFloat, relatedToView: UIView, parentController: NoteViewByCodeController) {
        
        self.relatedToView = relatedToView
        self.parentController = parentController
        self.imageView = UIImageView(image: image)
        
        self.noteImageMapping = NoteImageMapping(imageRawData: UIImageJPEGRepresentation(image, 1)!,
                                                 scale: scale,
                                                 rotation: rotation,
                                                 position: position)
    }
    
    deinit {
        self.imageView.superview?.removeConstraints(constraints)
        self.imageView.removeFromSuperview()
    }
    
    func showInNoteView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        parentController.view.addSubview(imageView)
        
        // Img View Constraints
        topImgConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .top,
            relatedBy: .equal,
            toItem: relatedToView,
            attribute: .top,
            multiplier: 1,
            constant: noteImageMapping.position.y)

        leftImgConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .left,
            relatedBy: .equal,
            toItem: relatedToView,
            attribute: .left,
            multiplier: 1,
            constant: noteImageMapping.position.x)

        
        self.constraints = [NSLayoutConstraint(
            item: imageView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0,
            constant: 100)]
        
        self.constraints.append(NSLayoutConstraint(
            item: self.imageView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0,
            constant: 150))
        
        self.constraints.append(contentsOf: [topImgConstraint, leftImgConstraint])
        
        if (self.noteImageMapping.scale != CGFloat(1)) {
            self.imageView.transform = self.imageView.transform.scaledBy(x: self.noteImageMapping.scale,
                                                                         y: self.noteImageMapping.scale)
        }
        
        if (self.noteImageMapping.rotation != CGFloat(0)) {
            self.imageView.transform = self.imageView.transform.rotated(by: self.noteImageMapping.rotation)
        }
        
        self.imageView.backgroundColor = .red;
        self.imageView.isUserInteractionEnabled = true // Está desactivado por defecto

        self.parentController.noteImageViewControllers.append(self)
        self.parentController.view.addConstraints(self.constraints)
        
        // Se puede hacer con un UIPanGestureRecognizer, aunque en este caso es mejor el LongPress
        // porque se activa cuando lleva pulsado un rato, así se evita moverlo por error.
        self.imageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(moveImage)))
        self.imageView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(scaleImage)))
        self.imageView.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: #selector(rotateImage)))
    }
    
    @objc func moveImage(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: relatedToView)  // Porque las constraints están respecto a noteTextView
        
        switch gesture.state {
        case .began:
            self.parentController.closeKeyboard()
            relativePoint = gesture.location(in: gesture.view)
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
            self.noteImageMapping.position = CGPoint(x: leftImgConstraint.constant, y: topImgConstraint.constant)
            NoteImage.update(id: self.managedObject!.objectID, noteImageMap: self.noteImageMapping)
        default:
            break
        }
    }
    
    @objc func scaleImage(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            break
        case .changed:
            if (self.noteImageMapping.scale > 0.7 && gesture.scale < 1) ||
               (self.noteImageMapping.scale > 1.3 && gesture.scale > 1) {
                break
            }
            
            self.noteImageMapping.scale += (gesture.scale - 1)
            self.imageView.transform = self.imageView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1
            break
            
        case .ended, .cancelled:
            self.parentController.viewDidLayoutSubviews()
            NoteImage.update(id: self.managedObject!.objectID, noteImageMap: self.noteImageMapping)
            break
        default:
            break
        }
    }
    
    @objc func rotateImage(_ gesture : UIRotationGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            self.noteImageMapping.rotation += gesture.rotation
            self.imageView.transform = self.imageView.transform.rotated(by: gesture.rotation)
            gesture.rotation = 0
            break
        case .ended, .cancelled:
            self.parentController.viewDidLayoutSubviews()
            NoteImage.update(id: self.managedObject!.objectID, noteImageMap: self.noteImageMapping)
            break
        default:
            break
        }
    }
}
