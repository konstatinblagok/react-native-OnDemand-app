//
//  TransTableViewCell.swift
//  Plumbal
//
//  Created by Casperon on 06/09/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit

class TransTableViewCell: UITableViewCell {
    
    @IBOutlet var Transac_titlelabl: UILabel!
    
    @IBOutlet var Transac_Datelabl: UILabel!

    @IBOutlet var Transac_amountlabl: UILabel!
    @IBOutlet var Transac_Balancelabl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
