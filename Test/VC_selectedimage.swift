//
//  VC_selectedimage.swift
//  Test
//
//  Created by Jessica Vilaysak on 21/9/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit

class VC_selectedimage: UIViewController {

    var imgUrl : String!
    var imgSent: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnExit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnExit.isHidden = true;
        
        if (imgUrl != nil)
        {
            imageView.sd_setImage(with: URL(string:imgUrl))
        }
        else
        {
            imageView.image = imgSent;
        }
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.isOpaque = false
        
        let textViewRecognizer = UITapGestureRecognizer()
        textViewRecognizer.addTarget(self, action: #selector(myTargetFunction))
        imageView.addGestureRecognizer(textViewRecognizer)
    }
    
    @objc private func myTargetFunction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.isOpaque = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnExit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
