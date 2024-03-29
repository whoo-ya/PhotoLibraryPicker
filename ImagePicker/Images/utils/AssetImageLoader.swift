import UIKit
import Photos

/**
 Загрузчик изображения из системного альбома на основе переданного PHAsset.
 После загрузки первично устанавливается сжатое фото, после оригинальное.
 */
public class AssetImageLoader {
    
    public static func loadImage(_ asset: PHAsset,
                                 for imageView: UIImageView,
                                 completion: (() -> Void)? = nil) {
        guard imageView.frame.size != CGSize.zero else {
            imageView.image = UIImage(named: "gallery_placeholder")
            completion?()
            return
        }
        
        if imageView.tag == 0 {
            imageView.image = UIImage(named: "gallery_placeholder")
        }
        else {
            // отменяем прошлый запрос ресурса, т.к. для переданного View нам нужно загрузить новое фото.
            PHImageManager.default().cancelImageRequest(PHImageRequestID(imageView.tag))
        }
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        
        let scale = UIScreen.main.scale
        let size = CGSize(width: imageView.frame.width * scale,
                          height: imageView.frame.height * scale)
        
        let id = PHImageManager.default().requestImage(for: asset,
                                                       targetSize: size,
                                                       contentMode: .aspectFill,
                                                       options: options) { [weak imageView] image, _ in
            imageView?.image = image
            completion?()
        }
        
        imageView.tag = Int(id)
    }
}
