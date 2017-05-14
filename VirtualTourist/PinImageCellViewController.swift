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

class PinImageCellViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewFlowLayout {
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    var photosFromPin: Set<Photos>?

    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?{
        didSet { fetchedResultsController?.delegate = self as? NSFetchedResultsControllerDelegate }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        /*do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }*/
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photosCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        /*guard let fc = fetchedResultsController else {
            print("No sections in fetchedResultsController")
            return 0
        }
        return fc.sections![section].numberOfObjects*/
        
        guard let photos = photosFromPin else { print("'photosFromPin = nil'"); return 0 }
        
        return photos.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PinPhotoCell", for: indexPath) as! autistcelle
        
        
        guard let photos = photosFromPin else { print("'photosFromPin = nil'"); return cell }
        let photosAsAnArray = Array(photos)
    
        let photoURL = photosAsAnArray[indexPath[1]].photoURL
        
        let url = URL(string: photoURL!)
        let data = try? Data(contentsOf: url!)
        let imageFromURL = UIImage(data: data!)
        cell.cellImage.image = imageFromURL

        cell.contentView.layer.cornerRadius = 2
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.masksToBounds = true
        
        let imageWidth = imageFromURL?.size.width
        let imageHeight = imageFromURL?.size.height
        
        
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        
        /*if indexPath.row == 0
        {
            return CGSize(width: screenWidth, height: screenWidth/3)
        }
        return CGSize(width: screenWidth/3, height: screenWidth/3);
        */
        let CVWidth = collectionView.frame.width
        
        
        return CGSize(width: CVWidth/4, height: CVWidth/4)
    }
}

class autistcelle: UICollectionViewCell{
    
    @IBOutlet weak var cellImage: UIImageView!
    
}
