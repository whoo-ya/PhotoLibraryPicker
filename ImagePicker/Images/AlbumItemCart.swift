import Foundation

class AlbumItemCart {
    
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
        if !isAdded(item) {
            selectedItems.append(item)
        }
        else {
            print("test Dont add item")
        }
    }
    
    public func removeItem(_ item: AlbumItem) {
        if let removeIndex = selectedItems.firstIndex(where: { $0 == item}) {
            selectedItems.remove(at: removeIndex)
        }
        else {
            print("test Dont remove item")
        }
    }
    
    public func removeAll() {
        selectedItems.removeAll()
    }
    
}
