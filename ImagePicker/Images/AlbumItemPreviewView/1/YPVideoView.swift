import UIKit
import AVFoundation
import Photos

/// A video view that contains video layer, supports play, pause and other actions.
/// Supports xib initialization.
public class YPVideoView: UIView {
    public let playImageView = UIImageView(image: nil)
    
    internal let playerView = UIView()
    internal let playerLayer = AVPlayerLayer()
    internal var previewImageView = UIImageView()
    
    public var player: AVPlayer {
        guard playerLayer.player != nil else {
            return AVPlayer()
        }
        playImageView.image = UIImage(named: "video_play")
        return playerLayer.player!
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    internal func setup() {
        let singleTapGR = UITapGestureRecognizer(target: self,
                                                 action: #selector(singleTap))
        singleTapGR.numberOfTapsRequired = 1
        addGestureRecognizer(singleTapGR)
        
        // Loop playback
        addReachEndObserver()
    
        playerView.alpha = 0
        playImageView.alpha = 0.8
        playerLayer.videoGravity = .resizeAspect
        previewImageView.contentMode = .scaleAspectFit
        
        addSubview(previewImageView)
        previewImageView.snp.makeConstraints { snp in
            snp.edges.equalToSuperview()
        }
        addSubview(playerView)
        playerView.snp.makeConstraints { snp in
            snp.edges.equalToSuperview()
        }
        
        addSubview(playImageView)
        playImageView.snp.makeConstraints { snp in
            snp.edges.equalToSuperview()
        }
        
        playerView.layer.addSublayer(playerLayer)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = playerView.bounds
    }
    
    @objc internal func singleTap() {
        pauseUnpause()
    }
    
    @objc public func playerItemDidReachEnd(_ note: Notification) {
        player.actionAtItemEnd = .none
        player.seek(to: CMTime.zero)
        player.play()
    }
}

// MARK: - Video handling
extension YPVideoView {

    public func loadVideo<T>(_ item: T) {        
        switch item.self {
        case let asset as PHAsset:
            PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil) { [weak self] (assets, audioMix, info) in
                let asset = assets as! AVURLAsset
                DispatchQueue.main.async {
                    self?.playerLayer.player = AVPlayer(url: asset.url)
                    self?.playerView.alpha = 1
                    self?.setNeedsLayout()
                }
            }
        case let url as URL:
            playerLayer.player = AVPlayer(url: url)
            playerView.alpha = 1
            setNeedsLayout()
        case let playerItem as AVPlayerItem:
            playerLayer.player = AVPlayer(playerItem: playerItem)
            playerView.alpha = 1
            setNeedsLayout()
        default:
            return
        }
    }
    
    /// Convenience func to pause or unpause video dependely of state
    public func pauseUnpause() {
        (player.rate == 0.0) ? play() : pause()
    }

    /// Mute or unmute the video
    public func muteUnmute() {
        player.isMuted = !player.isMuted
    }
    
    public func play() {
        player.play()
        showPlayImage(show: false)
        addReachEndObserver()
    }
    
    public func pause() {
        player.pause()
        showPlayImage(show: true)
    }
    
    public func stop() {
        player.pause()
        player.seek(to: CMTime.zero)
        showPlayImage(show: true)
        removeReachEndObserver()
    }
    
    public func deallocate() {
        playerLayer.player = nil
        playImageView.image = nil
    }
}

// MARK: - Other API
extension YPVideoView {
    public func setPreviewImage(_ image: UIImage) {
        previewImageView.image = image
    }
    
    /// Shows or hide the play image over the view.
    public func showPlayImage(show: Bool) {
        UIView.animate(withDuration: 0.1) {
            self.playImageView.alpha = show ? 0.8 : 0
        }
    }
    
    public func addReachEndObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }
    
    /// Removes the observer for AVPlayerItemDidPlayToEndTime. Could be needed to implement own observer
    public func removeReachEndObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: .AVPlayerItemDidPlayToEndTime,
                                                  object: nil)
    }
}
