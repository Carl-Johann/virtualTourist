//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by CarlJohan on 26/04/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var pinGestureRecognizer: UILongPressGestureRecognizer!
    
    var annotations: [MKAnnotation] = [MKAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
    }
    
    @IBAction func pinGesureRecognizer(_ sender: Any) {
        
        let xValue = pinGestureRecognizer.location(in: self.mapView).x
        let yValue = pinGestureRecognizer.location(in: self.mapView).y
        
        print("--------")
        let mapPoint = CGPoint(x: xValue,y:  yValue)
        
        let coordinateFromTouch = self.mapView.convert(mapPoint, toCoordinateFrom: self.mapView)
        print(coordinateFromTouch)
        
        let latitude = coordinateFromTouch.latitude as Double
        let longitude = coordinateFromTouch.longitude as Double
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinateFromTouch
        
        
        
        self.mapView.addAnnotation(annotation)
        
        DispatchQueue.main.async {
            FlickrClient.sharedInstance.getImagesForPin(latitude, longitude){ (succes) in
                
            }
        }
    }
    
    
}
