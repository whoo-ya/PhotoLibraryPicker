import Foundation

public protocol PhotoLibraryCollectionViewDelegate: class {
    
    /**
     Был выбран элемент новый элемент для предпросмотра.
     */
    func selectItemForPreview(_ albumItem: AlbumItem)
    
    /**
     Получить экземпляр корзины для работы выбора фото
     */
    func getCart() -> AlbumItemsCart
}
