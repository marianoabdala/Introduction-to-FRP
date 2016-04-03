import Foundation
import ReactiveCocoa
import Result

struct RegisterViewModel {
    
    let registerEnabledSignalProducer: SignalProducer<Bool, NoError>
    let registerService: RegisterServiceProtocol

    let username = MutableProperty<String?>(nil)
    let password = MutableProperty<String?>(nil)
    let isRegistering = MutableProperty(false)
    let registryError = MutableProperty<String?>(nil)

    init(registerService: RegisterServiceProtocol) {

        self.registerService = registerService

        self.registerEnabledSignalProducer = combineLatest(self.username.producer, self.password.producer, self.isRegistering.producer)
            .map { (username, password, isRegistering) -> Bool in
                
                return username?.characters.count >= 8 &&
                        password?.characters.count >= 8 &&
                        isRegistering == false
        }

    }
    
    func register() -> Signal<Void, NoError> {

        var didRegisterSink: Observer<Void, NoError>?
        let didRegisterSignal = Signal<Void, NoError> { (sink) -> Disposable? in
            
            didRegisterSink = sink
            return nil
        }

        guard let username = self.username.value,
                    password = self.password.value else {

                self.registryError.value = "Invalid username or password"
                self.isRegistering.value = false
                
                return didRegisterSignal
        }

        self.isRegistering.value = true

        self.registerService.register(username: username, password: password)
            .map { (data, urlResponse) -> String? in
        
                self.isRegistering.value = false
                
                if let responseDictionary = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves) as! [String: AnyObject] {
                    
                    return responseDictionary["token"] as? String
                    
                } else {
                    
                    return nil
                }
            }
            .mapError { (error) -> NSError in

                self.registryError.value = error.userInfo["Reason"] as? String
                self.isRegistering.value = false

                return error
            }
            .observeOn(UIScheduler())
            .startWithNext { (token) in

                if let token = token {
                    
                    // Let's assume that the token should go into some sort of
                    // local authentication store for later use.
                    print(token)
                    
                    self.isRegistering.value = false
                    didRegisterSink?.sendCompleted()
                    
                } else {
                    
                    self.registryError.value = "Invalid token"
                    self.isRegistering.value = false
                }
        }
        
        return didRegisterSignal
    }
}
