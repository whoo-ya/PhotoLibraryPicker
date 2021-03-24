import UIKit

public struct LibraryItemCropPosition {
    
    public var cropRect: CGRect?
    
    public var scrollViewContentOffset: CGPoint?
    
    public var scrollViewZoomScale: CGFloat?
    
    public init(cropRect: CGRect? = nil,
                scrollViewContentOffset: CGPoint? = nil,
                scrollViewZoomScale: CGFloat? = nil) {
        self.cropRect = cropRect
        self.scrollViewContentOffset = scrollViewContentOffset
        self.scrollViewZoomScale = scrollViewZoomScale
    }
}
