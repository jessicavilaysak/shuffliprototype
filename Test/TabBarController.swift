//
//  TabBarController.swift
//  Test
//
//  Created by Jessica Vilaysak on 22/8/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    var selectedControllerId : String?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let nav_manageusers = UINavigationController()
        let first: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "VC_manageusers")
        nav_manageusers.viewControllers = [first]
        nav_manageusers.setNavigationBarHidden(true, animated: true)
        nav_manageusers.title = "VC_manageusers"
        
        let nav_createpost = UINavigationController()
        let second: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "VC_createpost")
        nav_createpost.viewControllers = [second]
        nav_createpost.setNavigationBarHidden(true, animated: true)
        nav_createpost.title = "VC_createpost"
        
        let nav_viewposts = UINavigationController();
        let third: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "VC_viewposts")
        nav_viewposts.viewControllers = [third]
        nav_viewposts.setNavigationBarHidden(true, animated: true)
        nav_viewposts.title = "VC_viewposts";
    
        
        if(userObj.isAdmin && userObj.permissionToManageUsers)
        {
            self.viewControllers = [nav_manageusers, nav_viewposts, nav_createpost]
        }
        else
        {
            self.viewControllers = [nav_viewposts, nav_createpost]
        }
        
        if(selectedControllerId != nil)
            
        {
            let c = self.viewControllers?.count;
            for i in 0...((c)!-1) {
                
                let t = self.viewControllers?[i].title;
                if(t == selectedControllerId)
                {
                    self.selectedViewController = self.viewControllers?[i];
                    break;
                }
            }
            
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
