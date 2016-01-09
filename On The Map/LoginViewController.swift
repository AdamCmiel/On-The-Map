//
//  LoginViewController.swift
//  On The Map
//
//  Created by Adam Cmiel on 11/1/15.
//  Copyright © 2015 Adam Cmiel. All rights reserved.
//

import UIKit

protocol LoginControllerDelegate {
    func loginViewController(loginViewController: LoginViewController, didSuccessfullyLoginWithData: JSONData)
    func loginViewController(loginViewController: LoginViewController, didPressSignUpButton: UIButton)
}

class LoginViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate {
    
    var delegate: LoginControllerDelegate?
    private var controls: [UIControl] {
        get { return [emailField, passwordField, facebookButton] }
    }
    
    private var loginCallback: APIResponse -> Void {
        get {
            return ({ [unowned self] result in
                switch result {
                case .Failure(let error):
                    switch error.errorType {
                    case .RequestJSONFormat:
                        fatalError("JSON error in facebook login request")
                    case .ResponseJSONFormat: fallthrough
                    case .Network:
                        print(error.error)
                        self.showLoginErrorAlert("no internet connection")
                    case .Cancelled:
                        print("user cancelled facebook signin")
                    case .ResponseCode:
                        print("strange response from api")
                    case .Unauthorized:
                        self.showLoginErrorAlert("udacity account credentials invalid")
                    }
                    
                case .Success(var data):
                    // if successful login, store login in the dataStore
                    if let _ = data["error"] {
                        return self.showLoginErrorAlertFromProvider("udacity")
                    } else {
                        
                        let key = data["account"]!["key"] as! String
                        APIActions.getPublicUserData(key) { publicDataResult in
                            switch publicDataResult {
                            case .Success(let userData):
                                data["_user"] = userData["user"]!
                                self.delegate?.loginViewController(self, didSuccessfullyLoginWithData: data)
                            case .Failure(let error):
                                print(error)
                                self.showLoginErrorAlert("could not fetch public data from Udacity")
                            }
                            
                        }
                    }
                }
                
                self.enable()
            })
        }
    }

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBAction final func signUpButtonPressed(sender: AnyObject) {
        delegate?.loginViewController(self, didPressSignUpButton: signUpButton)
    }
    
    @IBAction final func facebookButtonPressed(sender: AnyObject) {
        disable()
        APIActions.facebookLogInFromViewController(self, completion: loginCallback)
    }
    
    private final func signIn() {
        disable()
        APIActions.signIn(email: emailField.text!, password: passwordField.text!, completion: loginCallback)
    }
    
    private final func disable() {
        controls.forEach { $0.enabled = false }
    }
    
    private final func enable() {
        controls.forEach { $0.enabled = true }
    }
    
    private final func showLoginErrorAlertFromProvider(provider: String) {
        return showLoginErrorAlert("there was an error logging in with \(provider)")
    }
    
    private final func showLoginErrorAlert(message: String = "there was an error loggin in") {
        let alert = UIAlertController(title: "Failed Login", message: message, preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "OK", style: .Default) { [unowned self] _ in
            alert.dismissViewControllerAnimated(true, completion: nil)
            self.enable()
        }
        alert.addAction(okButton)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - UIViewController
    
    final override func viewDidLoad() {
        super.viewDidLoad()
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            delegate?.loginViewController(self, didSuccessfullyLoginWithData: ["token": FBSDKAccessToken.currentAccessToken()])
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
    
    final func textFieldShouldReturn(textField: UITextField) -> Bool {
        // dismiss the keyboard
        textField.resignFirstResponder()
        // text input returned, sign in
        signIn()
        // should return true
        return true
    }
}

