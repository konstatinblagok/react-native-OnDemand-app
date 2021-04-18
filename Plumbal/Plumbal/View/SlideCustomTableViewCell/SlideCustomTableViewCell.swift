//
//  SlideCustomTableViewCell.swift
//  Plumbal
//
//  Created by Casperon Tech on 25/02/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit

class SlideCustomTableViewCell: UITableViewCell {
    @IBOutlet weak var Menulist: UILabel!
    @IBOutlet weak var MenuIcon: UIImageView!
    @IBOutlet weak var SeperatorLab: UILabel!
    @IBOutlet weak var animation_view: CSAnimationView!



    @IBOutlet weak var Wallet_Amount: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
