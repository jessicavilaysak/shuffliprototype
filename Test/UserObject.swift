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
    var creatorURL: String!;
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
    var fcmToken: String!;
    
    /*
     - Function 'resetObj' is called to reset all values to default when the current user is signed out.
     */
    func resetObj()
    {
        isAdmin = nil;
        username = nil;
        accountID = nil;
        creatorName = nil;
        creatorURL = nil;
        creatorID = nil;
        uid = nil;
        accountName = nil;
        permissionToManageUsers = nil;
        firstTimeLogin = nil;
        listenerPath = nil;
        role = nil;
        email = nil;
        inviteCode = nil;
        manageuserPath = nil;
        invitedUsersPath = nil;
        fcmToken = nil;
    }
    
    /*
     - Function 'init' is called when an instance of the 'UserObject' class is created.
     */
    init() {
        firstTimeLogin = false;
        isAdmin = true;
        permissionToManageUsers = true;
    }
    
    /*
     - Function 'setRole' will set permissions for the current user according to their role ID.
     */
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
    
    /*
     - Function 'completeAsyncCalls' is used to get all information necessary to start the application.
     - The permissions the signed in user has will define what gets displayed on the app.
     */
    func completeAsyncCalls(completion: @escaping (Bool) -> ()) {
        
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
    
    /*
     - Function 'getUserInfo' will get the following user info:
         - account ID, team ID (creatorID), username.
     */
    func getUserInfo(completion: @escaping (Bool) -> ()) {
        if (accountID != nil)
        {
            print("getUserInfo not executed bc userObj already filled this out.");
            completion(true);
        }
        let userUID = uid;
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
            }}
        );
    }
    
    /*
     - Function 'getAccountInfo' will get the following account info:
         - account name, team name (creatorName), team image (imageURL).
     */
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
                    if(recent["imageURL"] != nil)
                    {
                        self.creatorURL = (recent["imageURL"] as? String)!;
                    }
                    completion(true);
                }});
            }}
        );
    }
    
    /*
     - Function 'getRoleInfo' will get all the current user's role ID.
     */
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
            }}
        );
    }
    
    /*
     - This function 'canNewUserBeCreated' is called upon sign up.
     - This function will check if the current account has exceeded their max
     number of users.
     - IF the account has exceeded then this person will not be able to sign up.
     - IF the account hasn't exceeded, then this person will be allowed to continue.
     */
    func canNewUserBeCreated(completion: @escaping (Bool) -> ())
    {
        var max_users = -1;
        var active_users = -1;
        
        let userDataGroup = DispatchGroup()
        userDataGroup.enter()
        //get max users for this account.
        //max_users: accountPlans/{accID}/max_users
        let maxUserPath = "accountPlans/"+accountID!+"/max_users";
        FIRDatabase.database().reference().child(maxUserPath).observeSingleEvent(of: .value , with: { snapshot in
            
            if snapshot.exists() {
                max_users = snapshot.value as! Int;
            }
            userDataGroup.leave();
        });
        
        //get number of current active users for this account.
        //users: userCount/{accID}/count
        userDataGroup.enter()
        let activeUserPath = "userCount/"+accountID!+"/count";
        FIRDatabase.database().reference().child(activeUserPath).observeSingleEvent(of: .value , with: { snapshot in
            
            if snapshot.exists() {
                active_users = snapshot.value as! Int;
            }
            userDataGroup.leave();
        });
        userDataGroup.notify(queue: .main) {
            print("newUsers: max_users");
            print(max_users);
            print("newUsers: count");
            print(active_users);
            if((max_users != -1) && (active_users != -1) && (active_users < max_users))
            {
                completion(true);
            }
            else
            {
                print("Could not find values for max_users or active_users.");
                completion(false);
            }
        }
    }
}

//Global variable
let userObj = UserObject()

/*
 - This extension enables the keyboard to behave natively.
 */
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
