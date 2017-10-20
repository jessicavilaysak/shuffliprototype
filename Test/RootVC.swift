//
//  RootVC.swift
//  Test
//
//  Created by Pranav Joshi on 4/10/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
/**
 This class handles auto user login depending on if the user has remained logged in from previous
 session. The auto login performs the same async calls as the Sign VC but the process is hidden behind
 storyboard animations.
 */
class RootVC: UIViewController {

    var handle: FIRAuthStateDidChangeListenerHandle!
    var signingOut: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signingOut = false;
       
    }
    
    //start the auto login process on view did appear
        override func viewDidAppear(_ animated: Bool) {
    
            super.viewDidAppear(animated)
            
           // segueToInitialVC(vc_name: "VC_initialview")
            //return;
            if FIRAuth.auth()?.currentUser != nil{ // current user does exist, Firebase caches user object
                print("User is NOT null.");
                userObj.uid = FIRAuth.auth()?.currentUser?.uid; //set uid
                userObj.completeAsyncCalls{ success in // perform async calls
                    if success{
                        print("SUCCESS - completeAsyncCalls");
                        //self.directSegue()
                        let activeAccountPath = "accountPlans/"+userObj.accountID!+"/status";
                        FIRDatabase.database().reference().child(activeAccountPath).observeSingleEvent(of: .value , with: { snapshot in
                            
                            if snapshot.exists() { // check payment status
                                let isActive = snapshot.value as! String;
                                print("isActive: "+isActive);
                                if(isActive == "active") // account paid
                                {
                                    self.directSegue(); // goto app home screen
                                    return;
                                }
                                else // account not paid
                                {
                                    let alert = UIAlertController(title: "NOTICE", message: "Dashboard account is inactive.\nPlease contact your dashboard administrator for more information.", preferredStyle: UIAlertControllerStyle.alert);
                                    let cancelAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                                    self.logout(); // perfrom logout as account not paid
                                    });
                                    
                                    alert.addAction(cancelAction)
                                    self.present(alert,animated: true)
                                }
                            }
                            
                        });
                    }
                    else // async calls failed
                    {
                        print("FAILURE - completeAsyncCalls");
                        self.segueToInitialVC(vc_name: "VC_initialview") // go to initial vc
                    }
                };
                setUser()// setting uid here
                
            } else { //user logged out from the previous session
                
                print("User is null.")
                segueToInitialVC(vc_name: "VC_initialview")
                
            }
    
        }
    
    // handling logout if the account payment status is inactive
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // [START remove_auth_listener]
        if(signingOut)
        {
            FIRAuth.auth()?.removeStateDidChangeListener(handle!)
            FIRDatabase.database().reference(withPath: userObj.listenerPath).removeAllObservers();
            FIRDatabase.database().reference(withPath: userObj.manageuserPath).removeAllObservers();
            FIRDatabase.database().reference(withPath: userObj.invitedUsersPath).removeAllObservers();
            userObj.resetObj();
            usersUIDs = Array<String>();
            images = [imageDataModel]()
            print("SHUFFLI | signed out.");
            SVProgressHUD.showSuccess(withStatus: "Logged out!");
            SVProgressHUD.dismiss(withDelay: 1);
        }
        // [END remove_auth_listener]
    }
    
    func logout() { // perform logout operation
        
        FIRDatabase.database().reference().child("creatorCommands/"+userObj.accountID!+"/"+userObj.creatorID!+"/deleteFcmToken/"+userObj.uid!).setValue(["delete":"true"]);
        
        try! FIRAuth.auth()!.signOut()
        
        self.handle = FIRAuth.auth()?.addStateDidChangeListener({ (auth: FIRAuth,user: FIRUser?) in
            if user?.uid == userObj.uid {
                print("SHUFFLI | could not log out for some reason :(");
            } else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_initialview");
                self.present(vc!, animated: true, completion: nil);
                self.signingOut = true;
                
                
                //the user has now signed out so go to login view controller
                // and remove this listener
            }
        });
        print("Handle Yes logic here")
    }

    func setUser(){ //set userUID value here
        
        if let user = FIRAuth.auth()?.currentUser?.uid{
            userObj.uid = user
        }
        
    }
    func directSegue() { // instantiate tabs
        let tabs = TabBarController();
        self.present(tabs, animated: true, completion: nil)
        
    }
    
    func segueToInitialVC(vc_name: String) { // go to initial vc 
        let vc = storyboard?.instantiateViewController(withIdentifier: vc_name);
        present(vc!, animated: false, completion: nil);
    }
    
}
