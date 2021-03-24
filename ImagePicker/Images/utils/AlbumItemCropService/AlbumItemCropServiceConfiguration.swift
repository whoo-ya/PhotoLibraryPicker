import Foundation
import Photos
import AVFoundation
import MobileCoreServices

class AlbumItemCropServiceConfiguration {
    
    /**
     Defines the time limit for videos from the library.
     Defaults to 60 seconds.
     */
    public var libraryTimeLimit: TimeInterval
    
    /**
     Defines the minimum time for the video
     Defaults to 3 seconds.
     */
    public var minimumTimeLimit: TimeInterval
    
    /**
     Choose the result video extension if you trim or compress a video.
     Defaults to mov.
     */
    public var videoFileType: AVFileType
    
    /**
     Уровень сжатия видео.
     Defaults AVAssetExportPresetHighestQuality
     */
    public var videoCompression: String
    
    init(libraryTimeLimit: TimeInterval = 60,
         minimumTimeLimit: TimeInterval = 3.0,
         videoFileType: AVFileType = .mov,
         videoCompression: String = AVAssetExportPresetHighestQuality) {
        self.libraryTimeLimit = libraryTimeLimit
        self.minimumTimeLimit = minimumTimeLimit
        self.videoFileType = videoFileType
        self.videoCompression = videoCompression
    }
}
