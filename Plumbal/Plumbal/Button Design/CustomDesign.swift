//
//  CustomButton.swift
//  Plumbal
//
//  Created by Casperon Tech on 07/11/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

//MARK: - Custom Button

class CustomButton: UIButton {
    var themes:Themes=Themes()
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
         self.backgroundColor = PlumberLightGrayColor
         self.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.titleLabel?.font = UIFont.init(name: plumberMediumFont, size: 15)

     }
}

class TextColorButton: UIButton {
    var themes:Themes=Themes()
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(themes.ThemeColour(), forState: UIControlState.Normal)
        self.titleLabel?.font = UIFont.init(name: plumberMediumFont, size: 15)

    }
}

//MARK: - Custom TextField

class CustomTextField:UITextField{
    var themes:Themes=Themes()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.textColor = UIColor.whiteColor()
        self.font = UIFont.init(name: plumberMediumFont, size: 15)
     }
}

//MARK: - Custom Label

class CustomLabel: UILabel {
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        self.textColor=themes.ThemeColour()
       // self.font = UIFont.init(name: plumberMediumFont, size: 14)

    }
}

class CustomLabelWhite:UILabel{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.textColor=UIColor.whiteColor()
        self.font = UIFont.init(name: plumberMediumFont, size: 14)
    }
}
