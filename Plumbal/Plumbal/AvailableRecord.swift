//
//  AvailableRecord.swift
//  PlumberJJ
//
//  Created by Casperon on 06/10/16.
//  Copyright © 2016 Casperon Technologies. All rights reserved.
//

import UIKit

class AvailableRecord: NSObject {
    var AvailDays:NSString=""
 var AvailMornigtime:NSString=""
    var AvailAftertime:NSString=""
    var Availeveningtime:NSString=""

    init(dayrec: String, mornigrec: String , Afterrec: String ,eveningrec: String) {
        
        AvailDays = dayrec as NSString
        AvailMornigtime = mornigrec as NSString
        AvailAftertime = Afterrec as NSString
        Availeveningtime = eveningrec as NSString
        super.init()
    }

}
