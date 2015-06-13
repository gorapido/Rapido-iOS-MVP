//
//  SignInViewController.swift
//  Rapido
//
//  Created by Alexander Hernandez on 4/12/15.
//  Copyright (c) 2015 Rapido. All rights reserved.
//

import UIKit
import Parse

class SignInViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var email: UITextField!
  @IBOutlet weak var passwd: UITextField!
  
  var delegate: SessionDelegate?
  var kbHeight: CGFloat?
  var prevKbHeight: CGFloat = 0.0
  var kbDown: Bool = true
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    passwd.secureTextEntry = true
    
    email.delegate = self
    passwd.delegate = self
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func signInTapped(sender: AnyObject) {
    PFUser.logInWithUsernameInBackground(email.text, password: passwd.text) { (user: PFUser?, err: NSError?) -> Void in
      if user != nil {
        user?.pinInBackgroundWithBlock({ (finished: Bool, error: NSError?) -> Void in
          self.delegate?.signInSuccessfully()
        })
      } else {
        
      }
    }
  }
  
  @IBAction func signUpTouchUpInside(sender: AnyObject) {
    performSegueWithIdentifier("signUpVCSegue", sender: nil)
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    return true
  }
  
  func keyboardWillShow(notification: NSNotification) {
    if let userInfo = notification.userInfo {
      if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
        if kbDown {
          kbDown = false
          kbHeight = keyboardSize.height
            
          animateTextField(true)
        }
      }
    }
  }
  
  func keyboardWillHide(notification: NSNotification) {
    kbDown = true
    
    animateTextField(false)
  }
  
  func animateTextField(up: Bool) {
    var movement = up ? -kbHeight! : kbHeight
    
    UIView.animateWithDuration(0.3, animations: {
      self.view.frame = CGRectOffset(self.view.frame, 0, movement!)
    })
  }
  
  @IBAction func facebookTouchUpInside(sender: AnyObject) {
    PFFacebookUtils.logInInBackgroundWithReadPermissions(["email"], block: { (user: PFUser?, error: NSError?) -> Void in
      if let user = user {
        self.delegate?.signInSuccessfully()
      }
    })
  }
  
  @IBAction func forgotPasswordTouchUpInside(sender: AnyObject) {
    var alert = UIAlertController(title: "Forgot Password?", message: "Enter your email address to reset it.", preferredStyle: .Alert)
    
    alert.addTextFieldWithConfigurationHandler({ email in
      email.placeholder = "you@example.com"
    })
    
    alert.addAction(UIAlertAction(title: "OK", style: .Default) { action in
      let email = alert.textFields![0] as! UITextField
      
      PFUser.requestPasswordResetForEmail(email.text)
    })
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { action in
      
    })
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    var signUpVC = segue.destinationViewController as? SignUpViewController
    
    signUpVC?.delegate = delegate
  }
  
  
}
