//
//  DashBoardView.swift
//  Plumbal
//
//  Created by Casperon Tech on 16/12/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class DashBoardView: UIImageView {
    
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        // self.backgroundColor = PlumberThemeColor
        if(self.tag == 0)
        {
        self.image=UIImage(named: "dashboard_bg")
        }
        
     }


    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
