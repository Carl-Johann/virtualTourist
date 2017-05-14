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
    var selectedAnnotation: MKAnnotation?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
            
            for pin in fetchedResultsController.fetchedObjects! as! [Pin] {
                //print("XXXXXXXXXXX: \(pin.latitude)")
                
                let annotationFromCoreData = MKPointAnnotation()
                let annotationCoordinate = CLLocationCoordinate2D( latitude: pin.latitude, longitude: pin.longitude )
                annotationFromCoreData.coordinate = annotationCoordinate
                
                self.annotations.append(annotationFromCoreData)
                
            }
            //pinTableVC.fetchedResultsController = fetchedResultsController
            
            self.mapView.addAnnotations(self.annotations)
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?{
         didSet { fetchedResultsController?.delegate = self as? NSFetchedResultsControllerDelegate }
         }*/
        
    }
    
    
    
    @IBAction func editButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "ClickedPinSegue", sender: self)
    }
    
    @IBAction func pinGesureRecognizer(_ sender: Any) {
        if self.pinGestureRecognizer.state == .ended {
            
            
            let newPin = Pin(context: appDelegate.stack.context)
            let annotation = MKPointAnnotation()
            
            
            let xValue = pinGestureRecognizer.location(in: self.mapView).x
            let yValue = pinGestureRecognizer.location(in: self.mapView).y
            
            
            let mapPoint = CGPoint(x: xValue,y:  yValue)
            let coordinateFromTouch = self.mapView.convert(mapPoint, toCoordinateFrom: self.mapView)
            
            
            annotation.coordinate = coordinateFromTouch
            self.annotations.append(annotation)
            
            
            let latitude = coordinateFromTouch.latitude as Double
            let longitude = coordinateFromTouch.longitude as Double
            
            
            self.mapView.addAnnotation(annotation)
            
            
            
            DispatchQueue.main.async {
                
                
                FlickrClient.sharedInstance.getImagesForPin(latitude, longitude){ (photos, success) in
                    if success != true { print("An error occured trying to download images for the created pin"); return }
                    
                    print()
                    print()
                    print("Did get images for pin. API method call was successfull")
                    print()
                    print()
                    
                    
                    newPin.latitude = latitude
                    newPin.longitude = longitude
                    
                    
                    for photo in photos {
                        let pinPhoto = Photos(context: self.appDelegate.stack.context)
                        
                        //self.mapView.userLocation.
                        
                        guard let dateTaken = photo["datetaken"] as? String else { print("ERROR: MapViewController. Couldn't find 'datetaken' in 'photos'"); return }
                        guard let photoURL = photo["url_s"] as? String else { print("ERROR: MapViewController. Couldn't find 'url_s' in 'photos'"); return }
                        
                        let dateFormatter = DateFormatter()
                        
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let date = dateFormatter.date(from: dateTaken)
                        
                        print("--------------")
                        print(dateTaken)
                        print(date!)
                        
                        pinPhoto.photoURL = photoURL
                        //pinPhoto.dateTaken = date! as NSDate
                        
                        pinPhoto.pin = newPin
                        newPin.addToPhotos(pinPhoto)
                        
                    }
                    print("newPin: \(newPin.photos)")
                    
                    do {
                        try self.appDelegate.stack.saveContext()
                    } catch { print("An error occured trying to save core data, after adding a pin ") }
                    
                    
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "latitude", ascending: true) ]
        
        let context = appDelegate.stack.context
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        if segue.identifier! == "ClickedPinSegue" {
            
            if let pinTableVC = segue.destination as? PinViewController {
                pinTableVC.fetchedResultsController = fetchedResultsController
            }
            
        }
        
        if segue.identifier == "ClickedPinSegueToCell" {
            guard let pinCellVC = segue.destination as? PinImageCellViewController else {
                print("Couldn't convert 'segue.destination' to type 'PinImageCellViewController'")
                return
            }
            
            guard let annotation = selectedAnnotation else { print("'selectedAnnotation = nil'"); return }
            
            let latitude = annotation.coordinate.latitude
            let longitude = annotation.coordinate.longitude
            
            let pred = NSPredicate(format: "latitude = %@ AND longitude = %@", argumentArray: [latitude, longitude])
            fetchRequest.predicate = pred
            fetchRequest.fetchLimit = 1

            
            do {
                try fetchedResultsController.performFetch()
            } catch {
                print("Failed to initialize FetchedResultsController: \(error)")
            }
            
            
            
            guard let pinFromAnnotation = fetchedResultsController.fetchedObjects?.first as? Pin else {
                print("no pin found from latitude and/or longitude from clicked annotation")
                return
            }
            
            guard let photosFromPin = pinFromAnnotation.photos as? Set<Photos> else { print("no photos found from 'pinFromAnnotation'"); return }
            
            pinCellVC.photosFromPin = photosFromPin
           
        }
        
        
        
    }
    
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation
        
        performSegue(withIdentifier: "ClickedPinSegueToCell", sender: self)
        
    }
    
    
    
    
}
