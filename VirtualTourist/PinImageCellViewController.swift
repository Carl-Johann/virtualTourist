//
//  PinImageView.swift
//  VirtualTourist
//
//  Created by CarlJohan on 26/04/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var MapPinView: MKMapView!
    @IBOutlet weak var newCollectionLoadingIndicator: UIActivityIndicatorView!
    
    var photosFromPin: Set<Photos>?
    var pin: Pin?
    
    var photoURLS: [String]?
    var photosDateTaken: [String]?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapAnnotation()
        setupCollectionView()
    }
    
    
    @IBAction func newCollectionButtonAction(_ sender: Any) {
        let request:NSFetchRequest<Photos> = Photos.fetchRequest()
        let predicate = NSPredicate(format: "pin = %@", argumentArray: [pin!])
        request.sortDescriptors = [ NSSortDescriptor(key: "dateTaken", ascending: true) ]
        request.predicate = predicate
        
        newCollectionLoadingIndicator.startAnimating()
        DispatchQueue.main.async {
            FlickrClient.sharedInstance.getImagesForPin(self.pin!.latitude, self.pin!.longitude) { (downloadedPhotos, succes) in
                
                do {
                    let searchResults = try self.appDelegate.stack.context.fetch(request)
                    
                    for (index, photo) in searchResults.enumerated() {
                        let photoForIndex = downloadedPhotos[index]
                        
                        guard let dateTaken = photoForIndex["datetaken"] as? String else { print("ERROR: PinImageCellViewController. Couldn't find 'datetaken' in 'photos'")
                            self.newCollectionLoadingIndicator.stopAnimating(); return }
                        
                        guard let photoURL = photoForIndex["url_s"] as? String else { print("ERROR: PinImageCellViewController. Couldn't find 'url_s' in 'photos'")
                            self.newCollectionLoadingIndicator.stopAnimating(); return }
                        
                        let dateAsNSDate = self.dateFormatter(dateTaken)
                        
                        photo.photoURL = photoURL
                        photo.dateTaken = dateAsNSDate
                        
                    }
                    
                    
                    do { try self.appDelegate.stack.saveContext(); DispatchQueue.main.async {
                        self.newCollectionLoadingIndicator.stopAnimating()
                        self.photosCollectionView.reloadData()
                        }
                        
                    } catch { print("An error occured trying to save core data, after updating the selected pins photos ") }
                    
                    
                } catch let err { print("error: \(err)") }
            }
        }
    }
    
    
    // MARK: - Methods
    
    
    func setupMapAnnotation() {
        
        let annotation = MKPointAnnotation()
        let coordinateFromPin = CLLocationCoordinate2D(latitude: pin!.latitude, longitude: pin!.longitude)
        
        annotation.coordinate = coordinateFromPin
        self.MapPinView.addAnnotation(annotation)
    }
    
    
    //
    func dateFormatter(_ dateTaken: String) -> NSDate {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: dateTaken)
        return date! as NSDate
    }
    
    //
    func updatePhoto(index: Int, photoURL:String, dateTaken: NSDate) {
        
        guard let pin = self.pin else { print("ERROR. PinImageCellViewController. Self.pin == nil"); return }
        pin.photos?.setValue(photoURL, forKey: "photoURL")
        pin.photos?.setValue(dateTaken, forKeyPath: "dateTaken")
    }
    
    //
    func setupCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        let mapCoordinate = CLLocationCoordinate2D(latitude: pin!.latitude, longitude: pin!.longitude)
        
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        photosCollectionView.contentInset = UIEdgeInsets(top: 2, left: 3, bottom: 0, right: 3)
        
        
        let coordinateSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let mkCoordination: MKCoordinateRegion = MKCoordinateRegion(center: mapCoordinate, span: coordinateSpan)
        MapPinView.setRegion(mkCoordination, animated: true)
        
        photosCollectionView.collectionViewLayout = layout
        photosCollectionView.reloadData()
    }
    
    //
    func imageFromURL(_ url: String) -> UIImage {
        let url = URL(string: url)
        let data = try? Data(contentsOf: url!)
        let imageFromURL = UIImage(data: data!)
        
        return imageFromURL!
    }
    
    
    
    // MARK: - CollectionView Methods
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PinPhotoCell", for: indexPath) as! PhotoCell
        
        guard let photos = photosFromPin else { print("'photosFromPin = nil'"); return cell }
        let photosAsAnArray = Array(photos)
        
        guard let photoURL = photosAsAnArray[indexPath[1]].photoURL else { print("photosAsAnArray[indexPath[1]].photoURL = nil"); return cell }
        
        cell.cellImage.image = imageFromURL(photoURL)
        
        cell.cellLoadingIndicator.stopAnimating()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let photos = photosFromPin else { print("'photosFromPin = nil'"); return 0 }
        
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let CVWidth = collectionView.frame.width
        let numberOfItemsPerRow: CGFloat = 3.0
        
        let itemSize = (CVWidth/numberOfItemsPerRow) - 4
        
        return CGSize(width: itemSize, height: itemSize)
        
    }
    
}


// MARK: - PhotoCell Class
class PhotoCell: UICollectionViewCell{
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellLoadingIndicator: UIActivityIndicatorView!
    
    
}
