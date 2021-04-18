//
//  ProviderInfoTableViewCell.swift
//  Plumbal
//
//  Created by Casperon Tech on 12/01/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit

class ProviderInfoTableViewCell: UITableViewCell {

    @IBOutlet var Email_Lab: UILabel!
    @IBOutlet var Contact_Lab: UILabel!
    @IBOutlet var Name_Lab: UILabel!
    @IBOutlet var ratingView: TPFloatRatingView!
    @IBOutlet var Provider_Image: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        


        // Configure the view for the selected state
    }
    
}
