//
//  ReviewRecords.swift
//  PlumberJJ
//
//  Created by Casperon Technologies on 11/25/15.
//  Copyright © 2015 Casperon Technologies. All rights reserved.
//

import UIKit

class ReviewRecords: NSObject {
    var reviewName:NSString=""
    var reviewTime:NSString=""
    var reviewDesc:NSString=""
    var reviewRate:NSString=""
    var reviewImage:NSString=""
    var ratterImage:NSString=""
    var reviewJobID:NSString=""
    
    
    init(name: String, time: String, desc: String, rate: String, img: String,ratting:String,jobid:String) {
        reviewName = name
        reviewTime = time
        reviewDesc = desc
        reviewRate = rate
        reviewImage = img
        ratterImage = ratting
        reviewJobID = jobid
        
        super.init()
    }
}
