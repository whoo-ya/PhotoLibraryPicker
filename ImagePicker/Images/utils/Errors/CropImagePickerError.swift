import Foundation

public class CropImagePickerError: ImagePickerBaseError {
    
    public let errors: [Error]
    
    public init(errors: [Error]) {
        self.errors = errors
        super.init(message: "")
    }
}
