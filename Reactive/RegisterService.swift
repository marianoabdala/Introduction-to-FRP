import Foundation
import ReactiveCocoa

struct RegisterService: RegisterServiceProtocol {
    
    private let urlSession: NSURLSession
    
    init(urlSession: NSURLSession) {
        
        self.urlSession = urlSession
    }
    
    func register(username username: String, password: String) -> SignalProducer<(NSData, NSURLResponse), NSError> {

        // Let's assume we are inserting username and password to the request.
        guard let url = NSURL(string: "http://zerously.com/misc/register.json") else {
            
            return SignalProducer<(NSData, NSURLResponse), NSError>(error: NSError(domain: "RegisterService", code: -1, userInfo: ["Reason": "Invalid URL."]))
        }
        
        let request = NSURLRequest(URL: url)
        return self.urlSession.rac_dataWithRequest(request)
    }
}