import UIKit
import Photos
import SnapKit

class ImageCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = self.makeImageView()
    lazy var highlightOverlay: UIView = self.makeHighlightOverlay()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override var isHighlighted: Bool {
        didSet {
            highlightOverlay.isHidden = !isHighlighted
        }
    }
    
    func configure(_ item: AlbumItem) {
        imageView.layoutIfNeeded()
        switch item {
        case .photo(let photo):
            AssetImageLoader.loadImage(photo.asset, for: imageView)
        case .video(let video):
            AssetImageLoader.loadImage(video.asset, for: imageView)
        }
    }
    
    // MARK: - Setup
    
    func setup() {
        [imageView, highlightOverlay].forEach {
            self.contentView.addSubview($0)
        }
        
        imageView.snp.makeConstraints { snp in
            snp.edges.equalToSuperview()
        }
        
        highlightOverlay.snp.makeConstraints { snp in
            snp.edges.equalToSuperview()
        }
    }
    
    // MARK: - Controls
    
    private func makeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }
    
    private func makeHighlightOverlay() -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = UIColor.red
        view.isHidden = true
        
        return view
    }
}
