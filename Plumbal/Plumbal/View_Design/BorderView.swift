//
//  BorderView.swift
//  Plumbal
//
//  Created by Casperon Tech on 17/12/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class BorderView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var themes:Themes=Themes()
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        // self.backgroundColor = PlumberThemeColor
        
        self.backgroundColor=PlumberThemeColor
    }
    


}
