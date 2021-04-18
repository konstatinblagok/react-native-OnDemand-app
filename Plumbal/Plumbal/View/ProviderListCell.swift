//
//  ProviderListCell.swift
//  Plumbal
//
//  Created by CASPERON on 20/07/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit

class ProviderListCell: UITableViewCell {

    @IBOutlet var btnChat: UIButton!
    @IBOutlet var btnOrderConfirm: UIButton!
    @IBOutlet var providerRating: TPFloatRatingView!
    @IBOutlet var lblProviderName: UILabel!
    @IBOutlet var imgProvider: UIImageView!
    @IBOutlet weak var Mincost: UILabel!
    @IBOutlet var perhouramount: UILabel!
    @IBOutlet weak var lblPerHour: UILabel!
    @IBOutlet weak var lblMinCost: UILabel!
    @IBOutlet var lblReviewsCount: UILabel!
    @IBOutlet var lblDistance: UILabel!
    
    @IBOutlet var backView: UIView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
       btnChat.setTitle(themes.setLang("chat_caps"), for: UIControlState())
       btnOrderConfirm.setTitle(themes.setLang("book"), for: UIControlState())
        lblMinCost.text = themes.setLang("base_price")
        lblPerHour.text = themes.setLang("per_hour")
        
        lblMinCost.adjustsFontSizeToFitWidth=true
        lblPerHour.adjustsFontSizeToFitWidth = true
        imgProvider.layer.cornerRadius = imgProvider.frame.width/2
imgProvider.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
