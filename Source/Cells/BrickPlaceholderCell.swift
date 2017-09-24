//
//  BrickPlaceholderCell.swift
//  BrickKit-iOS
//
//  Created by Aaron Sky on 9/25/17.
//  Copyright © 2017 Wayfair. All rights reserved.
//

class BrickPlaceholderCell: BaseBrickCell {
    @IBOutlet private weak var progressView: UIProgressView!

    /// Stores a progress that is observed using KVO to update the progress view.
    private var progress: Progress? {
        willSet(newProgress) {
            progress?.removeObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted))
        }
        didSet {
            if let progress = progress {
                progressView.setProgress(Float(progress.fractionCompleted), animated: false)
                // TODO: Update to Swift 4 key path syntax
                progress.addObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted), options: [.initial, .new], context: nil)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.isUserInteractionEnabled = false
        self.contentView.isUserInteractionEnabled = false
    }

    func configure(with progress: Progress) {
        self.progress = progress
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? Progress == progress && keyPath == #keyPath(Progress.fractionCompleted) {
            if let fractionCompleted = change?[.newKey] as? Double {
                DispatchQueue.main.async {
                    // Update the progress view to display the new fractionCompleted value from the progress.
                    self.progressView.setProgress(Float(fractionCompleted), animated: true)
                }
            }
        }
    }

    deinit {
        progress = nil
    }
}
