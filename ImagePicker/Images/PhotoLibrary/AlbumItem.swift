import Foundation
import Photos

/**
 Элемент системного альбома фото/видео
 */
public enum AlbumItem: Equatable {
    case photo(PhotoAlbumItem)
    case video(VideoAlbumItem)
    
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
