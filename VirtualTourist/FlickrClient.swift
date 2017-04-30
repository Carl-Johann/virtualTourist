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
    
    func getImagesForPin(_ Latitude: Double, _ Longitude: Double, CHForImagesForPin: @escaping (_ succes: Bool) -> Void) {
        
        let parameters = [
            FlickrParameterKeys.Method:FlickrMethods.photosSearch,
            FlickrParameterKeys.APIKey:Flickr.ApiKey,
            FlickrParameterKeys.Radius:FlickrParameterValues.RadiusSize,
            FlickrParameterKeys.Latitude:Latitude,
            FlickrParameterKeys.Longitude:Longitude,
            FlickrParameterKeys.Format:FlickrParameterValues.JSONResponseFormat,
            FlickrParameterKeys.NoJSONCallBack:FlickrParameterValues.DisableJSONCallback,
            FlickrParameterKeys.Extras:FlickrParameterValues.URLMedium,
            FlickrParameterKeys.PerPage:FlickrParameterValues.NumberOfPhotosPerPage
        ] as [String : AnyObject]
        
        
        let request = URLRequest(url: flickrURLFromParameters(parameters))
        
        let task = self.session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { print("error: \(error!)"); return }
            
            
            let parsedResult = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
            
            print(parsedResult)
            
            guard let results = parsedResult["photos"] as? [String:AnyObject] else { print("ERROR: FlickrClient, 41. Coudln't find 'photos' in 'parsedResult'"); return }
            guard let photos = results["photo"] as? [[String:AnyObject]] else { print("ERROR: FlickrClient, 42. Coudln't find 'photo' in 'results'"); return }
            
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
