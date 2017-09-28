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

class VC_ClickImage: UIViewController {
    
    @IBOutlet weak var btn_delete_lvl3: UIButton!
    @IBOutlet weak var btn_approve_lvl2: UIButton!
    @IBOutlet weak var btn_delete_lvl2: UIButton!
    
    @IBOutlet weak var imgCaption: UITextView!
    @IBOutlet weak var image: UIImageView!
    
    var imgIndex : Int!
    
    override func viewWillAppear(_ animated: Bool) {
        imgCaption.text = images[self.imgIndex].caption!;
    }
    
    override func viewDidLoad() {
 
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround();
        
        SVProgressHUD.setDefaultStyle(.dark)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageSelected(tapGestureRecognizer:)))
        image.addGestureRecognizer(tapGestureRecognizer)
        image.sd_setImage(with: URL(string:images[self.imgIndex].url!))
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
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_viewselectedimg") as! VC_selectedimage;
        vc.imgUrl = images[self.imgIndex].url;
        vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen;
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical;
        self.present(vc, animated: true, completion: nil);
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
            FIRDatabase.database().reference().child(path).removeValue()
            let imgToDel = storage.child(userObj.uid).child(images[self.imgIndex].imgId)
            SVProgressHUD.show(withStatus: "Deleting Post")
            imgToDel.delete(completion: { (Error) in
                SVProgressHUD.dismiss()
                if let error = Error{
                    print(error)
                }
                self.navigationController?.popViewController(animated: true)
                print("Handle Yes logic here")
                
            })
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle No Logic here")
        }))
        present(refreshAlert, animated: true, completion: nil)

    }
    @IBAction func approvePost(_ sender: Any) {
        
        let path = "dashboardPosts/"+userObj.accountID!+"/pending";
        let refreshAlert = UIAlertController(title: "APPROVE", message: "Do you wish to approve this post?\nNOTE: This cannot be undone.", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        refreshAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
            
            FIRDatabase.database().reference().child(path).childByAutoId().setValue([
                "creatorID": images[self.imgIndex].creatorID!, "description": self.imgCaption.text!, "uploadedBy": images[self.imgIndex].uploadedBy!, "url": images[self.imgIndex].url, "approvedBy": userObj.uid!
                ]);
            let updatePath = "creatorPosts/"+userObj.accountID!+"/"+userObj.creatorID!+"/"+images[self.imgIndex].key!;
            FIRDatabase.database().reference().child(updatePath).updateChildValues(["status": "approved"]);
            images[self.imgIndex].dashboardApproved = true;
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
