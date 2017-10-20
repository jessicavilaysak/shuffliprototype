//
//  ManageUserCell.swift
//  Test
//
//  Created by Pranav Joshi on 20/9/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit

/**
 This class contains all the cell UI outlets for the manage user VC
 */
class ManageUserCell: UITableViewCell{
    
    
// Invited users details displayed in the cell 
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
