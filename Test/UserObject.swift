//
//  UserObject.swift
//  Test
//
//  Created by Jessica Vilaysak on 21/8/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit

class UserObject {
    
    var isAdmin: Bool!;
    var username: String!;
    var accountID: Int!;
    var permissionToManageUsers: Bool!;
    var firstTimeLogin: Bool!;
  
    
    init() {
        isAdmin = true;
        username = "Simon";
        accountID = 10101;
        permissionToManageUsers = true;
        firstTimeLogin = false;
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
