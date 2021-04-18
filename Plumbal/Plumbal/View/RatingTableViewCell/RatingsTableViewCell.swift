//
//  RatingsTableViewCell.swift
//  PlumberJJ
//
//  Created by Casperon Technologies on 12/12/15.
//  Copyright © 2015 Casperon Technologies. All rights reserved.
//

import UIKit
protocol ratingsDelegate {
    
    func ratingsCount(_ withRateVal:Float , withIndex:IndexPath)
   
}
class RatingsTableViewCell: UITableViewCell {
    @IBOutlet var ratingview: HCSStarRatingView!
var delegate:ratingsDelegate?
    var objIndexPath:IndexPath=IndexPath()
    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func loadRateTableCell(_ objRateRec:RatingsRecord){
       
       // ratingView.value = Float (objRateRec.rateCount as String)!
        ratingview.value = CGFloat((objRateRec.rateCount as NSString).floatValue)
        
    }
   
    @IBAction func didclickValueChanged(_ sender: AnyObject) {
        let getval : CGFloat = sender.value
        self.delegate?.ratingsCount(Float(getval.description)!, withIndex: objIndexPath)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
