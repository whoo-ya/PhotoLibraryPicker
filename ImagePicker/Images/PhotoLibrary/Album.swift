import UIKit
import Photos

/**
 Представление системного альбома с фото/видео
 */
public class Album {
    
    public let collection: PHAssetCollection
    public var items: [AlbumItem] = []
    
    public init(collection: PHAssetCollection) {
        self.collection = collection
    }
    
    public func reload() {
        items = []
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let itemsFetchResult = PHAsset.fetchAssets(in: collection, options: options)
        
        itemsFetchResult.enumerateObjects({ (asset, count, stop) in
            switch asset.mediaType {
            case .image:
                let albumItem = AlbumItem.photo(PhotoAlbumItem(asset: asset))
                self.items.append(albumItem)
                break
            case .video:
                let albumItem = AlbumItem.video(VideoAlbumItem(asset: asset))
                self.items.append(albumItem)
                break
            case .unknown, .audio:
                break
            @unknown default:
                break
            }
        })
    }
}
