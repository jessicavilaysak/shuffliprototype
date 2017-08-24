//
//  ViewControllerViewpostsCreator.swift
//  Test
//
//  Created by Jessica Vilaysak on 11/5/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseAuth

class VC_Creator_Viewposts: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var viewposts: UITableView!

    @IBOutlet var fldusername: UILabel!
    
    @IBOutlet var fldcompany: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        fldusername.text = FIRAuth.auth()?.currentUser?.uid
//dataSource.username;
        fldcompany.text = "Cotton On (Eastland)"
        self.hideKeyboardWhenTappedAround()
  
        // Do any additional setup after loading the view.
    }

    
    override func viewDidAppear(_ animated: Bool) {
        viewposts.reloadData()
        
        let tabItems = self.tabBarController?.tabBar.items;
        let tabItem = tabItems?[0]
        dataSource.postNotifications = 0;
        tabItem?.badgeValue = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.postsobj.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.viewposts.dequeueReusableCell(withIdentifier: "cellCreator", for: indexPath as IndexPath) as! CustomCellCreator
        if indexPath.row < dataSource.postsobj.count
        {
            let temp = dataSource.postsobj[indexPath.row]
            cell.photo.image = temp.image
            cell.fld_caption.text = temp.caption
            
            
        }
        
        return cell
    }
    
    
    @IBAction func logout(_ sender: UIButton) {
       try! FIRAuth.auth()?.signOut()
        self.performSegue(withIdentifier: "goToSignin", sender: self)
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
