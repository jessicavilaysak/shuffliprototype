//
//  VC_CellToVCViewController.swift
//  Test
//
//  Created by Pranav Joshi on 2/9/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import SDWebImage

class VC_ClickImage: UIViewController {
    
    @IBOutlet weak var btn_delete_lvl3: UIButton!
    @IBOutlet weak var btn_approve_lvl2: UIButton!
    @IBOutlet weak var btn_delete_lvl2: UIButton!
    
    @IBOutlet weak var imgCaption: UITextView!
    @IBOutlet weak var image: UIImageView!
    
    var imagesDv : String?
    var captionDv : String?
    var dashboardApproved : Bool?
    
    override func viewDidLoad() {
 
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround();
        
        image.sd_setImage(with: URL(string:imagesDv!))
        imgCaption.text = captionDv
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
        
        if(dashboardApproved)!
        {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: (btn_approve_lvl2.titleLabel?.text)!)
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
            btn_approve_lvl2.titleLabel?.attributedText = attributeString;
            imgCaption.textColor = UIColor.lightGray;
        }
        
        let textViewRecognizer = UITapGestureRecognizer()
        textViewRecognizer.addTarget(self, action: #selector(myTargetFunction))
        imgCaption.addGestureRecognizer(textViewRecognizer)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imgCaption.scrollRangeToVisible(NSMakeRange(0, 0))
    }
    
    func buttonPressed() {
        print("buttonPressed!")

    }
    
    @objc private func myTargetFunction() {
        print("testing ?");
        let refreshAlert = UIAlertController(title: "EDIT CAPTION", message: "Do you wish to edit this caption?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_editcaption") as! VC_EditCaption;
            
            vc.lCaption = self.imgCaption.text;
            
            self.navigationController?.pushViewController(vc, animated: true);
            print("Handle Yes logic here")
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle No Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)

    }
}
