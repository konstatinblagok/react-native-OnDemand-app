//
//  SwapLanguage.swift
//  Plumbal
//
//  Created by Casperon iOS on 10/10/2017.
//  Copyright © 2017 Casperon Tech. All rights reserved.
//

import UIKit

class SwapLanguage: NSObject {
    
    
    var storyboard : UIStoryboard{
        
        get{
            if themes.getAppLanguage() == "en"{
                return UIStoryboard(name: "Main", bundle: nil)
            }
            else {
                return UIStoryboard(name: "Main", bundle: nil)
            }
        }
        set{
            
        }
    }
    
    override init() {
        super.init()
        if themes.getAppLanguage() == "en"{
            storyboard = UIStoryboard(name: "Main", bundle: nil)
        }
        else{
            storyboard = UIStoryboard(name: "Main", bundle: nil)
        }
    }
    
    convenience init(language : String) {
        self.init()
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.setInitialViewcontroller()
    }
    
    
}
