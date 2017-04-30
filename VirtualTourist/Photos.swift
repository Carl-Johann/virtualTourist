//
//  FlickrPin.swift
//  VirtualTourist
//
//  Created by CarlJohan on 30/04/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import CoreData



class FlickrPinPhotos: Photos {
    
    convenience init ( photoURL: String = "", context: NSManagedObjectContext ) {
        
        guard let ent = NSEntityDescription.entity(forEntityName: "Photos", in: context) else {
            print("ERROR. FlickrPin, 18. No NSEntityDescription matching 'Photos'")
            return
        }
        
        self.init(entity: ent, insertInto: context)
        self.photoURL = photoURL
        
    }
    
}
/*  var title: String? = ""
    var height: Int? = 0
    var width: Int? = 0
    var url: String? = ""
    
    init(dictionary: [String:AnyObject]) {
        if let title = dictionary["title"] as? String { self.title = title }
        if let height = dictionary["height_m"] as? Int { self.height = height }
        if let width = dictionary["width_m"] as? Int { self.width = width }
        if let url = dictionary["url_m"] as? String { self.url = url }

    }
    
    static func dataFromStudents(_ results: [[String:AnyObject]]) -> [FlickrPinPhotos] {
        
        var PinData = [FlickrPinPhotos]()
        
        for result in results { PinData.append(FlickrPinPhotos(dictionary: result)) }
        
        return PinData
    }
}*/
