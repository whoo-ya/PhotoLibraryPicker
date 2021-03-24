import Foundation
import Photos

/**
 Элемент системного альбома фото/видео
 Включает CropInfo для элемента, если пользователь его отредактировал.
 */
public enum AlbumItem: Equatable {
    case photo(PhotoAlbumItem)
    case video(VideoAlbumItem)
    
    func getAsset() -> PHAsset {
        switch self {
        case .photo(let item):
            return item.asset
        case .video(let item):
            return item.asset
        }
    }
    
    func getCropRect() -> CGRect? {
        switch self {
        case .photo(let item):
            return item.cropRect
        case .video(let item):
            return item.cropRect
        }
    }
    
    func clearCropInfo() {
        updateCropInfo(cropRect: nil,
                       scrollViewContentOffset: nil,
                       scrollViewZoomScale: nil)
    }
    
    func updateCropInfo(cropRect: CGRect?,
                        scrollViewContentOffset: CGPoint?,
                        scrollViewZoomScale: CGFloat?) {
        switch self {
        case .photo(let item):
            item.cropRect = cropRect
            item.scrollViewContentOffset = scrollViewContentOffset
            item.scrollViewZoomScale = scrollViewZoomScale
        case .video(let item):
            item.cropRect = cropRect
            item.scrollViewContentOffset = scrollViewContentOffset
            item.scrollViewZoomScale = scrollViewZoomScale
        }
    }
    
    static public func == (lhs: AlbumItem, rhs: AlbumItem) -> Bool {
        let lhsAsset: PHAsset
        let rhsAsset: PHAsset
        
        switch lhs {
        case .photo(let photo):
            lhsAsset = photo.asset
        case .video(let video):
            lhsAsset = video.asset
        }
        
        switch rhs {
        case .photo(let photo):
            rhsAsset = photo.asset
        case .video(let video):
            rhsAsset = video.asset
        }
        
        return lhsAsset == rhsAsset
    }
}
