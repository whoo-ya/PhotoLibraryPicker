import UIKit
import SnapKit

class TestPreviewSelectedItemViewController: UIViewController {
    
    private var items: [MediaItem]!
    
    private let imageStackView = UIStackView()
    
    public static func create(_ items: [MediaItem]) -> TestPreviewSelectedItemViewController {
        let vc = TestPreviewSelectedItemViewController()
        vc.items = items
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(items: items)
    }
    
    private func configureUI() {
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { snp in
            snp.edges.equalToSuperview()
        }
        
        scrollView.addSubview(imageStackView)
        imageStackView.snp.makeConstraints { snp in
            snp.edges.equalToSuperview()
        }
        
        imageStackView.axis = .vertical
    }
    
    private func bind(items: [MediaItem]) {
        for item in items {
            switch item {
            case .photo(let item):
                let imageView = UIImageView(image: item.image)
                imageStackView.addArrangedSubview(imageView)
            case .video(let item):
                let imageView = UIImageView(image: item.thumbnail)
                imageStackView.addArrangedSubview(imageView)
            }
        }
    }
    
}
