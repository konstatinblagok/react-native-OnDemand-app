//
//  taskerlistCollectionViewCell.swift
//  Plumbal
//
//  Created by Casperon on 12/07/17.
//  Copyright © 2017 Casperon Tech. All rights reserved.
//

import UIKit

class taskerlistCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var close: UILabel!
    @IBOutlet var select_tasker: UILabel!
    @IBOutlet var content: UIView!
    @IBOutlet var taskerRating: TPFloatRatingView!
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var viewBtn: UIButton!
    @IBOutlet var chatBtn: UIButton!
    @IBOutlet var selectBtn: UIButton!
    @IBOutlet var taskerAdd: UITextView!
    @IBOutlet var min_cost: UILabel!
    @IBOutlet var taskerimg: UIImageView!
    @IBOutlet var taskername: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
