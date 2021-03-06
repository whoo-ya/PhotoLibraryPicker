//
//  YPLibrarySelection.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 18/04/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit

public struct YPLibrarySelection {
    public let index: Int
    public var cropRect: CGRect?
    public var scrollViewContentOffset: CGPoint?
    public var scrollViewZoomScale: CGFloat?
    public let assetIdentifier: String
    
    public init(index: Int,
                cropRect: CGRect? = nil,
                scrollViewContentOffset: CGPoint? = nil,
                scrollViewZoomScale: CGFloat? = nil,
                assetIdentifier: String) {
        self.index = index
        self.cropRect = cropRect
        self.scrollViewContentOffset = scrollViewContentOffset
        self.scrollViewZoomScale = scrollViewZoomScale
        self.assetIdentifier = assetIdentifier
    }
}
