//
//  TabBarController.swift
//  Test
//
//  Created by Jessica Vilaysak on 22/8/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseInstanceID
import FirebaseMessaging
import UserNotifications
import SDWebImage

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
        var second: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "VC_createpost");
        
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
        
        let application = UIApplication.shared
        registerPushNotification(application)
    }
    
    func registerPushNotification(_ application: UIApplication){
        
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in
            
            if granted {
                print("Notification: Granted")
                application.registerForRemoteNotifications()
                // [START add_token_refresh_observer]
                // Add observer for InstanceID token refresh callback.
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(self.tokenRefreshNotification),
                                                       name: .firInstanceIDTokenRefresh,
                                                       object: nil)
                // [END add_token_refresh_observer]
                self.tokenRefreshNotification();
                
            } else {
                print("Notification: not granted")
                
            }
        }
    }
    
    func tokenRefreshNotification() {
        // NOTE: It can be nil here
        let refreshedToken = FIRInstanceID.instanceID().token()
        if(refreshedToken != nil)
        {
            if(userObj.fcmToken != refreshedToken)
            {
                print("InstanceID tokenn: \(refreshedToken)")
                FIRDatabase.database().reference().child("creatorCommands/"+userObj.accountID!+"/"+userObj.creatorID!+"/updateFcmToken/"+userObj.uid!).setValue(["token": refreshedToken]);
                userObj.fcmToken = refreshedToken;
            }
            else
            {
                print("manage users | userObj: "+userObj.fcmToken+", token: "+refreshedToken!);
            }
            
        }
    }
}
