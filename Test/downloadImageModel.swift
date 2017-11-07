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
/**
 Data model which gets all post related info from the database and stores them in variables
 which can be globally accessed through the global object "images" which is an array of type
 imageDataModel.
 **/
struct imageDataModel{
    // Variables to store information from the database
    let key : String!
    let url : String!
    let ref : FIRDatabaseReference? // reference to the database
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
    
    init() { // initialiser setting variables with default values
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
    /**
     - data snapshot initialiser which takes in a firebase snapshot object as a parameter
     and stores the value of that snapshot as an NSDictionary which is then extracted
     from the snapshot's value using the key defined in the database.
     - all keys are hard coded.
     **/
    init(snapshot: FIRDataSnapshot){
        key = snapshot.key
        ref = snapshot.ref
        
        let snapshotValue = snapshot.value as? NSDictionary
        
        //Getting and setting all database values in local variables

        if let imageURL = snapshotValue?["url"] as? String{ // download url of image
            url = imageURL
        }else{
            url = ""
        }
        if let imageCaption = snapshotValue?["description"] as? String{ // post captions
            caption = imageCaption
        }else{
            caption = ""
        }
        if let imageStatus = snapshotValue?["status"] as? String{ // post approve status
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
        if let lCreatorID = snapshotValue?["creatorID"] as? String{ // post creator ID
            creatorID = lCreatorID;
        }else{
            creatorID = "";
        }
        if let lUploadedBy = snapshotValue?["uploadedBy"] as? String{
            uploadedBy = lUploadedBy;
        }else{
            uploadedBy = "";
        }
        if let lApprovedBy = snapshotValue?["approvedBy"] as? String{ // ID of person who approved the post (if any)
            approvedBy = lApprovedBy;
        }else{
            approvedBy = "";
        }
        if let lImgId = snapshotValue?["imageUid"] as? String{ // UID of image
            imgId = lImgId;
        }else{
            imgId = "";
        }
        if let lUserPostID = snapshotValue?["userPostID"] as? String{ // ID of person who created the post
            userPostID = lUserPostID;
        }else{
            userPostID = "";
        }
        if let lThumbnailUID = snapshotValue?["thumbnailUID"] as? String{ // UID of video thumbnail image
            thumbnailUID = lThumbnailUID;
        }else{
            thumbnailUID = "";
        }
        if let lThumbnailURL = snapshotValue?["thumbnailURL"] as? String{ // video thumbnail download URL
            thumbnailURL = lThumbnailURL;
        }else{
            thumbnailURL = "";
        }
        
        if let lCreatedDate = snapshotValue?["createdDate"] as? Double{ // the date the post was created
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
        if let lApprovedDate = snapshotValue?["approvedDate"] as? Double{ // the date the post was approved
            print("approveDate..........................................");
            timeUnixApproved = lApprovedDate
            let date = moment(lApprovedDate).fromNow();
            print(key+" "+date)
            approvedDate = date
            
        }else{
            approvedDate = nil;
            timeUnixApproved = 0.0
        }
        if let lCategory = snapshotValue?["category"] as? String{ // cateegory of the post as selected by the user
            category = lCategory;
        }else{
            category = "-";
        }
    }
    
}


var images = [imageDataModel]() // global variable

