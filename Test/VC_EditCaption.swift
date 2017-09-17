//
//  VC_EditCaption.swift
//  Test
//
//  Created by Jessica Vilaysak on 17/9/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit

class VC_EditCaption: UIViewController {

   
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var buttonUpdate: UIButton!
    
    var lCaption : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround();
       
        caption.layer.cornerRadius = 4
        buttonUpdate.layer.cornerRadius = 4
        caption.text = lCaption!;
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        caption.scrollRangeToVisible(NSMakeRange(0, 0))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnUpdate(_ sender: Any) {
        print("pressed!");
    }

}
