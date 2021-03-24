import UIKit
import Photos

/**
 Элемент альбома в виде фото
 */
public class PhotoAlbumItem: Equatable {
    
    public let asset: PHAsset
    
    public var cropRect: CGRect?
    public var scrollViewContentOffset: CGPoint?
    public var scrollViewZoomScale: CGFloat?
    
    init(asset: PHAsset,
         cropRect: CGRect? = nil,
         scrollViewContentOffset: CGPoint? = nil,
         scrollViewZoomScale: CGFloat? = nil) {
        self.asset = asset
        self.cropRect = cropRect
        self.scrollViewContentOffset = scrollViewContentOffset
        self.scrollViewZoomScale = scrollViewZoomScale
    }
    
    static public func == (lhs: PhotoAlbumItem, rhs: PhotoAlbumItem) -> Bool {
        return lhs.asset == rhs.asset
    }
}
