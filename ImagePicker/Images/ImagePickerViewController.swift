import UIKit
import Photos
import SnapKit

class ImagePickerViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    
//    private lazy var previewView: AlbumItemPreviewView = AlbumItemPreviewView.viewFromNib()
    
    private lazy var previewView = YPAssetZoomableView(frame: CGRect(origin: .zero,
                                                                     size: CGSize(width: 200, height: 200)))
    
    
    private lazy var toolsView: ImagePickerToolsView = ImagePickerToolsView.viewFromNib()
    
    private lazy var collectionView: PhotoLibraryCollectionView = {
        return PhotoLibraryCollectionView(photoLibraryDelegate: self)
    }()
    
    private let library = PhotoLibrary()
    
    private var selectedAlbum: Album?
    
    private let cart = AlbumItemCart()
    
    private var previewViewTopConstraint: NSLayoutConstraint!
    
    private var headerMinimizeTool: HeaderMinimizeTool?
        
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
    
    func configureUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { snp in
            snp.edges.equalToSuperview()
        }
        scrollView.alwaysBounceVertical = true
        
        toolsView.delegate = self
        
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
        
    @objc
    private func saveSelectedPhoto() {
        print("cart.count = '\(cart.getItems().count)'")
    }
}

extension ImagePickerViewController: PhotoLibraryCollectionViewDelegate {

    func selectItem(_ albumItem: AlbumItem) {
        switch albumItem {
        case .photo(let photo):
            previewView.setImage(photo.asset, storedCropPosition: nil) { result in
                print("test set image result: '\(result)'")
            } updateCropInfo: {
                print("test set image updateCropInfo")
            }

        case .video(let video):
            previewView.setVideo(video.asset, storedCropPosition: nil) {
                print("test set video result")
            } updateCropInfo: {
                print("test set video updateCropInfo")
            }
        }
//        previewView.bind(albumItem)
    }
    
    func getCart() -> AlbumItemCart {
        return cart
    }
}

extension ImagePickerViewController: ImagePickerToolsViewDelegate {
    
    func didTapSelectAlbum() {
        
    }
    
    func didTapMultipleMode(_ enable: Bool) {
        collectionView.enableMultipleMode(enable)
    }
}
