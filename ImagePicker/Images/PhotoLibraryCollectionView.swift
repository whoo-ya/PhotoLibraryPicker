import UIKit

public class PhotoLibraryCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var items: [AlbumItem] = []
    
    private weak var photoLibraryDelegate: PhotoLibraryCollectionViewDelegate?
    
    public init(photoLibraryDelegate: PhotoLibraryCollectionViewDelegate) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        self.photoLibraryDelegate = photoLibraryDelegate
                
        super.init(frame: .zero, collectionViewLayout: layout)
        
        self.delegate = self
        self.dataSource = self
        
        register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCell.self),
                                                      for: indexPath) as! ImageCell
        let item = items[(indexPath as NSIndexPath).item]
        
        cell.configure(item)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
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
        photoLibraryDelegate?.selectItem(item)
    }
}
