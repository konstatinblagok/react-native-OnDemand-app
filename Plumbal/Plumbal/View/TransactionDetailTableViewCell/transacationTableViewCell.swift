//
//  transacationTableViewCell.swift
//  Plumbal
//
//  Created by Casperon on 07/02/17.
//  Copyright © 2017 Casperon Tech. All rights reserved.
//

import UIKit

class transacationTableViewCell: UITableViewCell {

    @IBOutlet var totalview: UIView!
    @IBOutlet var totalamount: UILabel!
    @IBOutlet var category: UILabel!
    @IBOutlet var jobid: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
