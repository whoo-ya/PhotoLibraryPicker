import Foundation

/**
 Сервис реализует бизнес логику выбора элементов для корзины:
 - Для одиночного фото сохраняется индекс старого элемента и нового для обновления в списке
 - Для мультивыбора сохраняется индекс всех выбранных элементов для обновления списка + новый
   - Если выбрать ранее выбранное фото оно отобразится в preview, но выделение не снимется. Кроме выбора текущего выбранного, в этом случае снимается выделение элемента
 */
public class AlbumItemCartService {
    
    private let errorHandler = ErrorHandler()
    
    private let cart: AlbumItemsCart
    
    public init(cart: AlbumItemsCart) {
        self.cart = cart
    }
    
    /**
     Добавляет в корзину новый выбранный элемент если его там нет или удаляет если он уже есть там, при условии:
     - Одиночный выбор, удаляется старый элемент, добавляется новый
     - Мультивыбор:
        - Выбран новый элемент, добавляется в корзину
        - Выбран уже добавленный в корзину элемент, но не текущий - выбираем его (корзина не обновляется)
        - Выбран уже добавленный в корзину элемент, текущий в предпросмотре - удаляем его из корзины, последний добавленный в корзину становится в фокус предпросмотра
     - returns:
        - [IndexPath]: Индексы элементов в списке которые нужно обновить
        - AlbumItem: Текущий выбранный элемент, который будет установлен в качестве текущего для предпросмотра пользователю.
     */
    public func selectItem(item: AlbumItem,
                           items: [AlbumItem],
                           currentSelectItem: AlbumItem?,
                           isMultiple: Bool) throws -> ([IndexPath], AlbumItem) {
        if isMultiple {
            return try selectItemForMultipleMode(cart: cart,
                                                 item: item,
                                                 items: items,
                                                 currentSelectedItem: currentSelectItem)
        }
        else {
            return try selectItemForOneItemMode(cart: cart,
                                            item: item,
                                            items: items,
                                            currentSelectedItem: currentSelectItem)
        }
    }
    
    private func selectItemForOneItemMode(cart: AlbumItemsCart,
                                          item: AlbumItem,
                                          items: [AlbumItem],
                                          currentSelectedItem: AlbumItem?) throws -> ([IndexPath], AlbumItem) {
        guard currentSelectedItem != item else {
            return ([], item)
        }
        
        var indexPaths: [IndexPath?] = cart.getItems().map { cartItem in
            if let index = items.firstIndex(of: cartItem) {
                return IndexPath(row: index, section: 0)
            }
            else {
                return nil
            }
        }
        
        cart.removeAll()
        cart.addItem(item)
        if let index = items.firstIndex(of: item) {
            indexPaths.append(IndexPath(row: index, section: 0))
        }
        else {
            throw ImagePickerBaseError(message: "Переданный item: '\(item)' отсутсвует в переданном альбоме '\(items)'")
        }
        
        return (indexPaths.compactMap { $0 }, item)
    }
    
    private func selectItemForMultipleMode(cart: AlbumItemsCart,
                                           item: AlbumItem,
                                           items: [AlbumItem],
                                           currentSelectedItem: AlbumItem?) throws -> ([IndexPath], AlbumItem) {
        var indexPaths: [IndexPath?] = cart.getItems().map { cartItem in
            if let index = items.firstIndex(of: cartItem) {
                return IndexPath(row: index, section: 0)
            }
            else {
                return nil
            }
        }
        
        var selectedItem: AlbumItem?
        if cart.isAdded(item) {
            if item == currentSelectedItem, cart.getItems().count > 1 {
                // Если нажали второй раз на выбранное фото, то удаляем его
                // Если это не единственное выбранное фото 
                try cart.removeItem(item)
                selectedItem = cart.getLastAdded()
            }
            else {
                // Выбираем это фото как текущее просто, код дальше
                selectedItem = item
            }
        }
        else {
            // Добавляем новое фото в список
            cart.addItem(item)
            selectedItem = item
            if let index = items.firstIndex(of: item) {
                indexPaths.append(IndexPath(row: index, section: 0))
            }
            else {
                throw ImagePickerBaseError(message: "Переданный item: '\(item)' отсутсвует в переданном альбоме '\(items)'")
            }
        }
        
        if selectedItem == nil {
            if let lastAddedItem = cart.getLastAdded() {
                selectedItem = lastAddedItem
            }
            else if let firstItem = items.first {
                selectedItem = firstItem
            }
        }
        
        if let selectedItem = selectedItem {
            return (indexPaths.compactMap { $0 }, selectedItem)
        }
        else {
            throw ImagePickerBaseError(message: "Нет элемента для выбора")
        }
    }
}
