//
//  VC_SelectCategory.swift
//  Test
//
//  Created by Jessica Vilaysak on 21/9/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import DropDown

class VC_SelectCategory: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var categories: [String] = [String]()
    
    @IBOutlet weak var categoryTable: UITableView!
    @IBOutlet weak var categoryLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryTable.delegate = self;
        categoryTable.dataSource = self;
        categories = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6"];
    }
    
    @IBAction func btn_back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1;
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count;
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! SelectCategoryCell;
        
        cell.categoryLabel.text = categories[indexPath.row];
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vcsCount = self.navigationController?.viewControllers.count
        let vc = self.navigationController?.viewControllers[vcsCount! - 2] as! VC_PostContent;
        vc.categoryName = categories[indexPath.row];
        self.navigationController?.popViewController(animated: true);
    }
    
    @IBAction func btn_cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
        
    }

}
