//
//  TaskerdetailTableViewCell.swift
//  Plumbal
//
//  Created by Casperon on 27/09/17.
//  Copyright © 2017 Casperon Tech. All rights reserved.
//

import UIKit

class TaskerdetailTableViewCell: UITableViewCell {

   
    @IBOutlet var cat_amount: UILabel!
    @IBOutlet var categorylabl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
