//
//  VC_SetPassword.swift
//  Test
//
//  Created by Jessica Vilaysak on 25/9/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class VC_SetPassword: UIViewController {

    @IBOutlet weak var fld_displayMessage: UITextView!
    @IBOutlet weak var fld_password: UITextField!
    @IBOutlet weak var fld_confirmPassword: UITextField!
    @IBOutlet weak var fld_name: UITextField!
    var inviteRef: FIRDatabaseReference!;
    
    func containsNumbers(pword: String) -> Bool
    {
        let decimalCharacters = CharacterSet.decimalDigits
        let decimalRange = pword.rangeOfCharacter(from: decimalCharacters)
        if decimalRange != nil {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    func containsUppercase(pword: String) -> Bool
    {
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalresult = texttest.evaluate(with: pword);
        if(capitalresult)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    func containsLowercase(pword: String) -> Bool
    {
        let capitalLetterRegEx  = ".*[a-z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalresult = texttest.evaluate(with: pword);
        if(capitalresult)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    @IBAction func btn_createUser(_ sender: Any) {
        
        let potentialPword = fld_password.text;
        var check = true;
        var displayMsg = "";
        
        if (potentialPword == "")
        {
            displayMsg += "Set your password using the fields above ^\n";
        }
        else{
            if (!containsNumbers(pword: potentialPword!))
            {
                check = false;
                print("NO NUMBER");
            }
            if (!containsUppercase(pword: potentialPword!))
            {
                check = false;
                print("NO UPPER");
            }
            if (!containsLowercase(pword: potentialPword!))
            {
                check = false;
                print("NO LOWER");
            }
            if ((potentialPword?.count)! < 6)
            {
                check = false;
                print("LESS THAN 6");
            }
            if(!check)
            {
                displayMsg += "You have entered an invalid password!\nYour password must contain: at least 6 characters, at least one uppercase, at least one lowercase, at least one number.\n"
            }
        }
        if(fld_name.text == "")
        {
            displayMsg += "You must enter a name.\n";
            check = false;
        }
        if(!check)
        {
            fld_displayMessage.text = displayMsg;
            return;
        }
        if(potentialPword == fld_confirmPassword.text!)
        {
            fld_displayMessage.text = "YOUVE CONFIRMED YOUR PASSWORD YAY!";
        }
        else
        {
            fld_displayMessage.text = "Your passwords do not match.";
            return;
        }
        
        //userObj.username = self.fld_name.text;
        
        SVProgressHUD.show(withStatus: "Creating new user")
        FIRAuth.auth()?.createUser(withEmail: userObj.email, password: potentialPword!) { (user, error) in
        // [START_EXCLUDE]
            if let error = error {
                print("error: "+error.localizedDescription);
                self.fld_displayMessage.text = "Could not create new user with this email. Please contact your Shuffli administrator."
                SVProgressHUD.dismiss();
                return
            }
            print("\(user!.email!) created")
            userObj.uid = FIRAuth.auth()?.currentUser?.uid;
            self.fld_displayMessage.text = "Successful!\n new user with uid: "+userObj.uid;
            self.inviteRef = FIRDatabase.database().reference().child("actions/acceptInvite").childByAutoId().ref;
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
                    userObj.completeAsyncCalls{ success in
                        if success{
                            print("SUCCESS - completeAsyncCalls");
                            SVProgressHUD.dismiss();
                            let tabs = TabBarController();
                            self.present(tabs, animated: true, completion: nil);
                        }
                        else
                        {
                            print("FAILURE - completeAsyncCalls");
                            SVProgressHUD.dismiss();
                        }
                    };
                }
                if(cmdCompleted == "error")
                {
                    print("completed is ERROR??????!!?!");
                    SVProgressHUD.dismiss();
                    
                    SVProgressHUD.showError(withStatus: "Failed to authorise you.\nPlease try again later.")
                    SVProgressHUD.dismiss(withDelay: 2)
                }
            })
            self.inviteRef.setValue(["userID": userObj.uid!, "inviteCode": userObj.inviteCode!, "username": self.fld_name.text!]);
            
        // [END_EXCLUDE]
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.inviteRef.removeAllObservers();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround();
        // Do any additional setup after loading the view.
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
