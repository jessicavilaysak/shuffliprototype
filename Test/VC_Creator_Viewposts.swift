//
//  ViewControllerViewpostsCreator.swift
//  Test
//
//  Created by Jessica Vilaysak on 11/5/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage
import SVProgressHUD
import FirebaseStorage

class VC_Creator_Viewposts: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var viewposts: UITableView!
    
    @IBOutlet weak var logOut: UIBarButtonItem!
   
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet var fldcompany: UILabel!
    @IBOutlet weak var fldcreator: UILabel!
    @IBOutlet var fldusername: UILabel!
    var handle: FIRAuthStateDidChangeListenerHandle!
    var signingOut: Bool!
    
    
    override func viewDidLoad() {
        signingOut = false;
        self.navigationController?.isNavigationBarHidden = false;
        super.viewDidLoad()
        //dataSource.username;
        
        viewposts.delegate = self;
        viewposts.dataSource = self;
        
        fldcompany.text = userObj.accountName;
        fldcreator.text = userObj.creatorName;
        fldusername.text = userObj.username;
        self.hideKeyboardWhenTappedAround();
        
        SVProgressHUD.setDefaultStyle(.dark)
        
        //Creating a shadow
        bgImage.layer.masksToBounds = false
        bgImage.layer.shadowColor = UIColor.black.cgColor
        bgImage.layer.shadowOffset = CGSize(width: 1.0, height:1.0)
        bgImage.layer.shadowOpacity = 0.5
        bgImage.layer.shadowRadius = 10;
        bgImage.layer.shouldRasterize = true //tells IOS to cache the shadow
        
        FIRDatabase.database().reference(withPath: userObj.listenerPath).observe(FIRDataEventType.value, with: {(snapshot) in
            //print(snapshot)
            var newImages = [imageDataModel]()
            
            for imageSnapshot in snapshot.children{
                let imgObj = imageDataModel(snapshot: imageSnapshot as! FIRDataSnapshot)
                //newImages.append(imgObj)
                newImages.insert(imgObj, at: 0);
            }
            images = newImages;
            print("SHUFFLI | path: "+userObj.listenerPath+" | images count: "+String(images.count));
            //print(self.images);
            self.viewposts.reloadData()
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
        if userObj.isAdmin {
            logOut.title = ""
            logOut.isEnabled = false
        }else{
            logOut.title = "Log Out"
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.viewposts.dequeueReusableCell(withIdentifier: "cellCreator", for: indexPath as IndexPath) as! CustomCellCreator
        if indexPath.row < images.count
        {
            let image = images[indexPath.row]
            
            //Checking if user is admin and if image dashboard status is approved, if it is, showing the approve icon
            if(!userObj.isAdmin){
                cell.approveStatus.isHidden = true
            }else{
                if (image.dashboardApproved == true){
                    cell.approveStatus.isHidden = false
                }else{
                    cell.approveStatus.isHidden = true
                }
                
            }
            cell.photo.sd_setShowActivityIndicatorView(true)
            cell.photo.sd_setIndicatorStyle(.gray)
            cell.photo.sd_setImage(with: URL(string: image.url),placeholderImage: UIImage(named: "placeholder"))
            cell.imageCaption.text = image.caption;
            cell.imageCaption.textColor = UIColor.white
        }
        return cell
}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // [START remove_auth_listener]
        if(signingOut)
        {
            FIRAuth.auth()?.removeStateDidChangeListener(handle!)
            FIRDatabase.database().reference(withPath: userObj.listenerPath).removeAllObservers();
            FIRDatabase.database().reference(withPath: userObj.manageuserPath).removeAllObservers();
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
            print("Handle Yes logic here")
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle No Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let vc = storyboard?.instantiateViewController(withIdentifier: "VC_clickimage") as! VC_ClickImage;

        vc.imgIndex = indexPath.row;
        
        self.navigationController?.pushViewController(vc, animated: true);
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        return;
        var path = ""
        let storage = FIRStorage.storage().reference()
        if(userObj.isAdmin)
        {
            path = "creatorPosts/"+userObj.accountID!+"/"+userObj.creatorID!+"/"+images[indexPath.row].key;
        }
        else
        {
            path = "userPosts/"+userObj.accountID!+"/"+userObj.creatorID!+"/"+userObj.uid!+"/"+images[indexPath.row].key;
        }
        let refreshAlert = UIAlertController(title: "DELETE", message: "Do you wish to delete this post?\nNOTE: this cannot be undone.", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        refreshAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
            
            FIRDatabase.database().reference().child(path).removeValue(){ error in
                if error != nil {
                    images.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    print("Handle Yes logic here")
                }else{
                    print(error)
                }
            }
            
            /*let imgToDel = storage.child(userObj.uid).child(images[indexPath.row].imgId)
            imgToDel.delete(completion: { (Error) in
                if let error = Error{
                    print(error)
                }
            })*/
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle No Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        
        
        
    }

}

