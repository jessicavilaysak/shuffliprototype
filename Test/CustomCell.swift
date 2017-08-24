//
//  CustomCell.swift
//  Test
//
//  Created by Jessica Vilaysak on 10/5/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet var buttonApprove: UIButton!
    @IBOutlet var buttonDelete: UIButton!
    @IBOutlet var fld_caption: UITextView!
    @IBOutlet var photo: UIImageView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
