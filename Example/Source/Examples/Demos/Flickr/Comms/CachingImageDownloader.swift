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
    
    private let cache = NSCache<NSURL, CachedImage>() //<NSURL, ChachedImage>() <-- For Swift 3.0
    var metaDataHandler: ((UIImage) -> Bool)? = nil

    func downloadImage(with imageURL: URL, onCompletion completionHandler: @escaping ((_ image: UIImage, _ url: URL) -> Void)) {
        if let cachedImage = cache.object(forKey: imageURL as NSURL), let imageData = cachedImage.imageData, let image = UIImage(data: imageData as Data) {
            completionHandler(image, imageURL)
            return
        }
        
        
        URLSession.shared.dataTask(with: imageURL, completionHandler: { (data, response, error) in
            guard
                let data = data , error == nil,
                let image = UIImage(data: data)
                else { return }
            
            
            let cached = CachedImage(imageData: data as NSData?, url: imageURL as NSURL, expirationDate: NSDate())
            cached.hasImage = self.metaDataHandler?(image) ?? true
            self.cache.setObject(cached, forKey: imageURL as NSURL)
            if !cached.hasImage {
                return
            }
            
            completionHandler(image, (imageURL as NSURL) as URL)
        }).resume()
    }
    
}
