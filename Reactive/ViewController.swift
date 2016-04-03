import UIKit
import ReactiveCocoa

class ViewController: UIViewController {

    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var registerButton: UIButton!
    
    private let registerService: RegisterServiceProtocol
    private let registerViewModel: RegisterViewModel

    required init?(coder aDecoder: NSCoder) {

        self.registerService = RegisterService(urlSession: NSURLSession.sharedSession())
        self.registerViewModel = RegisterViewModel(registerService: self.registerService)

        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setupBindings()
    }
    
    private func setupBindings() {
        
        self.errorLabel.rac_text <~ registerViewModel.registryError
        self.registerViewModel.username <~ self.usernameTextField.rac_text
        self.registerViewModel.password <~ self.passwordTextField.rac_text
        self.activityIndicatorView.rac_animating <~ registerViewModel.isRegistering
        self.registerButton.rac_enabled <~ self.registerViewModel.registerEnabledSignalProducer
    }
    
    @IBAction private func registerButtonTapped(sender: AnyObject) {
        
        self.registerViewModel.register().observeCompleted { [weak self] in
            
            guard let strongSelf = self else {
                
                return
            }
            
            strongSelf.performSegueWithIdentifier("registerIdentifier", sender: strongSelf)
        }
    }
}

