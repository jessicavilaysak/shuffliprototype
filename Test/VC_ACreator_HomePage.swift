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

class VC_ACreator_HomePage: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet var fldusername: UILabel!
    
    @IBOutlet var fldcompany: UILabel!
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
       /* if dataSource.userArray.count > 0
        {
            fld_nouser.isHidden = true
        }*/
        //viewusers.reloadData()
        let tabItems = self.tabBarController?.tabBar.items;
        
        for i in 0...((tabItems?.count)!-1) {
            let controllerTitle = (self.tabBarController?.viewControllers?[i].title!)!;
            
            if(controllerTitle == "VC_manageusers"){
                print(": "+controllerTitle);
                let tabItem = tabItems?[i];
                dataSource.postNotifications = dataSource.postNotifications + 1;
                tabItem?.badgeValue = nil;
            }
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return dataSource.userArray.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell : CustomCellUser = collectionView.dequeueReusableCell(withReuseIdentifier: "cellUser", for: indexPath) as! CustomCellUser
//        cell.fld_username.text = dataSource.userArray[indexPath.row]
//        //print("shuffli - indexPath.row "+String(dataSource.userArray[indexPath.row]));
//        cell.deleteUser.tag = indexPath.row;
//        
//        //set delete image as a touch,
//        let singletap = UITapGestureRecognizer(target: self, action: #selector(deleteUserButton))
//        singletap.numberOfTapsRequired = 1 // you can change this value
//        cell.deleteUser.isUserInteractionEnabled = true
//        cell.deleteUser.addGestureRecognizer(singletap)
//        
//        
//        return cell
//    }

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


}
