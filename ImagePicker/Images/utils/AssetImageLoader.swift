import UIKit
import Photos

public class AssetImageLoader {
    
    public static func loadImage(_ asset: PHAsset, for imageView: UIImageView) {
        guard imageView.frame.size != CGSize.zero else {
            imageView.image = UIImage(named: "gallery_placeholder")
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
        }
        
        imageView.tag = Int(id)
    }
}
