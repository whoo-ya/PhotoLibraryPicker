import UIKit
import Photos
import AVFoundation
import MobileCoreServices

/**
 Сервис для обрезки фото/видео в оригинальном разрешении.
 */
class AlbumItemCropService {
    
    private let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    private var exportTimer: Timer?
    
    private var currentExportSessions: [AVAssetExportSession] = []
    
    private let configuration: AlbumItemCropServiceConfiguration
    
    init(configuration: AlbumItemCropServiceConfiguration) {
        self.configuration = configuration
    }
    
    public func getCropedMediaItems(items: [AlbumItem],
//                                    updateProgress: ((_ progress: Float) -> Void),
                                    _ completed: @escaping ((Result<[MediaItem], Error>) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                return
            }
            let selectedAssets: [(asset: PHAsset, cropRect: CGRect?)] = items.map { item in
                return (item.getAsset(), item.getCropRect())
            }
            
            var assetDictionary = Dictionary<PHAsset?, Int>()
            for (index, assetPair) in selectedAssets.enumerated() {
                assetDictionary[assetPair.asset] = index
            }
            
            var resultMediaItems: [MediaItem] = []
            let asyncGroup = DispatchGroup()
            
            for asset in selectedAssets {
                asyncGroup.enter()
                
                switch asset.asset.mediaType {
                case .image:
                    self.fetchImageAndCrop(for: asset.asset, withCropRect: asset.cropRect) { result in
                        switch result {
                        case .success(let (image, exifMeta)):
                            let photo = MediaPhotoItem(image: image, exifMeta: exifMeta, asset: asset.asset)
                            resultMediaItems.append(MediaItem.photo(item: photo))
                        case .failure(let error):
                            // TODO: Прервать обработку и вернуть ошибку.
                            completed(.failure(error))
                            break
                        }
                        asyncGroup.leave()
                    }
                case .video:
                    self.fetchVideoAndApplySettings(for: asset.asset,
                                                    withCropRect: asset.cropRect) { result in
                        switch result {
                        case .success(let videoURL):
                            do {
                                let videoItem = MediaVideoItem(thumbnail: try self.thumbnailFromVideoPath(videoURL),
                                                               videoURL: videoURL, asset: asset.asset)
                                resultMediaItems.append(MediaItem.video(item: videoItem))
                                asyncGroup.leave()
                            }
                            catch {
                                // TODO: Прервать обработку и вернуть ошибку.
                                completed(.failure(error))
                                asyncGroup.leave()
                                return
                            }
                        case .failure(let error):
                            // TODO: Прервать обработку и вернуть ошибку.
                            completed(.failure(error))
                            asyncGroup.leave()
                            return
                        }
                    }
                default:
                    break
                }
            }
            
            asyncGroup.notify(queue: .main) {
                //TODO: sort the array based on the initial order of the assets in selectedAssets
                resultMediaItems.sort { (first, second) -> Bool in
                    var firstAsset: PHAsset?
                    var secondAsset: PHAsset?
                    
                    switch first {
                    case .photo(let photo):
                        firstAsset = photo.asset
                    case .video(let video):
                        firstAsset = video.asset
                    }
                    guard let firstIndex = assetDictionary[firstAsset] else {
                        return false
                    }
                    
                    switch second {
                    case .photo(let photo):
                        secondAsset = photo.asset
                    case .video(let video):
                        secondAsset = video.asset
                    }
                    
                    guard let secondIndex = assetDictionary[secondAsset] else {
                        return false
                    }
                    
                    return firstIndex < secondIndex
                }
                completed(.success(resultMediaItems))
            }
        }
    }
    
    public func fetchImageAndCrop(for asset: PHAsset,
                                  withCropRect cropRect: CGRect?,
                                  callback: @escaping ((Result<(UIImage, [String: Any]), Error>) -> Void)) {
        let cropRect = cropRect ?? CGRect(x: 0, y: 0, width: 1, height: 1)
        let ts = targetSize(for: asset, cropRect: cropRect)
        imageManager.fetchImage(for: asset, cropRect: cropRect, targetSize: ts, callback: callback)
    }
    
    private func fetchVideoAndApplySettings(for asset: PHAsset,
                                            withCropRect rect: CGRect? = nil,
//                                            updateProgress: ((_ progress: Float) -> Void),
                                            callback: @escaping (Result<URL, Error>) -> Void) {
        guard fitsVideoLengthLimits(asset: asset) else {
            callback(.failure(ImagePickerBaseError(message: "Длина видео не соответсвует настройкам 3-60сек")))
            return
        }
        
        let normalizedCropRect = rect ?? CGRect(x: 0, y: 0, width: 1, height: 1)
        let ts = targetSize(for: asset, cropRect: normalizedCropRect)
        let xCrop: CGFloat = normalizedCropRect.origin.x * CGFloat(asset.pixelWidth)
        let yCrop: CGFloat = normalizedCropRect.origin.y * CGFloat(asset.pixelHeight)
        let resultCropRect = CGRect(x: xCrop,
                                    y: yCrop,
                                    width: ts.width,
                                    height: ts.height)
        
        fetchVideoUrlAndCrop(for: asset,
                             cropRect: resultCropRect,
//                                 updateProgress: updateProgress,
                             callback: callback)
    }
    
    func fetchVideoUrlAndCrop(for videoAsset: PHAsset,
                              cropRect: CGRect,
//                              updateProgress: ((_ progress: Float) -> Void),
                              callback: @escaping (Result<URL, Error>) -> Void) {
        let videosOptions = PHVideoRequestOptions()
        videosOptions.isNetworkAccessAllowed = true
        videosOptions.deliveryMode = .highQualityFormat
        imageManager.requestAVAsset(forVideo: videoAsset, options: videosOptions) { asset, _, _ in
            do {
                guard let asset = asset else {
                    callback(.failure(ImagePickerBaseError(message: "⚠️ PHCachingImageManager >>> Don't have the asset")))
                    return
                }
                
                let assetComposition = AVMutableComposition()
                let assetMaxDuration = asset.duration
                let trackTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: assetMaxDuration)
                
                // 1. Inserting audio and video tracks in composition
                
                guard let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first,
                      let videoCompositionTrack = assetComposition
                        .addMutableTrack(withMediaType: .video,
                                         preferredTrackID: kCMPersistentTrackID_Invalid) else {
                    callback(.failure(ImagePickerBaseError(message: "⚠️ PHCachingImageManager >>> Problems with video track")))
                    return
                    
                }
                if let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first,
                    let audioCompositionTrack = assetComposition
                        .addMutableTrack(withMediaType: AVMediaType.audio,
                                         preferredTrackID: kCMPersistentTrackID_Invalid) {
                    try audioCompositionTrack.insertTimeRange(trackTimeRange, of: audioTrack, at: CMTime.zero)
                }
                
                try videoCompositionTrack.insertTimeRange(trackTimeRange, of: videoTrack, at: CMTime.zero)
                
                // Layer Instructions
                let layerInstructions = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
                var transform = videoTrack.preferredTransform
                let videoSize = videoTrack.naturalSize.applying(transform)
                transform.tx = (videoSize.width < 0) ? abs(videoSize.width) : 0.0
                transform.ty = (videoSize.height < 0) ? abs(videoSize.height) : 0.0
                transform.tx -= cropRect.minX
                transform.ty -= cropRect.minY
                layerInstructions.setTransform(transform, at: CMTime.zero)
                videoCompositionTrack.preferredTransform = transform
                
                // CompositionInstruction
                let mainInstructions = AVMutableVideoCompositionInstruction()
                mainInstructions.timeRange = trackTimeRange
                mainInstructions.layerInstructions = [layerInstructions]
                
                // Video Composition
                let videoComposition = AVMutableVideoComposition(propertiesOf: asset)
                videoComposition.instructions = [mainInstructions]
                videoComposition.renderSize = cropRect.size // needed?
                
                // 5. Configuring export session
                
                let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingUniquePathComponent(pathExtension: self.configuration.videoFileType.fileExtension)
                let exportSession = try assetComposition
                    .export(to: fileURL,
                            videoComposition: videoComposition,
                            videoCompression: self.configuration.videoCompression,
                            videoFileType: self.configuration.videoFileType,
                            removeOldFile: true) { [weak self] session in
                                DispatchQueue.main.async {
                                    switch session.status {
                                    case .completed:
                                        if let url = session.outputURL {
                                            if let index = self?.currentExportSessions.firstIndex(of: session) {
                                                self?.currentExportSessions.remove(at: index)
                                            }
                                            callback(.success(url))
                                        } else {
                                            callback(.failure(ImagePickerBaseError(message: "LibraryMediaManager -> Don't have URL.")))
                                        }
                                    case .failed:
                                        callback(.failure(ImagePickerBaseError(message: "Export of the video failed : \(String(describing: session.error))")))
                                    default:
                                        callback(.failure(ImagePickerBaseError(message: "Export session completed with \(session.status) status. Not handled.")))
                                    }
                                }
                }

                // 6. Exporting
                DispatchQueue.main.async {
                    self.exportTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                            target: self,
                                                            selector: #selector(self.onTickExportTimer),
                                                            userInfo: exportSession,
                                                            repeats: true)
                }

                if let s = exportSession {
                    self.currentExportSessions.append(s)
                }
            } catch let error {
                callback(.failure(error))
            }
        }
    }
    
    func thumbnailFromVideoPath(_ path: URL) throws -> UIImage {
        let asset = AVURLAsset(url: path, options: nil)
        let gen = AVAssetImageGenerator(asset: asset)
        gen.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
        var actualTime = CMTimeMake(value: 0, timescale: 0)
        let image: CGImage
        
        do {
            image = try gen.copyCGImage(at: time, actualTime: &actualTime)
            let thumbnail = UIImage(cgImage: image)
            return thumbnail
        }
        catch {
            throw error
        }
    }
    
    @objc func onTickExportTimer(sender: Timer) {
        // TODO: добавить индикатор прогресса
//        if let exportSession = sender.userInfo as? AVAssetExportSession {
//            if let v = v {
//                if exportSession.progress > 0 {
//                    v.updateProgress(exportSession.progress)
//                }
//            }
//
//            if exportSession.progress > 0.99 {
//                sender.invalidate()
//                v?.updateProgress(0)
//                self.exportTimer = nil
//            }
//        }
    }
    
    private func fitsVideoLengthLimits(asset: PHAsset) -> Bool {
        guard asset.mediaType == .video else {
            return true
        }
        
        let tooLong = floor(asset.duration) > configuration.libraryTimeLimit
        let tooShort = floor(asset.duration) < configuration.minimumTimeLimit
        
        return !(tooLong || tooShort)
    }
    
    private func targetSize(for asset: PHAsset, cropRect: CGRect) -> CGSize {
        var width = (CGFloat(asset.pixelWidth) * cropRect.width).rounded(.toNearestOrEven)
        var height = (CGFloat(asset.pixelHeight) * cropRect.height).rounded(.toNearestOrEven)
        // round to lowest even number
        width = (width.truncatingRemainder(dividingBy: 2) == 0) ? width : width - 1
        height = (height.truncatingRemainder(dividingBy: 2) == 0) ? height : height - 1
        return CGSize(width: width, height: height)
    }
}


fileprivate extension AVFileType {
    /// Fetch and extension for a file from UTI string
    var fileExtension: String {
        if let ext = UTTypeCopyPreferredTagWithClass(self as CFString,
                                                     kUTTagClassFilenameExtension)?.takeRetainedValue() {
            return ext as String
        }
        return "None"
    }
}

fileprivate extension URL {
    /// Adds a unique path to url
    func appendingUniquePathComponent(pathExtension: String? = nil) -> URL {
        var pathComponent = UUID().uuidString
        if let pathExtension = pathExtension {
            pathComponent += ".\(pathExtension)"
        }
        return appendingPathComponent(pathComponent)
    }
}

fileprivate extension AVAsset {
    
    /// Export the video
    ///
    /// - Parameters:
    ///   - destination: The url to export
    ///   - videoComposition: video composition settings, for example like crop
    ///   - removeOldFile: remove old video
    ///   - completion: resulting export closure
    /// - Throws: YPTrimError with description
    func export(to destination: URL,
                videoComposition: AVVideoComposition? = nil,
                videoCompression: String,
                videoFileType: AVFileType,
                removeOldFile: Bool = false,
                completion: @escaping (_ exportSession: AVAssetExportSession) -> Void) throws -> AVAssetExportSession? {
        guard let exportSession = AVAssetExportSession(asset: self, presetName: videoCompression) else {
            throw ImagePickerBaseError(message: "YPImagePicker -> AVAsset -> Could not create an export session.")
        }
        
        exportSession.outputURL = destination
        exportSession.outputFileType = videoFileType
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = videoComposition

        if removeOldFile {
            try FileManager.default.removeFileIfNecessary(at: destination)
        }
        
        exportSession.exportAsynchronously(completionHandler: {
            completion(exportSession)
        })

        return exportSession
    }
}

fileprivate extension FileManager {
    func removeFileIfNecessary(at url: URL) throws {
        guard fileExists(atPath: url.path) else {
            return
        }
        
        do {
            try removeItem(at: url)
        } catch let error {
            throw ImagePickerBaseError(message: "Couldn't remove existing destination file: \(error)", cause: error)
        }
    }
}
