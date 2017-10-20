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
import FirebaseMessaging
import FirebaseInstanceID
import UserNotifications
import FontAwesome_swift
import SwiftMoment

/**
 This class is responsible for displaying the user's previous posts or show the admin its user's post.
 The class also handles logout for a creator account and displays users account info
 */
class VC_Creator_Viewposts: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //outlets
    @IBOutlet weak var creatorImg: UIImageView!
    @IBOutlet var viewposts: UITableView!
    @IBOutlet weak var logOut: UIBarButtonItem!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet var fldcompany: UILabel!
    @IBOutlet weak var fldcreator: UILabel!
    @IBOutlet var fldusername: UILabel!
    
    //variables
    var handle: FIRAuthStateDidChangeListenerHandle!
    var signingOut: Bool!
    var timer: Timer?
    
  
    
    override func viewDidLoad() {
        
        signingOut = false;
        self.navigationController?.isNavigationBarHidden = false; //dont hide nav bar
        super.viewDidLoad()
        
        viewposts.delegate = self;
        viewposts.dataSource = self;
        //User account info details
        fldcompany.font = UIFont.fontAwesome(ofSize: 14)
        fldcompany.text = String.fontAwesome(code: "fa-users")!.rawValue + " " + userObj.accountName;
        fldcreator.font = UIFont.fontAwesome(ofSize: 14)
        fldcreator.text = String.fontAwesome(code: "fa-paint-brush")!.rawValue + " " + userObj.creatorName;
        fldusername.font = UIFont.fontAwesome(ofSize: 16)
        fldusername.text = String.fontAwesome(code: "fa-user-circle-o")!.rawValue + " " + userObj.username;
        
        self.hideKeyboardWhenTappedAround(); // hide keyboard when tapped anywhere on vc
    
        SVProgressHUD.setDefaultStyle(.dark)
        //get creator image account picture
        creatorImg.sd_setShowActivityIndicatorView(true)
        creatorImg.sd_setIndicatorStyle(.gray)
        if(userObj.creatorURL != nil)
        {
            creatorImg.sd_setImage(with: URL(string: userObj.creatorURL!)) //sets the picture here
        }
        
        //Rounded profile picture
        creatorImg.layer.cornerRadius = creatorImg.frame.size.width/2;
        creatorImg.clipsToBounds = true; // no overflow
        creatorImg.layer.borderWidth = 3.0
        creatorImg.layer.borderColor = UIColor.lightGray.cgColor
        //Creating a shadow
        bgImage.layer.masksToBounds = false
        bgImage.layer.shadowColor = UIColor.black.cgColor
        bgImage.layer.shadowOffset = CGSize(width: 1.0, height:1.0)
        bgImage.layer.shadowOpacity = 0.5
        bgImage.layer.shadowRadius = 10;
        bgImage.layer.shouldRasterize = true //tells IOS to cache the shadow
        // Observe for newposts and append to images array global object
        FIRDatabase.database().reference(withPath: userObj.listenerPath).observe(FIRDataEventType.value, with: {(snapshot) in
            //print(snapshot)
            var newImages = [imageDataModel]() // local var
            
            for imageSnapshot in snapshot.children{ // iteration through db nodes
                let imgObj = imageDataModel(snapshot: imageSnapshot as! FIRDataSnapshot) // provide custom constructor with snapshot parameter
            
                newImages.insert(imgObj, at: 0); // append to local array at first index
            }
            images = newImages; // assign global var with local array value
            print("SHUFFLI | path: "+userObj.listenerPath+" | images count: "+String(images.count));
            //print(self.images);
           self.viewposts.reloadData() // reload table data
            
        })
        
    }
    
    /*
     * This function will update each row every 10 seconds.
     */
    func updateRows() // for updating the time lbls every 10 seconds
    {
        print("updateTime()");
        let numberOfRows = viewposts.numberOfRows(inSection: 0);
        var iterator = 0;
        while(iterator < numberOfRows)
        {
            let indexPath = IndexPath(item: iterator, section: 0)
            viewposts.reloadRows(at: [indexPath], with: .none) // reload table data without animation
            iterator = iterator+1;
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //starting timer
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.updateRows), userInfo: nil, repeats: true) // TIMER
        
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
        // hide or display logout depending on account type
        if userObj.permissionToManageUsers {
            logOut.title = ""
            logOut.isEnabled = false
        }else{
            logOut.title = "Log Out"
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count // return number of elements in the array
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.viewposts.dequeueReusableCell(withIdentifier: "cellCreator", for: indexPath as IndexPath) as! CustomCellCreator // cell reuse
        
        if indexPath.row < images.count
        {
            let image = images[indexPath.row] // set current image depeding on indexpath
            
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
            //show image loading indicator
            cell.photo.sd_setShowActivityIndicatorView(true)
            cell.photo.sd_setIndicatorStyle(.gray)
            var lUrl = image.url;
            cell.playButton.isHidden = true;
            
            if(image.thumbnailURL != "") // if not nill then display the play button
            {
                lUrl = image.thumbnailURL; // thumbnail download url
                cell.playButton.isHidden = false; // show play btn
            }
            cell.photo.sd_setImage(with: URL(string: lUrl!),placeholderImage: UIImage(named: "placeholder")) //set image or thmbnail image with video button
            cell.imageCaption.text = image.caption; // set caption
            cell.imageCaption.textColor = UIColor.white
            cell.dateLabel.font = UIFont.fontAwesome(ofSize: 12) //setup for awesome font
            if image.createdDate == nil{ // handle empty time due to lag in server function
                cell.dateLabel.text = ""
            }else{
                let timeCreated = moment(image.timeUnixCreated).fromNow().lowercased()// get time created
                var dateLabel = String.fontAwesome(code: "fa-clock-o")!.rawValue + "  " + timeCreated; //display time
                if(image.approvedDate != nil) //check if approve date exists
                {
                    let timeApproved = moment(image.timeUnixApproved).fromNow().lowercased() // approved time
                    dateLabel += "  "+String.fontAwesome(code: "fa-check-square-o")!.rawValue + "  "+timeApproved;
                }
                cell.dateLabel.text = dateLabel; //set cells date label
            }
        }
        return cell
}
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear");
        super.viewWillDisappear(animated)
        //stopping timer when view disappears
        timer?.invalidate();
        timer = nil;
        if(signingOut)
        {
            // [START remove_auth_listener]
            FIRAuth.auth()?.removeStateDidChangeListener(handle!)
            FIRDatabase.database().reference(withPath: userObj.listenerPath).removeAllObservers();
            FIRDatabase.database().reference(withPath: userObj.manageuserPath).removeAllObservers();
            userObj.resetObj();
            usersUIDs = Array<String>();
            images = [imageDataModel]()
            print("SHUFFLI | signed out.");
            SVProgressHUD.showSuccess(withStatus: "Logged out!");
            SVProgressHUD.dismiss(withDelay: 1);
            // [END remove_auth_listener]
        }
        
    }
    
    @IBAction func logout(_ sender: Any) { // handle logout, check other vc for comments
        
        let refreshAlert = UIAlertController(title: "", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        refreshAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
            FIRDatabase.database().reference().child("creatorCommands/"+userObj.accountID!+"/"+userObj.creatorID!+"/deleteFcmToken/"+userObj.uid!).setValue(["delete":"true"]);
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // row selected in table
 
        let vc = storyboard?.instantiateViewController(withIdentifier: "VC_clickimage") as! VC_ClickImage; // create vc
        vc.imgIndex = indexPath.row; // set clickImage vc's indexpath
        self.navigationController?.pushViewController(vc, animated: true); // show vc using navigation controller
    }
    
}

