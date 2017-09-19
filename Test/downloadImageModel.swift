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
    let dashboardApproved : Bool!
    let creatorID: String!
    let uploadedBy: String!
    let approvedBy: String!
    
    
    init() {
        self.key = nil
        self.url = nil
        self.ref = nil
        self.caption = nil
        self.dashboardApproved = false;
        self.creatorID = nil;
        self.uploadedBy = nil;
        self.approvedBy = nil;
    }
    
    init(snapshot: FIRDataSnapshot){
        key = snapshot.key
        ref = snapshot.ref
        
        
        let snapshotValue = snapshot.value as? NSDictionary
        print(snapshotValue!);
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
        if let imageStatus = snapshotValue?["status"] as? String{
            if(imageStatus == "approved")
            {
                dashboardApproved = true;
            }
            else
            {
                dashboardApproved = false;
            }
        }else{
            dashboardApproved = false;
        }
        if let lCreatorID = snapshotValue?["creatorID"] as? String{
            creatorID = lCreatorID;
        }else{
            creatorID = "";
        }
        if let lUploadedBy = snapshotValue?["uploadedBy"] as? String{
            uploadedBy = lUploadedBy;
        }else{
            uploadedBy = "";
        }
        if let lApprovedBy = snapshotValue?["approvedBy"] as? String{
            approvedBy = lApprovedBy;
        }else{
            approvedBy = "";
        }
    }
    
}
