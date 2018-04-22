//
//  SelectionMapViewController.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 22/4/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import Contacts

protocol SelectionMapViewControllerDelegate: class {
    func selectionMapViewControl(_ viewControl: SelectionMapViewController, didSelectionLocation: CLLocationCoordinate2D)
}

class SelectionMapViewController: UIViewController {
    
    // MARK: - Properties
    
    let mapView = MKMapView()
    let textField = UITextField()
    
    let location: CLLocationCoordinate2D
    
    weak var delegate: SelectionMapViewControllerDelegate?
    var annotation: MKPointAnnotation?
    
    // MARK: - Initialization
    
    init(_ location: CLLocationCoordinate2D) {
        self.location = location
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        title = "Select a location"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func loadView() {
        let backView = UIView()
        
        backView.addSubview(mapView)
        backView.addSubview(textField)
        textField.backgroundColor = UIColor.init(white: 1, alpha: 0.7)
        
        // MARK: Autolayout.
        mapView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let dictViews = [
            "mapView" : mapView,
            "textField" : textField
        ]
        
        // Horizontals
        var constraint = NSLayoutConstraint.constraints(withVisualFormat: "|-0-[mapView]-0-|", options: [], metrics: nil, views: dictViews)
        
        constraint.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-20-[textField]-20-|", options: [], metrics: nil, views: dictViews))
        
        // Verticals
        constraint.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[mapView]-0-|", options: [], metrics: nil, views: dictViews))
        
        constraint.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[textField(40)]", options: [], metrics: nil, views: dictViews))
        
        constraint.append(NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: backView.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 20))
        
        backView.addConstraints(constraint)
        
        self.view = backView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        mapView.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(addAnnotation))
        mapView.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var region: MKCoordinateRegion!
        
        if location.latitude == 0 && location.longitude == 0 {
            region = MKCoordinateRegion(center: CLLocationCoordinate2D.init(latitude: 40.425, longitude: -3.7035), span: MKCoordinateSpan.init(latitudeDelta: 0.1, longitudeDelta: 0.1))
        } else {
            region = MKCoordinateRegion(center: location, span: MKCoordinateSpan.init(latitudeDelta: 0.1, longitudeDelta: 0.1))
            
            self.annotation = MKPointAnnotation()
            self.annotation?.coordinate = location;
            self.mapView.addAnnotation(self.annotation!)
        }
        
        mapView.setRegion(region, animated: false)
        setupUI()
    }
    
    // MARK: - Helpers
    
    func setupUI() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done)),
        ]
    }
    
    // MARK: - Actions
    
    @objc func done() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coord = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        let geoCoder = CLGeocoder()
        
        if annotation != nil {
            mapView.removeAnnotation(annotation!)
        }
        
        geoCoder.reverseGeocodeLocation(location) { (placeMarkArray, error) in
            if error != nil {
                self.delegate?.selectionMapViewControl(self, didSelectionLocation: coord)
                return
            }
            
            if let places = placeMarkArray {
                if let place = places.first {
                    DispatchQueue.main.async {
                        if let postalAdd = place.postalAddress {
                            self.annotation = MKPointAnnotation()
                            self.annotation?.coordinate = coord;
                            self.annotation?.title = "\(postalAdd.street), \(postalAdd.city)"
                            self.mapView.addAnnotation(self.annotation!)
                            
                            self.textField.text = self.annotation?.title
                            
                            self.delegate?.selectionMapViewControl(self, didSelectionLocation: coord)
                        } else {
                            self.annotation = MKPointAnnotation()
                            self.annotation?.coordinate = coord;
                            self.mapView.addAnnotation(self.annotation!)
                            
                            self.delegate?.selectionMapViewControl(self, didSelectionLocation: coord)
                        }
                    }
                }
            }
        }
    }
}

extension SelectionMapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    }
    
}

// UITextField Delegate
extension SelectionMapViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        mapView.isScrollEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.text != nil && !textField.text!.isEmpty {
            mapView.isScrollEnabled = false
            
            let geocoder = CLGeocoder()
            let postalAddress = CNMutablePostalAddress()
            
            postalAddress.street = textField.text!
            // postalAddress.subAdministrativeArea
            // postalAddress.subLocality
            postalAddress.isoCountryCode = "ES"
            
            geocoder.geocodePostalAddress(postalAddress) { (placeMarkArray, error) in
                
                if placeMarkArray != nil && placeMarkArray!.count > 0
                {
                    let placemark = placeMarkArray?.first
                    
                    DispatchQueue.main.async
                        {
                            let region = MKCoordinateRegion(center:placemark!.location!.coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.004, longitudeDelta: 0.004))
                            self.mapView.setRegion(region, animated: true)
                    }
                    
                    
                }
                
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
}
