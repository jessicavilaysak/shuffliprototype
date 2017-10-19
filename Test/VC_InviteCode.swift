//
//  VC_InviteCode.swift
//  Test
//
//  Created by Jessica Vilaysak on 25/9/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SVProgressHUD
import Spring

class VC_InviteCode: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var fld_invitecode: UITextField!
    @IBOutlet weak var btn_signingup: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    
    var signingOut: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround();
        fld_invitecode.delegate = self
        btn_signingup.layer.cornerRadius = 4
        SVProgressHUD.setDefaultStyle(.dark)
        signingOut = false;
        
        fld_invitecode.tag = 0
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
            btn_signup(AnyObject.self)
        }
        // Do not add a line break
        return false
    }
    @IBAction func btn_signup(_ sender: Any) {
        let invitecode = fld_invitecode.text;
        print("shuffli | invitecode: "+invitecode!);
        if invitecode == "" {
            SVProgressHUD.showError(withStatus: "Enter invite code!")
            SVProgressHUD.dismiss(withDelay: 2)
            return;
        }
        SVProgressHUD.show(withStatus: "Validating invite code")
        self.getInviteInfo { success in
            if success {
                print("shuffli - SUCCESS.");
                userObj.inviteCode = invitecode;
                
                userObj.canNewUserBeCreated { success in
                    if success {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_setpassword");
                        self.present(vc!, animated: true, completion: nil);
                        
                        /*let activeAccountPath = "accountPlans/"+userObj.accountID!+"/status";
                        FIRDatabase.database().reference().child(activeAccountPath).observeSingleEvent(of: .value , with: { snapshot in
                            
                            if snapshot.exists() {
                                let isActive = snapshot.value as! String;
                                print("isActive: "+isActive);
                                if(isActive == "active")
                                {
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_setpassword");
                                    self.present(vc!, animated: true, completion: nil);
                                    return;
                                }
                            }
                            let alert = UIAlertController(title: "NOTICE", message: "Dashboard account is inactive.\nPlease contact your dashboard administrator for more information.", preferredStyle: UIAlertControllerStyle.alert);
                            let cancelAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                                self.logout();
                            });
                            
                            alert.addAction(cancelAction)
                            self.present(alert,animated: true)
                            
                        });*/
                    }
                    else
                    {
                        let refreshAlert = UIAlertController(title: "NOTICE", message: "The max amount of users for this account has been reached.\nContact your dashboard manager for further information.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                            userObj.resetObj();
                            self.dismiss(animated: true, completion: nil);
                        }));
                        self.present(refreshAlert, animated: true, completion: nil);
                    }
                    SVProgressHUD.dismiss();
                }
                
            }
            else
            {
                print("shuffli - no success with invite info.");
                let refreshAlert = UIAlertController(title: "NOTICE", message: "Please enter a valid invite code.", preferredStyle: UIAlertControllerStyle.alert)
               
                refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                }));
                self.present(refreshAlert, animated: true, completion: nil);
            }
            
            SVProgressHUD.dismiss();
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // [START remove_auth_listener]
        if(signingOut)
        {
            userObj.resetObj();
            usersUIDs = Array<String>();
            images = [imageDataModel]()
            print("SHUFFLI | signed out.");
            SVProgressHUD.showSuccess(withStatus: "Logged out!");
            SVProgressHUD.dismiss(withDelay: 1);
        }
        // [END remove_auth_listener]
    }
    
    func logout() {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_initialview");
        self.present(vc!, animated: true, completion: nil);
        self.signingOut = true;
    }
    
    func getInviteInfo(completion: @escaping (Bool) -> ()) {
        print("getInviteInfo()");
        FIRDatabase.database().reference().child("userInvites").child(fld_invitecode.text!).observeSingleEvent(of: .value , with: { snapshot in
            
            if snapshot.exists() {
                
                let recent = snapshot.value as!  NSDictionary
                print(recent);
                print("email: "+(recent["email"] as! String));
                userObj.accountID = recent["accountID"] as! String;
                userObj.accountName = recent["accountName"] as! String;
                userObj.creatorID = recent["creatorID"] as! String;
                userObj.creatorName = recent["creatorName"] as! String;
                userObj.email = recent["email"] as! String;
                userObj.role = recent["role"] as! String;
                completion(true);
            }
            else
            {
                completion(false);
            }
        });
        
    }

    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
