import UIKit

/**
 Панель инструментов для работы с пикером выбора фото. Включает:
 - Инициализацию действия выбора альбома
 - Переключения режима мультивыбора
 */
class ImagePickerToolsView: UIView {
    
    public weak var delegate: ImagePickerToolsViewDelegate?
    
    @IBOutlet weak var albumContainerView: UIView!
    
    @IBOutlet weak var albumTitleLabel: UILabel!
    
    @IBOutlet weak var albumSelectImage: UIImageView!
    
    private var isMultipleSelectEnable = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureUI()
    }
    
    private func configureUI() {
        
    }
    
    public func bind(_ item: ImagePickerToolsViewItem) {
        albumTitleLabel.text = item.album.title
    }
    
    public func multipleSelectEnable() -> Bool {
        return isMultipleSelectEnable
    }
    
    @IBAction func didTapSelectAlbum() {
        delegate?.didTapSelectAlbum()
    }
    
    @IBAction func didTapMultipleMode(_ sender: Any) {
        isMultipleSelectEnable = !isMultipleSelectEnable
        delegate?.didTapMultipleMode(isMultipleSelectEnable)
    }
}
