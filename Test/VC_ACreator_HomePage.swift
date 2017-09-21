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

    @IBAction func logout(_ sender: Any) {
        if FIRAuth.auth()?.currentUser != nil {
            do{
                try FIRAuth.auth()?.signOut()
                let vc = storyboard?.instantiateViewController(withIdentifier: "VC_signin");
                present(vc!, animated: true, completion: nil);
            } catch let error as NSError{
                print(error)
            }
        }else{
            print("User is nill")
        }
    }

    
    @IBAction func btn_addUser(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_adduser")
        self.present(vc!,animated: true,completion: nil)
        
    }
    
    

}
