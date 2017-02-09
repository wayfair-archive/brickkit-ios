//
//  ImageDownloader.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/15/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

// Mark: - Image Downloader
public protocol ImageDownloader: class {
    func downloadImage(with imageURL: NSURL, onCompletion completionHandler: ((image: UIImage, url: NSURL) -> Void))
    func downloadImageAndSet(on imageView: UIImageView, with imageURL: NSURL, onCompletion completionHandler: ((image: UIImage, url: NSURL) -> Void))
}

class NSURLSessionImageDownloader: ImageDownloader {

    func downloadImageAndSet(on imageView: UIImageView, with imageURL: NSURL, onCompletion completionHandler: ((image: UIImage, url: NSURL) -> Void)) {
        self.downloadImage(with: imageURL) { (image, url) in
            guard imageURL == url else {
                return
            }

            NSOperationQueue.mainQueue().addOperationWithBlock({
                imageView.image = image
                completionHandler(image: image, url: url)
            })
        }
    }

    func downloadImage(with imageURL: NSURL, onCompletion completionHandler: ((image: UIImage, url: NSURL) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(imageURL, completionHandler: { (data, response, error) in
            guard
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }

            completionHandler(image: image, url: imageURL)
        }).resume()
    }
}
