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

class VC_SetPassword: UIViewController {

    @IBOutlet weak var fld_displayMessage: UITextView!
    @IBOutlet weak var fld_password: UITextField!
    @IBOutlet weak var fld_confirmPassword: UITextField!
    
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
        if (potentialPword == "")
        {
            fld_displayMessage.text = "Set your password using the fields above ^";
            return;
        }
        else{
            var check = true;
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
                fld_displayMessage.text = "You have entered an invalid password!\nYour password must contain: at least 6 characters, at least one uppercase, at least one lowercase, at least one number."
                return;
            }
        }
        fld_displayMessage.text = "You have entered a valid password!";
        if(potentialPword == fld_confirmPassword.text!)
        {
            fld_displayMessage.text = "YOUVE CONFIRMED YOUR PASSWORD YAY!";
        }
        else
        {
            fld_displayMessage.text = "Your passwords do not match.";
            return;
        }
        FIRAuth.auth()?.createUser(withEmail: userObj.email, password: potentialPword!) { (user, error) in
        // [START_EXCLUDE]
            if let error = error {
                print("error: "+error.localizedDescription);
                return
            }
            print("\(user!.email!) created")
            userObj.uid = FIRAuth.auth()?.currentUser?.uid;
            self.fld_displayMessage.text = "Successful!\n new user with uid: "+userObj.uid;
        // [END_EXCLUDE]
        }
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
