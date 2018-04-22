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
    var longitude: CGFloat
    var position: CGPoint!
}

class NoteMapViewController {
    let mapView = MKMapView()
    let relatedToView: UIView
    var topImgConstraint: NSLayoutConstraint!
    var leftImgConstraint: NSLayoutConstraint!
    var constraints: [NSLayoutConstraint]!
    var relativePoint: CGPoint!
    let parentController: NoteViewByCodeController
    var noteMapMapping: NoteMapMapping


    var managedObject: NoteMap?

    init(position: CGPoint, latitude: CGFloat, longitude: CGFloat, relatedToView: UIView, parentController: NoteViewByCodeController) {

        self.relatedToView = relatedToView
        self.parentController = parentController

        self.noteMapMapping = NoteMapMapping(latitude: latitude,
                                             longitude: longitude,
                                             position: position)
    }

    deinit {
        self.mapView.superview?.removeConstraints(constraints)
        self.mapView.removeFromSuperview()
    }

    func showInNoteView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        parentController.view.addSubview(mapView)

        // Img View Constraints
        topImgConstraint = NSLayoutConstraint(
            item: mapView,
            attribute: .top,
            relatedBy: .equal,
            toItem: relatedToView,
            attribute: .top,
            multiplier: 1,
            constant: noteMapMapping.position.y)

        leftImgConstraint = NSLayoutConstraint(
            item: mapView,
            attribute: .left,
            relatedBy: .equal,
            toItem: relatedToView,
            attribute: .left,
            multiplier: 1,
            constant: noteMapMapping.position.x)


        self.constraints = [NSLayoutConstraint(
            item: mapView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0,
            constant: 100)]

        self.constraints.append(NSLayoutConstraint(
            item: mapView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0,
            constant: 150))

        self.constraints.append(contentsOf: [topImgConstraint, leftImgConstraint])

        self.mapView.isUserInteractionEnabled = true // Está desactivado por defecto

        self.parentController.noteMapViewControllers.append(self)
        self.parentController.view.addConstraints(self.constraints)
        self.mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(moveMap)))
    }

    @objc func moveMap(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: relatedToView)  // Porque las constraints están respecto a noteTextView

        switch gesture.state {
        case .began:
            self.parentController.closeKeyboard()
            relativePoint = gesture.location(in: gesture.view)
            UIView.animate(withDuration: 0.1, animations: {
                self.mapView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            })
        case .changed:
            leftImgConstraint.constant = location.x - relativePoint.x
            topImgConstraint.constant = location.y - relativePoint.y
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.1, animations: {
                self.mapView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            })
            self.noteMapMapping.position = CGPoint(x: leftImgConstraint.constant, y: topImgConstraint.constant)
            NoteMap.update(id: self.managedObject!.objectID, noteMapMapping: self.noteMapMapping)
        default:
            break
        }
    }
}
