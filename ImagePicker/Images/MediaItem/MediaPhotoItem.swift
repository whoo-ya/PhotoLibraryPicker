import UIKit
import Photos

public class MediaPhotoItem {
    
    /**
     Фото для показа пользователю
     */
    public let image: UIImage
    
    /**
     Служебная информация о фото
     */
    public let exifMeta: [String: Any]?
    
    /**
     Оригинальные данные о фото из альбома
     */
    public var asset: PHAsset?
    
    public init(image: UIImage, exifMeta: [String: Any]? = nil, asset: PHAsset? = nil) {
        self.image = image
        self.exifMeta = exifMeta
        self.asset = asset
    }
}
