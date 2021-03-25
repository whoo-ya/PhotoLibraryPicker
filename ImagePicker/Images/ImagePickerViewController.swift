import UIKit
import Photos
import SnapKit

class ImagePickerViewController: UIViewController {
    
    private let errorHandler = ErrorHandler()
    
    private lazy var previewView = AssetZoomableView(frame: CGRect(origin: .zero, size: .zero))
    
    private lazy var toolsView: ImagePickerToolsView = ImagePickerToolsView.viewFromNib()
    
    private lazy var collectionView: PhotoLibraryCollectionView = {
        return PhotoLibraryCollectionView(photoLibraryDelegate: self)
    }()
    
    private let library = PhotoLibrary()
    
    private lazy var albumItemCropService = {
        return AlbumItemCropService(configuration: AlbumItemCropServiceConfiguration())
    }()
    
    private var selectedAlbum: Album?
    
    private let cart = AlbumItemsCart()
    
    private var previewViewTopConstraint: NSLayoutConstraint!
    
    private var headerMinimizeTool: HeaderMinimizeTool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        library.reload { [weak self] result in
            switch result {
            case .success(let albums):
                if let album = albums.first {
                    self?.show(album: album)
                }
                else {
                    // TODO: Empty View
                }
            case .failure(let error):
                self?.errorHandler.handleError(error)
                if error is PermissionImagePickerError {
                    // Запрос доступа к галерее
                }
                else {
                    // TODO: добавить тип ошибки и обработать как emptyView
                }
            }
        }
        
        previewView.cropAreaDidChange = { [weak self] in
            self?.updateCropInfo()
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
        toolsView.delegate = self
        
        let containerView = UIView()
        view.addSubview(containerView)
        containerView.snp.makeConstraints { snp in
            snp.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            snp.bottom.equalToSuperview()
            snp.left.equalToSuperview()
            snp.right.equalToSuperview()
        }
        
        containerView.addSubview(previewView)
        previewView.snp.makeConstraints { snp in
            snp.left.equalToSuperview()
            snp.right.equalToSuperview()
            snp.width.equalTo(view.snp.width)
            snp.height.equalTo(containerView.snp.width)
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
            snp.width.equalTo(view.snp.width)
        }
        
        containerView.addSubview(collectionView)
        collectionView.snp.makeConstraints { snp in
            snp.top.equalTo(toolsView.snp.bottom)
            snp.bottom.equalToSuperview()
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
        guard album != self.selectedAlbum else {
            return
        }
        
        self.selectedAlbum = album
        
        cart.removeAll()
        
        collectionView.bind(album)
        toolsView.bind(ImagePickerToolsViewItem(album: album))
    }
    
    func refreshSelectedAlbum() {
        if let selectedAlbum = selectedAlbum {
            selectedAlbum.reload()
            show(album: selectedAlbum)
        }
    }
    
    @objc
    private func saveSelectedPhoto() {
        albumItemCropService.getCropedMediaItems(items: cart.getItems(),
                                                 updateProgress: { progress in
                                                    print("progress: '\(progress)'")
                                                 },
                                                 completed: { [weak self] result in 
                                                    switch result {
                                                    case .success(let items):
                                                        DispatchQueue.main.async {
                                                            let vc = TestPreviewSelectedItemViewController.create(items)
                                                            self?.present(vc, animated: true, completion: nil)
                                                        }
                                                    case .failure(let error):
                                                        self?.errorHandler.handleError(error)
                                                    }
                                                 })
    }
    
    internal func updateCropInfo() {
        guard let selectedItem = collectionView.getCurrentSelectedItem() else {
            return
        }
        
        selectedItem.updateCropInfo(cropRect: previewView.currentCropRect(),
                                    scrollViewContentOffset: previewView.contentOffset,
                                    scrollViewZoomScale: previewView.zoomScale)
        cart.addItem(selectedItem)
    }
}

extension ImagePickerViewController: PhotoLibraryCollectionViewDelegate {
    
    func selectItemForPreview(_ albumItem: AlbumItem) {
        switch albumItem {
        case .photo(let photo):
            let storedCropPosition = LibraryItemCropPosition(cropRect: photo.cropRect,
                                                             scrollViewContentOffset: photo.scrollViewContentOffset,
                                                             scrollViewZoomScale: photo.scrollViewZoomScale)
            previewView.setImage(photo.asset, storedCropPosition: storedCropPosition) { [weak self] result in
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    self?.errorHandler.handleError(error)
                }
            } updateCropInfo: { [weak self] in
                self?.updateCropInfo()
            }
            
        case .video(let video):
            let storedCropPosition = LibraryItemCropPosition(cropRect: video.cropRect,
                                                             scrollViewContentOffset: video.scrollViewContentOffset,
                                                             scrollViewZoomScale: video.scrollViewZoomScale)
            previewView.setVideo(video.asset, storedCropPosition: storedCropPosition) { [weak self] error in
                if let error = error {
                    self?.errorHandler.handleError(error)
                }
            } updateCropInfo: {
                print("test set video updateCropInfo")
            }
        }
    }
    
    func getCart() -> AlbumItemsCart {
        return cart
    }
}

extension ImagePickerViewController: ImagePickerToolsViewDelegate {
    
    func didTapSelectAlbum() {
        let selectAlbumViewController = SelectAlbumViewController(albums: library.albums, delegate: self)
        let navigationController = UINavigationController(rootViewController: selectAlbumViewController)

        present(navigationController, animated: true, completion: nil)
    }
    
    func didTapMultipleMode(_ enable: Bool) {
        collectionView.enableMultipleMode(enable)
    }
}

extension ImagePickerViewController: SelectAlbumViewControllerDelegate {
    
    func didSelectAlbum(_ album: Album) {
        show(album: album)
    }
}
