//
//  downloadUserModel.swift
//  Test
//
//  Created by Jessica Vilaysak on 28/9/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct userData {
    
    var key : String!
    var email : String!;
    var username : String!;
    var role : String!;
    
    init(lKey: String, lRole: String)
    {
        key = lKey;
        email = nil;
        username = nil;
        role = lRole;
    }
}

struct userDataModel {
    
    init() {
       activeUsersObj = [:];
        activeUsersData = [:];
    }
    
    public func instantiateUsers(snapshot: FIRDataSnapshot, completion: @escaping (Bool) -> ())
    {
        let userDataGroup = DispatchGroup() // group of completion handlers for user data (username, email etc)
        
        activeUsersObj = [:];
        activeUsersUids = Array<String>();
        for imageSnapshot in snapshot.children{
            let imgS = imageSnapshot as! FIRDataSnapshot;
            activeUsersUids.append(imgS.key);
            activeUsersObj[imgS.key] = ["role": (imgS.value as! String), "uid": imgS.key];
        }
        
        for uid in activeUsersUids {
            //enter the user data group
            userDataGroup.enter()
            FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                activeUsersData[uid] = value;
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
        
        
        
    }
    
    func getUserInfo(userUid: String, completion: @escaping (Bool) -> ()) {
        
        FIRDatabase.database().reference().child("users/"+userUid).observeSingleEvent(of: .value , with: { snapshot in
            
            if snapshot.exists() {
                let s = snapshot.value as! NSDictionary;
                let username = s["username"] as!  String;
                var email = "";
                print("username: "+username);
                if(s["email"] != nil)
                {
                    email = s["email"] as! String;
                }
                activeUsersObj[snapshot.key]!["username"] = username;
                activeUsersObj[snapshot.key]!["email"] = email;
                completion(true);
            }});
    }
    
    func getUserUid(element: Int) -> String{
        return activeUsersUids[element];
    }
    
    func getUserObj(uid: String) -> [String:String] {
        return activeUsersObj[uid]!;
    }
    
    func getUserData(uid: String) -> NSDictionary {
        let data = activeUsersData.value(forKey: uid) as? NSDictionary;
        if (data != nil) {
            return data!;
            
        } else {
            return NSDictionary();
        }
    }
}

var activeUsersUids = Array<String>();
var activeUsersObj = [String:[String:String]]();
var activeUsersData = NSMutableDictionary();
var lUserDataModel = userDataModel();
