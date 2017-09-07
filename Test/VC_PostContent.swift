//
//  ViewControllerPost.swift
//  Test
//
//  Created by Jessica Vilaysak on 11/5/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SVProgressHUD

class VC_PostContent: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var fld_caption: UITextView!
    @IBOutlet var fld_photo: UIImageView!
    @IBOutlet weak var postBtn: UIButton!
    
    let myPickerController = UIImagePickerController()
    
    var count = 1
    
    var ref: FIRDatabaseReference? // create property
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        fld_caption.delegate = self;
        fld_caption.text = "Insert caption..."
        fld_caption.textColor = UIColor.lightGray
        // Do any additional setup after loading the view.
        
        let singletap = UITapGestureRecognizer(target: self, action: #selector(buttonSelectImage))
        singletap.numberOfTapsRequired = 1 // you can change this value
        fld_photo.isUserInteractionEnabled = true
        fld_photo.addGestureRecognizer(singletap)
        
        myPickerController.delegate = self;
        
        ref = FIRDatabase.database().reference() // get reference to actual db
        postBtn.layer.cornerRadius = 4
        fld_caption.layer.cornerRadius = 4
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Insert caption..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    func camera()
    {
        myPickerController.sourceType = UIImagePickerControllerSourceType.camera;
        self.present(myPickerController, animated: true, completion: nil)
        
    }
    
    func photoLibrary()
    {
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary;
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    @IBAction func buttonPost(_ sender: Any) {
        
        let caption = fld_caption.text
        let image = fld_photo.image
        
        if(image == UIImage(named: "takePhototPlaceholder"))
        {
            let refreshAlert = UIAlertController(title: "NOTICE", message: "Please select an image to post!", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            }))
            present(refreshAlert, animated: true, completion: nil)
            return;
        }
        if(caption == "Insert caption...")
        {
            let refreshAlert = UIAlertController(title: "NOTICE", message: "Are you sure you wish to post this image without a caption?", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
                self.uploadImg(img: image!, caption: "");
                
            }));
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            }));
            present(refreshAlert, animated: true, completion: nil);
            return;
        }
        uploadImg(img: image!, caption: caption!)
        
    }
    func uploadImg(img: UIImage, caption: String){ //Posting image to firebase
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let imgUid = NSUUID().uuidString
            
            let metadata = FIRStorageMetadata();
            metadata.contentType = "img/jpeg";
            SVProgressHUD.show(withStatus: "Uploading");
            FIRStorage.storage().reference().child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: "Could not upload!")
                    SVProgressHUD.dismiss(withDelay: 3)
                    print("did not upload img")
                    
                } else {
                    
                    print("uploaded")
                    SVProgressHUD.showSuccess(withStatus: "Uploaded!")
                    SVProgressHUD.dismiss(withDelay: 2)
                    
                    let downloadURl = metadata?.downloadURL()?.absoluteString;
                    var URLtoSend = "";
                    if(!(downloadURl?.isEmpty)!){
                        URLtoSend = downloadURl!;
                    }
                    print("downloadURL" + downloadURl!)
                    let accountID = userObj.accountID;
                    let creatorID = userObj.creatorID;
                    let uid = userObj.uid;
                    
//                    if(userObj.isAdmin)
//                    {
//                        self.ref?.child("creatorPosts").child(accountID!).child(creatorID!).childByAutoId().setValue(["url": downloadURl, "uploadedBy": uid!, "description": caption, "category": "School", "status": "approved", "creatorID": creatorID])
//                    }
//                    else
//                    {
//                        self.ref?.child("userPosts").child(accountID!).child(creatorID!).child(uid!).childByAutoId().setValue(["url": URLtoSend, "uploadedBy": uid!, "description": caption, "category": "School", "status": "approved", "review": true, "creatorID": creatorID])
//                    }
                    self.ref?.child("dashboardPosts").child(accountID!).child("pending").childByAutoId().setValue(["url": downloadURl, "uploadedBy": uid!, "description": caption, "category": "School", "status": "approved", "creatorID": creatorID]);
                    
                    self.fld_photo.image = #imageLiteral(resourceName: "takePhototPlaceholder")
                    self.fld_caption.text = ""
                    let tabItems = self.tabBarController?.tabBar.items;
                    
                    for i in 0...((tabItems?.count)!-1) {
                        let controllerTitle = (self.tabBarController?.viewControllers?[i].title!)!;
                        
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
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage;
        fld_photo.image = selectedImage;
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
}
