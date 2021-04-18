//
//  ChatListTableViewCell.swift
//  Plumbal
//
//  Created by Casperon Tech on 19/01/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

//
//  ChatListTableViewCell.swift
//  Plumbal
//
//  Created by Casperon Tech on 19/01/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {
    @IBOutlet var Provider_image: UIImageView!
    @IBOutlet var border_view: UIView!
    @IBOutlet var created_date: UILabel!
    
    @IBOutlet var catagory_labl: CustomLabel!
    @IBOutlet var Time_Lab: UILabel!
    @IBOutlet var Chat_Lbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
