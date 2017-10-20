//
//  ViewControllerHomePage.swift
//  Test
//
//  Created by Pranav Joshi on 10/5/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SVProgressHUD
import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging

/**
 This class is responsible for:
 - displaying the current logged in user's information. (USERNAME, COMPANY NAME, ACCOUNT CREATOR NAME)
 - loading invited users in table view, additionaly the invited user's current account status is also displayed (Active,Pending)
 - Logout
 - Adding a user
 - Deleting a use
 **/

class VC_ACreator_HomePage: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //UI outlets
    @IBOutlet weak var fldcreator: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet var fldusername: UILabel!
    @IBOutlet var fldcompany: UILabel!
    @IBOutlet weak var userTable: UITableView!
    
    // Variables
    var handle: FIRAuthStateDidChangeListenerHandle! // login state change listner
    var signingOut: Bool!
    var isInitialState: Bool!;
    
    
    
    override func viewDidLoad() {
       //Initialization
        signingOut = false;
        userTable.delegate = self;
        userTable.dataSource = self;
        
        // Using awesome font to display icons for account name, creator name and user name
        fldcompany.font = UIFont.fontAwesome(ofSize: 14)
        
        //account name is extracted from userObj global obj, the obj is setup during login
        fldcompany.text = String.fontAwesome(code: "fa-users")!.rawValue + " " + userObj.accountName;
        fldcreator.font = UIFont.fontAwesome(ofSize: 14)
        
        //Similar to accountName
        fldcreator.text = String.fontAwesome(code: "fa-paint-brush")!.rawValue + " " + userObj.creatorName;
        fldusername.font = UIFont.fontAwesome(ofSize: 16)
        fldusername.text = String.fontAwesome(code: "fa-user-circle-o")!.rawValue + " " + userObj.username;
       
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
       
        //Creating a shadow
        bgImage.layer.masksToBounds = false
        bgImage.layer.shadowColor = UIColor.black.cgColor
        bgImage.layer.shadowOffset = CGSize(width: 1.0, height:1.0)
        bgImage.layer.shadowOpacity = 0.5
        bgImage.layer.shadowRadius = 10;
        bgImage.layer.shouldRasterize = true //tells IOS to cache the shadow
        
        SVProgressHUD.setDefaultStyle(.dark)// setting the colour of the loader here, done in every VC
    }

    override func viewDidAppear(_ animated: Bool) {
        reloadList(); //every time vc appears the table data is reloaded
    }
    
    func reloadList()
    {
        SVProgressHUD.show(withStatus: "Loading...");
        lUserDataModel.instantiateUsers(){ success in // async function declared in downloadUserModel
            if success { // only if async function is successfully completed
                print("RELOADED users.");
                self.userTable.reloadData();
                if(usersUIDs.count > 0)
                {
                     self.userTable.scrollToRow(at: NSIndexPath.init(row: 0, section: 0) as IndexPath, at: .top, animated: true) // auto scroll to the top of the table
                }
                SVProgressHUD.dismiss();
            }
        }
    }

    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return usersUIDs.count; // number of elements in the userUID array
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.userTable.dequeueReusableCell(withIdentifier: "userCell", for: indexPath as IndexPath) as! ManageUserCell // cell reuse
        
        if indexPath.row < usersUIDs.count
        {
            let userUid = usersUIDs[indexPath.row] // from array for the specified indexpath
            print(userUid);
            let userObj = usersObj[userUid]!;
            
            // Set cell UI elements
            cell.userName.text = userObj["username"];
            cell.userEmail.text = userObj["email"];
            cell.userStatus.text = userObj["status"];
            
            //change colour of user status label depending on status value
            if(userObj["status"] == "Pending")
            {
                cell.userStatus.textColor = UIColor.red;
            }
            else
            {
                cell.userStatus.textColor = UIColor.init(hex: "33cc33");
            }
            
        }
        
        return cell; //return each cell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // [START remove_auth_listener]
        
        // Handle sign out
        if(signingOut)
        {
            FIRAuth.auth()?.removeStateDidChangeListener(handle!) // state change
            
            //removing observers at the specified listener path defined in user obj
            FIRDatabase.database().reference(withPath: userObj.listenerPath).removeAllObservers();
            FIRDatabase.database().reference(withPath: userObj.manageuserPath).removeAllObservers();
            FIRDatabase.database().reference(withPath: userObj.invitedUsersPath).removeAllObservers();
            // reset all values to nil
            userObj.resetObj();
            //Arrays
            usersUIDs = Array<String>();
            images = [imageDataModel]()
            
            print("SHUFFLI | signed out.");
            SVProgressHUD.showSuccess(withStatus: "Logged out!");
            SVProgressHUD.dismiss(withDelay: 1);
        }
        // [END remove_auth_listener]
    }

    @IBAction func logout(_ sender: Any) {
        
        let refreshAlert = UIAlertController(title: "", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        refreshAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
            FIRDatabase.database().reference().child("creatorCommands/"+userObj.accountID!+"/"+userObj.creatorID!+"/deleteFcmToken/"+userObj.uid!).setValue(["delete":"true"]);
            
            try! FIRAuth.auth()!.signOut() // force log out
            
            self.handle = FIRAuth.auth()?.addStateDidChangeListener({ (auth: FIRAuth,user: FIRUser?) in
                if user?.uid == userObj.uid { //check if not the same
                    print("SHUFFLI | could not log out for some reason :(");
                } else { // successfuly logged out so segue to specified VC
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_initialview");
                    self.present(vc!, animated: true, completion: nil);
                    self.signingOut = true;
                    
                    
                    //the user has now signed out so go to login view controller
                    // and remove this listener
                }
            });
            print("Handle Yes logic here")
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle No Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }

    
    @IBAction func btn_addUser(_ sender: Any) {
        SVProgressHUD.show(withStatus: "Validating...");
        userObj.canNewUserBeCreated { success in // async call to check if account has max no. of users added
            if success { // Max user not reached
                
                SVProgressHUD.dismiss();
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_adduser")
                self.present(vc!,animated: true,completion: nil)
            }
            else // max users reached
            {
                SVProgressHUD.dismiss();
                SVProgressHUD.showError(withStatus: "The max amount of users for this account has been reached.\nContact your dashboard manager for further information.")
                SVProgressHUD.dismiss(withDelay: 10)
                
            }
        }
    }
    
    func deleteUser(row: Int)
    {
        //setting vlaues from user object
        let userUid = usersUIDs[row];
        let user = usersObj[userUid]!;
        
        SVProgressHUD.show(withStatus: "Deleting user...");
        
        if(user["status"]! == "Active") //deleting user from firebase node depending on their status
        {
            FIRDatabase.database().reference().child("users/"+user["uid"]!).removeValue(); // removing child
            FIRDatabase.database().reference().child("userRoles/"+userObj.accountID!+"/"+userObj.creatorID!+"/"+user["uid"]!).removeValue(); //removing child from different path
        }
        else
        {
            FIRDatabase.database().reference().child("creatorInvites/"+userObj.accountID!+"/"+userObj.creatorID!+"/"+userUid).removeValue();
            if(user["code"] != nil)
            {
                FIRDatabase.database().reference().child("userInvites/"+user["code"]!).removeValue();
            }
            
        }
        SVProgressHUD.dismiss();
        reloadList(); // reload table data
    }
    
    // Handling delete a user based on the row tapped 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let userUid = usersUIDs[indexPath.row];
        let user = usersObj[userUid]!;
        
        var msg = "Email: ";
        if(user["email"] != nil)
        {
            msg += user["email"]!;
        }
        msg += "\nSTATUS: ";
        if(user["status"] != nil)
        {
            msg += user["status"]!;
        }
        let refreshAlert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        refreshAlert.addAction(UIAlertAction(title: "Delete User", style: .default, handler: { (action: UIAlertAction!) in
            let confirmDelete = UIAlertController(title: "", message: "Are you sure you wish to delete this user?", preferredStyle: UIAlertControllerStyle.alert)
            
            confirmDelete.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
                self.deleteUser(row: indexPath.row);
                print("Handle confirm delete YES logic here")
            }))
            
            confirmDelete.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle confirm delete NO Logic here")
            }))
            
            self.present(confirmDelete, animated: true, completion: nil)
            print("Handle Yes logic here")
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle No Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }

}
