//
//  Pin.swift
//  VirtualTourist
//
//  Created by CarlJohan on 30/04/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import CoreData

class MapPin: Pin {
    
    convenience init( latitude: Double, longitude: Double, context: NSManagedObjectContext ) {
        
        guard let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) else {
            print("ERROR. Pin.swift. Couldn't find a NSEntityDescription matching 'Pin'")
            return
        }
        
        self.init(entity: ent, insertInto: context)

        self.latitude = latitude
        self.longitude = longitude
        

    }

}
