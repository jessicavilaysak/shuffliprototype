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
        //myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.camera
        
        self.present(myPickerController, animated: true, completion: nil)
        
    }
    
    func photoLibrary()
    {
        
        //myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(myPickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func buttonPost(_ sender: Any) {
        
        
        let caption = fld_caption.text
        let image = fld_photo.image
        
        if(image == UIImage(named: "ImagePlaceholder"))
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
                self.postImage(img: image!, caption: "");
                
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            }))
            present(refreshAlert, animated: true, completion: nil)
            return;
        }
        
        postImage(img: image!, caption: caption!)
        uploadImg(img: image!, caption: caption!)
        
    }
    func uploadImg(img: UIImage, caption: String){ //Posting image to firebase
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            
            let metadata = FIRStorageMetadata()
            
            metadata.contentType = "img/jpeg"
            
            SVProgressHUD.show(withStatus: "Uploading")
            
            FIRStorage.storage().reference().child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                
                SVProgressHUD.dismiss()
                
                if error != nil {
                    
                    print("did not upload img")
                    
                } else {
                    
                    print("uploaded")
                    
                    let downloadURl = metadata?.downloadURL()?.absoluteString
                    print("downloadURL" + downloadURl!)
                    self.ref?.child("uploads").childByAutoId().setValue(["imageURL": downloadURl, "uploadedBy": FIRAuth.auth()?.currentUser?.uid, "caption": caption, "category": "School", "status": "approved"])
                }
            }
        }
    }
    
    
    func postImage(img: UIImage, caption: String) {
        
        dataSource.postsobj.append((image: img, caption: caption))
        
        self.fld_photo.image = #imageLiteral(resourceName: "ImagePlaceholder")
        self.fld_caption.text = "Insert caption..."
        self.fld_caption.textColor = UIColor.lightGray
        
        
        let tabItems = self.tabBarController?.tabBar.items;
        if((tabItems?.count)! > 2)
        {
            let tabItem = tabItems?[0]
            dataSource.postNotifications = dataSource.postNotifications + 1;
            tabItem?.badgeValue = String(dataSource.postNotifications)
        }
        else
        {
            let tabItem = tabItems?[0]
            dataSource.postNotifications = dataSource.postNotifications + 1;
            tabItem?.badgeValue = String(dataSource.postNotifications)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        fld_photo.image = selectedImage
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
        
        
        
        /* fld_photo.image = UIImage(named: String(count))
         if(count < 4)
         {
         count = count + 1
         }
         else
         {
         count = 1
         }*/
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
