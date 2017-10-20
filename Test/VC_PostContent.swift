//
//  ViewControllerPost.swift
//  Test
//
//  Created by Pranav Joshi on 11/5/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//


/*
 * Copyright (C) 2015 - 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SVProgressHUD
import DropDown
import MobileCoreServices
import AssetsLibrary
import AVFoundation
import Photos

class VC_PostContent: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var btn_chooseCategory: UIButton!
    @IBOutlet var fld_camera: UIImageView!
    @IBOutlet weak var fld_cameraRoll: UIImageView!
    @IBOutlet weak var fld_cameraRoll_label: UILabel!
    @IBOutlet weak var fld_camera_label: UILabel!
    @IBOutlet weak var fld_caption: UITextView!
    @IBOutlet weak var btn_removeImage: UIButton!
    @IBOutlet weak var fld_chosenImage: UIImageView!

    let categories = DropDown()  // creating a dropdown object
    var categoryName: String!
    let myPickerController = UIImagePickerController()
    var count = 1
    var ref: FIRDatabaseReference? // create property
    var categoryDataSource = [String]();
    var capturedVideoURL: URL!;
    var hasVideo = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCategories() //dropdown list
        categoryName = nil;
        
        SVProgressHUD.setDefaultStyle(.dark)
        
        self.hideKeyboardWhenTappedAround()
        self.fld_caption.delegate = self;
        
        let singletap = UITapGestureRecognizer(target: self, action: #selector(camera))
        fld_camera.isUserInteractionEnabled = true
        fld_camera.addGestureRecognizer(singletap)
        
        let cameraRollTap = UITapGestureRecognizer(target: self, action: #selector(photoLibrary))
        fld_cameraRoll.isUserInteractionEnabled = true
        fld_cameraRoll.addGestureRecognizer(cameraRollTap)
        
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(viewImage))
        fld_chosenImage.isUserInteractionEnabled = true
        fld_chosenImage.addGestureRecognizer(tapImage)
        
        //enables the images that allow the user to choose their content.
        hideCorrespondingElements(type: "1");
        
        myPickerController.delegate = self;
        
        ref = FIRDatabase.database().reference() // get reference to actual db
        btn_chooseCategory.layer.cornerRadius = 4
        if(categoryName != nil)
        {
            btn_chooseCategory.setTitle(categoryName + " ▾", for: UIControlState.normal);
        }
        else
        {
            btn_chooseCategory.setTitle("Choose Category", for: UIControlState.normal);
        }
        
        FIRDatabase.database().reference().child("accountCategories/"+userObj.accountID!).observeSingleEvent(of: .value, with: {(keyvalue) in
            print(keyvalue)
            let cValues = keyvalue.value as? [String : String] ?? [:];
            var newValues = [String]();
            newValues.append("None")
            for c in cValues {
                self.categoryDataSource.append(c.key);
                newValues.append(c.value)
            }
            self.categories.dataSource = newValues;
        })
    }
    
    //Keboard dismissed when return key is pressed 
    /*func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            self.dismissKeyboard()
            return false
        }
        
        return true
    }*/
    
    func viewImage() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VC_viewselectedimg") as! VC_selectedimage;
        vc.imgSent = fld_chosenImage.image;
        vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen;
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical;
        self.present(vc, animated: true, completion: nil);
    }
    
    func hideCorrespondingElements(type: String) {
        //when type is 1 it sets up user to select a new image.
        if(type == "1")
        {
            fld_chosenImage.isHidden = true;
            btn_removeImage.isHidden = true;
            fld_camera.isHidden = false;
            fld_camera_label.isHidden = false;
            fld_cameraRoll.isHidden = false;
            fld_cameraRoll_label.isHidden = false;
            fld_caption.placeholder = "Write caption...";
        }
        else
        {
            fld_chosenImage.isHidden = false;
            btn_removeImage.isHidden = false;
            fld_camera.isHidden = true;
            fld_camera_label.isHidden = true;
            fld_cameraRoll.isHidden = true;
            fld_cameraRoll_label.isHidden = true;
        }
    }
    
    /*
     * When the view appears again
     */
    override func viewWillAppear(_ animated: Bool) {
        if(categoryName != nil)
        {
            btn_chooseCategory.setTitle(categoryName + " ▾", for: UIControlState.normal);
        }
        else
        {
            btn_chooseCategory.setTitle("Choose Category ▾", for: UIControlState.normal);
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.placeholder = "Write caption..."
        }
    }
    
    func camera()
    {
        let myPickerController = UIImagePickerController();
        myPickerController.sourceType = UIImagePickerControllerSourceType.camera;
        //myPickerController.sourceType = .Camera
        myPickerController.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        myPickerController.delegate = self
        myPickerController.videoMaximumDuration = 10.0
        myPickerController.videoQuality = UIImagePickerControllerQualityType.typeHigh;
        self.present(myPickerController, animated: true, completion: nil);
    }
    
    func photoLibrary()
    {
        //let myPickerController = UIImagePickerController();
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary;
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    @IBAction func buttonPost(_ sender: Any) {
        
        let caption = fld_caption.text
        let image = fld_chosenImage.image
        if(image == nil)
        {
            let refreshAlert = UIAlertController(title: "NOTICE", message: "Please select an image to post!", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            }))
            present(refreshAlert, animated: true, completion: nil)
            return;
        }
        if(caption == "")
        {
            let refreshAlert = UIAlertController(title: "NOTICE", message: "Are you sure you wish to post this image without a caption?", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
                self.uploadImg();
                
            }));
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            }));
            present(refreshAlert, animated: true, completion: nil);
        }
        if categoryName == nil || categoryName == "NONE"{
            let refreshAlert = UIAlertController(title: "NOTICE", message: "Are you sure you wish to post without a category?", preferredStyle: UIAlertControllerStyle.alert)
            refreshAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
                self.uploadImg()
            }));
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            }));
            present(refreshAlert, animated: true, completion: nil);
            return;
        }
        
        uploadImg()
        
    }
    
    func fixOrientation(img:UIImage) -> UIImage {
        
        if (img.imageOrientation == UIImageOrientation.up) {
            return img;
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return normalizedImage;
        
    }
    
    func uploadImg(){ //Posting image to firebase
        let img = fld_chosenImage.image!;
        let caption = fld_caption.text!;
        var category = self.categoryName;
        /*
         * When category is nil or none, sets it to empty string.
         * --This is to ensure no errors occur when sending nil/invalid category.
         */
        if (category == nil) || (category == "None")
        {
            category = "";
        }
        else
        {
            category = self.categoryName!;
        }
        let imgUid = NSUUID().uuidString;
        print("imgUID");
        print(imgUid);
        let metadata = FIRStorageMetadata();
        var media = Data();
        /*
         * Setting media as the content with the right 'contentType'.
         */
        if(!hasVideo)
        {
            metadata.contentType = "image/jpeg";
            media = UIImageJPEGRepresentation(img, 0.2)!
        }
        else
        {
            metadata.contentType = "video/mp4";
            do {
                media = try NSData(contentsOf: capturedVideoURL, options: NSData.ReadingOptions()) as Data
                
            } catch {
                print(error)
                print("Cannot convert media to Data");
                return;
            }
        }

        //**BEGINS UPLOAD PROCESS**//
        SVProgressHUD.show(withStatus: "Uploading");
        /*
         * Will store the content in firebase and if it's successful will continue, otherwise stops there.
         */
        FIRStorage.storage().reference().child(userObj.uid).child(imgUid).put(media, metadata: metadata) { (metadata, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: "Could not upload!")
                SVProgressHUD.dismiss(withDelay: 3)
                print("did not upload img")
                
            } else {

                var thumbnailUID: String!;
                //if there is no downloadURL() then it puts empty string.
                let contentDownloadURL = metadata?.downloadURL()?.absoluteString ?? "";
                print(contentDownloadURL)
               
                /*
                 * - Here, a dictionary of values is created for the post.
                 * - This contains the following info: url of content (url), the current user uid (uploadedBy), caption (description), status which is always uploaded as 'pending' (status), the creatorID of the user (creatorID), category (category)
                 */
                var values = [String:Any]();
                values = ["url": contentDownloadURL, "uploadedBy": userObj.uid!, "description": caption, "status": "pending", "creatorID": userObj.creatorID!, "imageUid": imgUid, "category":category ?? ""];
                
                if(self.hasVideo)
                {
                    values["type"] = "video";
                    /*
                     * When the type of content is a video, we have to store the thumbnail before posting the post.
                     * - To do this we create another metadata object, set the contentType to image/jpeg and create a new uid.
                     */
                    let m = FIRStorageMetadata();
                    m.contentType = "image/jpeg";
                    thumbnailUID = NSUUID().uuidString;
                    /*
                     * Since this content is a video we need to store the corresponding thumbnail we've created.
                     */
                    FIRStorage.storage().reference().child(userObj.uid).child(thumbnailUID).put(UIImageJPEGRepresentation(self.fld_chosenImage.image!, 0.2)!, metadata: m){ (metadata, error) in
                        if(error == nil)
                        {
                            /*
                             * After successfully storing the thumbnail, we include two fields in the value dictionary for the thumbnail - thumbnailURL and thumbnailUID
                             */
                            values["thumbnailURL"] = metadata?.downloadURL()?.absoluteString ?? "";
                            values["thumbnailUID"] = thumbnailUID;
                            self.makePost(values: values){ success in
                                if success{
                                    SVProgressHUD.dismiss();
                                    print("Uploaded video successfully!");
                                    self.finalisePostContent();
                                }
                                else
                                {
                                    print("Error uploading video.");
                                    
                                }
                                return;
                            }
                        }
                    }
                }
                else
                {
                    values["type"] = "image";
                    self.makePost(values: values){ success in
                        if success{
                            SVProgressHUD.dismiss();
                            print("Uploaded image successfully!");
                            self.finalisePostContent();
                        }
                        else
                        {
                            print("Error uploading image.");
                        }
                    }
                }
            }
        }
    }
    
    func makePost(values: [String:Any], completion: @escaping (Bool) -> ())
    {
        /*
         * According to whether the user's an admin or not, the path will be different.
         */
        
        var path: String!;
        if(userObj.isAdmin)
        {
            path = "creatorPosts/"+userObj.accountID!+"/"+userObj.creatorID!;
            let autoUID = ref?.child(path).childByAutoId().key;
            print("autoUID");
            print(autoUID);
            /*
             * Since the user is a manager we need to make the post and then send that postID to a creatorCommand to automatically send the post to the dashboard.
             * We store the postID by creating the variable autoUID
             */
            ref?.child(path+"/"+autoUID!).setValue(values) { (error, ref) in
                if(error == nil)
                {
                    FIRDatabase.database().reference().child("creatorCommands/"+userObj.accountID!+"/"+userObj.creatorID!+"/approvePost").childByAutoId().setValue(["postID": autoUID, "uid": userObj.uid!]);
                    completion(true);
                }
                else
                {
                    print(error?.localizedDescription as Any);
                    completion(false);
                }
            }
        }
        else
        {
            var lValues = values;
            lValues["review"] = true;
            path = "userPosts/"+userObj.accountID!+"/"+userObj.creatorID!+"/"+userObj.uid!;
            ref?.child(path).childByAutoId().setValue(lValues);
            completion(true);
        }
    }
    
    /*
     * Performs these things after a post gets uploaded:
     * - sets up for a new post to be made.
     * - sets category blank.
     * - sets caption blank.
     */
    func finalisePostContent()
    {
        hideCorrespondingElements(type: "1");
        fld_caption.text = ""
        categoryName = nil;
        btn_chooseCategory.setTitle("Choose Category", for: UIControlState.normal);
        let tabItems = tabBarController?.tabBar.items;
        
        for i in 0...((tabItems?.count)!-1) {
            let controllerTitle = (tabBarController?.viewControllers?[i].title!)!;
            
            if(controllerTitle == "VC_viewposts"){
                print(": "+controllerTitle);
                let tabItem = tabItems?[i];
                var badgeValue = tabItem?.badgeValue;
                if((badgeValue) != nil)
                {
                    badgeValue = String(Int(badgeValue!)! + 1);
                }
                else
                {
                    badgeValue = "1";
                }
                tabItem?.badgeValue = badgeValue;
            }
        }
        SVProgressHUD.showSuccess(withStatus: "Uploaded!")
        SVProgressHUD.dismiss(withDelay: 2)
    }
    
    private func thumbnailForVideoAtURL(url: NSURL) -> UIImage? {
        print("ENTER.");
        
        let asset = AVAsset(url: url as URL)
        hasVideo = true;
        
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true;
        var time = asset.duration
        time.value = min(time.value, 2)
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil);
            print("got imageRef");
            return fixOrientation(img: UIImage(cgImage: imageRef));
        } catch {
            print("error")
            return nil
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        hasVideo = false;
        
        if(info[UIImagePickerControllerOriginalImage] != nil)
        {
            let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage;
            fld_chosenImage.image = fixOrientation(img: selectedImage);
        }
        else
        {
            //let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL);
            let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL
            capturedVideoURL = videoURL! as URL;
            /*
             * Commented out code to save video to user's phone.
             */
            
            /*PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL! as URL)
            }) { saved, error in
                if saved {
                    
                    let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }*/
            //UISaveVideoAtPathToSavedPhotosAlbum(pathString!, self, nil, nil);
            fld_chosenImage.image = thumbnailForVideoAtURL(url: videoURL!);
        }
        
        hideCorrespondingElements(type: "2")
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonSelectImage(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    @IBAction func btn_chooseCategory(_ sender: Any) {
//        let vc = storyboard?.instantiateViewController(withIdentifier: "VC_selectcategory") as! VC_SelectCategory;
//        self.navigationController?.pushViewController(vc, animated: true);
        categories.show()
    }
    
    @IBAction func button_removeImage(_ sender: Any) {
        hideCorrespondingElements(type: "1");
        fld_chosenImage.image = nil // added this because image was still being posted after cancel
    }
    
    func setupCategories() {
        categories.anchorView = btn_chooseCategory
        categories.bottomOffset = CGPoint(x: 0, y: btn_chooseCategory.bounds.height)
        // Action triggered on selection
        categories.selectionAction = { [unowned self] (index, item) in
            self.btn_chooseCategory.setTitle(item + " ▾", for: .normal)
            self.categoryName = item
            
        }
    }
}
