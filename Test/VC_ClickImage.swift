//
//  VC_CellToVCViewController.swift
//  Test
//
//  Created by Pranav Joshi on 2/9/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseDatabase
import SVProgressHUD
import FirebaseStorage
import AVFoundation
import AVKit
import SwiftMoment
import FontAwesome_swift

/**
     This class is responsible for displaying the post from the view post VC and additional information about the post such as created by, approved by (if an admin account), delete post or approve post if post has not been approved(if admin account).
 */
class VC_ClickImage: UIViewController {
    // Outlets
    @IBOutlet weak var img_playbutton: UIImageView!
    @IBOutlet weak var btn_delete_lvl3: UIButton!
    @IBOutlet weak var btn_approve_lvl2: UIButton!
    @IBOutlet weak var btn_delete_lvl2: UIButton!
    @IBOutlet weak var approvedSymbol: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var approvedDateLabel: UILabel!
    @IBOutlet weak var imgCaption: UITextView!
    @IBOutlet weak var image: UIImageView!
    //variables
    var imgIndex : Int! // indexpath set in viewposts vc
    var avPlayerViewController = AVPlayerViewController();
    var avPlayer : AVPlayer?;
    var timer: Timer?
    var createdBy: String!;
    var approvedBy: String!;
    
    override func viewDidLoad() {
 
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround();
        
        
        SVProgressHUD.setDefaultStyle(.dark)
        
         timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true) // TIMER
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageSelected(tapGestureRecognizer:))) // detects taps and calls the call back function
        image.addGestureRecognizer(tapGestureRecognizer) // set the gesture for the image
        
        var lUrl = images[self.imgIndex].url; //get url
        img_playbutton.isHidden = true; // hide button on load
        if(images[self.imgIndex].thumbnailURL != "") // chekcing if video by looking at thumbnail URL
        {
            lUrl = images[self.imgIndex].thumbnailURL; // get the video thumbnail URL
            img_playbutton.isHidden = false; // show the play button 
            //-------------code for loading vid------------------
            print("URL");
            print(images[self.imgIndex].url);
            
            let asset: NSURL? = NSURL(string: images[self.imgIndex].url!) // get the video url
            
            if let url = asset{// conditional binding
                self.avPlayer = AVPlayer(url: url as URL); // feed the avplayer with video URL
                self.avPlayerViewController.player = self.avPlayer; // launch avplayer vc
            }
            //-------up til here-----------
        }
        image.sd_setImage(with: URL(string:lUrl!)) // using SDWebimages to set the image because image URL is cached
        imgCaption.text = images[self.imgIndex].caption!; // get the caption from index
        imgCaption.layer.cornerRadius = 4
        
        
        
        performInitialisation(); // display or hide certain UI elements according to account type
        
        let textViewRecognizer = UITapGestureRecognizer() // gesture recognizer
        textViewRecognizer.addTarget(self, action: #selector(myTargetFunction))
        imgCaption.addGestureRecognizer(textViewRecognizer)
        
        
        imgCaption.text = images[self.imgIndex].caption!; // set text by looking up in array for index path
        if images[self.imgIndex].category != ""{ // check if category exits for the post
            categoryLabel.font = UIFont.fontAwesome(ofSize: 15)
            categoryLabel.text = String.fontAwesome(code: "fa-tag")!.rawValue + "  "+images[self.imgIndex].category;
        }else{ // no category so hide label
            categoryLabel.isHidden = true
        }
        let userDataGroup = DispatchGroup() // grouping async calls
        userDataGroup.enter() // enter calls
         FIRDatabase.database().reference().child("users/"+images[self.imgIndex].uploadedBy!).observeSingleEvent(of: .value, with: { (snapshot) in // obeserver
            let recent = snapshot.value as!  NSDictionary
            print(recent);
            
            if(recent["username"] != nil)
            {
                let username = (recent["username"] as? String)!; // get username from db
                self.createdBy = username; // set the post creators user name
                print("uploadedBy: "+username);
            }
            userDataGroup.leave(); // leave group
        })
        if(images[self.imgIndex].approvedBy != nil) // has post been approved?
        {
            // post approved
            userDataGroup.enter() // enter group
            FIRDatabase.database().reference().child("users/"+images[self.imgIndex].approvedBy!).observeSingleEvent(of: .value, with: { (snapshot) in
                let recent = snapshot.value as!  NSDictionary
                print(recent);
                if(recent["username"] != nil)
                {
                    let lApproved = (recent["username"] as? String)!; // get username of the user who approved the post
                    self.approvedBy = lApproved; //set
                    print("approvedBy: "+lApproved)
                }
                userDataGroup.leave(); // leave group
            })
        }
        userDataGroup.notify(queue: .main) {
            self.updateTime(); // update time
        }
    }
    
    func updateTime(){  // timer call back function, executed every 10 secs
        
        if(images[imgIndex].createdDate != nil) // created date exists
        {
            let createdDate = moment(images[imgIndex].timeUnixCreated).fromNow().lowercased() // get unix timestamp and pass it to moment library which calcs time passed
            print("createdDate");
            print(images[imgIndex].timeUnixCreated);
            print(createdDate);
            createdDateLabel.font = UIFont.fontAwesome(ofSize: 15)
            var createdText = String.fontAwesome(code: "fa-clock-o")!.rawValue + "  " + createdDate+"  "; // set lbl
            if(userObj.isAdmin) // check account type
            {
                createdText += String.fontAwesome(code: "fa-user-o")!.rawValue+"  "+createdBy!;
            }
            createdDateLabel.text = createdText;
        }
        if(images[imgIndex].approvedDate != nil) // if post date approval exists
        {
            let approvedDate = moment(images[imgIndex].timeUnixApproved).fromNow().lowercased()
            print("approvedDate");
            print(images[imgIndex].timeUnixApproved);
            print(approvedDate);
            approvedDateLabel.font = UIFont.fontAwesome(ofSize: 15)
            var approvedText = String.fontAwesome(code: "fa-check-square-o")!.rawValue + "  "+approvedDate;
            if(approvedBy != nil)
            {
                approvedText += "  "+String.fontAwesome(code: "fa-user-o")!.rawValue+"  "+approvedBy!; // set
            }
            approvedDateLabel.text = approvedText;
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate() // stop timer
    }
    
    func imageSelected(tapGestureRecognizer: UITapGestureRecognizer) // tap gesture call back function
    {
        if(images[self.imgIndex].thumbnailURL == "") // if image
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_viewselectedimg") as! VC_selectedimage;
            vc.imgUrl = images[self.imgIndex].url;
            vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen;
            vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical;
            self.present(vc, animated: true, completion: nil);
        }
        else // if video
        {
            self.present(self.avPlayerViewController, animated: true) { () -> Void in
                self.avPlayerViewController.player?.play();
            }
        }
    }
    
    func performInitialisation() {
        
        
        if(userObj.isAdmin) // check if account type is admin
        {
            // account type is admin so display Admin UI elements and hide some "creator" UI elements
            btn_delete_lvl3.isHidden = true;
            createdDateLabel.isHidden = false
            if images[self.imgIndex].dashboardApproved{ // checking post approved status
                approvedSymbol.isHidden = false
                approvedDateLabel.isHidden = false
                btn_approve_lvl2.isUserInteractionEnabled = false
                imgCaption.textColor = UIColor.lightGray;
                imgCaption.isUserInteractionEnabled = false;
                
            }else{ // post not approved
                btn_approve_lvl2.setTitle("Approve", for: .normal)
                approvedSymbol.isHidden = true
                approvedDateLabel.isHidden = true
                
            }
        }
        else // not admin
        {
            btn_approve_lvl2.isHidden = true;
            btn_delete_lvl2.isHidden = true;
            approvedSymbol.isHidden = true;
            approvedDateLabel.isHidden = true
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imgCaption.scrollRangeToVisible(NSMakeRange(0, 0))
    }
    
    @objc private func myTargetFunction() { // editing caption
        print("testing ?");
        let refreshAlert = UIAlertController(title: "EDIT", message: "Do you wish to edit this caption?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_editcaption") as! VC_EditCaption;
            
            vc.imgIndex = self.imgIndex;
            
            self.navigationController?.pushViewController(vc, animated: true);
            print("Handle Yes logic here")
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle No Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)

    }
    
    @IBAction func deletePost(_ sender: Any) { // delete post from the users account
        var path = ""
        let storage = FIRStorage.storage().reference() // get storage reference
        if(userObj.isAdmin) // set path according to account type
        {
            path = "creatorPosts/"+userObj.accountID!+"/"+userObj.creatorID!+"/"+images[self.imgIndex].key;
        }
        else
        {
            path = "userPosts/"+userObj.accountID!+"/"+userObj.creatorID!+"/"+userObj.uid!+"/"+images[self.imgIndex].key;
        }
        let refreshAlert = UIAlertController(title: "DELETE", message: "Do you wish to delete this post?\nNOTE: this cannot be undone.", preferredStyle: UIAlertControllerStyle.actionSheet)
        refreshAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
            SVProgressHUD.show(withStatus: "Deleting Post")
            FIRDatabase.database().reference().child(path).removeValue() // delete from firebase
            if(userObj.isAdmin)
            {
                if(images[self.imgIndex].userPostID != nil)
                {// remove from user posts node
                    FIRDatabase.database().reference().child("userPosts/"+userObj.accountID!+"/"+userObj.creatorID!+"/"+images[self.imgIndex].uploadedBy+"/"+images[self.imgIndex].userPostID).removeValue();
                }
                if(!images[self.imgIndex].dashboardApproved)
                {
                    storage.child(images[self.imgIndex].uploadedBy).child(images[self.imgIndex].imgId).delete();
                    storage.child(images[self.imgIndex].uploadedBy).child("thumb_"+images[self.imgIndex].imgId).delete();
                }
            }
            SVProgressHUD.dismiss()
            self.navigationController?.popViewController(animated: true)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle No Logic here")
        }))
        present(refreshAlert, animated: true, completion: nil)
        
    }
    @IBAction func approvePost(_ sender: Any) { // handle post approval
      
        let refreshAlert = UIAlertController(title: "APPROVE", message: "Do you wish to approve this post?\nNOTE: This cannot be undone.", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        refreshAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
            
            FIRDatabase.database().reference().child("creatorCommands/"+userObj.accountID!+"/"+userObj.creatorID!+"/approvePost").childByAutoId().setValue(["postID": images[self.imgIndex].key, "uid": userObj.uid!]);// set database approve post status 
            //images[self.imgIndex].dashboardApproved = true;
            SVProgressHUD.showSuccess(withStatus: "Approved!")
            SVProgressHUD.dismiss(withDelay: 2)
            self.performInitialisation();
            self.navigationController?.popViewController(animated: true);
            print("Handle Yes logic here")
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle No Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
}

