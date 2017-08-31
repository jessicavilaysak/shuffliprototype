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
import SwiftKeychainWrapper

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
                    /*
                     Do we want to get user information EVERY time they log in OR only the first time they log in??
                     
                     ALSO, i used a completion handler to get all the information i need (username, company name, etc.) SYNCHRONOUSLY. All firebase calls are ASYNCHRONOUS so i had to do this to ensure i grabbed the info before going to the tab controller.
                    */
                    //first handler for getting user info will make the firebase call then come back and continue to the second handler IF successful.
                    self.getUserInfo{ success in
                        if success{
                            //this is the second handler that gets the account information.
                            self.getAccountInfo{ successAcc in
                                if successAcc {
                                    //this is the third handler that gets the user role information.
                                    self.getRoleInfo { successRole in
                                        if successRole {
                                            self.directSegue();
                                            SVProgressHUD.dismiss();
                                        }
                                        else
                                        {
                                            print("shuffli - no success with role info.");
                                            SVProgressHUD.dismiss()
                                        }
                                    }
                                }
                                else
                                {
                                    print("shuffli - no success with account info.");
                                    SVProgressHUD.dismiss()
                                }
                            }
                        }
                        else{
                            print("shuffli - no success with user info.");
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
    
    func getUserInfo(completion: @escaping (Bool) -> ()) {
        let userUID = userObj.uid;
        print("shuffli: "+userUID!);
        FIRDatabase.database().reference().child("users").child(userUID!).observeSingleEvent(of: .value , with: { snapshot in
            
            if snapshot.exists() {
                
                let recent = snapshot.value as!  NSDictionary
                print(recent);
                userObj.accountID = (recent["accountID"] as? String)!;
                userObj.creatorID = (recent["creatorID"] as? String)!;
                userObj.username = (recent["username"] as? String)!;
                completion(true);
            }});
        
    }
    
    func getAccountInfo(completion: @escaping (Bool) -> ()) {
        let accountID = userObj.accountID;
        print("shuffli: accountID: "+accountID!);
        FIRDatabase.database().reference().child("accounts").child(accountID!).observeSingleEvent(of: .value , with: { snapshot in
            
            if snapshot.exists() {
                
                let recent = snapshot.value as!  NSDictionary
                print(recent);
                userObj.accountName = (recent["accountName"] as? String)!;
                completion(true);
            }});
    }
    
    func getRoleInfo(completion: @escaping (Bool) -> ()) {
        let accountID = userObj.accountID;
        let creatorID = userObj.creatorID;
        let uid = userObj.uid;
        print("getRoleInfo()");
        FIRDatabase.database().reference().child("userRoles").child(accountID!).child(creatorID!).child(uid!).observeSingleEvent(of: .value , with: { snapshot in
            
            if snapshot.exists() {
                
                let roleID = snapshot.value as!  String;
                print("roleID: "+roleID);
                
                if (roleID == "m1")
                {
                    userObj.isAdmin = true;
                    userObj.permissionToManageUsers = true;
                }
                else if (roleID == "m2")
                {
                    userObj.isAdmin = true;
                    userObj.permissionToManageUsers = false;
                }
                else
                {
                    userObj.isAdmin = false;
                    userObj.permissionToManageUsers = false;
                }
                
                completion(true);
            }});

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

        if (userObj.firstTimeLogin && !userObj.isAdmin)
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_resetpassword");
            self.present(vc!, animated: true, completion: nil);
        }
        else
        {
            let tabs = TabBarController();
            self.present(tabs, animated: true, completion: nil);
        }

        
        
    }
    
    func setUser(){ //set userUID value here
        
        if let user = FIRAuth.auth()?.currentUser?.uid{
            self.userUid = user
        }
        
        keychain()
    }
    /*
     override func viewDidAppear(_ animated: Bool) {
     if let _ = KeychainWrapper.standard.string(forKey: "uid"){ //retrive from keychain
     
     self.performSegue(withIdentifier: "goToHome", sender: self)
     
     }
     
     }
     */
    func keychain(){
        
        KeychainWrapper.standard.set(userUid, forKey: "uid") //set uid value in keychain
    }
    
}
