import Foundation

public class AlbumItemCellItem {
    
    public let albumItem: AlbumItem
    
    public let isSelected: Bool
    
    public init(albumItem: AlbumItem, isSelected: Bool) {
        self.albumItem = albumItem
        self.isSelected = isSelected
    }
}
