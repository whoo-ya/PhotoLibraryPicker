import UIKit

public class PhotoLibraryCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var items: [AlbumItem] = []
    
    private weak var photoLibraryDelegate: PhotoLibraryCollectionViewDelegate?
    
    private let cart = AlbumItemCart()
    
    private var isMultipleSelecteEnable = false
    
    public init(photoLibraryDelegate: PhotoLibraryCollectionViewDelegate) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        self.photoLibraryDelegate = photoLibraryDelegate
                
        super.init(frame: .zero, collectionViewLayout: layout)
        
        self.delegate = self
        self.dataSource = self
        
        register(AlbumItemCell.self, forCellWithReuseIdentifier: String(describing: AlbumItemCell.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func bind(_ album: Album) {
        self.items = album.items
        reloadData()
        setContentOffset(CGPoint.zero, animated: false)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AlbumItemCell.self),
                                                      for: indexPath) as! AlbumItemCell
        let albumItem = items[(indexPath as NSIndexPath).item]
        
        cell.bind(AlbumItemCellItem(albumItem: albumItem, isSelected: cart.isAdded(albumItem)))
        
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
        
        if isMultipleSelecteEnable {
            var selectedItem: AlbumItem
            
            if cart.isAdded(item) {
                cart.removeItem(item)
                
                if let lastAdded = cart.getLastAdded() {
                    selectedItem = lastAdded
                }
                else {
                    selectedItem = item
                }
            }
            else {
                selectedItem = item
            }
            
            cart.addItem(selectedItem)
            photoLibraryDelegate?.selectItem(selectedItem)
            
            if let selectedIndex = items.firstIndex(of: selectedItem) {
                let newIndexPath = IndexPath(row: selectedIndex, section: indexPath.section)
                
                let cell = (collectionView.cellForItem(at: indexPath) as? AlbumItemCell)
                cell?.setSelected(indexPath == newIndexPath)
            }
        }
        else {
            if let lastAddedItem = cart.getLastAdded(), let lastAddedIndex = items.firstIndex(of: lastAddedItem) {
                let newIndexPath = IndexPath(row: lastAddedIndex, section: indexPath.section)
                
                let cell = (collectionView.cellForItem(at: newIndexPath) as? AlbumItemCell)
                cell?.setSelected(false)
            }
            
            cart.removeItem(item)
            cart.addItem(item)
            photoLibraryDelegate?.selectItem(item)
            
            let cell = (collectionView.cellForItem(at: indexPath) as? AlbumItemCell)
            cell?.setSelected(true)
        }
    }
}
