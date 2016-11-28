//
//  MockFlickerViewController.swift
//  BrickKit-Example
//
//  Created by Justin Anderson on 10/13/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation
import BrickKit

class CachedImage {
    var imageData: NSData?
    var url: NSURL
    var expirationDate: NSDate
    var hasImage: Bool = true
    
    init(imageData: NSData?, url: NSURL, expirationDate: NSDate) {
        self.url = url
        self.expirationDate = expirationDate
        self.imageData = imageData
    }
}

class CachingImageDownloader: ImageDownloader {
    
    private let cache = NSCache() //<NSURL, ChachedImage>() <-- For Swift 3.0
    var metaDataHandler: ((UIImage) -> Bool)? = nil

    func downloadImage(with imageURL: NSURL, onCompletion completionHandler: ((image: UIImage, url: NSURL) -> Void)) {
        if let cachedImage = cache.objectForKey(imageURL) as? CachedImage, let imageData = cachedImage.imageData, let image = UIImage(data: imageData) {
            completionHandler(image: image, url: imageURL)
            return
        }
        
        
        NSURLSession.sharedSession().dataTaskWithURL(imageURL, completionHandler: { (data, response, error) in
            guard
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            
            
            let cached = CachedImage(imageData: data, url: imageURL, expirationDate: NSDate())
            cached.hasImage = self.metaDataHandler?(image) ?? true
            self.cache.setObject(cached, forKey: imageURL as NSURL)
            if !cached.hasImage {
                return
            }
            
            completionHandler(image: image, url: imageURL)
        }).resume()
    }
}
