//
//  downloadImageModel.swift
//  Test
//
//  Created by Pranav Joshi on 28/8/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftMoment

struct imageDataModel{
    
    let key : String!
    let url : String!
    let ref : FIRDatabaseReference?
    var caption : String!
    var dashboardApproved : Bool!
    var approvedDate: String!;
    let creatorID: String!
    let uploadedBy: String!
    let createdDate: String!;
    let approvedBy: String!
    let imgId: String!
    var userPostID : String!
    var thumbnailURL: String!;
    var thumbnailUID: String!;
    var timer: Timer!
    var timeUnixApproved: Double!
    var timeUnixCreated: Double!
    var category: String!;
    
    init() {
        self.key = nil
        self.url = nil
        self.ref = nil
        self.caption = nil
        self.dashboardApproved = false;
        self.approvedDate = nil;
        self.creatorID = nil;
        self.uploadedBy = nil;
        self.createdDate = nil;
        self.approvedBy = nil;
        self.imgId = nil;
        self.userPostID = nil;
        self.thumbnailURL = nil;
        self.thumbnailUID = nil;
        self.timeUnixApproved = nil;
        self.timeUnixCreated = nil;
        self.category = nil;
    }
    
    init(snapshot: FIRDataSnapshot){
        key = snapshot.key
        ref = snapshot.ref
        
        
        let snapshotValue = snapshot.value as? NSDictionary
        //print(snapshotValue!);
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
        if let lImgId = snapshotValue?["imageUid"] as? String{
            imgId = lImgId;
        }else{
            imgId = "";
        }
        if let lUserPostID = snapshotValue?["userPostID"] as? String{
            userPostID = lUserPostID;
        }else{
            userPostID = "";
        }
        if let lThumbnailUID = snapshotValue?["thumbnailUID"] as? String{
            thumbnailUID = lThumbnailUID;
        }else{
            thumbnailUID = "";
        }
        if let lThumbnailURL = snapshotValue?["thumbnailURL"] as? String{
            thumbnailURL = lThumbnailURL;
        }else{
            thumbnailURL = "";
        }
        
        if let lCreatedDate = snapshotValue?["createdDate"] as? Double{
            print("createdDate..........................................");
            print(lCreatedDate);
            timeUnixCreated = lCreatedDate;
            let date = moment(lCreatedDate).fromNow();
            print(date)
            createdDate = date
        }else{
            timeUnixCreated = 0.0;
            createdDate = nil;
        }
        if let lApprovedDate = snapshotValue?["approvedDate"] as? Double{
            print("approveDate..........................................");
            timeUnixApproved = lApprovedDate
            let date = moment(lApprovedDate).fromNow();
            print(key+" "+date)
            approvedDate = date
            
        }else{
            approvedDate = nil;
            timeUnixApproved = 0.0
        }
        if let lCategory = snapshotValue?["category"] as? String{
            category = lCategory;
        }else{
            category = "-";
        }
    }
    
}


var images = [imageDataModel]()









/*
 newdate = Date(timeIntervalSince1970: lCreatedDate);
 formatter = DateFormatter();
 formatter.timeStyle = DateFormatter.Style.medium;
 formatter.dateStyle = DateFormatter.Style.medium;
 formatter.timeZone = TimeZone.current;
 formatter.doesRelativeDateFormatting = true;
 createdDate = formatter.string(from: newdate)
 print(createdDate);
 */


/*
 newdate = Date(timeIntervalSince1970: lApprovedDate);
 formatter = DateFormatter();
 formatter.timeStyle = DateFormatter.Style.medium;
 formatter.dateStyle = DateFormatter.Style.medium;
 formatter.timeZone = TimeZone.current;
 formatter.doesRelativeDateFormatting = true;
 approvedDate = formatter.string(from: newdate)
 print(approvedDate);*/
