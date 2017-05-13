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

class PinImageCellViewController: UICollectionViewController {//UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?{
        didSet { fetchedResultsController?.delegate = self as? NSFetchedResultsControllerDelegate }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    /*func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
        //return searches[section].searchResults.count
    }*/
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    /*func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pinPhotoCell", for: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PinPhotoCell", for: indexPath)

        //cell.backgroundColor = UIColor.black
        
        /*guard let pin = self.fetchedResultsController?.object(at: indexPath) as? Pin else {
            print("Attempt to configure cell without a managed object")
            return cell
        }*/
        
        
        return cell
    }
    */
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PinPhotoCell", for: indexPath)
        
        return cell
    }

    
    
}
