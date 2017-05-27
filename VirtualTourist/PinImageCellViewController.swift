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
    
    // MARK: - IBOutlets
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var MapPinView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var deleteSelectedButton: UIButton!
    
    // MARK: - Class Variables and Constants
    var photosFromPin: Set<Photo>?
    var selectedCells = [PhotoCell]()
    var pin: Pin?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    // MARK: - View override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapAnnotation()
        setupCollectionView()
    }
    
    // MARK: - IBActions
    @IBAction func newCollectionButtonAction(_ sender: Any) {
        
        let request:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin = %@", argumentArray: [pin!])
        request.predicate = predicate
        request.sortDescriptors = [ NSSortDescriptor(key: "dateTaken", ascending: true) ]
        
        
        DispatchQueue.main.async {
            FlickrClient.sharedInstance.getImagesForPin(self.pin!.latitude, self.pin!.longitude) { (downloadedPhotos, succes) in
                do {
                    let searchResults = try self.appDelegate.stack.context.fetch(request)
                    print(2, searchResults.count)
                    print(4, searchResults)
                    for (index, photo) in searchResults.enumerated() {
                        let photoForIndex = downloadedPhotos[index]
                        
                        guard let dateTaken = photoForIndex["datetaken"] as? String else { print("ERROR: PinImageCellViewController. Couldn't find 'datetaken' in 'photos'")
                            self.newCollectionButton.isEnabled = true; return }
                        
                        guard let photoURL = photoForIndex["url_s"] as? String else { print("ERROR: PinImageCellViewController. Couldn't find 'url_s' in 'photos'")
                            self.newCollectionButton.isEnabled = true; return }
                        
                        let dateAsNSDate = self.dateFormatter(dateTaken)
                        
                        let image = self.imageFromURL(photoURL)
                        let data = UIImagePNGRepresentation(image) as NSData?
                        
                        
                        
                        photo.image = data
                        photo.dateTaken = dateAsNSDate
                        
                        print("-------------------")
                        print(photo)
                        
                        
                    }
                    
                    
                    
                } catch let err { print("error: \(err)") }
                
                print(100, self.pin!.photos!.count)
                
            }
        }
    }
    
    @IBAction func deleteSelectedItemsButton(_ sender: Any) {
        let itemIndexPaths = photosCollectionView.indexPathsForSelectedItems!
        var subpredicates = [NSPredicate]()
        
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        request.sortDescriptors = [ NSSortDescriptor(key: "dateTaken", ascending: true) ]

        
        for indexPath in itemIndexPaths {
            
            let cell = photosCollectionView.cellForItem(at: indexPath) as! PhotoCell
            let imageFromCell = cell.cellImage.image!
            
            guard let imageAsData = UIImagePNGRepresentation(imageFromCell) as NSData? else {
                print("Couldn't convert image from photo to NSData")
                return
            }
            
            
            let predicate = NSPredicate(format: "image = %@", argumentArray: [imageAsData])
            subpredicates.append(predicate)
        }
        
        
    
        let predicates = NSCompoundPredicate(type: .or, subpredicates: subpredicates)
        request.predicate = predicates
        let selectedPhotos = NSSet(array: try! self.appDelegate.stack.context.fetch(request) )
        
        
        
        self.photosCollectionView.performBatchUpdates({
            
            self.photosCollectionView.deleteItems(at: itemIndexPaths)
            self.pin?.removeFromPhotos(selectedPhotos)
            
        }) { (true) in
            print(123)
            self.saveDeletedChangesAndSetButtons()
        }
        
    }
    
    
    
    
    
    
    // MARK: - Convenience Methods
    
    //
    func saveDeletedChangesAndSetButtons() {
        do { try self.appDelegate.stack.saveContext(); DispatchQueue.main.async {
            print("Photos Length: \(self.pin!.photos!.count)")
            self.deleteSelectedButton.alpha = 0
            self.newCollectionButton.alpha = 1
            
            //self.photosCollectionView.reloadData()
            
            }
        } catch { print("An error occured trying to save core data, after updating the selected pins photos ") }
    }
    
    //
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
        
        photosCollectionView.allowsMultipleSelection = true
        
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
    
    //
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PinPhotoCell", for: indexPath) as! PhotoCell
        
        guard let photos = photosFromPin else { print("'photosFromPin = nil'"); return cell }
        let photosAsAnArray = Array(photos)
        
        guard let image = photosAsAnArray[indexPath[1]].image else { print("photosAsAnArray[indexPath[1]].photoURL = nil"); return cell }
        let imageFromPin = UIImage(data: image as Data)
        
        cell.cellImage.image = imageFromPin
        
        cell.cellLoadingIndicator.stopAnimating()
        return cell
    }
    
    //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let photos = photosFromPin else { print("'photosFromPin = nil'"); return 0 }
        
        return photos.count
    }
    
    //
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let CVWidth = collectionView.frame.width
        let numberOfItemsPerRow: CGFloat = 3.0
        
        let itemSize = (CVWidth/numberOfItemsPerRow) - 4
        
        return CGSize(width: itemSize, height: itemSize)
        
    }
    
    //
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedCell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        selectedCell.alpha = 0.5
        self.checkAndUpdateView(selectedCell)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let selectedCell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        selectedCell.alpha = 1
        self.checkAndUpdateView(selectedCell)
        
    }
    
    // MARK: - CollectionView Methods
    
    func checkAndUpdateView(_ selectedCell: PhotoCell) {
        
        if photosCollectionView.indexPathsForSelectedItems?.count != 0 {
            
            newCollectionButton.alpha = 0
            deleteSelectedButton.alpha = 1
            
        } else {
            if photosCollectionView.indexPathsForSelectedItems?.count == 0 {
                
                newCollectionButton.alpha = 1
                deleteSelectedButton.alpha = 0
                
            }
        }
    }
    
    
}


// MARK: - PhotoCell Class
class PhotoCell: UICollectionViewCell{
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellLoadingIndicator: UIActivityIndicatorView!
    
    
}
