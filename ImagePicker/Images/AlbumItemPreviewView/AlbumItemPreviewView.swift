import UIKit
import Photos
import AVKit

class AlbumItemPreviewView: UIView {
    
    @IBOutlet private weak var previewView: UIView!
    
    private var currentItem: AlbumItem? = nil
    
    private let photoView = UIImageView()
    
    private let videoView = UIView()
    
    private let playerViewController = AVPlayerViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureUI()
    }
    
    private func configureUI() {
        previewView.contentMode = .scaleAspectFit
        previewView.addSubview(photoView)
        photoView.snp.makeConstraints {snp in
            snp.edges.equalToSuperview()
        }
        photoView.isHidden = true
        
        previewView.addSubview(videoView)
        videoView.snp.makeConstraints {snp in
            snp.edges.equalToSuperview()
        }
        videoView.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapItem))
        addGestureRecognizer(tapGesture)
    }
    
    func bind(_ item: AlbumItem) {
        clear()
        
        self.currentItem = item
        switch item {
        case .photo(let photo):
            showPhoto(asset: photo.asset)
        case .video(let video):
            showVideo(asset: video.asset)
        }
    }
    
    private func clear() {
        photoView.image = nil
        photoView.isHidden = true
        
        videoView.subviews.forEach {
            $0.removeFromSuperview()
        }
        videoView.isHidden = true
        
        playerViewController.player?.pause()
        playerViewController.player = nil
    }
    
    private func showPhoto(asset:PHAsset) {
        photoView.isHidden = false
        AssetImageLoader.loadImage(asset, for: photoView)
    }
    
    private func showVideo(asset:PHAsset) {
        videoView.isHidden = false
        
        PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil) { (assets, audioMix, info) in
            let asset = assets as! AVURLAsset
            DispatchQueue.main.async {
                let player = AVPlayer(url: asset.url)
                self.playerViewController.player = player
                self.playerViewController.showsPlaybackControls = false
                self.videoView.addSubview(self.playerViewController.view)
                self.playerViewController.view.snp.makeConstraints { snp in
                    snp.edges.equalToSuperview()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.playerViewController.player!.play()
                }
            }
        }
    }
    
    @objc
    private func didTapItem() {
        
    }
}
