//
//  Datasource.swift
//  Test
//
//  Created by Jessica Vilaysak on 10/5/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit

class Datasource {
    
    var username: String!
    var userArray : [String] = ["temp_user_00", "temp_user_01", "temp_user_02", "temp_user_03", "temp_user_04", "temp_user_05"]
    var currentCount: Int!
    var userNotifications: Int!;
    var postsobj : [(image: UIImage, caption: String)] = [(image: UIImage(named: "1")!, caption: "What a beautiful day"),
                                                          (image: UIImage(named: "2")!, caption: "What a total uggo"),
                                                          (image: UIImage(named: "3")!, caption: "I love this!!")
    ]
    //var postsobj : [(image: UIImage, caption: String)] = []
    var tempPosts : [String] = ["1", "2", "3", "4"]
    var postNotifications: Int!;
    var acceptedPayment: Bool!;
    
    init() {
        
        currentCount = 3
        postNotifications = 0;
        acceptedPayment = false;
        userNotifications = 0;
    }
    
    
}
let dataSource = Datasource()


