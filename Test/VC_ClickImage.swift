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
    
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imgCaption: UILabel!
    
    var imagesDv : String?
    var captionDv : String?
    
    override func viewDidLoad() {
        //self.navigationController?.isNavigationBarHidden = false;
        super.viewDidLoad()
        image.sd_setImage(with: URL(string:imagesDv!))
        imgCaption.text = captionDv
        
        imgCaption.layer.cornerRadius = 4
        

        
    }
    
    
    
    @IBAction func btn_backToImages(_ sender: Any) {
        
        self.navigationController?.popToRootViewController(animated: true);
    }
}
