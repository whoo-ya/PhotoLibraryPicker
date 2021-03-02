import Foundation

public class AlbumItemCellItem {
    
    public let albumItem: AlbumItem
    
    public let isSelected: Bool
    
    public let selectedIndex: Int
    
    public init(albumItem: AlbumItem,
                isSelected: Bool,
                selectedIndex: Int) {
        self.albumItem = albumItem
        self.isSelected = isSelected
        self.selectedIndex = selectedIndex
    }
}
