//
//  AddressTableViewCell.swift
//  Plumbal
//
//  Created by Casperon Tech on 29/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class AddressTableViewCell: UITableViewCell {

    @IBOutlet var DeleteIcon: UIButton!
   
    @IBOutlet var More_icon: UIImageView!
    @IBOutlet var More_address_btn: UIButton!
     @IBOutlet var Checkmark_ImageView: UIImageView!
    @IBOutlet var Address_Label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
