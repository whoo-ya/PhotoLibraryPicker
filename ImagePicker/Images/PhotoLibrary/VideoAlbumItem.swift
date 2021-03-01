import UIKit
import Photos

/**
 Элемент альбома в виде видео
 */
public class VideoAlbumItem: Equatable {
    
    public let asset: PHAsset
    
    var durationRequestID: Int = 0
    var duration: Double = 0
    
    public init(asset: PHAsset) {
        self.asset = asset
    }
    
    static public func == (lhs: VideoAlbumItem, rhs: VideoAlbumItem) -> Bool {
        return lhs.asset == rhs.asset
    }
}
