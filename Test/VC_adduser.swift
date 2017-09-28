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

class VC_adduser: UIViewController, UITextFieldDelegate {

    let usrRoles = DropDown()
    @IBOutlet weak var fld_email: UITextField!
    @IBOutlet weak var btn_userRoles: FlatButton!
    
    var userRole : String!
    
    var inviteRef: FIRDatabaseReference!;
    @IBOutlet weak var btn_createuser: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround();
        
        setupCategories() //dropdown list
        
        SVProgressHUD.setDefaultStyle(.dark)

        btn_createuser.layer.cornerRadius = 4
        // Do any additional setup after loading the view.
        fld_email.delegate = self
        fld_email.tag = 1
        
        usrRoles.dataSource = ["m1","m2","u1"]
        
    }
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
    
    

    @IBAction func btn_createNewUser(_ sender: Any) {
        print("btn_createNewUser() ENTRY.");
        if(fld_email.text == "" || userRole == "")
        {
            print("No value in email field.");
            let refreshAlert = UIAlertController(title: "NOTICE", message: "You must enter a valid email.", preferredStyle: UIAlertControllerStyle.alert)
            refreshAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            present(refreshAlert, animated: true, completion: nil)
            return;
        }
        let role = userRole;
        if(role != "m1" && role != "m2" && role != "u1")
        {
            print("Not valid role.");
            let refreshAlert = UIAlertController(title: "NOTICE", message: "Please enter a valid role: [m1, m2, u1]", preferredStyle: UIAlertControllerStyle.alert)
            refreshAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            present(refreshAlert, animated: true, completion: nil)
            return;
        }
        SVProgressHUD.show(withStatus: "Sending out invite")
        //creatorCommands/{accountID}/{creatorID}/userInvite/{commandID}
        self.inviteRef = FIRDatabase.database().reference().child("creatorCommands/"+userObj.accountID!+"/"+userObj.creatorID!+"/userInvite").childByAutoId().ref;
        self.inviteRef.observe(FIRDataEventType.value, with: {(snapshot) in
            //print(snapshot)
            let recent = snapshot.value as!  NSDictionary;
            if(recent["completed"] == nil)
            {
                print("completed doesn't exist.");
                return;
            }
            let cmdCompleted = recent["completed"] as! String;
            if(cmdCompleted == "true")
            {
                print("completed is TRUE");
                SVProgressHUD.dismiss();
                
                SVProgressHUD.showSuccess(withStatus: "Successfully sent invite!")
                SVProgressHUD.dismiss(withDelay: 2)
                
                self.dismiss(animated: true, completion: nil);
            }
            if(cmdCompleted == "error")
            {
                print("completed is ERROR??????!!?!");
                SVProgressHUD.dismiss();
                
                SVProgressHUD.showError(withStatus: "Failed to send invite.\nPlease try again later.")
                SVProgressHUD.dismiss(withDelay: 3)
            }
        })
        self.inviteRef.setValue(["email": fld_email.text, "roleID": role]);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(inviteRef != nil)
        {
            self.inviteRef.removeAllObservers();
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btn_userRoleDropdown(_ sender: Any) {
        usrRoles.show()
        print(userRole)
        
    }
    
    
    @IBAction func btn_cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func setupCategories() {
        
        usrRoles.anchorView = btn_userRoles
        usrRoles.bottomOffset = CGPoint(x: 0, y: btn_userRoles.bounds.height)
        // Action triggered on selection
        usrRoles.selectionAction = { [unowned self] (index, item) in
            self.btn_userRoles.setTitle(item + " ▾", for: .normal)
            self.userRole = item
            
        }
    }
}
