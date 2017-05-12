//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by CarlJohan on 26/04/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var pinGestureRecognizer: UILongPressGestureRecognizer!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var annotations: [MKAnnotation] = [MKAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?{
         didSet { fetchedResultsController?.delegate = self as? NSFetchedResultsControllerDelegate }
         }*/
        
        DispatchQueue.main.async {
            
            
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "latitude", ascending: true) ]
            
            let context = self.appDelegate.stack.context
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            
            do {
                try fetchedResultsController.performFetch()
            } catch {
                print("Failed to initialize FetchedResultsController: \(error)")
            }
            
            for pin as Pin in fetchedResultsController.fetchedObjects! {
                print("XXXXXXXXXXX: \(pin)")
            }
            //pinTableVC.fetchedResultsController = fetchedResultsController
            
        }}
    
    
    
    @IBAction func editButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "ClickedPinSegue", sender: self)
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
        
        
        
        
        if self.pinGestureRecognizer.state == .ended {
            let newPin = Pin(context: appDelegate.stack.context)
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = coordinateFromTouch
            self.mapView.addAnnotation(annotation)
            
            DispatchQueue.main.async {
                FlickrClient.sharedInstance.getImagesForPin(latitude, longitude){ (photos, success) in
                    if success != true { print("An error occured trying to download images for the created pin"); return }
                    
                    
                    
                    newPin.latitude = latitude
                    newPin.longitude = longitude
                    
                    for photo in photos {
                        guard let dateTaken = photo["datetaken"] as? String else { print("ERROR: FlickrClient. Couldn't find 'datetaken' in 'photos'"); return }
                        guard let photoURL = photo["url_s"] as? String else { print("ERROR: FlickrClient. Couldn't find 'url_s' in 'photos'"); return }
                        
                        print("Date Taken: \(dateTaken)")
                        print("Photo URL: \(photoURL)")
                        print("-------------------------")
                    }
                }
                
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "ClickedPinSegue" {
            
            if let pinTableVC = segue.destination as? PinViewController {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
                fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "latitude", ascending: true) ]
                
                
                let context = appDelegate.stack.context
                
                let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                
                
                pinTableVC.fetchedResultsController = fetchedResultsController
                
            }
        }
        
    }
    
    
    
    
    //func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    
    //}
    
    
}
