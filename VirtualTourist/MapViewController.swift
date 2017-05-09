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
    
    var annotations: [MKAnnotation] = [MKAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    @IBAction func editButtonAction(_ sender: Any) {
        print("Clicked 'editButtonAction'")
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
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinateFromTouch
                
        self.mapView.addAnnotation(annotation)
        if self.pinGestureRecognizer.state == .ended {
            
            DispatchQueue.main.async {
                FlickrClient.sharedInstance.getImagesForPin(latitude, longitude){ (succes) in
                    
                }
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "ClickedPinSegue" {
            
            if let pinTableVC = segue.destination as? PinViewController {
                let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
                fr.sortDescriptors = [ NSSortDescriptor(key: "latitude", ascending: false) ]
                
                
                //let indexPath = tableView.indexPathForSelectedRow!
                //fetchedResultsController?.object(at: indexPath)
                //let pin = fetchedResultsController?.object(at: indexPath) as? MapPin
                
                
                let predicate = NSPredicate(format: "pin = %@", argumentArray: [pin!])
                fr.predicate = predicate
                
                
                let frc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext:pinTableVC.fetchedResultsController!.managedObjectContext, sectionNameKeyPath: "longitude", cacheName: nil)
                pinTableVC.fetchedResultsController = frc
                
                //PinViewController.
                // So far we have a search that will match ALL notes. However, we're
                // only interested in those within the current notebook:
                // NSPredicate to the rescue!
                /* let indexPath = tableView.indexPathForSelectedRow!
                 fetchedResultsController?.object(at: <#T##IndexPath#>)
                 let notebook = fetchedResultsController?.object(at: indexPath) as? Notebook
                 
                 
                 let pred = NSPredicate(format: "notebook = %@", argumentArray: [notebook!])
                 
                 fr.predicate = pred
                 
                 // Create FetchedResultsController
                 let fc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext:fetchedResultsController!.managedObjectContext, sectionNameKeyPath: "humanReadableAge", cacheName: nil)
                 
                 // Inject it into the notesVC
                 notesVC.fetchedResultsController = fc
                 
                 // Inject the notebook too!
                 notesVC.notebook = notebook*/
            }
        }
        
    }

    
    
    
    //func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    
    //}
    
    
}
