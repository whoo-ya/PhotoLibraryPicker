import Foundation

class BaseError: Error {
    
    let message: String
    
    let cause: Error?
    
    init(message: String, cause: Error? = nil) {
        self.message = message
        self.cause = cause
    }
}
