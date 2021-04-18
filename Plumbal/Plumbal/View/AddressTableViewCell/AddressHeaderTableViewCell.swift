//
//  AddressHeaderTableViewCell.swift
//  Plumbal
//
//  Created by Casperon Tech on 02/11/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit
import AKPickerView

class AddressHeaderTableViewCell: UITableViewCell {
 
    @IBOutlet var Addaddress_Lbl: UILabel!
    @IBOutlet var AddAddress_View: UIView!
    @IBOutlet var Timepicker: AKPickerView!
    var themes:Themes=Themes()
     override func awakeFromNib() {
        super.awakeFromNib()
        Addaddress_Lbl.text = themes.setLang("add_address_title")

        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: Timepicker.frame.size.height, width: Timepicker.frame.size.width+100, height: 1.0)
        bottomBorder.backgroundColor =  themes.ThemeColour().cgColor
        Timepicker.layer.addSublayer(bottomBorder)
        
        
        
//        let border_Timepicker = CALayer()
//        let width_Timepicker = CGFloat(1.0)
//        border_Timepicker.borderColor = themes.ThemeColour().cgColor
//        border_Timepicker.frame = CGRect(x: 0, y: Timepicker.frame.size.height - width_Timepicker, width:  414, height: Timepicker.frame.size.height)
//        border_Timepicker.borderWidth = width_Timepicker
//        Timepicker.layer.addSublayer(border_Timepicker)
        Timepicker.layer.masksToBounds = false
        
         Timepicker.font = UIFont(name: "Roboto-Regular", size: 16.0)
        Timepicker.highlightedFont = UIFont(name: "Roboto-Bold", size: 16.0)
         Timepicker.interitemSpacing = 16.0
        Timepicker.pickerViewStyle = .style3D
        Timepicker.fisheyeFactor=0.001
         Timepicker.isMaskDisabled = false;
       // Timepicker.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(UIViewAutoresizing.FlexibleHeight)


        
        
      //  self.AddAddress_View.layer.borderColor=themes.ThemeColour().cgColor
        
        
     //   self.AddAddress_View.layer.borderWidth=1.0


        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
