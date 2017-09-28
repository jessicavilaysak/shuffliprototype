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
