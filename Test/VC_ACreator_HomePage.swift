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

class VC_ACreator_HomePage: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet var fldusername: UILabel!
    @IBOutlet var fldcompany: UILabel!
    @IBOutlet weak var userTable: UITableView!
    
    var handle: FIRAuthStateDidChangeListenerHandle!
    var signingOut: Bool!
    
    
   // @IBOutlet weak var collectionView: UICollectionView!
    
    func deleteUserButton(sender: UITapGestureRecognizer) {
        var index = Int((sender.view?.tag)!);
        //delete from data source
        if index == dataSource.userArray.count
        {
            index -= 1
        }
        dataSource.userArray.remove(at: index);
        
        //tell collection view data source has changed
        //self.collectionView.reloadData()
    }
    
    
    //@IBOutlet var viewusers: UICollectionView!
    override func viewDidLoad() {
        signingOut = false;
        
        userTable.delegate = self;
        userTable.dataSource = self;
        
        fldcompany.text = userObj.accountName;
        fldusername.text = userObj.username;
        /*if dataSource.userArray.count > 0
        {
            fld_nouser.isHidden = true
        }*/
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
    }

    override func viewDidAppear(_ animated: Bool) {
        
        
        
    }
    
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.userTable.dequeueReusableCell(withIdentifier: "userCell", for: indexPath as IndexPath) as! ManageUserCell
        cell.userName.text = "Simon Waters"
        cell.userEmail.text = FIRAuth.auth()?.currentUser?.email
        
        return cell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // [START remove_auth_listener]
        if(signingOut)
        {
            FIRAuth.auth()?.removeStateDidChangeListener(handle!)
            FIRDatabase.database().reference(withPath: userObj.listenerPath).removeAllObservers();
        }
        
        // [END remove_auth_listener]
    }

    @IBAction func logout(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
        
        handle = FIRAuth.auth()?.addStateDidChangeListener({ (auth: FIRAuth,user: FIRUser?) in
            if user?.uid == userObj.uid {
                print("SHUFFLI | could not log out for some reason :(");
            } else {
                print("SHUFFLI | signed out.");
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_signin");
                self.present(vc!, animated: true, completion: nil);
                self.signingOut = true;
                //the user has now signed out so go to login view controller
                // and remove this listener
            }
        });    }

    
    @IBAction func btn_addUser(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_adduser")
        self.present(vc!,animated: true,completion: nil)
        
    }
    
    

}
