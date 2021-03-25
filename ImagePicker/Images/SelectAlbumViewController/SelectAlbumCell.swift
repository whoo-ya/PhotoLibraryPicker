import UIKit

class SelectAlbumCell: UITableViewCell {
    
    public static let nibName = "\(SelectAlbumCell.self)"
    
    public static let reuseIdentifier = "\(SelectAlbumCell.self)"
    
    @IBOutlet private weak var albumPreviewImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var numberOfItemsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureUI()
    }
    
    private func configureUI() {
        albumPreviewImageView.contentMode = .scaleAspectFill
        albumPreviewImageView.clipsToBounds = true
    }
    
    func bind(_ item: SelectAlbumCellItem) {
        albumPreviewImageView.image = item.album.thumbnail
        titleLabel.text = item.album.title
        numberOfItemsLabel.text = "\(item.album.items.count)"
    }
}
