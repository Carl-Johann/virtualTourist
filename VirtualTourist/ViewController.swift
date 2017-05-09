//
//  ViewController.swift
//  VirtualTourist
//
//  Created by CarlJohan on 26/04/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import UIKit
import CoreData

class CoreDataViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print()
        print()
        print()
        print("CoreDataViewController is called")
        print()
        print()
        print()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?{
        didSet {
            print()
            print()
            print()
            print("fetchedResultsController is called")
            print()
            print()
            print()
            fetchedResultsController?.delegate = self as? NSFetchedResultsControllerDelegate
        }
    }
    
    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>, style : UITableViewStyle = .plain) {
        super.init(style: style)
        print()
        print()
        print()
        print("init is called")
        print()
        print()
        print()
        fetchedResultsController = fc
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}

extension CoreDataViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("This method MUST be implemented by a subclass of CoreDataTableViewController")
    }
}

class PinViewController: CoreDataViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print()
        print()
        print()
        print("PinViewController did load")
        print()
        print()
        print()
        
        title = "PinsPhoto"
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [ NSSortDescriptor(key: "latitude", ascending: false) ]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
}





/*override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
 // This method must be implemented by our subclass. There's no way
 // CoreDataTableViewController can know what type of cell we want to
 // use.
 
 // Find the right notebook for this indexpath
 
 
 // Create the cell
 
 // Sync notebook -> cell
 //cell.detailTextLabel?.text = "\(nb.notes!.count) notes"
 
 }*/




