@testable import Reactive //Our project.
import XCTest
import ReactiveCocoa
import Result

class ReactiveTests: XCTestCase {
    
    func testAPICall() {
        
        let registerService = RegisterService(urlSession: NSURLSession.sharedSession())
        let registerViewModel = RegisterViewModel(registerService: registerService)
        let registerButton = UIButton()
        let usernameTextField = UITextField()
        let passwordTextField = UITextField()
        
        registerViewModel.username <~ usernameTextField.rac_text
        registerViewModel.password <~ passwordTextField.rac_text
        registerButton.rac_enabled <~ registerViewModel.registerEnabledSignalProducer

        XCTAssertFalse(registerButton.enabled)
        
        usernameTextField.inputText("mariano@zerously.com")
        
        XCTAssertFalse(registerButton.enabled)
        
        passwordTextField.inputText("pa55worD")
        
        XCTAssertTrue(registerButton.enabled)
        
        let activityIndicatorView = UIActivityIndicatorView()
        let errorLabel = UILabel()
        
        errorLabel.rac_text <~ registerViewModel.registryError
        activityIndicatorView.rac_animating <~ registerViewModel.isRegistering
        
        let expectation = expectationWithDescription("Wait for register to return")

        registerViewModel.register().observeCompleted {

            XCTAssertTrue(registerButton.enabled)
            XCTAssertFalse(activityIndicatorView.isAnimating())

            // On a View Controller, we'd probably move to the onboarding screen.
            // Since this is a test, we'll simply mark the expectation as fulfilled.
            expectation.fulfill()
        }
        
        XCTAssertFalse(registerButton.enabled)
        XCTAssertTrue(activityIndicatorView.isAnimating())
        
        waitForExpectationsWithTimeout(10) { (error) in
            
            if error != nil {

                XCTFail()
            }
        }
     }
    
    func testAPICallDataFailure() {
        
        let registerService = NoTokenRegisterService(urlSession: NSURLSession.sharedSession())
        let registerViewModel = RegisterViewModel(registerService: registerService)
        let registerButton = UIButton()
        let usernameTextField = UITextField()
        let passwordTextField = UITextField()
        
        registerViewModel.username <~ usernameTextField.rac_text
        registerViewModel.password <~ passwordTextField.rac_text
        registerButton.rac_enabled <~ registerViewModel.registerEnabledSignalProducer

        usernameTextField.inputText("mariano@zerously.com")
        passwordTextField.inputText("pa55worD")

        let activityIndicatorView = UIActivityIndicatorView()
        let errorLabel = UILabel()
        
        errorLabel.rac_text <~ registerViewModel.registryError
        activityIndicatorView.rac_animating <~ registerViewModel.isRegistering
        
        registerViewModel.register().observeCompleted {

            XCTFail("Should fail and not call sendCompleted")
        }
        
        XCTAssertTrue(registerButton.enabled)
        XCTAssertFalse(activityIndicatorView.isAnimating())
        XCTAssertEqual(errorLabel.text, "Invalid token")
    }
    
    func testAPICallError() {
        
        let registerService = ErrorRegisterService(urlSession: NSURLSession.sharedSession())
        let registerViewModel = RegisterViewModel(registerService: registerService)
        let registerButton = UIButton()
        let usernameTextField = UITextField()
        let passwordTextField = UITextField()
        
        registerViewModel.username <~ usernameTextField.rac_text
        registerViewModel.password <~ passwordTextField.rac_text
        registerButton.rac_enabled <~ registerViewModel.registerEnabledSignalProducer
        
        usernameTextField.inputText("mariano@zerously.com")
        passwordTextField.inputText("pa55worD")
        
        let activityIndicatorView = UIActivityIndicatorView()
        let errorLabel = UILabel()
        
        errorLabel.rac_text <~ registerViewModel.registryError
        activityIndicatorView.rac_animating <~ registerViewModel.isRegistering
        
        registerViewModel.register().observeCompleted {
            
            XCTFail("Should fail and not call sendCompleted")
        }
        
        XCTAssertTrue(registerButton.enabled)
        XCTAssertFalse(activityIndicatorView.isAnimating())
        XCTAssertEqual(errorLabel.text, "Dunno.")
    }
}

extension UITextField {
    
    func inputText(text: String) {
        
        self.text = text
        self.sendActionsForControlEvents(.EditingChanged)
    }
}