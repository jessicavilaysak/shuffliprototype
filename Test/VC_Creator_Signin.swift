//
//  ViewControllerHomePageCreator.swift
//  Test
//
//  Created by Pranav Joshi and Jessica Vilaysak on 11/5/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SVProgressHUD

/** This class is responsible for handling user Login and login related validation
*/
class VC_Creator_Signin: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var fld_password: UITextField!
    @IBOutlet var fld_username: UITextField!
    @IBOutlet weak var SigninBtn: UIButton!
    var userUid: String!
    
    var ref: FIRDatabaseReference? // create property
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        //Setting delegates and tags so that the next text field is loaded when the return key is pressed
        fld_username.delegate = self
        fld_password.delegate = self
        fld_username.tag = 0
        fld_password.tag = 1
        
        
        //text field stylings
        fld_password.layer.cornerRadius = 4
        fld_username.layer.cornerRadius = 4
        SigninBtn.layer.cornerRadius = 4
        
        SVProgressHUD.setDefaultStyle(.dark)
        
        
    }
    // function executed on pressing keyboard return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
            BtnTapped((Any).self)
        }
        // Do not add a line break
        return false
    }
    
    
    
    // Login button tapped
    @IBAction func BtnTapped(_ sender: Any) {
    
        if let email = fld_username.text, let pass = fld_password.text // get email and pass from txt field
        {
            SVProgressHUD.show(withStatus: "Logging In")
            FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in // Firebase login call
                if user != nil{ // completion handler to check current user is not nill
                    userObj.uid = FIRAuth.auth()?.currentUser?.uid; // set obj
                    userObj.completeAsyncCalls{ success in // perform async calls
                        if success{ // wait for all calls to complete
                            print("SUCCESS - completeAsyncCalls");
                            SVProgressHUD.dismiss();
                            let activeAccountPath = "accountPlans/"+userObj.accountID!+"/status"; // current account status path which tells the user's payment status
                    
                            FIRDatabase.database().reference().child(activeAccountPath).observeSingleEvent(of: .value , with: { snapshot in // observe the specified path
                                
                                if snapshot.exists() {
                                    let isActive = snapshot.value as! String;
                                    print("isActive: "+isActive);
                                    if(isActive == "active") // checking if account has been paid
                                    {
                                        SVProgressHUD.dismiss()
                                        self.directSegue();
                                        return;
                                    }
                                    else // if account payment status is inactive
                                    {
                                        SVProgressHUD.dismiss();
                                        let alert = UIAlertController(title: "NOTICE", message: "Dashboard account is inactive.\nPlease contact your dashboard administrator for more information.", preferredStyle: UIAlertControllerStyle.alert);
                                        let cancelAction = UIAlertAction(title: "OK",
                                                                         style: .cancel, handler: nil)
                                        alert.addAction(cancelAction)
                                        self.present(alert,animated: true){}
                                    }
                                }
                                
                            });
                            
                            
                        }
                        else // Async calls not completed
                        {
                            print("FAILURE - completeAsyncCalls");
                            SVProgressHUD.dismiss()
                        }
                    }
                }
                else{ // wrong username and/or password combo. 
                    print(error!);
                    let alert = UIAlertController(title: "Login Failed", message: "Enter correct username or password", preferredStyle: UIAlertControllerStyle.alert);
                    let cancelAction = UIAlertAction(title: "OK",
                                                     style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    
                    self.present(alert,animated: true){}
                    SVProgressHUD.dismiss()
                }
            })
        }
    }
    
    

    
    /*
     Here we need to decide where to direct the user. A few rules:
     - IF user is level 3:
     - IF this is their first sign in we direct them to 'reset password' (id: 'VC_resetpassword').
     - IF not first sign in, direct them to tabviewcontroller as a lvl3 creator.
     - IF user is level 2:
     - payments?
     - Does this user have permissions to manage users or not? (ie. A brand ambassador does not have permission to manage users).
     - IF user has 'manage users' permission, we direct them to tabviewcontroller as a lvl2 admin creator OTHERWISE direct them to tabviewcontroller as a lvl3.
     */
    
    func directSegue() {
        let tabs = TabBarController();
        self.present(tabs, animated: true, completion: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
        fld_password.text = "";
        fld_username.text = "";
        
    }
    

    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
