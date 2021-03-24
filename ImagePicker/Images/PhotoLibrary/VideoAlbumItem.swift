import UIKit
import Photos

/**
 Элемент альбома в виде видео
 */
public class VideoAlbumItem: Equatable {
    
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
    
    static public func == (lhs: VideoAlbumItem, rhs: VideoAlbumItem) -> Bool {
        return lhs.asset == rhs.asset
    }
}
