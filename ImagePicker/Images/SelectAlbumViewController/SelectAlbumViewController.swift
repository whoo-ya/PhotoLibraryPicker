import UIKit

class SelectAlbumViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let albums: [Album]
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private weak var delegate: SelectAlbumViewControllerDelegate?
    
    init(albums: [Album], delegate: SelectAlbumViewControllerDelegate?) {
        self.albums = albums
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        tableView.reloadData()
    }
    
    private func configureUI() {
        // TODO: Локализация и цвет текста
        title = "Albums"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(closeScreen))
        navigationController?.navigationBar.tintColor = UIColor.darkText
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { snp in
            snp.edges.equalToSuperview()
        }
        
        tableView.separatorStyle = .none
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: SelectAlbumCell.nibName, bundle: .main),
                           forCellReuseIdentifier: SelectAlbumCell.reuseIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let album = getAlbum(indexPath),
              let cell = tableView.dequeueReusableCell(withIdentifier: SelectAlbumCell.reuseIdentifier, for: indexPath) as? SelectAlbumCell else {
            return UITableViewCell()
        }
        
        cell.bind(SelectAlbumCellItem(album: album))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let album = getAlbum(indexPath) else {
            return
        }
        delegate?.didSelectAlbum(album)
        closeScreen()
    }
    
    private func getAlbum(_ indexPath: IndexPath) -> Album? {
        guard indexPath.row < albums.count else {
            return nil
        }
        let album = albums[indexPath.row]
        return album
    }
    
    @objc
    private func closeScreen() {
        dismiss(animated: true, completion: nil)
    }
}
