import UIKit

extension UIView {
    
    static func viewFromNib<T>() -> T {
        return viewFromNib(String(describing: self)) as! T
    }
        
    static func viewFromNib(_ name: String) -> UIView {
        return Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.last as! UIView
    }
}
