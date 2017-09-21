//
//  SelectCategoryCell.swift
//  Test
//
//  Created by Jessica Vilaysak on 21/9/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit

class SelectCategoryCell: UITableViewCell{
    
    @IBOutlet weak var categoryLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

