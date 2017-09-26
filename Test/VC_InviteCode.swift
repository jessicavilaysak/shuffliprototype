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

class VC_InviteCode: UIViewController {

    @IBOutlet weak var fld_invitecode: UITextField!
    @IBOutlet weak var btn_signingup: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround();
        btn_signingup.layer.cornerRadius = 4
        // Do any additional setup after loading the view.
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
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_setpassword");
                SVProgressHUD.dismiss();
                self.present(vc!, animated: true, completion: nil);
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
    
    func getInviteInfo(completion: @escaping (Bool) -> ()) {

        FIRDatabase.database().reference().child("userInvites").child(fld_invitecode.text!).observeSingleEvent(of: .value , with: { snapshot in
            
            if snapshot.exists() {
                
                let recent = snapshot.value as!  NSDictionary
                print(recent);
                print("email: "+(recent["email"] as! String));
                userObj.accountID = recent["accountID"] as! String;
                userObj.creatorID = recent["creatorID"] as! String;
                userObj.username = recent["name"] as! String;
                userObj.email = recent["email"] as! String;
                
                let roleID = recent["role"] as! String;
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
                if(userObj.isAdmin)
                {
                    userObj.listenerPath = "creatorPosts/"+userObj.accountID!+"/"+userObj.creatorID!;
                }
                else
                {
                    userObj.listenerPath = "userPosts/"+userObj.accountID!+"/"+userObj.creatorID!+"/"+userObj.uid!;
                }
                completion(true);
            }
            else
            {
                completion(false);
            }
        });
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
