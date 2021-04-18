//
//  ProviderRatingTableViewCell.swift
//  Plumbal
//
//  Created by Casperon Tech on 12/01/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit

class ProviderDetailTableViewCell: UITableViewCell {
    @IBOutlet var bio_Lab: UILabel!

    @IBOutlet var About_Lab: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
