//
//  VC_adduser.swift
//  Test
//
//  Created by Pranav Joshi on 21/9/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SVProgressHUD
import DropDown
import Material

/**
 This class is responsible for adding a new user from an admin account, it allows
 the user to enter an email and a user role such as manager, creator or moderator.
 */

class VC_adduser: UIViewController, UITextFieldDelegate {

    let usrRoles = DropDown() // uses the dropdown pod to create a dropdown list
    
    //outlsets
    @IBOutlet weak var fld_email: UITextField!
    @IBOutlet weak var btn_userRoles: FlatButton!
    @IBOutlet weak var btn_createuser: UIButton!
    //variables
    var userRole : String!
    var roleObj = [String:String]()
    var inviteRef: FIRDatabaseReference!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround();
        
        setupCategories() //dropdown list
        
        SVProgressHUD.setDefaultStyle(.dark)
        btn_createuser.layer.cornerRadius = 4
        // for getting the next text field
        fld_email.delegate = self
        fld_email.tag = 1
        // datsource for the dropdown
        usrRoles.dataSource = ["Manager","Moderator","Creator"];
        // corresponding dropdown values which are sent to the db
        roleObj = ["Manager":"m1", "Moderator":"m2", "Creator":"u1"];
        
    }
    
    //Find next text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
            
        }
        // Do not add a line break
        return false
    }
    
    
// Creates a new user by sending input info to creator commands node which then takes care of
// sending out email to   the user using backend function
    @IBAction func btn_createNewUser(_ sender: Any) {
        print("btn_createNewUser() ENTRY.");
        if(fld_email.text == "" || userRole == "") // check input
        {
            print("No value in email field.");
            let refreshAlert = UIAlertController(title: "NOTICE", message: "You must enter a valid email.", preferredStyle: UIAlertControllerStyle.alert)
            refreshAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            present(refreshAlert, animated: true, completion: nil)
            return;
        }
        let role = userRole; // set in setUpCategories
        if(role == nil) // make sure user has selected a role
        {
            print("Not valid role.");
            let refreshAlert = UIAlertController(title: "NOTICE", message: "Please choose a role.", preferredStyle: UIAlertControllerStyle.alert)
            refreshAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            present(refreshAlert, animated: true, completion: nil)
            return;
        }
        print("role");
        print(role);
        SVProgressHUD.show(withStatus: "Sending out invite")
        // set invite ref path
        //creatorCommands/{accountID}/{creatorID}/userInvite/{commandID}
        self.inviteRef = FIRDatabase.database().reference().child("creatorCommands/"+userObj.accountID!+"/"+userObj.creatorID!+"/userInvite").childByAutoId().ref;
        //observer path
        self.inviteRef.observe(FIRDataEventType.value, with: {(snapshot) in
            //print(snapshot)
            let recent = snapshot.value as!  NSDictionary; // get values from db
            
            if(recent["completed"] == nil)
            {
                print("completed doesn't exist.");
                return;
            }
            let cmdCompleted = recent["completed"] as! String;
            if(cmdCompleted == "true") // invite successfully sent out depending on value set by backend function
            {
                print("completed is TRUE");
                SVProgressHUD.dismiss();
                
                SVProgressHUD.showSuccess(withStatus: "Successfully sent invite!")
                SVProgressHUD.dismiss(withDelay: 2)
                
                self.dismiss(animated: true, completion: nil);
            }
            if(cmdCompleted == "error") // unsuccessfull
            {
                print("completed is ERROR??????!!?!");
                SVProgressHUD.dismiss();
                
                SVProgressHUD.showError(withStatus: "Failed to send invite.\nPlease try again later.")
                SVProgressHUD.dismiss(withDelay: 3)
            }
        })
        self.inviteRef.setValue(["email": fld_email.text, "roleID": roleObj[role!]]); // set db values
    }
    
    override func viewWillDisappear(_ animated: Bool) { // cleanup
        super.viewWillDisappear(animated)
        if(inviteRef != nil)
        {
            self.inviteRef.removeAllObservers();
        }
        
    }
    
    @IBAction func btn_userRoleDropdown(_ sender: Any) { // dropdown button
        usrRoles.show() // show the dropdown
        print(userRole)
        
    }
    
    
    @IBAction func btn_cancel(_ sender: Any) { // dismiss vc
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func setupCategories() { // setup dropdown list and style
        
        usrRoles.anchorView = btn_userRoles
        usrRoles.bottomOffset = CGPoint(x: 0, y: btn_userRoles.bounds.height)
        // Action triggered on selection
        usrRoles.selectionAction = { [unowned self] (index, item) in
            self.btn_userRoles.setTitle(item + " ▾", for: .normal) // current selected dropdown item
            self.userRole = item; // set user role here
            
        }
    }
}
