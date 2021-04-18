//
//  CardListTableViewCell.swift
//  Plumbal
//
//  Created by Casperon Tech on 27/01/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit

class CardListTableViewCell: UITableViewCell {
    @IBOutlet var Carddetail_Lab:UILabel!
    @IBOutlet var card_Image:UIImageView!
    @IBOutlet var Selected_Img:UIImageView!
    @IBOutlet var Delete_card:UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
