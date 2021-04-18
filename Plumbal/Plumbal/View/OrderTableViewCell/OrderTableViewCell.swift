//
//  OrderTableViewCell.swift
//  Plumbal
//
//  Created by Casperon Tech on 01/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    @IBOutlet var bottomView: UIView!

    @IBOutlet var sidebarse: UIImageView!
    @IBOutlet var sidebarf: UIImageView!
    @IBOutlet var topborder: UIImageView!
    @IBOutlet var Jobtitle: UILabel!
    @IBOutlet var phoneimg: UIImageView!
    @IBOutlet var chatimg: UIImageView!
    @IBOutlet var Call_Btn: UIButton!
    @IBOutlet var Message_Btn: UIButton!
    @IBOutlet var Order_Detail: UILabel!
    @IBOutlet var orderID_label: UILabel!
    @IBOutlet var Status_label: UILabel!
    @IBOutlet var Service_Image: UIImageView!
    @IBOutlet var User_Message: UILabel!
    @IBOutlet var Cancel_But: UIButton!
     override func awakeFromNib() {
        super.awakeFromNib()
        Status_label.backgroundColor=UIColor.orange
        Call_Btn.setTitle("   \(themes.setLang("call_space"))", for: UIControlState())
        Message_Btn.setTitle("   \(themes.setLang("chat_space"))", for: UIControlState())
        Cancel_But.setTitle(themes.setLang("cancel_space"), for: UIControlState())
        Service_Image.layer.cornerRadius = Service_Image.frame.width/2
        Jobtitle.sizeToFit()
        Jobtitle.frame = CGRect(x: Jobtitle.frame.origin.x, y: Jobtitle.frame.origin.y, width: self.bounds.width-5, height: Jobtitle.frame.height)

        

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
