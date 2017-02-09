//
//  ImageDownloader.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/15/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

private func _downloadImageAndSet(imageDownloader: ImageDownloader, on imageView: UIImageView, with imageURL: NSURL, onCompletion completionHandler: ((image: UIImage, url: NSURL) -> Void)) {
    
    imageDownloader.downloadImage(with: imageURL) { (image, url) in
        guard imageURL == url else {
            return
        }

        NSOperationQueue.mainQueue().addOperationWithBlock {
            imageView.image = image
            completionHandler(image: image, url: url)
        }
    }

}

// Mark: - Image Downloader
public protocol ImageDownloader: class {
    func downloadImage(with imageURL: NSURL, onCompletion completionHandler: ((image: UIImage, url: NSURL) -> Void))
    func downloadImageAndSet(on imageView: UIImageView, with imageURL: NSURL, onCompletion completionHandler: ((image: UIImage, url: NSURL) -> Void))
}

public extension ImageDownloader {

    func downloadImageAndSet(on imageView: UIImageView, with imageURL: NSURL, onCompletion completionHandler: ((image: UIImage, url: NSURL) -> Void)) {
        _downloadImageAndSet(self, on: imageView, with: imageURL, onCompletion: completionHandler)
    }

}

public class NSURLSessionImageDownloader: ImageDownloader {

    public func downloadImageAndSet(on imageView: UIImageView, with imageURL: NSURL, onCompletion completionHandler: ((image: UIImage, url: NSURL) -> Void)) {
        _downloadImageAndSet(self, on: imageView, with: imageURL, onCompletion: completionHandler)
    }

    public func downloadImage(with imageURL: NSURL, onCompletion completionHandler: ((image: UIImage, url: NSURL) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(imageURL, completionHandler: { (data, response, error) in
            guard
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }

            completionHandler(image: image, url: imageURL)
        }).resume()
    }
}
