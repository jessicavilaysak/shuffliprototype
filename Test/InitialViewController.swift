//
//  InitialViewController.swift
//  Test
//
//  Created by Jessica Vilaysak on 21/8/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBAction func btnAdminCreator(_ sender: Any) {
        userObj.isAdmin = true;
        segueToLogin(vc_name: "VC_signin");
    }
    
    @IBAction func btnCreator(_ sender: Any) {
        userObj.isAdmin = false;
        segueToLogin(vc_name: "VC_invitecode");
    }
    
    func segueToLogin(vc_name: String) {
        let vc = storyboard?.instantiateViewController(withIdentifier: vc_name);
        present(vc!, animated: true, completion: nil);
    }
    
    let tute1 = ["title":"Take A Photo", "descripiton": "Take an interesting photograph.", "image": "taking-a-selfie"]
    let tute2 = ["title":"Add Caption", "descripiton": "Say something about your photo.", "image": "writing"]
    let tute3 = ["title":"Post It", "descripiton": "Post it to the Shuffli platform.", "image": "post"]
    let tute4 = ["title":"Approval", "descripiton": "Wait for your photo to be approved.", "image": "approved-signal"]
    
    var tuteArray = [Dictionary<String,String>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tuteArray = [tute1,tute2,tute3,tute4]
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: self.view.bounds.width * CGFloat(tuteArray.count), height: 50)
            
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        pageControl.numberOfPages = tuteArray.count
        loadTutes()
       
        scrollView.layer.masksToBounds = false
        scrollView.layer.shadowColor = UIColor.black.cgColor
        scrollView.layer.shadowOffset = CGSize(width: 1.0, height:1.0)
        scrollView.layer.shadowOpacity = 0.5
        scrollView.layer.shadowRadius = 10;
        scrollView.layer.shouldRasterize  = false
    }
    
    func loadTutes() {
        for (index,tute) in tuteArray.enumerated(){
            if let tuteView = Bundle.main.loadNibNamed("TuteView", owner: self, options: nil)?.first as? TuteView {
                
                tuteView.tuteImage.image = UIImage(named:tute["image"]!)
                tuteView.tuteTitle.text = tute["title"]
                tuteView.tuteDescription.text = tute["descripiton"]
                
                scrollView.addSubview(tuteView)
                //tuteView.frame.size.width = self.view.bounds.size.width
                tuteView.frame.origin.x = CGFloat(index) * self.view.bounds.size.width
                
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(page)
        
    }
    
    
    
}
