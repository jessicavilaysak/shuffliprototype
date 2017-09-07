//
//  ViewControllerViewpostsCreator.swift
//  Test
//
//  Created by Jessica Vilaysak on 11/5/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftKeychainWrapper
import FirebaseDatabase
import SDWebImage
import SVProgressHUD

class VC_Creator_Viewposts: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var viewposts: UITableView!
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet var fldusername: UILabel!
    
    @IBOutlet var fldcompany: UILabel!
    
    var images = [imageDataModel]()
    var dbRef : FIRDatabaseReference!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        dbRef = FIRDatabase.database().reference()
        fldusername.text = userObj.username;
        //dataSource.username;
        
        viewposts.delegate = self;
        viewposts.dataSource = self;
        
        fldcompany.text = userObj.accountName;
        self.hideKeyboardWhenTappedAround()
        
        loadImagesfromDb()
        
        //Creating a shadow
        bgImage.layer.masksToBounds = false
        bgImage.layer.shadowColor = UIColor.black.cgColor
        bgImage.layer.shadowOffset = CGSize(width: 1.0, height:1.0)
        bgImage.layer.shadowOpacity = 0.5
        bgImage.layer.shadowRadius = 10;
        bgImage.layer.shouldRasterize = true //tells IOS to cache the shadow
        
    }
    
    func loadImagesfromDb(){
        FIRAuth.auth()?.addStateDidChangeListener({ (auth: FIRAuth,user: FIRUser?) in
            
            if user != nil {
                //print("uid: "+userObj.uid);
                let accountID = userObj.accountID;
                let creatorID = userObj.creatorID;
                //print(user!)
                var path = "";
                if(userObj.isAdmin)
                {
                    path = "creatorPosts/"+accountID!+"/"+creatorID!;
                }
                else
                {
                    path = "userPosts/"+accountID!+"/"+creatorID!+"/"+userObj.uid!;
                }
                self.dbRef.child(path).observe(FIRDataEventType.value, with: {(snapshot) in
                    print(snapshot)
                    var newImages = [imageDataModel]()
                    
                    for imageSnapshot in snapshot.children{
                        let imgObj = imageDataModel(snapshot: imageSnapshot as! FIRDataSnapshot)
                        //newImages.append(imgObj)
                        newImages.insert(imgObj, at: 0);
                    }
                    self.images = newImages;
                    //print(self.images);
                    self.viewposts.reloadData()
                })
            }
        })
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        viewposts.reloadData()
        
        let tabItems = self.tabBarController?.tabBar.items;
        for i in 0...((tabItems?.count)!-1) {
            let controllerTitle = (self.tabBarController?.viewControllers?[i].title!)!;
            
            if(controllerTitle == "VC_viewposts"){
                print(": "+controllerTitle);
                let tabItem = tabItems?[i];
                tabItem?.badgeValue = nil;
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.viewposts.dequeueReusableCell(withIdentifier: "cellCreator", for: indexPath as IndexPath) as! CustomCellCreator
        if indexPath.row < images.count
        {
            let image = images[indexPath.row]
            cell.photo.sd_setShowActivityIndicatorView(true)
            cell.photo.sd_setIndicatorStyle(.gray)
            cell.photo.sd_setImage(with: URL(string: image.url),placeholderImage: UIImage(named: "placeholder"))
            cell.imageCaption.text = image.caption;
            cell.imageCaption.textColor = UIColor.white;
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let vc = storyboard?.instantiateViewController(withIdentifier: "VC_clickimage") as! VC_ClickImage;

        let image = images[indexPath.row]
        vc.imagesDv =  image.url
        vc.captionDv = image.caption
        
        self.navigationController?.pushViewController(vc, animated: true);
    }

}




//dataSource.uid = ""
//KeychainWrapper.standard.set(dataSource.uid, forKey: "uid")


