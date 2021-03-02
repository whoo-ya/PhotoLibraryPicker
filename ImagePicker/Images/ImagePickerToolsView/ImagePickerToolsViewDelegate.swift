import Foundation

public protocol ImagePickerToolsViewDelegate: class {
    
    func didTapSelectAlbum()
    
    func didTapMultipleMode(_ enable: Bool)
    
}
