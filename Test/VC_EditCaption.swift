//
//  VC_EditCaption.swift
//  Test
//
//  Created by Jessica Vilaysak on 17/9/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SVProgressHUD

class VC_EditCaption: UIViewController {

   
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var buttonUpdate: UIButton!
    
    var imgIndex : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround();
       
        caption.layer.cornerRadius = 4
        buttonUpdate.layer.cornerRadius = 4
        caption.text = images[imgIndex].caption!;
        SVProgressHUD.setDefaultStyle(.dark)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        caption.scrollRangeToVisible(NSMakeRange(0, 0))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnUpdate(_ sender: Any){
        var currentCaption = caption.text!
        print("current: "+currentCaption);
        var path = ""
        if(userObj.isAdmin)
        {
            path = "creatorPosts/"+userObj.accountID!+"/"+userObj.creatorID!+"/"+images[self.imgIndex].key!;
        }
        else
        {
            path = "userPosts/"+userObj.accountID!+"/"+userObj.creatorID!+"/"+userObj.uid!+"/"+images[self.imgIndex].key!;
        }
        print("path: "+path);
        FIRDatabase.database().reference().child(path).updateChildValues(["description": currentCaption])
        
        FIRDatabase.database().reference().child(path).observeSingleEvent(of: .value , with: { snapshot in
            
            if snapshot.exists() {
                
                let check = snapshot.value as!  NSDictionary
                let desc = (check["description"] as? String)!;
                if(desc == currentCaption)
                {
                    SVProgressHUD.showSuccess(withStatus: "Updated!")
                    SVProgressHUD.dismiss(withDelay: 2)
                    images[self.imgIndex].caption = currentCaption;
                }
                else
                {
                    SVProgressHUD.showSuccess(withStatus: "Could not update, please try again later.")
                    SVProgressHUD.dismiss(withDelay: 2)
                }
            }});

    }

}
