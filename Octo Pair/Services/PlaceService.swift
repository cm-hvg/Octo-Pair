//
//  PlaceService.swift
//  Octo Pair
//
//  Created by Chuck Ng on 21/07/2018.
//  Copyright © 2018 Chuck Ng. All rights reserved.
//

import Foundation
import GooglePlacePicker
import Alamofire

class PlaceService {
    
    static let shared = PlaceService()
    
    let manager = CLLocationManager()
    
    var location: CLLocation?
    
    private var busySearching = false
    
    func searchRestaurants(at location: String, _ completion: ((_ json: [String: Any]) -> Void)?) {
        
        guard busySearching == false else {
            return
        }
        
        busySearching = true
        
        let parameters: Parameters = [
            "key": "AIzaSyCPTMcUfo639RkdUfWNvV-m1pbToL6Xx8Y",
            "location": location,
            "radius": "1000",
            //            "rankby": "distance",
            "type": "restaurant"
        ]
        
        Alamofire.request("https://maps.googleapis.com/maps/api/place/nearbysearch/json", parameters: parameters).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value as? [String: Any] {
                completion?(json)
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
            
            self.busySearching = false
        }
    }
    
    func loadFirstPhoto(placeID: String, completion: @escaping (UIImage?) -> Void) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImage(photoMetadata: firstPhoto, completion: completion)
                }
            }
        }
    }
    
    func loadImage(photoMetadata: GMSPlacePhotoMetadata, completion: @escaping (UIImage?) -> Void) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                completion(photo)
            }
        })
    }
}
