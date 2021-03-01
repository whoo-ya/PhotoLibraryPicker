import UIKit
import Photos
import SnapKit

class ImagePickerViewController: UIViewController, PhotoLibraryCollectionViewDelegate {
    
    private let scrollView = UIScrollView()
    
    private lazy var previewView: AlbumItemPreviewView = AlbumItemPreviewView.viewFromNib()
    
    private lazy var toolsView: ImagePickerToolsView = ImagePickerToolsView.viewFromNib()
    
    private lazy var collectionView: PhotoLibraryCollectionView = {
        return PhotoLibraryCollectionView(photoLibraryDelegate: self)
    }()
    
    let library = PhotoLibrary()
    var selectedAlbum: Album?
    
    private var previewViewTopConstraint: NSLayoutConstraint!
    
    private var headerMinimizeTool: HeaderMinimizeTool?
    
    private let cart = AlbumItemCart()
    
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
        scrollView.alwaysBounceVertical = true
        
        let containerView = UIView()
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { snp in
            snp.edges.equalToSuperview()
        }
        
        containerView.addSubview(previewView)
        previewView.snp.makeConstraints { snp in
            snp.left.equalToSuperview()
            snp.right.equalToSuperview()
            snp.width.equalTo(scrollView.snp.width)
            snp.height.equalTo(scrollView.snp.width)
        }
        
        previewViewTopConstraint = NSLayoutConstraint(item: previewView,
                                                      attribute: .top,
                                                      relatedBy: .equal,
                                                      toItem: containerView,
                                                      attribute: .top,
                                                      multiplier: 1,
                                                      constant: 0)
        previewViewTopConstraint.isActive = true
        
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
            
//            snp.bottom.equalTo(view.snp.bottom)
            snp.bottom.equalToSuperview()
            snp.height.equalTo(300)
            
            snp.left.equalToSuperview()
            snp.right.equalToSuperview()

        }
        
        headerMinimizeTool = HeaderMinimizeTool(parentView: view,
                                            headerView: previewView,
                                            collectionView: collectionView,
                                            headerViewTopConstraints: previewViewTopConstraint,
                                            headerViewMinimalHeight: 20)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(saveSelectedPhoto))
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
    
    @objc
    private func saveSelectedPhoto() {
        print("cart.count = '\(cart.getItems().count)'")
    }
}
