//
//  BorderLabel.swift
//  Plumbal
//
//  Created by Casperon Tech on 30/12/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class BorderLabel: UILabel {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        // self.backgroundColor = PlumberThemeColor
        
        self.backgroundColor=themes.ThemeColour()
    }
    


}
