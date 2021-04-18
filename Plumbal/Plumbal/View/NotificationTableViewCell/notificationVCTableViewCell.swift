//
//  notificationVCTableViewCell.swift
//  PlumberJJ
//
//  Created by Casperon on 09/02/17.
//  Copyright © 2017 Casperon Technologies. All rights reserved.
//

import UIKit

class notificationVCTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet var timelable: UILabel!
    @IBOutlet var message: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
