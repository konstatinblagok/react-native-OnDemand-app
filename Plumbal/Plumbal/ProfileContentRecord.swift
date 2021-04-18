//
//  ProfileContentRecord.swift
//  PlumberJJ
//
//  Created by Casperon Technologies on 11/7/15.
//  Copyright © 2015 Casperon Technologies. All rights reserved.
//

import UIKit


class ProfileContentRecord: NSObject {
    var UserId:NSString=""
    var Title:NSString=""
    var email:NSString=""
     var Address:NSString=""
    var userDesc:NSString=""
    var IsMobile:NSString=""
    var userImage:NSString=""
    
    init(userTitle: String, desc: String) {
       
        Title = userTitle as NSString
        userDesc = desc as NSString
        super.init()
    }
}
