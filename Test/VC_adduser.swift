//
//  VC_adduser.swift
//  Test
//
//  Created by Pranav Joshi on 21/9/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit

class VC_adduser: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func btn_cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }

}
