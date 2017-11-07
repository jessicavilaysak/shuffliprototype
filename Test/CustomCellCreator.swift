//
//  CustomCellCreator.swift
//  Test
//
//  Created by Jessica Vilaysak on 11/5/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit

/**
 This cell class correpsonds to the view post feed
 and contains outlets for all the cell UI elements.
 **/
class CustomCellCreator: UITableViewCell {
    
    
    @IBOutlet weak var playButton: UIImageView!
    @IBOutlet var photo: UIImageView!
    @IBOutlet var imageCaption: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
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
       
    }
    
    // Creates a card like effect when displaying the Post cell
    func updateUi(){
        
        //background colors
        cardviewBg.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        contentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        
        //Rounded corners
        cardviewBg.layer.cornerRadius = 3.0
        photo.layer.cornerRadius = 3.0
        visualEffect.layer.cornerRadius = 3.0
        vfView.layer.cornerRadius = 3.0
        cardviewBg.layer.masksToBounds = false
        
        //Shadow
        cardviewBg.layer.shadowColor = UIColor.black.cgColor
        cardviewBg.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        cardviewBg.layer.shadowOpacity = 0.8
    }
    
}
