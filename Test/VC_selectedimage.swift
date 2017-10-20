//
//  VC_selectedimage.swift
//  Test
//
//  Created by Jessica Vilaysak on 21/9/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit

/**
 This class is responsible for dispaying an enlarged version of a
 photograph when the user clicks on it.
 */

class VC_selectedimage: UIViewController {

    var imgUrl : String! // set in previous vc, that is clickImage
    var imgSent: UIImage! // sent image from prev vc
    
    //outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnExit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnExit.isHidden = true; // hide button on load
        
        if (imgUrl != nil)
        {
            imageView.sd_setImage(with: URL(string:imgUrl)) // img url exists so set it
        }
        else // if no url use sent over image to display
        {
            imageView.image = imgSent;
        }
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7) // transparent black bg
        view.isOpaque = false // transparent bg since false
        //Tap gesture setup
        let textViewRecognizer = UITapGestureRecognizer()
        textViewRecognizer.addTarget(self, action: #selector(myTargetFunction))
        imageView.addGestureRecognizer(textViewRecognizer)
    }
    //dismiss vc when tap on image
    @objc private func myTargetFunction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.isOpaque = false
    }
    //dismiss vc if cancel button tapped
    @IBAction func btnExit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
