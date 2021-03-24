import UIKit
import Photos

/**
 View для отображения Photo/Video Asset из галереи пользователя.
 
 Включает:
 - Зум фото с сохранением инфморации о степени увеличения/уменьшения
 - Смещение фото
 - Сохранение и применение ранее примененных значений зума и смещения
 */
public final class AssetZoomableView: UIScrollView {
    
    private let errorHandler = ErrorHandler()
    
    public weak var myDelegate: AssetZoomableViewDelegate?
    public var cropAreaDidChange = {}
    public var isVideoMode = false
    public var photoImageView = UIImageView()
    public var videoView = VideoView()
    public var squaredZoomScale: CGFloat = 1
    
    private var minWidth: CGFloat? = nil
    private var onlySquare = false
    
    fileprivate var currentAsset: PHAsset?
    
    // Image view of the asset for convenience. Can be video preview image view or photo image view.
    public var assetImageView: UIImageView {
        return isVideoMode ? videoView.previewImageView : photoImageView
    }
    
    private var assetViewBackgroundColor = UIColor.clear
    private let imageManager: PHCachingImageManager = PHCachingImageManager()

    /// Set zoom scale to fit the image to square or show the full image
    //
    /// - Parameters:
    ///   - fit: If true - zoom to show squared. If false - show full.
    public func fitImage(_ fit: Bool, animated isAnimated: Bool = false) {
        do {
            squaredZoomScale = try calculateSquaredZoomScale()
            if fit {
                setZoomScale(squaredZoomScale, animated: isAnimated)
            } else {
                setZoomScale(1, animated: isAnimated)
            }
        }
        catch {
            errorHandler.handleError(error)
        }
    }
    
    /// Re-apply correct scrollview settings if image has already been adjusted in
    /// multiple selection mode so that user can see where they left off.
    public func applyStoredCropPosition(_ scp: LibraryItemCropPosition) {
        // ZoomScale needs to be set first.
        if let zoomScale = scp.scrollViewZoomScale {
            setZoomScale(zoomScale, animated: false)
        }
        if let contentOffset = scp.scrollViewContentOffset {
            setContentOffset(contentOffset, animated: false)
        }
    }
    
    public func setVideo(_ video: PHAsset,
                         storedCropPosition: LibraryItemCropPosition?,
                         completion: @escaping (Error?) -> Void,
                         updateCropInfo: @escaping () -> Void) {

        imageManager.fetchPreviewFor(video: video) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            guard strongSelf.currentAsset != video else {
                completion(nil)
                return
            }
            
            if strongSelf.videoView.isDescendant(of: strongSelf) == false {
                strongSelf.isVideoMode = true
                strongSelf.photoImageView.removeFromSuperview()
                strongSelf.addSubview(strongSelf.videoView)
            }
            
            switch result {
            case .success(let preview):
                strongSelf.videoView.setPreviewImage(preview)
                strongSelf.setAssetFrame(for: strongSelf.videoView, with: preview)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
            
            // Stored crop position in multiple selection
            if let scp173 = storedCropPosition {
                strongSelf.applyStoredCropPosition(scp173)
                // MARK: add update CropInfo after multiple
                updateCropInfo()
            }
        }
        
        imageManager.fetchPlayerItem(for: video) { [weak self] playerItem in
            guard let strongSelf = self else {
                return
            }
            guard strongSelf.currentAsset != video else {
                return
            }
            strongSelf.currentAsset = video

            strongSelf.videoView.loadVideo(playerItem)
            strongSelf.videoView.play()
        }
    }
    
    public func setImage(_ photo: PHAsset,
                         storedCropPosition: LibraryItemCropPosition?,
                         completion: @escaping (Result<Bool, Error>) -> Void,
                         updateCropInfo: @escaping () -> Void) {
        guard currentAsset != photo else {
            DispatchQueue.main.async {
                completion(.success(false))
            }
            return
        }
        currentAsset = photo
        
        imageManager.fetch(photo: photo) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                if strongSelf.photoImageView.isDescendant(of: strongSelf) == false {
                    strongSelf.isVideoMode = false
                    strongSelf.videoView.removeFromSuperview()
                    strongSelf.videoView.showPlayImage(show: false)
                    strongSelf.videoView.deallocate()
                    strongSelf.addSubview(strongSelf.photoImageView)
                    
                    strongSelf.photoImageView.contentMode = .scaleAspectFill
                    strongSelf.photoImageView.clipsToBounds = true
                }
                
                switch result {
                case .success((let image, let isLowResIntermediaryImage)):
                    strongSelf.photoImageView.image = image
                    
                    strongSelf.setAssetFrame(for: strongSelf.photoImageView, with: image)
                    
                    // Stored crop position in multiple selection
                    if let scp173 = storedCropPosition {
                        strongSelf.applyStoredCropPosition(scp173)
                        // add update CropInfo after multiple
                        updateCropInfo()
                    }
                    
                    completion(.success(isLowResIntermediaryImage))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    fileprivate func setAssetFrame(`for` view: UIView, with image: UIImage) {
        // Reseting the previous scale
        self.minimumZoomScale = 1
        self.zoomScale = 1
        
        // Calculating and setting the image view frame depending on screenWidth
        let screenWidth = UIScreen.main.bounds.width
        
        let w = image.size.width
        let h = image.size.height

        var aspectRatio: CGFloat = 1
        var zoomScale: CGFloat = 1

        if w > h { // Landscape
            aspectRatio = h / w
            view.frame.size.width = screenWidth
            view.frame.size.height = screenWidth * aspectRatio
        } else if h > w { // Portrait
            aspectRatio = w / h
            view.frame.size.width = screenWidth * aspectRatio
            view.frame.size.height = screenWidth
            
            if let minWidth = minWidth {
                let k = minWidth / screenWidth
                zoomScale = (h / w) * k
            }
        } else { // Square
            view.frame.size.width = screenWidth
            view.frame.size.height = screenWidth
        }
        
        // Centering image view
        view.center = center
        centerAssetView()
        
        // Setting new scale
        minimumZoomScale = zoomScale
        self.zoomScale = zoomScale
    }
    
    /// Calculate zoom scale which will fit the image to square
    fileprivate func calculateSquaredZoomScale() throws -> CGFloat {
        guard let image = assetImageView.image else {
            throw ImagePickerBaseError(message: "YPAssetZoomableView >>> No image")
        }
        
        var squareZoomScale: CGFloat = 1.0
        let w = image.size.width
        let h = image.size.height
        
        if w > h { // Landscape
            squareZoomScale = (w / h)
        } else if h > w { // Portrait
            squareZoomScale = (h / w)
        }
        
        return squareZoomScale
    }
    
    // Centring the image frame
    fileprivate func centerAssetView() {
        let assetView = isVideoMode ? videoView : photoImageView
        let scrollViewBoundsSize = self.bounds.size
        var assetFrame = assetView.frame
        let assetSize = assetView.frame.size
        
        assetFrame.origin.x = (assetSize.width < scrollViewBoundsSize.width) ?
            (scrollViewBoundsSize.width - assetSize.width) / 2.0 : 0
        assetFrame.origin.y = (assetSize.height < scrollViewBoundsSize.height) ?
            (scrollViewBoundsSize.height - assetSize.height) / 2.0 : 0.0
        
        assetView.frame = assetFrame
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = assetViewBackgroundColor
        self.frame.size = CGSize.zero
        clipsToBounds = true
        photoImageView.frame = CGRect(origin: CGPoint.zero, size: CGSize.zero)
        videoView.frame = CGRect(origin: CGPoint.zero, size: CGSize.zero)
        maximumZoomScale = 6.0
        minimumZoomScale = 1
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        delegate = self
        alwaysBounceHorizontal = true
        alwaysBounceVertical = true
        isScrollEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        backgroundColor = assetViewBackgroundColor
        frame.size = CGSize.zero
        clipsToBounds = true
        photoImageView.frame = CGRect(origin: CGPoint.zero, size: CGSize.zero)
        videoView.frame = CGRect(origin: CGPoint.zero, size: CGSize.zero)
        maximumZoomScale = 6.0
        minimumZoomScale = 1
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        delegate = self
        alwaysBounceHorizontal = true
        alwaysBounceVertical = true
        isScrollEnabled = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        myDelegate?.assetZoomableViewDidLayoutSubviews(self)
    }
    
    public func currentCropRect() -> CGRect {
        let normalizedX = min(1, contentOffset.x &/ contentSize.width)
        let normalizedY = min(1, contentOffset.y &/ contentSize.height)
        let normalizedWidth = min(1, frame.width / contentSize.width)
        let normalizedHeight = min(1, frame.height / contentSize.height)
        return CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
    }
}

// MARK: UIScrollViewDelegate Protocol
extension AssetZoomableView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return isVideoMode ? videoView : photoImageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        myDelegate?.assetZoomableViewScrollViewDidZoom()
        
        centerAssetView()
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        guard let view = view, view == photoImageView || view == videoView else { return }
        
        // prevent to zoom out
        if onlySquare && scale < squaredZoomScale {
            self.fitImage(true, animated: true)
        }
        
        myDelegate?.assetZoomableViewScrollViewDidEndZooming()
        cropAreaDidChange()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        cropAreaDidChange()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        cropAreaDidChange()
    }
}

infix operator &/

// With that you can devide to zero
fileprivate extension CGFloat {
    static func &/ (lhs: CGFloat, rhs: CGFloat) -> CGFloat {
        if rhs == 0 {
            return 0
        }
        return lhs/rhs
    }
}
