import UIKit

class ImagePickerToolsView: UIView {
    
    public weak var delegate: ImagePickerToolsViewDelegate?
    
    @IBOutlet weak var albumContainerView: UIView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    
    @IBOutlet weak var albumSelectImage: UIImageView!
    
    private var isMultipleSelectEnable = false
    
    private func configureUI() {
        albumContainerView.target(forAction: #selector(didTapSelectAlbum), withSender: self)
    }
    
    public func bind(_ item: ImagePickerToolsViewItem) {
        
    }
    
    public func multipleSelectEnable() -> Bool {
        return isMultipleSelectEnable
    }
    
    @objc func didTapSelectAlbum() {
        delegate?.didTapSelectAlbum()
    }
    
    @IBAction func didTapMultipleMode(_ sender: Any) {
        isMultipleSelectEnable = !isMultipleSelectEnable
        delegate?.didTapMultipleMode(isMultipleSelectEnable)
    }
}
