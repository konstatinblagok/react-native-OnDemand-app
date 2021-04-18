//
//  Nodata.swift
//  Plumbal
//
//  Created by Casperon Tech on 28/11/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class Nodata: UIView {
    @IBOutlet var pullRef_lbl:UILabel!
    @IBOutlet var Noorder_lbl:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        loadFromNibNamed("Nodata")

        

     }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
     }
    
    func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        
        pullRef_lbl.text = themes.setLang("pull_refresh")
        Noorder_lbl.text = themes.setLang("no_order_yet")
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }



    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

extension UIView {
    class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}
