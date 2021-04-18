//
//  MarkerView.swift
//  Plumbal
//
//  Created by Casperon iOS on 1/3/2017.
//  Copyright © 2017 Casperon Tech. All rights reserved.
//

import UIKit

class MarkerView: CSAnimationView {

    @IBOutlet var Detailview: UIView!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var minCOst: UILabel!
    @IBOutlet var lblAdd: UITextView!
    @IBOutlet var btnChat: UIButton!
    @IBOutlet var btnViewDetails: UIButton!
    @IBOutlet var btnClose: UIButton!

    @IBOutlet var close: UILabel!
    @IBOutlet var select: UILabel!
    @IBOutlet var providerRating: TPFloatRatingView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var btnAccept: UIButton!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        userImage.layer.cornerRadius = userImage.frame.width/2
        userImage.clipsToBounds = true
    }
    
    
}
