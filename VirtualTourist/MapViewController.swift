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
    @IBOutlet weak var editDoneButton: UIBarButtonItem!
    @IBOutlet weak var tapToDeleteLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var annotations: [MKAnnotation] = [MKAnnotation]()
    var selectedAnnotation: MKAnnotation?
    var editStatus: Bool?
    
    
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
            
            for pin in fetchedResultsController.fetchedObjects! as! [Pin] { self.makePinFromCoreData(pin) }
            
            self.mapView.addAnnotations(self.annotations)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        editStatus = false
    }
    
    // MARK: - @IBAction's
    @IBAction func editDoneButton(_ sender: Any) {
        if editStatus == false {
            editStatus = true
            tapToDeleteLabel.alpha = 1
            
        } else {
            editStatus = false
            tapToDeleteLabel.alpha = 0
            
            do { try self.appDelegate.stack.saveContext()
            } catch { print("An error occured trying to save core data") }
        }
        
        self.setEditing(!self.isEditing, animated: true)
        let newButton = UIBarButtonItem(barButtonSystemItem: (self.isEditing) ? .done : .edit, target: self, action: #selector(editDoneButton(_:)))
        self.navigationItem.setRightBarButton(newButton, animated: false)
        
    }
    
    
    @IBAction func pinGesureRecognizer(_ sender: Any) {
        if self.pinGestureRecognizer.state == .ended {
            
            //
            let annotation = makeAPin()
            self.mapView.addAnnotation(annotation)
            
            //
            let latitude = annotation.coordinate.latitude as Double
            let longitude = annotation.coordinate.longitude as Double
            
            //
            DispatchQueue.main.async {
                FlickrClient.sharedInstance.getImagesForPin(latitude, longitude){ (photos, success) in
                    
                    //
                    let newPin = self.setupPin(latitude, longitude)
                    if success != true { print("An error occured trying to download images for the created pin"); return }
                    
                    //
                    for photo in photos {
                        let pinPhoto = self.setupPinPhoto(photo)
                        
                        pinPhoto.pin = newPin
                        newPin.addToPhotos(pinPhoto)
                    }
                    
                    //
                    do { try self.appDelegate.stack.saveContext()
                    } catch { print("An error occured trying to save core data, after adding a pin ") }
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ClickedPinSegueToCell" {
            let pinCellVC = segue.destination as! PhotoAlbumViewController
            
            //
            let pinFromAnnotation = self.pinFromSelectedAnnotation()
            guard let photosFromPin = pinFromAnnotation.photos as? Set<Photo> else { print("no photos found from 'pinFromAnnotation'"); return }
            
            //
            pinCellVC.pin = pinFromAnnotation
            pinCellVC.photosFromPin = photosFromPin
            
        }
    }
    
    
    
    // MARK: - Methods/Functions
    
    
    //
    func pinFromSelectedAnnotation() -> Pin {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "latitude", ascending: true) ]
        
        let context = appDelegate.stack.context
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        
        //
        guard let annotation = selectedAnnotation else { print("'selectedAnnotation = nil'"); return Pin(context: context) }
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        
        //
        let pred = NSPredicate(format: "latitude = %@ AND longitude = %@", argumentArray: [latitude, longitude])
        fetchRequest.predicate = pred
        fetchRequest.fetchLimit = 1
        
        //
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
        
        
        //
        guard let pinFromAnnotation = fetchedResultsController.fetchedObjects?.first as? Pin else {
            print("no pin found from latitude and/or longitude from clicked annotation")
            return Pin(context: context)
        }
        
        return pinFromAnnotation
    }
    
    
    //
    func makePinFromCoreData(_ pin: Pin) {
        
        let annotationFromCoreData = MKPointAnnotation()
        let annotationCoordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        annotationFromCoreData.coordinate = annotationCoordinate
        self.annotations.append(annotationFromCoreData)
    }
    
    
    //
    func makeAPin() -> MKPointAnnotation {
        
        let annotation = MKPointAnnotation()
        
        let xValue = pinGestureRecognizer.location(in: self.mapView).x
        let yValue = pinGestureRecognizer.location(in: self.mapView).y
        
        let mapPoint = CGPoint(x: xValue,y:  yValue)
        let coordinateFromTouch = self.mapView.convert(mapPoint, toCoordinateFrom: self.mapView)
        
        annotation.coordinate = coordinateFromTouch
        self.annotations.append(annotation)
        
        return annotation
    }
    
    
    //
    func setupPin(_ latitude: Double, _ longitude: Double) -> Pin {
        //DispatchQueue.main.async {
            
        let pin = Pin(context: self.appDelegate.stack.context)
            
        pin.latitude = latitude
        pin.longitude = longitude
        
        return pin
        //}
        
    }
    
    
    //
    func setupPinPhoto(_ photo:[String : AnyObject]) -> Photo {
        
        let pinPhoto = Photo(context: self.appDelegate.stack.context)
        
        guard let dateTaken = photo["datetaken"] as? String else { print("ERROR: MapViewController. Couldn't find 'datetaken' in 'photos'"); return pinPhoto}
        guard let photoURL = photo["url_s"] as? String else { print("ERROR: MapViewController. Couldn't find 'url_s' in 'photos'"); return pinPhoto }
        
        let image = imageFromURL(photoURL)
        let data = UIImagePNGRepresentation(image) as NSData?
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: dateTaken)
        
        
        pinPhoto.image = data
        pinPhoto.dateTaken = date! as NSDate
        
        return pinPhoto
    }
    
    
    //
    func imageFromURL(_ url: String) -> UIImage {
        let url = URL(string: url)
        let data = try? Data(contentsOf: url!)
        let imageFromURL = UIImage(data: data!)
        
        return imageFromURL!
    }
    
    
    
    
    // MARK: - mapView Methods
    
    
    //
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation
        
        switch editStatus! {
        case false:
            performSegue(withIdentifier: "ClickedPinSegueToCell", sender: self)
            
        case true:
            deletePin()
        }
    }
    
    
    //
    func deletePin() {
        
        let selectedPin = pinFromSelectedAnnotation()
        let context = appDelegate.stack.context
        
        context.delete(selectedPin)
        mapView.removeAnnotation(self.selectedAnnotation!)
        
        
    }
    
}
