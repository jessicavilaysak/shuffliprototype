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
    let tute0 = ["title":"Shuffli", "descripiton": "", "image": ""]
    let tute1 = ["title":"Create Content", "descripiton": "Take a photo, video, or choose from your library.", "image": "taking-a-selfie"]
    let tute2 = ["title":"Caption", "descripiton": "Write a caption for your post.", "image": "writing"]
    let tute3 = ["title":"Connect", "descripiton": "Send your content to your team's social media publisher.", "image": "post"]
    let tute4 = ["title":"Publish", "descripiton": "Your post is awaiting approval before being shared via your team's social media pages. Simple.", "image": "approved-signalGrey"]
    let tute5 = ["title":"Shuffli.", "descripiton": "Collect great content from your team, preview and post to the platform of your choice. Simple.", "image": "22446738_1605821302771542_656990994_n"]
    
    var tuteArray = [Dictionary<String,String>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tuteArray = [tute0,tute1,tute2,tute3,tute4,tute5]
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
                
                if index != 0{
                    tuteView.firstTileLabel.isHidden = true
                    tuteView.firstTileLogo.isHidden = true
                    tuteView.firstTileDescription.isHidden = true
                    
                }
                if index == tuteArray.count - 1{
                    
                    tuteView.firstTileLogo.isHidden = false
                    tuteView.firstTileDescription.isHidden = false
                    tuteView.firstTileDescription.text = "To learn more visit: www.shuffli.com"
                    tuteView.tuteImage.isHidden = true
                }
                
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
