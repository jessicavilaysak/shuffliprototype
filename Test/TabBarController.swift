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

/*
 - This class is used to instantiate the application with VCs.
 - The VCs are determined by the current user's permissions.
 */
class TabBarController: UITabBarController {

    var selectedControllerId : String?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        //Creates the 'manager users' VC.
        let nav_manageusers = UINavigationController()
        let first: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "VC_manageusers")
        nav_manageusers.viewControllers = [first]
        nav_manageusers.setNavigationBarHidden(true, animated: true)
        nav_manageusers.title = "VC_manageusers"
        
        //Creates the 'create post' VC.
        let nav_createpost = UINavigationController()
        var second: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "VC_createpost");
        nav_createpost.viewControllers = [second]
        nav_createpost.setNavigationBarHidden(true, animated: true)
        nav_createpost.title = "VC_createpost"
        
        //Creates the 'view posts' VC.
        let nav_viewposts = UINavigationController();
        let third: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "VC_viewposts")
        nav_viewposts.viewControllers = [third]
        nav_viewposts.setNavigationBarHidden(true, animated: true)
        nav_viewposts.title = "VC_viewposts";
    
        //These conditions decide which VCs to show the user.
        if(userObj.isAdmin && userObj.permissionToManageUsers)
        {
            self.viewControllers = [nav_manageusers, nav_viewposts, nav_createpost]
        }
        else
        {
            self.viewControllers = [nav_viewposts, nav_createpost]
        }
        
        /*
         - If for whatever reason a VC would like to be selected as default
         this can be done by setting the 'selectedControllerId' variable before presenting this VC.
         */
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
    
    /*
     - Function 'registerPushNotification' asks for permission from the user.
     - If user has already granted permission then a token for this device is obtained
     and sent to firebase to be stored.
     */
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
    
    /*
     - Retrieves token for this device to be used when sending push notifications.
     */
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
