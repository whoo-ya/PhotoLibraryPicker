import UIKit
import Photos

/**
 Элемент альбома в виде фото
 */
public class PhotoAlbumItem: Equatable {
    
    public let asset: PHAsset
    
    init(asset: PHAsset) {
        self.asset = asset
    }
    
    static public func == (lhs: PhotoAlbumItem, rhs: PhotoAlbumItem) -> Bool {
        return lhs.asset == rhs.asset
    }
}
