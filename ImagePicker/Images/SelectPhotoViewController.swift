import UIKit
import Photos
import SnapKit

class SelectPhotoViewController: UIViewController, PhotoLibraryCollectionViewDelegate {
    
    private let scrollView = UIScrollView()
    
    private lazy var previewView: AlbumItemPreviewView = AlbumItemPreviewView.viewFromNib()
    
    private lazy var toolsView: SelectPhotoToolsView = SelectPhotoToolsView.viewFromNib()
    
    private lazy var collectionView: PhotoLibraryCollectionView = {
        return PhotoLibraryCollectionView(photoLibraryDelegate: self)
    }()
    
    let library = PhotoLibrary()
    var selectedAlbum: Album?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        library.reload {
            if let album = self.library.albums.first {
                self.show(album: album)
            }
        }
        
        configureUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: - Setup
    
    func configureUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { snp in
            snp.edges.equalToSuperview()
        }
        
        let containerView = UIView()
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { snp in
            snp.edges.equalToSuperview()
        }
        
        containerView.addSubview(previewView)
        previewView.snp.makeConstraints { snp in
            snp.top.equalToSuperview()
            snp.left.equalToSuperview()
            snp.right.equalToSuperview()
            snp.width.equalTo(scrollView.snp.width)
            snp.height.equalTo(scrollView.snp.width)
        }
        
        containerView.addSubview(toolsView)
        toolsView.snp.makeConstraints { snp in
            snp.top.equalTo(previewView.snp.bottom)
            snp.left.equalToSuperview()
            snp.right.equalToSuperview()
            snp.width.equalTo(scrollView.snp.width)
        }
        
        containerView.addSubview(collectionView)
        collectionView.snp.makeConstraints { snp in
            snp.top.equalTo(toolsView.snp.bottom)
            snp.bottom.equalToSuperview()
            snp.left.equalToSuperview()
            snp.right.equalToSuperview()
            snp.height.equalTo(300)
        }        
    }
    
    func show(album: Album) {
        self.selectedAlbum = album
        collectionView.bind(album)
    }
    
    func refreshSelectedAlbum() {
        if let selectedAlbum = selectedAlbum {
            selectedAlbum.reload()
            show(album: selectedAlbum)
        }
    }
    
    func selectItem(_ albumItem: AlbumItem) {
        previewView.bind(albumItem)
    }
}
