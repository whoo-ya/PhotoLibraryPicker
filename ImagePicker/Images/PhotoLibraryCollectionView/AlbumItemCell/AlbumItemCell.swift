import UIKit
import Photos
import SnapKit

public class AlbumItemCell: UICollectionViewCell {
    
    public static let reuseIdentifier = String(describing: AlbumItemCell.self)
    public static let nibName = "AlbumItemCell"

    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var indexLabel: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        configureUI()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        indexLabel.text = ""
    }
    
    private func configureUI() {
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
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
            self?.setSelected(item.isSelected, item.selectedIndex)
        }
    }
    
    public func setSelected(_ isSelected: Bool, _ index: Int) {
        imageView.alpha = isSelected ? 0.5 : 1.0
        
        if index != 0 {
            indexLabel.text = "\(index)"
        }
    }
}
