//
//  ImageDownloader.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/15/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

private func _downloadImageAndSet(_ imageDownloader: ImageDownloader, on imageView: UIImageView, with imageURL: URL, onCompletion completionHandler: @escaping ((_ image: UIImage, _ url: URL) -> Void)) {

    imageView.image = nil
    imageDownloader.downloadImage(with: imageURL) { (image: UIImage, url: URL) in
        guard imageURL == url else {
            return
        }

        DispatchQueue.main.async {
            imageView.image = image
            completionHandler(image, url)
        }
    }
}

// Mark: - Image Downloader
public protocol ImageDownloader: class {
    func downloadImage(with imageURL: URL, onCompletion completionHandler: @escaping ((_ image: UIImage, _ url: URL) -> Void))
    func downloadImageAndSet(on imageView: UIImageView, with imageURL: URL, onCompletion completionHandler: @escaping ((_ image: UIImage, _ url: URL) -> Void))
}

public extension ImageDownloader {

    func downloadImageAndSet(on imageView: UIImageView, with imageURL: URL, onCompletion completionHandler: @escaping ((_ image: UIImage, _ url: URL) -> Void)) {
        _downloadImageAndSet(self, on: imageView, with: imageURL, onCompletion: completionHandler)
    }

}

open class NSURLSessionImageDownloader: ImageDownloader {
    open func downloadImageAndSet(on imageView: UIImageView, with imageURL: URL, onCompletion completionHandler: @escaping ((_ image: UIImage, _ url: URL) -> Void)) {
        _downloadImageAndSet(self, on: imageView, with: imageURL, onCompletion: completionHandler)
    }

    open func downloadImage(with imageURL: URL, onCompletion completionHandler: @escaping ((_ image: UIImage, _ url: URL) -> Void)) {
        URLSession.shared.dataTask(with: imageURL, completionHandler: { (data, response, error) in
            guard
                let data = data , error == nil,
                let image = UIImage(data: data)
                else { return }

            completionHandler(image, imageURL)
        }).resume()
    }
}
