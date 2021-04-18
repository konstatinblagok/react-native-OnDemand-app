//
//  HomePageTableViewCell.swift
//  Plumbal
//
//  Created by Casperon Tech on 05/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class HomePageTableViewCell: UITableViewCell {
    
    @IBOutlet var single_LayoutView: UIView!
    @IBOutlet var Single_ImageView: UIImageView!
    @IBOutlet var Single_wrapperView: UIButton!
    @IBOutlet var Single_Label: UILabel!
    
    var gradient: CAGradientLayer = CAGradientLayer()
    var gradient1: CAGradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
