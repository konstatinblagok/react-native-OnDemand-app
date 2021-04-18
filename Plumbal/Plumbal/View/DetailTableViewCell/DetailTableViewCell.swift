//
//  DetailTableViewCell.swift
//  Plumbal
//
//  Created by Casperon Tech on 17/11/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    @IBOutlet var borderlable: BorderLabel!
    @IBOutlet var Time_Lab: UILabel!
    @IBOutlet var Last_VertLine: UILabel!
    @IBOutlet var Detail_Lab: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
