//
//  ViewControllerHomePage.swift
//  Test
//
//  Created by Jessica Vilaysak on 10/5/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseDatabase

class VC_ACreator_HomePage: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var fldusername: UILabel!
    
    @IBOutlet var fldcompany: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    func deleteUserButton(sender: UITapGestureRecognizer) {
        var index = Int((sender.view?.tag)!);
        //delete from data source
        if index == dataSource.userArray.count
        {
            index -= 1
        }
        dataSource.userArray.remove(at: index);
        
        //tell collection view data source has changed
        self.collectionView.reloadData()
        //let item = IndexPath(item: index, section: 0);
        //self.collectionView.deleteItems(at: [item]);
    }
    
    
    @IBOutlet var viewusers: UICollectionView!
    override func viewDidLoad() {
        
        
        
        fldcompany.text = userObj.accountName;
        fldusername.text = userObj.username;
        /*if dataSource.userArray.count > 0
        {
            fld_nouser.isHidden = true
        }*/
        super.viewDidLoad()
        viewusers.reloadData()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view
    }
    
    /*func getList_Lvl3Users(completion: @escaping (Bool) -> ()) {
        let accountUID = userObj.accountID;
        print("shuffli: accountUID: "+accountUID!);
        
        FIRDatabase.database().reference().child("users").queryEqual(toValue: <#T##Any?#>, childKey: <#T##String?#>)
        
        FIRDatabase.database().reference().child("users").child(userUID!).observeSingleEvent(of: .value , with: { snapshot in
            
            if snapshot.exists() {
                
                let recent = snapshot.value as!  NSDictionary
                print(recent);
                completion(true);
            }});
    }*/

    
    /*
     self.ref = FIRDatabase.database().referenceFromURL(FIREBASE_URL).child("topics").
     queryOrderedByChild("published").queryEqualToValue(true)
     .observeEventType(.Value, withBlock: { (snapshot) in
     for childSnapshot in snapshot.children {
     print(snapshot)
     }
     })
 */
    
    
    override func viewDidAppear(_ animated: Bool) {
       /* if dataSource.userArray.count > 0
        {
            fld_nouser.isHidden = true
        }*/
        viewusers.reloadData()
        
        let tabItems = self.tabBarController?.tabBar.items;
        let tabItem = tabItems?[0]
        dataSource.userNotifications = 0;
        tabItem?.badgeValue = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.userArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : CustomCellUser = collectionView.dequeueReusableCell(withReuseIdentifier: "cellUser", for: indexPath) as! CustomCellUser
        cell.fld_username.text = dataSource.userArray[indexPath.row]
        //print("shuffli - indexPath.row "+String(dataSource.userArray[indexPath.row]));
        cell.deleteUser.tag = indexPath.row;
        
        //set delete image as a touch,
        let singletap = UITapGestureRecognizer(target: self, action: #selector(deleteUserButton))
        singletap.numberOfTapsRequired = 1 // you can change this value
        cell.deleteUser.isUserInteractionEnabled = true
        cell.deleteUser.addGestureRecognizer(singletap)
        
        
        return cell
    }


}
