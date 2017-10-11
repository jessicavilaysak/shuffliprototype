//
//  ViewControllerHomePage.swift
//  Test
//
//  Created by Jessica Vilaysak on 10/5/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SVProgressHUD

class VC_ACreator_HomePage: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var fldcreator: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet var fldusername: UILabel!
    @IBOutlet var fldcompany: UILabel!
    @IBOutlet weak var userTable: UITableView!
    
    var handle: FIRAuthStateDidChangeListenerHandle!
    var signingOut: Bool!
    var isInitialState: Bool!;
    
   
    //@IBOutlet var viewusers: UICollectionView!
    override func viewDidLoad() {
       
        signingOut = false;
        userTable.delegate = self;
        userTable.dataSource = self;
        
        fldcompany.text = userObj.accountName;
        fldcreator.text = userObj.creatorName;
        fldusername.text = userObj.username;
       
        super.viewDidLoad()
        //viewusers.reloadData()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view
        
        //Creating a shadow
        bgImage.layer.masksToBounds = false
        bgImage.layer.shadowColor = UIColor.black.cgColor
        bgImage.layer.shadowOffset = CGSize(width: 1.0, height:1.0)
        bgImage.layer.shadowOpacity = 0.5
        bgImage.layer.shadowRadius = 10;
        bgImage.layer.shouldRasterize = true //tells IOS to cache the shadow
        SVProgressHUD.setDefaultStyle(.dark)
    }

    override func viewDidAppear(_ animated: Bool) {
        reloadList();
    }
    
    func reloadList()
    {
        SVProgressHUD.show(withStatus: "Loading...");
        lUserDataModel.instantiateUsers(){ success in
            if success {
                print("RELOADED users.");
                
                self.userTable.reloadData();
                self.userTable.scrollToRow(at: NSIndexPath.init(row: 0, section: 0) as IndexPath, at: .top, animated: true)
                SVProgressHUD.dismiss();
            }
        }
    }

    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int{
        return usersUIDs.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.userTable.dequeueReusableCell(withIdentifier: "userCell", for: indexPath as IndexPath) as! ManageUserCell
        if indexPath.row < usersUIDs.count
        {
            let userUid = usersUIDs[indexPath.row]
            print(userUid);
            let userObj = usersObj[userUid]!;
            cell.userName.text = userObj["username"];
            cell.userEmail.text = userObj["email"];
            cell.userStatus.text = userObj["status"];
            if(userObj["status"] == "Pending")
            {
                cell.userStatus.textColor = UIColor.red;
            }
            else
            {
                cell.userStatus.textColor = UIColor.init(hex: "33cc33");
            }
        }
        return cell;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // [START remove_auth_listener]
        if(signingOut)
        {
            FIRAuth.auth()?.removeStateDidChangeListener(handle!)
            FIRDatabase.database().reference(withPath: userObj.listenerPath).removeAllObservers();
            FIRDatabase.database().reference(withPath: userObj.manageuserPath).removeAllObservers();
            FIRDatabase.database().reference(withPath: userObj.invitedUsersPath).removeAllObservers();
            userObj.resetObj();
            usersUIDs = Array<String>();
            usersObj = [String:[String:String]]();
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
            try! FIRAuth.auth()!.signOut()
            
            self.handle = FIRAuth.auth()?.addStateDidChangeListener({ (auth: FIRAuth,user: FIRUser?) in
                if user?.uid == userObj.uid {
                    print("SHUFFLI | could not log out for some reason :(");
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_initialview");
                    self.present(vc!, animated: true, completion: nil);
                    self.signingOut = true;
                    
                    //the user has now signed out so go to login view controller
                    // and remove this listener
                }
            });
        }))
        refreshAlert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle No Logic here")
        }))
        present(refreshAlert, animated: true, completion: nil)
    }

    @IBAction func btn_addUser(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_adduser")
        self.present(vc!,animated: true,completion: nil)
    }
    
    func deleteUser(row: Int)
    {
        let userUid = usersUIDs[row];
        let user = usersObj[userUid]!;
        SVProgressHUD.show(withStatus: "Deleting user...");
        if(user["status"]! == "Active")
        {
            FIRDatabase.database().reference().child("users/"+user["uid"]!).removeValue();
            FIRDatabase.database().reference().child("userRoles/"+userObj.accountID!+"/"+userObj.creatorID!+"/"+user["uid"]!).removeValue();
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
        reloadList();
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let userUid = usersUIDs[indexPath.row];
        let user = usersObj[userUid]!;
        
        
        let refreshAlert = UIAlertController(title: "", message: "STATUS: "+user["status"]!, preferredStyle: UIAlertControllerStyle.actionSheet)
        
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
