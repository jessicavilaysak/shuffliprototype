//
//  UserObject.swift
//  Test
//
//  Created by Jessica Vilaysak on 21/8/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseDatabase

class UserObject {
    
    var isAdmin: Bool!;
    var username: String!;
    var accountID: String!;
    var creatorName: String!;
    var creatorID: String!;
    var uid: String!;
    var accountName: String!;
    var permissionToManageUsers: Bool!;
    var firstTimeLogin: Bool!;
    var listenerPath: String!;
    var role: String!;
    
    var email: String!;
    var inviteCode: String!;
    var manageuserPath: String!;
    var invitedUsersPath: String!;
    
    func resetObj()
    {
        isAdmin = nil;
        username = nil;
        accountID = nil;
        creatorID = nil;
        creatorName = nil;
        uid = nil;
        accountName = nil;
        permissionToManageUsers = nil;
        firstTimeLogin = nil;
        listenerPath = nil;
        role = nil;
        email = nil;
        inviteCode = nil;
        invitedUsersPath = nil;
    }
    
    init() {
        firstTimeLogin = false;
        isAdmin = true;
        permissionToManageUsers = true;
    }
    
    func setRole()
    {
        let lRole = role;
        if (lRole == "m1")
        {
            isAdmin = true;
            permissionToManageUsers = true;
        }
        else if (lRole == "m2")
        {
            isAdmin = true;
            permissionToManageUsers = false;
        }
        else
        {
            isAdmin = false;
            permissionToManageUsers = false;
        }
        if(isAdmin)
        {
            listenerPath = "creatorPosts/"+accountID!+"/"+creatorID!;
        }
        else
        {
            listenerPath = "userPosts/"+accountID!+"/"+creatorID!+"/"+uid!;
        }
    }
    
    func completeAsyncCalls(completion: @escaping (Bool) -> ()) {
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
                                self.manageuserPath = "userRoles/"+self.accountID!+"/"+self.creatorID!;
                                self.invitedUsersPath = "creatorInvites/"+self.accountID!+"/"+self.creatorID!;
                                completion(true);
                            }
                            else
                            {
                                print("shuffli - no success with role info.");
                                completion(false);
                            }
                        }
                    }
                    else
                    {
                        print("shuffli - no success with account info.");
                        completion(false);
                    }
                }
            }
            else{
                print("shuffli - no success with user info.");
                completion(false);
            }
        }
    }
    
    func getUserInfo(completion: @escaping (Bool) -> ()) {
        if (accountID != nil)
        {
            print("getUserInfo not executed bc userObj already filled this out.");
            completion(true);
        }
        let userUID = uid;
        print("shuffli: "+userUID!);
        FIRDatabase.database().reference().child("users").child(userUID!).observeSingleEvent(of: .value , with: { snapshot in
            
            if snapshot.exists() {
                
                let recent = snapshot.value as!  NSDictionary
                print(recent);
                self.accountID = (recent["accountID"] as? String)!;
                self.creatorID = (recent["creatorID"] as? String)!;
                if(recent["username"] != nil)
                {
                    self.username = (recent["username"] as? String)!;
                }
                
                completion(true);
            }});
        
    }
    
    func getAccountInfo(completion: @escaping (Bool) -> ()) {
    FIRDatabase.database().reference().child("accounts").child(accountID!).observeSingleEvent(of: .value , with: { snapshot in
        
        if snapshot.exists() {
            
            var recent = snapshot.value as!  NSDictionary
            //print(recent);
            self.accountName = (recent["accountName"] as? String)!;
        FIRDatabase.database().reference().child("creators/"+self.accountID!+"/"+self.creatorID!).observeSingleEvent(of: .value , with: { snapshot in
            
            if snapshot.exists() {
                
                recent = snapshot.value as!  NSDictionary
                
                self.creatorName = (recent["creatorName"] as? String)!;
                completion(true);
            }});
        }});
    
        
    }
    
    func getRoleInfo(completion: @escaping (Bool) -> ()) {

        if (role != nil)
        {
            print("getRoleInfo not executed bc userObj already filled this out.");
            completion(true);
        }
        print("getRoleInfo()");
        FIRDatabase.database().reference().child("userRoles").child(accountID!).child(creatorID!).child(uid!).observeSingleEvent(of: .value , with: { snapshot in
            
            if snapshot.exists() {
                
                let roleID = snapshot.value as!  String;
                print("roleID: "+roleID);
                self.role = roleID
                self.setRole();
                completion(true);
            }});
        
    }
}

let userObj = UserObject()



extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
