import UIKit
import Photos

extension PHCachingImageManager {
    
    private func photoImageRequestOptions() -> PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .exact
        options.isSynchronous = true // Ok since we're already in a background thread
        return options
    }
    
    func fetchImage(for asset: PHAsset,
                    cropRect: CGRect,
                    targetSize: CGSize,
                    callback: @escaping (Result<(UIImage, [String: Any]), Error>) -> Void) {
        let options = photoImageRequestOptions()
    
        let resultHandler: (Data?) -> Void = { data in
            if let data = data, let image = UIImage(data: data)?.resetOrientation() {
            
                // Crop the high quality image manually.
                let xCrop: CGFloat = cropRect.origin.x * CGFloat(asset.pixelWidth)
                let yCrop: CGFloat = cropRect.origin.y * CGFloat(asset.pixelHeight)
                let scaledCropRect = CGRect(x: xCrop,
                                            y: yCrop,
                                            width: targetSize.width,
                                            height: targetSize.height)
                if let imageRef = image.cgImage?.cropping(to: scaledCropRect) {
                    let croppedImage = UIImage(cgImage: imageRef)
                    let exifs = self.metadataForImageData(data: data)
                    callback(.success((croppedImage, exifs)))
                }
                else {
                    callback(.failure(ImagePickerBaseError(message: "Не удалось получить изображение '\(asset)'")))
                }
            }
        }
        
        // Fetch Highiest quality image possible.
        if #available(iOS 13, *) {
            requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                resultHandler(data)
            }
        }
        else {
            requestImageData(for: asset, options: options) { data, _, _, _ in
                resultHandler(data)
            }
        }
    }
    
    private func metadataForImageData(data: Data) -> [String: Any] {
        if let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
        let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil),
        let metaData = imageProperties as? [String: Any] {
            return metaData
        }
        return [:]
    }
    
    func fetchPreviewFor(video videoAsset: PHAsset, callback: @escaping (Result<UIImage, Error>) -> Void) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        let screenWidth = UIScreen.main.bounds.width
        let ts = CGSize(width: screenWidth, height: screenWidth)
        requestImage(for: videoAsset, targetSize: ts, contentMode: .aspectFill, options: options) { image, _ in
            DispatchQueue.main.async {
                if let image = image {
                    callback(.success(image))
                }
                else {
                    callback(.failure(ImagePickerBaseError(message: "Не удалось получить первью фото для видео '\(videoAsset)'")))
                }
            }
        }
    }
    
    func fetchPlayerItem(for video: PHAsset, callback: @escaping (AVPlayerItem) -> Void) {
        let videosOptions = PHVideoRequestOptions()
        videosOptions.deliveryMode = PHVideoRequestOptionsDeliveryMode.automatic
        videosOptions.isNetworkAccessAllowed = true
        requestPlayerItem(forVideo: video, options: videosOptions, resultHandler: { playerItem, _ in
            DispatchQueue.main.async {
                if let playerItem = playerItem {
                    callback(playerItem)
                }
            }
        })
    }
    
    /// This method return two images in the callback. First is with low resolution, second with high.
    /// So the callback fires twice.
    func fetch(photo asset: PHAsset, callback: @escaping (Result<(UIImage, Bool), Error>) -> Void) {
        let options = PHImageRequestOptions()
        // Enables gettings iCloud photos over the network, this means PHImageResultIsInCloudKey will never be true.
        options.isNetworkAccessAllowed = true
        // Get 2 results, one low res quickly and the high res one later.
        options.deliveryMode = .opportunistic
        requestImage(for: asset,
                     targetSize: PHImageManagerMaximumSize,
                     contentMode: .aspectFill,
                     options: options) { result, info in
            guard let image = result else {
                callback(.failure(ImagePickerBaseError(message: "No Result Image")))
                return
            }
            DispatchQueue.main.async {
                let isLowRes = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                callback(.success((image, isLowRes)))
            }
        }
    }
}
