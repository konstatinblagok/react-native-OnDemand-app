//
//  FareDetailTableViewCell.swift
//  PlumberJJ
//
//  Created by Casperon Technologies on 11/30/15.
//  Copyright © 2015 Casperon Technologies. All rights reserved.
//

import UIKit

class FareDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func loadFareTableCell(_ objOpenRec:JobDetailRecord){
        titleLbl.text=objOpenRec.jobTitle as String
        descLbl.text=objOpenRec.jobDesc as String
        titleLbl.sizeToFit()
        if(objOpenRec.jobStatus=="1"){
          descLbl.font=UIFont.boldSystemFont(ofSize: 16)
             titleLbl.font=UIFont.boldSystemFont(ofSize: 16)
        }else if(objOpenRec.jobStatus=="0"){
            descLbl.font=UIFont.systemFont(ofSize: 14)
             titleLbl.font=UIFont.systemFont(ofSize: 16)
        }else{
            descLbl.font=UIFont.systemFont(ofSize: 14)
             titleLbl.font=UIFont.systemFont(ofSize: 16)
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
