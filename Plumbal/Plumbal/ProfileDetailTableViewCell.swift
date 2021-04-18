//
//  ProfileDetailTableViewCell.swift
//  PlumberJJ
//
//  Created by Casperon Technologies on 11/7/15.
//  Copyright © 2015 Casperon Technologies. All rights reserved.
//

import UIKit

class ProfileDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func loadProfileTableCell(_ objOpenRec:ProfileContentRecord){
        titleLbl.text=objOpenRec.Title as String
        descLbl.text=objOpenRec.userDesc as String
        descLbl.sizeToFit()
        if(objOpenRec.IsMobile=="1"){
            
        }else if(objOpenRec.IsMobile=="1"){
            
        }else{
            
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
