//
//  LoginViewController.swift
//  On the Map
//
//  Created by X.I. Losada on 24/10/15.
//  Copyright © 2015 XiLosada. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    let udapi = UdacityApiClient.getSharedInstance()
    var activityIndicatorView : UIActivityIndicatorView?
    
    /**
     SPEC: Login page accepts email and password strings from users, with a “Login” button
     */
    @IBOutlet weak var emailTextView: UITextField!
    
    @IBOutlet weak var passwordTextView: UITextField!

    @IBOutlet weak var loginButton: UIButton!
    
    /**
     EXCEEDS SPEC: includes a “Login Using Facebook” option
    */
    @IBOutlet weak var fbButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbButton.delegate = self
        emailTextView.delegate = self
        passwordTextView.delegate = self
        if udapi.userID != nil {
            // If user is logged in
            completeLogin()
        }else if let token = FBSDKAccessToken.currentAccessToken(){
            // If the token is present, let's try to get the user data
            disableUIElements()
            getUserIdFromUdacity(token.tokenString)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == passwordTextView{
            login(loginButton)
        }
        return true
    }
    

    // Facebook Delegate Methods
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
            showError(error.localizedDescription)
        }
        if result.isCancelled {
            showError("Operation Cancelled")
        } else {
            if result.grantedPermissions.contains("email"){
                disableUIElements()
                getUserIdFromUdacity(result.token.tokenString)
            }
        }
    }
    
    func getUserIdFromUdacity(token:String){
        let udapi = UdacityApiClient.getSharedInstance()
        dispatch_async(dispatch_get_main_queue()) {
            udapi.loginWithFacebook(token,completionHandler: { userId,error -> Void
                in
                if let error = error{
                    self.showError(error.localizedDescription)
                    self.enableUIElements()
                }else{
                    self.completeLogin()
                }
            })
        }
    }
    
    //http://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func isValidPassword(testStr:String) -> Bool {
        return testStr.characters.count > 0
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        udapi.userID = nil
    }
    
    @IBAction func login(sender: AnyObject) {
        let email = emailTextView.text!
        let password = passwordTextView.text!
        if isValidEmail(email) && isValidPassword(password){
            udacityLogin(email,password:password)
        }
        else{
            showError("Invalid Credentials")
            credentialsAreInvalid()
        }
    }
    
    func udacityLogin(username:String, password:String){
        disableUIElements()
        udapi.login(username, password: password,completionHandler: { userId , error
            in
            if let error = error {
                self.enableUIElements()
                self.showError(error.localizedDescription)
                if(error.code == UdacityApiClient.ErrorCodes._credentialsError){
                    self.credentialsAreInvalid()
                }
            }else{
                self.completeLogin()
            }
        })
    }

    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(),{
            self.resetViews()
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NavigationController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func credentialsAreInvalid(){
        dispatch_async(dispatch_get_main_queue(),{
            self.tintTextViews(true)
            self.shakeAnimation()
        })
    }
    
    func resetViews(){
        enableUIElements()
        tintTextViews(false)
        emailTextView.text = ""
        passwordTextView.text = ""
    }
    
    //http://stackoverflow.com/questions/2647164
    func tintTextViews(error: Bool){
        emailTextView.layer.borderWidth = error ? 1.0 : 0
        passwordTextView.layer.borderWidth = error ? 1.0 : 0
        emailTextView.layer.borderColor = error ? UIColor.redColor().CGColor : UIColor.grayColor().CGColor
        passwordTextView.layer.borderColor = error ? UIColor.redColor().CGColor : UIColor.grayColor().CGColor
    }
    
    //http://stackoverflow.com/questions/3844557
    func shakeAnimation(){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(self.view.center.x - 2.0, self.view.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(self.view.center.x + 2.0, self.view.center.y))
        self.view.layer.addAnimation(animation, forKey: "position")
    }
    
    func disableUIElements(){
        configureUIElements(false)
        activityIndicatorView = showActivityIndicator()

    }
    
    func enableUIElements(){
        configureUIElements(true)
        releaseActivityIndicator(activityIndicatorView!)
    }
    
    func configureUIElements(enabled:Bool){
        dispatch_async(dispatch_get_main_queue(),{
            self.view.alpha = enabled ? 1 : 0.3
            self.emailTextView.enabled = enabled
            self.passwordTextView.enabled = enabled
            self.loginButton.enabled = enabled
            self.fbButton.enabled = enabled
        })
    }
    
}

