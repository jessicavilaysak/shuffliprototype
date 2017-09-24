//
//  CustomCellCreator.swift
//  Test
//
//  Created by Jessica Vilaysak on 11/5/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit

class CustomCellCreator: UITableViewCell {
    
    
    @IBOutlet var photo: UIImageView!
    
    @IBOutlet var imageCaption: UILabel!
    
    @IBOutlet weak var approveStatus: UIImageView!
    
    @IBOutlet weak var cardviewBg: UIView!
    
    @IBOutlet weak var vfView: UIView!
    @IBOutlet weak var visualEffect: UIVisualEffectView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        updateUi()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateUi(){
        cardviewBg.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        contentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        
        cardviewBg.layer.cornerRadius = 3.0
        photo.layer.cornerRadius = 3.0
        visualEffect.layer.cornerRadius = 3.0
        vfView.layer.cornerRadius = 3.0
        cardviewBg.layer.masksToBounds = false
        
        cardviewBg.layer.shadowColor = UIColor.black.cgColor
        
        cardviewBg.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        cardviewBg.layer.shadowOpacity = 0.8
    }
    
}
