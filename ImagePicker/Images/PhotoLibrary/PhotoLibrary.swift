import UIKit
import Photos

/**
 Представление библиотеки пользователя с списком альбомов.
 */
public class PhotoLibrary {
    
    public var albums: [Album] = []
    
    public var albumsFetchResults = [PHFetchResult<PHAssetCollection>]()
    
    public init() {
        
    }
        
    public func reload(_ completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            self.reloadSync()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private func reloadSync() {
        let types: [PHAssetCollectionType] = [.smartAlbum, .album]
        
        albumsFetchResults = types.map {
            return PHAssetCollection.fetchAssetCollections(with: $0, subtype: .any, options: nil)
        }
        
        albums = []
        
        for result in albumsFetchResults {
            result.enumerateObjects({ (collection, _, _) in
                let album = Album(collection: collection)
                album.reload()
                
                if !album.items.isEmpty {
                    self.albums.append(album)
                }
            })
        }
        
        if let index = albums.firstIndex(where: { $0.collection.assetCollectionSubtype == .smartAlbumUserLibrary }) {
            guard index != 0 && index < albums.count else {
                return
            }

            let item = albums[index]
            albums.remove(at: index)
            albums.insert(item, at: 0)
        }
    }
}
