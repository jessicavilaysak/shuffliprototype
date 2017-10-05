//
//  RootVC.swift
//  Test
//
//  Created by Pranav Joshi on 4/10/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseAuth

class RootVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
        override func viewDidAppear(_ animated: Bool) {
    
            super.viewDidAppear(animated)
            
            if FIRAuth.auth()?.currentUser != nil{
                print("User is NOT null.");
                userObj.uid = FIRAuth.auth()?.currentUser?.uid;
                userObj.completeAsyncCalls{ success in
                    if success{
                        print("SUCCESS - completeAsyncCalls");
                        self.directSegue()
                    }
                    else
                    {
                        print("FAILURE - completeAsyncCalls");
                        self.segueToInitialVC(vc_name: "VC_initialview")
                    }
                };
                setUser()
                
            } else {
                
                print("User is null.")
                segueToInitialVC(vc_name: "VC_initialview")
                
            }
    
        }

    func setUser(){ //set userUID value here
        
        if let user = FIRAuth.auth()?.currentUser?.uid{
            userObj.uid = user
        }
        
    }
    func directSegue() {
        let tabs = TabBarController();
        self.present(tabs, animated: true, completion: nil)
        
    }
    
    func segueToInitialVC(vc_name: String) {
        let vc = storyboard?.instantiateViewController(withIdentifier: vc_name);
        present(vc!, animated: false, completion: nil);
    }
    
}
