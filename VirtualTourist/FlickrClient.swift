//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by CarlJohan on 27/04/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation


struct FlickrClient {
    
    let session = URLSession.shared
    //let photos = [String]
    
    func getImagesForPin(_ Latitude: Double, _ Longitude: Double, CHForImagesForPin: @escaping (_ succes: Bool) -> Void) {
        
        let parameters = [
            FlickrParameterKeys.Method:FlickrMethods.photosSearch,
            FlickrParameterKeys.APIKey:Flickr.ApiKey,
            FlickrParameterKeys.Radius:FlickrParameterValues.RadiusSize,
            FlickrParameterKeys.Latitude:Latitude,
            FlickrParameterKeys.Longitude:Longitude,
            FlickrParameterKeys.Format:FlickrParameterValues.JSONResponseFormat,
            FlickrParameterKeys.NoJSONCallBack:FlickrParameterValues.DisableJSONCallback,
            FlickrParameterKeys.Extras:FlickrParameterValues.DateTakenAndUrlSmall,
            FlickrParameterKeys.PerPage:FlickrParameterValues.NumberOfPhotosPerPage
        ] as [String : AnyObject]
        
        
        let request = URLRequest(url: flickrURLFromParameters(parameters))
        
        let task = self.session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { print("error: \(error!)"); return }
            
            
            let parsedResult = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
          
            guard let results = parsedResult["photos"] as? [String:AnyObject] else { print("ERROR: FlickrClient. Couldn't find 'photos' in 'parsedResult'"); return }
            guard let photos = results["photo"] as? [[String:AnyObject]] else { print("ERROR: FlickrClient. Couldn't find 'photo' in 'results'"); return }
            
            
            for photo in photos {
                guard let dateTaken = photo["datetaken"] as? String else { print("ERROR: FlickrClient. Couldn't find 'datetaken' in 'photos'"); return }
                guard let photoURL = photo["url_s"] as? String else { print("ERROR: FlickrClient. Couldn't find 'url_s' in 'photos'"); return }
                
                print("Date Taken: \(dateTaken)")
                print("Photo URL: \(photoURL)")
                print("-------------------------")

            }
            
            /*guard let dateTaken = photos["datetaken"] as? String else { print("ERROR: FlickrClient. Couldn't find 'datetaken' in 'photos'"); return }
            guard let photoURL = photos["url_s"] as? String else { print("ERROR: FlickrClient. Couldn't find 'url_s' in 'photos'"); return }*/
            
            /*print("Date Taken: \(dateTaken)")
            print("Photo URL: \(photoURL)")
            print("-------------------------")*/
            //let structuedPhotos
            
            //FlickrPinsData.sharedInstance.students.append(FlickrPin.dataFromStudents(photos))
            
        }
        task.resume()
        
        CHForImagesForPin(true)
    }
    
    
    
    
    func flickrURLFromParameters(_ parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Flickr.APIScheme
        components.host = Flickr.APIHost
        components.path = Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
            
        }
        print("Request URL: \(components.url!)")
        print()
        print()
        return components.url!
    }
    
    
    static let sharedInstance = FlickrClient()
}
