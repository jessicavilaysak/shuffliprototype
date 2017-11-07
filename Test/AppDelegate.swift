//
//  AppDelegate.swift
//  Test
//
//  Created by Pranav Joshi on 30/3/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import DropDown
import FirebaseMessaging
import FirebaseInstanceID
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure() // Must have this to configure Firebase
        IQKeyboardManager.sharedManager().enable = true
        DropDown.startListeningToKeyboard() // Dropdown handles keyboard events
        
        return true
    }
}

