//
//  LoginViewController.swift
//  On The Map
//
//  Created by Adam Cmiel on 11/1/15.
//  Copyright © 2015 Adam Cmiel. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate {
    
    var controls: [UIControl] {
        get { return [emailField, passwordField, facebookButton] }
    }
    
    var loginCallback: APIResponse -> Void {
        get {
            return ({ [unowned self] result in
                self.enable()
                
                switch result {
                case .Failure(let error):
                    
                    switch error.errorType {
                    case .RequestJSONFormat:
                        fatalError("JSON error in facebook login request")
                    case .ResponseJSONFormat: fallthrough
                    case .Network:
                        print(error.error)
                        self.showLoginErrorAlertFromProvider("facebook")
                    case .Cancelled:
                        print("user cancelled facebook signin")
                    }
                    
                case .Success(let data):
                    
                    // if successful login, store login in the dataStore
                    StudentDataStore.sharedStore.session = data
                    
                    self.dismiss()
                    
                }
            })
        }
    }

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var facebookButton: UIButton!
    
    @IBAction func facebookButtonPressed(sender: AnyObject) {
        disable()
        APIActions.facebookLogInFromViewController(self, completion: loginCallback)
    }
    
    private final func signIn() {
        disable()
        APIActions.signIn(email: emailField.text!, password: passwordField.text!, completion: loginCallback)
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func disable() {
        controls.forEach { $0.enabled = false }
    }
    
    func enable() {
        controls.forEach { $0.enabled = true }
    }
    
    private final func showLoginErrorAlertFromProvider(provider: String) {
        let alert = UIAlertController(title: "Failed Login", message: "there was an error logging in with \(provider)", preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "OK", style: .Default) { _ in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(okButton)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            dismiss()
        }
        
        [emailField, passwordField].forEach {
            let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: $0.frame.size.height))
            leftView.backgroundColor = UIColor.clearColor()
            $0.leftView = leftView
            $0.leftViewMode = .Always
            $0.delegate = self
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // dismiss the keyboard
        textField.resignFirstResponder()
        // text input returned, sign in
        signIn()
        // should return true
        return true
    }
}
