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

class VC_PostContent: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var btn_chooseCategory: UIButton!
    @IBOutlet var fld_camera: UIImageView!
    @IBOutlet weak var fld_cameraRoll: UIImageView!
    
    @IBOutlet weak var fld_cameraRoll_label: UILabel!
    @IBOutlet weak var fld_camera_label: UILabel!
    
    @IBOutlet weak var fld_caption: UITextView!
    @IBOutlet weak var btn_removeImage: UIButton!
    @IBOutlet weak var fld_chosenImage: UIImageView!
    var pickerData: [String] = [String]()
    var categoryName: String!
    
    let myPickerController = UIImagePickerController()
    
    var count = 1
    
    var ref: FIRDatabaseReference? // create property
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
        
        let singletap = UITapGestureRecognizer(target: self, action: #selector(camera))
        fld_camera.isUserInteractionEnabled = true
        fld_camera.addGestureRecognizer(singletap)
        
        let cameraRollTap = UITapGestureRecognizer(target: self, action: #selector(photoLibrary))
        fld_cameraRoll.isUserInteractionEnabled = true
        fld_cameraRoll.addGestureRecognizer(cameraRollTap)
        
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(viewImage))
        fld_chosenImage.isUserInteractionEnabled = true
        fld_chosenImage.addGestureRecognizer(tapImage)
        
        hideCorrespondingElements(type: "1");
        
        myPickerController.delegate = self;
        
        ref = FIRDatabase.database().reference() // get reference to actual db
        //postBtn.layer.cornerRadius = 4
        btn_chooseCategory.layer.cornerRadius = 4
        if(categoryName != nil)
        {
            btn_chooseCategory.setTitle(categoryName, for: UIControlState.normal);
        }
        else
        {
            btn_chooseCategory.setTitle("NUN", for: UIControlState.normal);
        }
        // Do any additional setup after loading the view.
        
    }
    
    func viewImage() {
        print("viewImage() pressed.")
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
            fld_caption.placeholder = "Say something interesting...";
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
    
    override func viewWillAppear(_ animated: Bool) {
        if(categoryName != nil)
        {
            btn_chooseCategory.setTitle(categoryName, for: UIControlState.normal);
        }
        else
        {
            btn_chooseCategory.setTitle("NUN", for: UIControlState.normal);
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
        let image = fld_chosenImage.image
      
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
    
    func uploadImg(img: UIImage, caption: String){ //Posting image to firebase
        
        let imgFixed = fixOrientation(img: img);
        if let imgData = UIImageJPEGRepresentation(imgFixed, 0.2) {
            let imgUid = NSUUID().uuidString
       
            let metadata = FIRStorageMetadata();
            metadata.contentType = "image/jpeg";
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
                    var path = "";
                    if(userObj.isAdmin)
                    {
                        path = "creatorPosts/"+accountID!+"/"+creatorID!;
                        self.ref?.child(path).childByAutoId().setValue(["url": URLtoSend, "uploadedBy": uid!, "description": caption, "status": "pending", "creatorID": creatorID!, "imageUid": imgUid])
                    }
                    else
                    {
                        path = "userPosts/"+accountID!+"/"+creatorID!+"/"+uid!;
                        self.ref?.child(path).childByAutoId().setValue(["url": URLtoSend, "uploadedBy": uid!, "description": caption, "status": "pending", "creatorID": creatorID!, "review": true, "imageUid": imgUid])
                    }
                    //self.ref?.child("dashboardPosts").child(accountID!).child("pending").childByAutoId().setValue(["url": URLtoSend, "uploadedBy": uid!, "description": caption, "category": "School", "status": "approved", "creatorID": creatorID]);//
                    
                    
                    self.hideCorrespondingElements(type: "1");
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
        fld_chosenImage.image = selectedImage;
        hideCorrespondingElements(type: "2");
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
    
    @IBAction func btn_chooseCategory(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "VC_selectcategory") as! VC_SelectCategory;

        self.navigationController?.pushViewController(vc, animated: true);
    }
    
    @IBAction func button_removeImage(_ sender: Any) {
        hideCorrespondingElements(type: "1");
    }
}
