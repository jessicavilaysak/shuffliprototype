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

class VC_ClickImage: UIViewController {
    
    @IBOutlet weak var img_playbutton: UIImageView!
    @IBOutlet weak var btn_delete_lvl3: UIButton!
    @IBOutlet weak var btn_approve_lvl2: UIButton!
    @IBOutlet weak var btn_delete_lvl2: UIButton!
    
    @IBOutlet weak var imgCaption: UITextView!
    @IBOutlet weak var image: UIImageView!
    
    var imgIndex : Int!
    var avPlayerViewController = AVPlayerViewController();
    var avPlayer : AVPlayer?;
    
    override func viewWillAppear(_ animated: Bool) {
        imgCaption.text = images[self.imgIndex].caption!;
    }
    
    override func viewDidLoad() {
 
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround();
        
        
        SVProgressHUD.setDefaultStyle(.dark)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageSelected(tapGestureRecognizer:)))
        image.addGestureRecognizer(tapGestureRecognizer)
        var lUrl = images[self.imgIndex].url;
        img_playbutton.isHidden = true;
        if(images[self.imgIndex].thumbnailURL != "")
        {
            lUrl = images[self.imgIndex].thumbnailURL;
            img_playbutton.isHidden = false;
            //-------------code for loading vid------------------
            print("URL");
            print(images[self.imgIndex].url);
            
            let asset = AVAsset(url: URL(string: images[self.imgIndex].url)!);
            let playerItem = AVPlayerItem(asset: asset);
           
            self.avPlayer = AVPlayer(playerItem: playerItem);
            
            self.avPlayerViewController.player = self.avPlayer;
            //-------up til here-----------
        }
        image.sd_setImage(with: URL(string:lUrl!))
        imgCaption.text = images[self.imgIndex].caption!;
        imgCaption.layer.cornerRadius = 4
        
        if(userObj.isAdmin)
        {
            btn_delete_lvl3.isHidden = true;
        }
        else
        {
            btn_approve_lvl2.isHidden = true;
            btn_delete_lvl2.isHidden = true;
        }
        
        performInitialisation();
        
        let textViewRecognizer = UITapGestureRecognizer()
        textViewRecognizer.addTarget(self, action: #selector(myTargetFunction))
        imgCaption.addGestureRecognizer(textViewRecognizer)
        
    }
    
    func imageSelected(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if(images[self.imgIndex].thumbnailURL == "")
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_viewselectedimg") as! VC_selectedimage;
            vc.imgUrl = images[self.imgIndex].url;
            vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen;
            vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical;
            self.present(vc, animated: true, completion: nil);
        }
        else
        {
            self.present(self.avPlayerViewController, animated: true) { () -> Void in
                self.avPlayerViewController.player?.play();
            }
        }
    }
    
    func performInitialisation() {
        
        if(images[self.imgIndex].dashboardApproved)!
        {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: (btn_approve_lvl2.titleLabel?.text)!)
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
            btn_approve_lvl2.titleLabel?.attributedText = attributeString;
            btn_approve_lvl2.isUserInteractionEnabled = false // added this so that simon cant spam the approve button hahah
            imgCaption.textColor = UIColor.lightGray;
            imgCaption.isUserInteractionEnabled = false;
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imgCaption.scrollRangeToVisible(NSMakeRange(0, 0))
    }
    
    @objc private func myTargetFunction() {
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
    
    @IBAction func deletePost(_ sender: Any) {
        var path = ""
        let storage = FIRStorage.storage().reference()
        if(userObj.isAdmin)
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
            FIRDatabase.database().reference().child(path).removeValue()
            if(userObj.isAdmin)
            {
                if(images[self.imgIndex].userPostID != nil)
                {
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
    @IBAction func approvePost(_ sender: Any) {
      
        let refreshAlert = UIAlertController(title: "APPROVE", message: "Do you wish to approve this post?\nNOTE: This cannot be undone.", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        refreshAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
            
            FIRDatabase.database().reference().child("creatorCommands/"+userObj.accountID!+"/"+userObj.creatorID!+"/approvePost").childByAutoId().setValue(["postID": images[self.imgIndex].key, "uid": userObj.uid!]);
            //images[self.imgIndex].dashboardApproved = true;
            SVProgressHUD.showSuccess(withStatus: "Approved!")
            SVProgressHUD.dismiss(withDelay: 2)
            self.performInitialisation();
            print("Handle Yes logic here")
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle No Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
}
