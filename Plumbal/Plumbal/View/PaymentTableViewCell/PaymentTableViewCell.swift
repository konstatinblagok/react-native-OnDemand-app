//
//  PaymentTableViewCell.swift
//  Plumbal
//
//  Created by Casperon Tech on 30/11/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class PaymentTableViewCell: UITableViewCell {
    
    @IBOutlet var Payment_Lab: UILabel!
    @IBOutlet var Wallet_ImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
         // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
