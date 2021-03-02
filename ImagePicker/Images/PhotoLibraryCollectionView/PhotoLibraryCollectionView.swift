import UIKit

public class PhotoLibraryCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var items: [AlbumItem] = []
    
    private weak var photoLibraryDelegate: PhotoLibraryCollectionViewDelegate?
    
    private var currentSelectItem: AlbumItem? = nil
    
    private let cart = AlbumItemCart()
    
    public var isMultipleSelectEnable = false
    
    public init(photoLibraryDelegate: PhotoLibraryCollectionViewDelegate) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        self.photoLibraryDelegate = photoLibraryDelegate
                
        super.init(frame: .zero, collectionViewLayout: layout)
        
        self.delegate = self
        self.dataSource = self
        
        register(UINib(nibName: AlbumItemCell.nibName, bundle: .main),
                 forCellWithReuseIdentifier: AlbumItemCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func bind(_ album: Album) {
        self.items = album.items
        reloadData()
        setContentOffset(CGPoint.zero, animated: false)
    }
    
    public func enableMultipleMode(_ enable: Bool) {
        if !enable {
            let lastAddedItem = cart.getLastAdded()
            cart.removeAll()
            if let lastAddedItem = lastAddedItem {
                cart.addItem(lastAddedItem)
            }
        }
        isMultipleSelectEnable = enable
        reloadData()
    }
    
    private func showEmptyView() {
        print("showEmptyView")
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AlbumItemCell.self),
                                                      for: indexPath) as! AlbumItemCell
        let albumItem = items[(indexPath as NSIndexPath).item]
        
        cell.bind(AlbumItemCellItem(albumItem: albumItem,
                                    isSelected: currentSelectItem == albumItem,
                                    selectedIndex: getSelectedItemNumber(albumItem)))
        
        return cell
    }
        
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columnCount: CGFloat = 4
        let cellSpacing: CGFloat = 2
        
        let size = (collectionView.bounds.size.width - (columnCount - 1) * cellSpacing) / columnCount
        return CGSize(width: size, height: size)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < items.count else {
            return
        }
        
        let item = items[indexPath.item]
        
        if isMultipleSelectEnable {
            selectItemForMultipleMode(item)
        }
        else {
            selectItemForOneItemMode(item)
        }
    }
    
    private func selectItemForOneItemMode(_ item: AlbumItem) {
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
        
        self.currentSelectItem = item
        photoLibraryDelegate?.selectItem(item)
        
        reloadItems(at: indexPaths.compactMap { $0 })
    }
    
    private func selectItemForMultipleMode(_ item: AlbumItem) {
        var indexPaths: [IndexPath?] = cart.getItems().map { cartItem in
            if let index = items.firstIndex(of: cartItem) {
                return IndexPath(row: index, section: 0)
            }
            else {
                return nil
            }
        }
        
        let selectedItem: AlbumItem?
        if cart.isAdded(item) {
            if item == currentSelectItem {
                // Если нажали второй раз на выбранное фото, то удаляем его
                cart.removeItem(item)
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
        }
        
        if selectedItem == nil {
            if let lastAddedItem = cart.getLastAdded() {
                photoLibraryDelegate?.selectItem(lastAddedItem)
            }
            else if let firstItem = items.first {
                photoLibraryDelegate?.selectItem(firstItem)
            }
        }
        
        if let selectedItem = selectedItem {
            self.currentSelectItem = selectedItem
            photoLibraryDelegate?.selectItem(selectedItem)
        }
        else {
            ErrorHandler.handleError("Нет элемента для выбора")
            showEmptyView()
        }
                
        reloadItems(at: indexPaths.compactMap { $0 })
    }
    
    private func getSelectedItemNumber(_ item: AlbumItem) -> Int {
        guard isMultipleSelectEnable else {
            return 0
        }
        
        if let index = cart.getIndex(item) {
            return index + 1
        }
        else {
            return 0
        }
    }
}
