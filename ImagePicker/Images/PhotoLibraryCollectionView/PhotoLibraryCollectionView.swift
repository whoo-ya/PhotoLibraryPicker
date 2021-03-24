import UIKit

/**
 Коллекция для выбора фото/видео из переданного ей списка элементов [AlbumItem].
 Реализует логику мультивыбора с сохранением результата в переданную AlbumItemsCart
 */
public class PhotoLibraryCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let errorHandler = ErrorHandler()

    private weak var photoLibraryDelegate: PhotoLibraryCollectionViewDelegate?
    
    private let cart: AlbumItemsCart
    
    private let albumItemCartService: AlbumItemCartService
    
    private var items: [AlbumItem] = []
    
    private var currentSelectItem: AlbumItem? = nil
    
    public var isMultipleSelectEnable = false
    
    private let columnCount: CGFloat = 4
    private let cellSpacing: CGFloat = 2
    
    public init(photoLibraryDelegate: PhotoLibraryCollectionViewDelegate) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        self.photoLibraryDelegate = photoLibraryDelegate
        self.cart = photoLibraryDelegate.getCart()
        self.albumItemCartService = AlbumItemCartService(cart: cart)
                
        super.init(frame: .zero, collectionViewLayout: layout)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        isScrollEnabled = true
        alwaysBounceVertical = true
        
        delegate = self
        dataSource = self
        
        register(UINib(nibName: AlbumItemCell.nibName, bundle: .main),
                 forCellWithReuseIdentifier: AlbumItemCell.reuseIdentifier)
    }
    
    public func bind(_ album: Album) {
        self.items = album.items
        if let selectedItem = items.first {
            cart.addItem(selectedItem)
            selectItem(selectedItem)
        }
        else {
            showEmptyView()
        }
        
        reloadData()
        setContentOffset(CGPoint.zero, animated: false)
    }
    
    public func enableMultipleMode(_ enable: Bool) {
        if !enable {
            let lastAddedItem = cart.getLastAdded()
            cart.removeAll()
            
            if let lastAddedItem = lastAddedItem {
                cart.addItem(lastAddedItem)
                selectItem(lastAddedItem)
            }
            else if let selectedItem = items.first {
                cart.addItem(selectedItem)
                selectItem(selectedItem)
            }
            else {
                errorHandler.handleError(ImagePickerBaseError(message: "Нет элемента для выбора"))
            }
        }
        
        isMultipleSelectEnable = enable
        reloadData()
    }
    
    public func getCurrentSelectedItem() -> AlbumItem? {
        return currentSelectItem
    }
    
    private func selectItem(_ item: AlbumItem) {
        self.currentSelectItem = item
        photoLibraryDelegate?.selectItemForPreview(item)
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
        let size = (collectionView.bounds.size.width - (columnCount - 1) * cellSpacing) / columnCount
        return CGSize(width: size, height: size)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < items.count else {
            return
        }
        
        let item = items[indexPath.item]
        
        do {
            let result = try albumItemCartService.selectItem(item: item,
                                                             items: items,
                                                             currentSelectItem: currentSelectItem,
                                                             isMultiple: isMultipleSelectEnable)
            self.currentSelectItem = result.1
            photoLibraryDelegate?.selectItemForPreview(result.1)
            reloadItems(at: result.0)
        }
        catch {
            errorHandler.handleError(error)
        }
    }
    
    private func getSelectedItemNumber(_ item: AlbumItem) -> Int? {
        guard isMultipleSelectEnable else {
            return nil
        }
        
        if let index = cart.getIndex(item) {
            return index + 1
        }
        else {
            return nil
        }
    }
}
