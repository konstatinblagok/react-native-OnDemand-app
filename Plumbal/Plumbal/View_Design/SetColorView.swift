//
//  SetColorView.swift
//  PlumberJJ
//
//  Created by Casperon Technologies on 10/27/15.
//  Copyright © 2015 Casperon Technologies. All rights reserved.
//

import UIKit

class SetColorView: UIView {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.backgroundColor = PlumberThemeColor
        for subView in self.subviews {
            if subView .isKind(of: UILabel.self){
                if let label = subView as? UILabel{
                label.textColor=UIColor.white
                label.font = PlumberLargeBoldFont
                }
            }
        }
    }
}


/* class SetHeaderView:UIView{
    
    init(labelText:String,backImage:String,viewFrame:CGRect){
        super.init(frame:viewFrame)
        self.backgroundColor = PlumberThemeColor
        let label = UILabel.init(frame: CGRectMake(0, 0, self.frame.width, self.frame.height))
        label.backgroundColor = UIColor.clear
        label.text = labelText
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.init(name: plumberMediumFont, size: 14)
        label.textAlignment = .Center
        self.addSubview(label)
        let button = UIButton.init(frame: CGRectMake(0, 0, self.frame.width/3, self.frame.height))
        button.setImage(UIImage.init(named: backImage), forState: UIControlState.Normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(-15, 15, 15, 3)
        self.addSubview(button)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        fatalError("init(coder:) has not been implemented")
    }
    
} */
