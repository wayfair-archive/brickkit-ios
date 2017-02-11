//
//  MockFlickerViewController.swift
//  BrickKit-Example
//
//  Created by Justin Anderson on 10/13/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation
import UIKit

public class FlickrRecentImagesRequest: BaseRequest {
    
    var apiKey = "2f4747add301af4b5d34d688821b52ae" //Flickr example key
    var method = "flickr.photos.search"
    var format = "json"
    var minUploadDate = NSDate().addingTimeInterval(-(60*60*24))
    var privacyFilter = 1
    var safeSearch = 1
    
    
    public init() {
        super.init(controller: "services", action: "rest/")
    }
    
    public required init(map: [NSString: NSObject]) {
        fatalError("init(map:) has not been implemented")
    }
    
    public override func jsonValue() -> [NSString : AnyObject] {
        var map = super.jsonValue()
        map["api_key"] = apiKey as AnyObject?
        map["method"] = method as AnyObject?
        map["format"] = format as AnyObject?
        map["nojsoncallback"] = "1" as AnyObject?
        map["min_upload_date"] = "\(minUploadDate.timeIntervalSince1970)" as AnyObject?
        map["privacy_filter"] = "\(privacyFilter)" as AnyObject?
        map["safe_search"] = "\(safeSearch)" as AnyObject?
        return map
    }
}

class FlickrRecentImagesResponse: Mappable {
    
    let page: Int
    let totalPages: Int
    let perPage: Int
    let total: Int
    let photos: [FlickrImageResponse]
    
    required init(map: [NSString: NSObject]) {
        let response = map["photos"] as! [NSString: NSObject]
        
        page = response["page"] as! Int
        totalPages = response["pages"] as! Int
        perPage = response["perpage"] as! Int
        total = Int(response["total"] as! String) ?? 0
        
        var photos = [FlickrImageResponse]()
        
        let photoJson = response["photo"] as! [[NSString: NSObject]]
        
        photoJson.forEach {
            photos.append(FlickrImageResponse(map: $0))
        }
        
        self.photos = photos
    }
}

class FlickrImageResponse: Mappable {
    
    let id: String
    let owner: String
    let secret: String
    let farmId: Int
    let server: String
    let title: String
    let isPublic: Bool
    
    var imageUrl: String {
        return "https://farm\(farmId).staticflickr.com/\(server)/\(id)_\(secret)_b.jpg"
    }
    
    required init(map: [NSString: NSObject]) {
        id = map["id"] as! String
        owner = map["owner"] as! String
        secret = map["secret"] as! String
        server = map["server"] as! String
        farmId = (map["farm"] as! NSNumber).intValue
        title = map["title"] as! String
        let isPublicInt = map["ispublic"] as! Int
        isPublic = (isPublicInt > 0)
    }
}
