//
//  ReviewsTableViewCell.swift
//  PlumberJJ
//
//  Created by Casperon Technologies on 11/6/15.
//  Copyright © 2015 Casperon Technologies. All rights reserved.
//

import UIKit

class ReviewsTableViewCell: UITableViewCell {
    @IBOutlet weak var reviewLbl: UITextView!
    @IBOutlet weak var ratingView: FloatRatingView!
    
    @IBOutlet var job_idlable: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var userImgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loadReviewTableCell(_ objOpenRec:ReviewRecords,currentView:UIViewController){
        
//        if(objOpenRec.ratterImage != ""){
//            designTermslabel("\(objOpenRec.reviewDesc)", reviewImg: "\(objOpenRec.ratterImage)",currentView:currentView)
//        }else{
            reviewLbl.text=objOpenRec.reviewDesc as String
      //  }
        reviewLbl.sizeToFit()
        timeLbl.text=objOpenRec.reviewTime as String
        userNameLbl.text=objOpenRec.reviewName as String
        userImgView.sd_setImage(with: URL(string:objOpenRec.reviewImage as String), placeholderImage: UIImage(named: "PlaceHolderSmall"))
        userImgView.layer.cornerRadius=userImgView.frame.size.width/2
        userImgView.layer.masksToBounds=true
        ratingView.rating = Float(objOpenRec.reviewRate as NSString as String)!
        job_idlable.text=objOpenRec.reviewJobID as String
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func designTermslabel(_ reviewDisc:String,reviewImg:String,currentView:UIViewController){
        // reviewLbl.text="\(reviewDisc)"
        let current:MyProfileViewController = currentView as! MyProfileViewController
        
        
        print (reviewImg)
        if reviewImg != ""
        {
            
            let URL = Foundation.URL.init(string: "\(reviewImg)")
            let str:NSMutableAttributedString = NSMutableAttributedString.init(string: "\(reviewDisc) \(themes.setLang("view_image"))")
            str.addAttribute(NSLinkAttributeName, value:URL!, range: NSRange(location:reviewDisc.count+1,length:10))
            reviewLbl.attributedText = str;
            reviewLbl.isUserInteractionEnabled = true
            reviewLbl.font = UIFont(name: "Roboto-Regular", size: 13)
            reviewLbl.delegate = current
        }
            
            
        else{
            
            let str:NSMutableAttributedString = NSMutableAttributedString.init(string: "\(reviewDisc)")
            
            
            reviewLbl.attributedText = str;
            reviewLbl.isUserInteractionEnabled = true
            reviewLbl.font = UIFont(name: "Raleway-Regular", size: 16)
            reviewLbl.delegate = current
            
        }
        
    }
    
    func textView(_ textView: UITextView, shouldInteractWithURL URL: Foundation.URL, inRange characterRange: NSRange) -> Bool {
        
        return true
    }
    
}
