import Foundation

public protocol PhotoLibraryCollectionViewDelegate: class {
    
    func selectItem(_ albumItem: AlbumItem)
    
    func getCart() -> AlbumItemCart
}
