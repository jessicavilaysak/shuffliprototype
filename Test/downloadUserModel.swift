//
//  downloadUserModel.swift
//  Test
//
//  Created by Jessica Vilaysak on 28/9/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import Foundation
import FirebaseDatabase

/**
 The userData object
 **/
struct userDataModel {
    
    /*
     Instructions that need to execute when an instance of the userDataModel object is created.
     We have included no instructions.
     */
    init()
    {
        
    }
    
    /*
     - Function 'sortActiveUsers' is used to retrieve all active users for this team.
     - It grabs all relevant children from the 'userRoles' node then goes to
     the 'users' node to get their corresponding email, username and status.
     - The 'DispatchGroup' object is used as a method to track the asynchronous calls
     and ensure that this function returns when the asynchronous calls are completed.
     */
    private mutating func sortActiveUsers(completion: @escaping (Bool) -> ()) {
        
        let userDataGroup = DispatchGroup() // group of completion handlers for user data (username, email etc)
        FIRDatabase.database().reference().child(userObj.manageuserPath).observeSingleEvent(of: .value, with:{ (snapshot) in
            lActiveUserIDs = Array<String>();
            for imageSnapshot in snapshot.children{
                let imgS = imageSnapshot as! FIRDataSnapshot;
                if(imgS.key == userObj.uid)
                {
                    continue;
                }
                lActiveUserIDs.append(imgS.key);
                usersObj[imgS.key] = ["role": (imgS.value as! String), "uid": imgS.key];
            }
            
            for uid in lActiveUserIDs {
                //enter the user data group
                userDataGroup.enter()
                FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    if(snapshot.exists())
                    {
                        let value = snapshot.value as? NSDictionary
                        //print("inside snapshot");
                        var lUsername = "";
                        if(value!["username"] != nil)
                        {
                            lUsername = value!["username"] as! String;
                        }
                        usersObj[uid]!["username"] = lUsername;
                        var lEmail = "";
                        if(value!["email"] != nil)
                        {
                            lEmail = value!["email"] as! String;
                        }
                        usersObj[uid]!["email"] = lEmail;
                        usersObj[uid]!["status"] = "Active";
                    }
                    userDataGroup.leave()
                }) { (error) in
                    print(error.localizedDescription)
                    userDataGroup.leave()
                }
            }
            userDataGroup.notify(queue: .main) {
                print("Finished all user data requests.")
                completion(true);
            }
        })
        
    }
    
    /*
     - Function 'sortPendingUsers' collates all the invites for the current team.
     - Grabs all children from the 'creatorInvites' node for the current team.
     */
    private mutating func sortPendingUsers(completion: @escaping (Bool) -> ()) {
        
        FIRDatabase.database().reference().child(userObj.invitedUsersPath).observeSingleEvent(of: .value, with: { (snapshot) in
            for imageSnapshot in snapshot.children{
                let imgS = imageSnapshot as! FIRDataSnapshot;
                let value = imgS.value as! NSDictionary;
                lPendingUserIDs.append(imgS.key);
                usersObj[imgS.key] = ["email": (value["email"] as! String), "status": "Pending"];
                if(value["code"] != nil)
                {
                    usersObj[imgS.key]!["code"] = (value["code"] as! String);
                }
            }
            
            completion(true);
        })
    }
    
    /*
     - Function 'instantiateUsers' is used to reload the table in the 'Manage Users' VC.
     */
    public mutating func instantiateUsers(completion: @escaping (Bool) -> ())
    {
        usersUIDs = Array<String>();
        lActiveUserIDs = Array<String>();
        lPendingUserIDs = Array<String>();
        
        lUserDataModel.sortActiveUsers(){success in
            if success {
                lUserDataModel.sortPendingUsers(){success in
                    if success {
                        for a in lActiveUserIDs {
                            usersUIDs.append(a);
                        }
                        for b in lPendingUserIDs {
                            usersUIDs.append(b);
                        }
                        print("Finished all manage user requests.")
                        completion(true);
                    }
                }
            }
        }
    }
}

var usersUIDs = Array<String>();
var usersObj = [String:[String:String]]();

var lActiveUserIDs = Array<String>();
var lPendingUserIDs = Array<String>();

var lUserDataModel = userDataModel();

