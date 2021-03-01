import UIKit
import Photos
import SnapKit

public class AlbumItemCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = self.makeImageView()
    private lazy var highlightOverlay: UIView = self.makeHighlightOverlay()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override var isHighlighted: Bool {
        didSet {
            highlightOverlay.isHidden = !isHighlighted
        }
    }
    
    public func bind(_ item: AlbumItemCellItem) {
        imageView.layoutIfNeeded()
        
        let asset: PHAsset
        
        switch item.albumItem {
        case .photo(let photo):
            asset = photo.asset
        case .video(let video):
            asset = video.asset
        }
        
        AssetImageLoader.loadImage(asset, for: imageView) { [weak self] in
            self?.setSelected(item.isSelected)
        }
    }
    
    public func setSelected(_ isSelected: Bool) {
        imageView.alpha = isSelected ? 0.5 : 1.0
    }
        
    private func setup() {
        [imageView, highlightOverlay].forEach {
            self.contentView.addSubview($0)
        }
        
        imageView.snp.makeConstraints { snp in
            snp.edges.equalToSuperview()
        }
        
        highlightOverlay.snp.makeConstraints { snp in
            snp.edges.equalToSuperview()
        }
        
        imageView.isUserInteractionEnabled = true
        imageView.isMultipleTouchEnabled = true
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureActivated))
        imageView.addGestureRecognizer(pinchGesture)
    }
    
    @objc
    private func pinchGestureActivated(_ sender: UIPinchGestureRecognizer) {
        imageView.transform = imageView.transform.scaledBy(x: sender.scale, y: sender.scale)
    }
    
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
