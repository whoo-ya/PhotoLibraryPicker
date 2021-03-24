import Foundation

/**
 Корзина элементов выбранных из альбома.
 Реализует логику хранения, получения, удаления и добавления новых элементов при выборе пользователем.
 */
public class AlbumItemsCart {
    
    private var selectedItems: [AlbumItem] = []
    
    public func getItems() -> [AlbumItem] {
        return selectedItems
    }
    
    public func isAdded(_ item: AlbumItem) -> Bool {
        return selectedItems.contains(item)
    }
    
    public func getIndex(_ item: AlbumItem) -> Int? {
        return getItems().firstIndex(of: item)
    }
    
    public func getLastAdded() -> AlbumItem? {
        return selectedItems.last
    }
    
    public func addItem(_ item: AlbumItem) {
        if let index = selectedItems.firstIndex(of: item) {
            selectedItems.remove(at: index)
            selectedItems.insert(item, at: index)
        }
        else {
            selectedItems.append(item)
        }
    }
    
    public func removeItem(_ item: AlbumItem) throws {
        if let removeIndex = selectedItems.firstIndex(where: { $0 == item}) {
            item.clearCropInfo()
            selectedItems.remove(at: removeIndex)
        }
        else {
            throw ImagePickerBaseError(message: "Не удалось удалить элемент из корзины item: '\(item)' т.к. он не был найден в списке выбранных элементов")
        }
    }
    
    public func removeAll() {
        selectedItems.forEach({ $0.clearCropInfo() })
        selectedItems.removeAll()
    }
    
}
