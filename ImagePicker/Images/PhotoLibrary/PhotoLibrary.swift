import UIKit
import Photos

/**
 Представление системной библиотеки пользователя с списком альбомов.
 Включает:
 - Запрос доступа к библиотеке
 - Инициализацию и получение альбомов пользователя.
 */
public class PhotoLibrary {
    
    private(set) var albums: [Album] = []
    
    private(set) var albumsFetchResults = [PHFetchResult<PHAssetCollection>]()
        
    public init() {
        
    }
        
    public func reload(_ completion: @escaping (Result<[Album], Error>) -> Void) {
        checkPermissionToAccessPhotoLibrary() { [weak self] hasPermission in
            if hasPermission {
                DispatchQueue.global().async {
                    self?.reloadSync()
                    DispatchQueue.main.async {
                        if let albums = self?.albums {
                            completion(.success(albums))
                        }
                        else {
                            completion(.failure(ImagePickerBaseError(message: "PhotoLibrary deinit after load library")))
                        }
                    }
                }
            }
            else {
                completion(.failure(PermissionImagePickerError(message: "Отсутствует доступ к галерее")))
            }
        }
    }
    
    private func reloadSync() {
        let types: [PHAssetCollectionType] = [.smartAlbum, .album]
        
        albumsFetchResults = types.map {
            let options = PHFetchOptions()
            return PHAssetCollection.fetchAssetCollections(with: $0, subtype: .any, options: options)
        }
        
        albums = []
        
        for result in albumsFetchResults {
            result.enumerateObjects({ (assetCollection, _, _) in
                let album = Album(collection: assetCollection)
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
    
    // Async beacause will prompt permission if .notDetermined
    func checkPermissionToAccessPhotoLibrary(block: @escaping (Bool) -> Void) {
        // Only intilialize picker if photo permission is Allowed by user.
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            block(true)
        #if compiler(>=5.3)
        case .limited:
            block(true)
        #endif
        case .restricted, .denied:
            block(false)
        case .notDetermined:
            // Show permission popup and get new status
            PHPhotoLibrary.requestAuthorization { s in
                DispatchQueue.main.async {
                    block(s == .authorized)
                }
            }
        @unknown default:
            fatalError()
        }
    }
}
