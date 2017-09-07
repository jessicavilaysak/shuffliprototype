//
//  downloadImageModel.swift
//  Test
//
//  Created by Pranav Joshi on 28/8/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct imageDataModel{
    
    let key : String!
    let url : String!
    let ref : FIRDatabaseReference?
    let caption : String!
    
    init(key : String, url: String, caption: String) {
        self.key = key
        self.url = url
        self.ref = nil
        self.caption = caption
        
    }
    
    init(snapshot: FIRDataSnapshot){
        key = snapshot.key
        ref = snapshot.ref
        
        
        let snapshotValue = snapshot.value as? NSDictionary
        
        if let imageURL = snapshotValue?["url"] as? String{
            url = imageURL
        }else{
            url = ""
        }
        if let imageCaption = snapshotValue?["description"] as? String{
            caption = imageCaption
        }else{
            caption = ""
        }
    }
    
}
