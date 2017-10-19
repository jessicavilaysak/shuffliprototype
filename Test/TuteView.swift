//
//  TuteView.swift
//  Test
//
//  Created by Pranav Joshi on 4/10/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit

/**
 This class holds all the tutView.xib outlets. It is a holder class only
 and the implementation is carried out in the initial view controller.
 **/

class TuteView: UIView {
    
    @IBOutlet weak var tuteTitle: UILabel!
    @IBOutlet weak var tuteImage: UIImageView!
    @IBOutlet weak var tuteDescription: UILabel!
    /**
     These oulets are for the first "tile" of the tute view, they are hidden in the
     consicutive tiles.
 */
    @IBOutlet weak var firstTileLabel: UILabel!
    @IBOutlet weak var firstTileDescription: UILabel!
    @IBOutlet weak var firstTileLogo: UIImageView!
    
}
