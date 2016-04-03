import Foundation
import ReactiveCocoa

struct NoTokenRegisterService: RegisterServiceProtocol {
    
    private let urlSession: NSURLSession
    
    init(urlSession: NSURLSession) {
        
        self.urlSession = urlSession
    }
    
    func register(username username: String, password: String) -> SignalProducer<(NSData, NSURLResponse), NSError> {
        
        let signalProducer = SignalProducer<(NSData, NSURLResponse), NSError> { (sink, compositeDisposable) in
            
            let data = try! NSJSONSerialization.dataWithJSONObject(["Hello": "No Token Here"], options: .PrettyPrinted)
            let urlResponse = NSURLResponse()
            
            sink.sendNext((data, urlResponse))
        }
        
        return signalProducer
    }
}

struct ErrorRegisterService: RegisterServiceProtocol {
    
    private let urlSession: NSURLSession
    
    init(urlSession: NSURLSession) {
        
        self.urlSession = urlSession
    }
    
    func register(username username: String, password: String) -> SignalProducer<(NSData, NSURLResponse), NSError> {
        
        return SignalProducer<(NSData, NSURLResponse), NSError>(error: NSError(domain: "RegisterService", code: -1, userInfo: ["Reason": "Dunno."]))
    }
}