import UIKit
import Photos

public class MediaVideoItem {
    
    /**
     Превью изображения
     */
    public var thumbnail: UIImage
    /**
     Ссылка на оригинальный видео файл
     */
    public var url: URL
    
    /**
     Оригинальный Asset содержащий информацию о видео
     */
    public var asset: PHAsset?

    public init(thumbnail: UIImage, videoURL: URL, asset: PHAsset? = nil) {
        self.thumbnail = thumbnail
        self.url = videoURL
        self.asset = asset
    }
}
