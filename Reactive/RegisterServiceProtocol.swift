import Foundation
import ReactiveCocoa

protocol RegisterServiceProtocol {
    
    func register(username username: String, password: String) -> SignalProducer<(NSData, NSURLResponse), NSError>
}
