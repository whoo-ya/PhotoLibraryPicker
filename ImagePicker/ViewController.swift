import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("test")
    }
    
    @IBAction func showImagePicker(_ sender: Any) {
        let vc = ImagePickerViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

