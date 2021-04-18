//
//  TransactionDetailTableViewCell.swift
//  PlumberJJ
//
//  Created by Casperon iOS on 28/4/2017.
//  Copyright © 2017 Casperon Technologies. All rights reserved.
//

import UIKit

class TransactionDetailTableViewCell: UITableViewCell {

    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var lblDescL:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
