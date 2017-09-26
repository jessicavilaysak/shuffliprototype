//
//  ViewControllerHomePageCreator.swift
//  Test
//
//  Created by Jessica Vilaysak on 11/5/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SVProgressHUD


class VC_Creator_Signin: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var fld_password: UITextField!
    @IBOutlet var fld_username: UITextField!
    @IBOutlet weak var SigninBtn: UIButton!
    var userUid: String!
    
    var ref: FIRDatabaseReference? // create property
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
        
        //text field stylings
        
        fld_password.layer.cornerRadius = 4
        fld_username.layer.cornerRadius = 4
        SigninBtn.layer.cornerRadius = 4
        
        
    }
    @IBAction func BtnTapped(_ sender: Any) {
        //dataSource.username = fld_username.text;
        if let email = fld_username.text, let pass = fld_password.text
        {
            SVProgressHUD.show(withStatus: "Logging In")
            FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
                
                if user != nil{
                    userObj.uid = FIRAuth.auth()?.currentUser?.uid;
                    userObj.completeAsyncCalls{ success in
                        if success{
                            print("SUCCESS - completeAsyncCalls");
                            SVProgressHUD.dismiss()
                            self.directSegue();
                        }
                        else
                        {
                            print("FAILURE - completeAsyncCalls");
                            SVProgressHUD.dismiss()
                        }
                    }
                }
                else{
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
        self.present(tabs, animated: true, completion: nil);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // [START remove_auth_listener]
        fld_password.text = "";
        fld_username.text = "";
        
        // [END remove_auth_listener]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        return;
        if FIRAuth.auth()?.currentUser != nil{
            print("User is NOT null.");
            SVProgressHUD.show(withStatus: "Setting up for you...");
            userObj.uid = FIRAuth.auth()?.currentUser?.uid;
            userObj.completeAsyncCalls{ success in
                if success{
                    print("SUCCESS - completeAsyncCalls");
                }
                else
                {
                    print("FAILURE - completeAsyncCalls");
                }
            };
            setUser()
        }else{
            print("User is null.")
        }
        
    }
    
    func setUser(){ //set userUID value here
        
        if let user = FIRAuth.auth()?.currentUser?.uid{
            userObj.uid = user
    }
        
        //keychain()
    }

    
}
