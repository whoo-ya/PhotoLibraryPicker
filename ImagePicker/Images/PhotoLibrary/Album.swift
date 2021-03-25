import UIKit
import Photos

/**
 Представление системного альбома с фото/видео
 */
public class Album: Equatable {
    
    public let title: String
    
    public var thumbnail: UIImage?
    
    public let collection: PHAssetCollection
    public var items: [AlbumItem] = []
    
    private static let thumbnailSize = CGSize(width: 78, height: 78)
    
    public init(collection: PHAssetCollection) {
        self.collection = collection
        self.title = collection.localizedTitle ?? ""
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
        
        if self.items.count > 0 {
            // Загружаем первое фото альбома, как его preview
            let fetchResult = PHAsset.fetchKeyAssets(in: collection, options: nil)
            if let first = fetchResult?.firstObject {
                let deviceScale = UIScreen.main.scale
                let targetSize = CGSize(width: Self.thumbnailSize.width*deviceScale,
                                        height: Self.thumbnailSize.height*deviceScale)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                options.deliveryMode = .opportunistic
                PHImageManager.default().requestImage(for: first,
                                                      targetSize: targetSize,
                                                      contentMode: .aspectFill,
                                                      options: options,
                                                      resultHandler: { [weak self] image, _ in
                                                        self?.thumbnail = image
                })
            }
        }
        else {
            thumbnail = nil
        }
    }
    
    static public func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.collection.localIdentifier == rhs.collection.localIdentifier
    }
}
