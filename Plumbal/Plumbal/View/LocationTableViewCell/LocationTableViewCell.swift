//
//  LocationTableViewCell.swift
//  Plumbal
//
//  Created by Casperon Tech on 20/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    @IBOutlet var Pin_Mark: UIImageView!
    @IBOutlet var Check_Mark: UIImageView!
    @IBOutlet var markerView: UIImageView!
    @IBOutlet var City_Name_Lab: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
