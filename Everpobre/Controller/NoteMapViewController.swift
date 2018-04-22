//
//  NoteMapViewController.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 22/4/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import UIKit
import MapKit

struct NoteMapMapping {
    var latitude: CGFloat
    var logntitude: CGFloat
    var position: CGPoint!
}

class NoteMapViewController {
//    let mapView = MKMapView()
//    let relatedToView: UIView
//    var topImgConstraint: NSLayoutConstraint!
//    var leftImgConstraint: NSLayoutConstraint!
//    var constraints: [NSLayoutConstraint]!
//    var relativePoint: CGPoint!
//    let parentController: NoteViewByCodeController
//    var noteMapMapping: NoteMapMapping
//
//
//    var managedObject: NoteImage?
//
//    init(image: UIImage, position: CGPoint, scale: CGFloat, rotation:  CGFloat, relatedToView: UIView, parentController: NoteViewByCodeController) {
//
//        self.relatedToView = relatedToView
//        self.parentController = parentController
//        self.imageView = UIImageView(image: image)
//
//        self.noteImageMapping = NoteImageMapping(imageRawData: UIImageJPEGRepresentation(image, 1)!,
//                                                 scale: scale,
//                                                 rotation: rotation,
//                                                 position: position)
//    }
//
//    deinit {
//        self.imageView.superview?.removeConstraints(constraints)
//        self.imageView.removeFromSuperview()
//    }
//
//    func showInNoteView() {
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        parentController.view.addSubview(imageView)
//
//        // Img View Constraints
//        topImgConstraint = NSLayoutConstraint(
//            item: imageView,
//            attribute: .top,
//            relatedBy: .equal,
//            toItem: relatedToView,
//            attribute: .top,
//            multiplier: 1,
//            constant: noteImageMapping.position.y)
//
//        leftImgConstraint = NSLayoutConstraint(
//            item: imageView,
//            attribute: .left,
//            relatedBy: .equal,
//            toItem: relatedToView,
//            attribute: .left,
//            multiplier: 1,
//            constant: noteImageMapping.position.x)
//
//
//        self.constraints = [NSLayoutConstraint(
//            item: imageView,
//            attribute: .width,
//            relatedBy: .equal,
//            toItem: nil,
//            attribute: .notAnAttribute,
//            multiplier: 0,
//            constant: 100)]
//
//        self.constraints.append(NSLayoutConstraint(
//            item: self.imageView,
//            attribute: .height,
//            relatedBy: .equal,
//            toItem: nil,
//            attribute: .notAnAttribute,
//            multiplier: 0,
//            constant: 150))
//
//        self.constraints.append(contentsOf: [topImgConstraint, leftImgConstraint])
//
//
//        self.imageView.backgroundColor = .red;
//        self.imageView.isUserInteractionEnabled = true // Está desactivado por defecto
//
//        self.parentController.noteMapViewControllers.append(self)
//        self.parentController.view.addConstraints(self.constraints)
//
//        // Se puede hacer con un UIPanGestureRecognizer, aunque en este caso es mejor el LongPress
//        // porque se activa cuando lleva pulsado un rato, así se evita moverlo por error.
//        self.imageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(moveMap)))
//    }
//
//    @objc func moveMap(_ gesture: UILongPressGestureRecognizer) {
//        let location = gesture.location(in: relatedToView)  // Porque las constraints están respecto a noteTextView
//
//        switch gesture.state {
//        case .began:
//            self.parentController.closeKeyboard()
//            relativePoint = gesture.location(in: gesture.view)
//            UIView.animate(withDuration: 0.1, animations: {
//                self.imageView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
//            })
//        case .changed:
//            leftImgConstraint.constant = location.x - relativePoint.x
//            topImgConstraint.constant = location.y - relativePoint.y
//        case .ended, .cancelled:
//            UIView.animate(withDuration: 0.1, animations: {
//                self.imageView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
//            })
//            self.noteMapMapping.position = CGPoint(x: leftImgConstraint.constant, y: topImgConstraint.constant)
//            NoteImage.update(id: self.managedObject!.objectID, noteImageMap: self.noteImageMapping)
//        default:
//            break
//        }
//    }
}
