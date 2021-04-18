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
         self.backgroundColor = PlumberThemeColor
         self.setTitleColor(UIColor.white, for: UIControlState())
        self.titleLabel?.font = PlumberLargeFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

     }
}

class CustomButtonSmall: UIButton {
    var themes:Themes=Themes()
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.backgroundColor = PlumberThemeColor
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.titleLabel?.font = PlumberMediumFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
}

class CustomBorderButtonSmall: UIButton {
    var themes:Themes=Themes()
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.borderWidth = 1.0
        self.layer.borderColor = PlumberThemeColor.cgColor
        self.backgroundColor = UIColor.clear
        self.setTitleColor(UIColor.black, for: UIControlState())
        self.titleLabel?.font = PlumberMediumFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
}




class CustomButtonThemeColor: UIButton {
    var themes:Themes=Themes()
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.blue, for: UIControlState())
        self.titleLabel?.font = PlumberLargeBoldFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

    }
}
class CustomButtonTitle: UIButton {
    var themes:Themes=Themes()
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.backgroundColor = PlumberLightGrayColor
        self.setTitleColor(UIColor.black, for: UIControlState())
        self.titleLabel?.font = PlumberLargeFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

    }
}

class Customimageview: UIImageView {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = UIColor.blue
  
    }
}
class TextColorButton: UIButton {
    var themes:Themes=Themes()
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.titleLabel?.font = PlumberSmallFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

    }
}

class TextColorButtonTheme: UIButton {
    var themes:Themes=Themes()
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(PlumberThemeColor, for: UIControlState())
        self.titleLabel?.font = PlumberMediumFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

    }
}

class TextColorButtonBlack: UIButton {
    var themes:Themes=Themes()
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.black, for: UIControlState())
        self.titleLabel?.font = PlumberMediumFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
}
class TextColorButtonWhite: UIButton {
    var themes:Themes=Themes()
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.titleLabel?.font = PlumberMediumFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

    }
}

class CustomButtonBold: UIButton {
    var themes:Themes=Themes()
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.black, for: UIControlState())
        self.titleLabel?.font = PlumberMediumBoldFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

    }
}

class CustomButtonHeader:UIButton{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.titleLabel?.font = PlumberLargeFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

    }
}

class CustomButtonHeaderBold:UIButton{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.titleLabel?.font = PlumberLargeBoldFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
}

class CustomButtonRed: UIButton {
    var themes:Themes=Themes()
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.red, for: UIControlState())
        self.titleLabel?.font = PlumberMediumBoldFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

        
    }
}

class CustomButtonGray: UIButton {
    var themes:Themes=Themes()
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.darkGray, for: UIControlState())
        self.titleLabel?.font = PlumberLargeBoldFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

        
    }
}


//MARK: - Custom TextField

class CustomTextField:UITextField{
    var themes:Themes=Themes()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.textColor = themes.ThemeColour()
        self.font = PlumberMediumFont

     }
}

class CustomTextFieldBlack:UITextField{
    var themes:Themes=Themes()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.textColor = themes.ThemeColour()
        self.layer.borderColor=themes.Lightgray().cgColor
        self.layer.borderWidth=0.8
        self.font = PlumberMediumFont
        
    }
}

class CustomTextBlack:UITextField{
    var themes:Themes=Themes()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.textColor = themes.ThemeColour()
        self.font = PlumberMediumFont
        
    }
}

class CustomTextgray:UITextField{
    var themes:Themes=Themes()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.textColor = UIColor.darkGray
        self.font = PlumberMediumFont
        
    }
}
//MARK: - Custom Label

class CustomLabel: UILabel {
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        self.font = PlumberMediumBoldFont
        self.adjustsFontSizeToFitWidth = true

    }
}
class CustomLabelLarge: UILabel {
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        self.textColor=themes.ThemeColour()
        self.font = PlumberLargeBoldFont
        self.adjustsFontSizeToFitWidth = true

    }
}
class CustomLabelThemeColor: UILabel {
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        self.textColor=PlumberThemeColor
        self.font = PlumberMediumBoldFont
        self.adjustsFontSizeToFitWidth = true

    }
}

class CustomLabelGray: UILabel {
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        self.textColor=UIColor.darkGray
        self.font = PlumberMediumFont
        self.adjustsFontSizeToFitWidth = true

    }
}

class CustomLabelGraySmall: UILabel {
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        self.textColor=UIColor.darkGray
        self.font = PlumberSmallFont
        self.adjustsFontSizeToFitWidth = true

    }
}

class CustomLabelLightGray: UILabel {
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        self.textColor=UIColor.lightGray
        self.font = PlumberMediumFont
        self.adjustsFontSizeToFitWidth = true

    }
}

class CustomLabelWhite:UILabel{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.textColor=UIColor.white
        self.font = PlumberMediumFont
        self.adjustsFontSizeToFitWidth = true

    }
}

class CustomLabelHeader:UILabel{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.textColor=UIColor.white
        self.font = PlumberLargeFont
        self.adjustsFontSizeToFitWidth = true
}
}

class CustomLabelRed:UILabel{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.textColor=UIColor.red
        self.font = PlumberMediumFont
        self.adjustsFontSizeToFitWidth = true

    }
}
