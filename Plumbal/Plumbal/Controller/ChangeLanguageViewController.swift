//
//  ChangeLanguageViewController.swift
//  Plumbal
//
//  Created by Casperon iOS on 10/10/2017.
//  Copyright © 2017 Casperon Tech. All rights reserved.
//

import UIKit

class ChangeLanguageViewController: UIViewController {
    
    @IBOutlet var Tamil: UIButton!
    
    @IBOutlet var English: UIButton!
    
    @IBOutlet var lang_change: UILabel!
 var current_language = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lang_change.text =  themes.setLang("lang_change")
        Tamil.setTitle("Tamil", for: UIControlState())
        English.setTitle("Set", for: UIControlState())
        if themes.getAppLanguage() == "en"{
            Tamil.setTitle("English", for: UIControlState())
        }
        else{
            Tamil.setTitle("Tamil", for: UIControlState())
        }
       
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
//    @IBAction func didClickButton(sender:UIButton){
//        if sender.titleLabel?.text == "English"{
//            UIView.transitionWithView(sender, duration: 1, options: .TransitionFlipFromRight, animations: {() -> Void in
//                sender.setTitle(themes.setLang("arabic"), forState: .Normal)
//
//
//                if #available(iOS 9.0, *) {
//                    UIView.appearance().semanticContentAttribute = .ForceRightToLeft
//                } else {
//                    // Fallback on earlier versions
//                }
//            }, completion: { _ in
//            })
//
//        }else{
//            UIView.transitionWithView(sender, duration: 1, options: .TransitionFlipFromRight, animations: {() -> Void in
//                sender.setTitle("English", forState: .Normal)
//
//                if #available(iOS 9.0, *) {
//                    UIView.appearance().semanticContentAttribute = .ForceLeftToRight
//                } else {
//                    // Fallback on earlier versions
//                }
//
//            }, completion: { _ in    })
//
//        }
//
//
//    }
//
    
    
    
    
    
    @IBAction func Tamil(_ sender: AnyObject) {
        if sender.titleLabel!?.text == "English"{
        UIView.transition(with: sender as! UIView, duration: 1, options: .transitionFlipFromRight, animations: {() -> Void in
            
            sender.setTitle("Tamil", for: .normal)
                
             themes.saveLanguage("ta")
            },
                          completion: { _ in
            })
        }
        else
        {
            UIView.transition(with: sender as! UIView, duration: 1, options: .transitionFlipFromRight, animations: {() -> Void in
                
                
                sender.setTitle("English", for: .normal)
                 themes.saveLanguage("en")
                
            },
                              completion: { _ in
            })
            
            
        }

    }
    
    
    @IBAction func English(_ sender: AnyObject)
    {
        
        if themes.getAppLanguage() == "en"{
        
         themes.SetLanguageToApp()
         SwapLanguage(language: themes.getAppLanguage())
        }
        else{
        
         themes.SetLanguageToApp()
         SwapLanguage(language: themes.getAppLanguage())
        }
      
    }
    
    
    @IBAction func back(_ sender: AnyObject)
    {
        self.findHamburguerViewController()?.showMenuViewController()
    }
    
    
    
    
}
