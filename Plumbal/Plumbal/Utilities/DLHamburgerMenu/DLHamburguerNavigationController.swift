//
//  DLHamburguerNavigationController.swift
//  DLHamburguerMenu
//
//  Created by Nacho on 5/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

class DLHamburguerNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
      //  self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panGestureRecognized:"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
//    func panGestureRecognized(sender: UIPanGestureRecognizer!) {
//        // dismiss keyboard
//        if(self.visibleViewController?.restorationIdentifier == "HomePageVCID" || self.visibleViewController?.restorationIdentifier == "ProfileVCID" || self.visibleViewController?.restorationIdentifier == "OrderVCID" || self.visibleViewController?.restorationIdentifier == "EmergencyVCID" || self.visibleViewController?.restorationIdentifier == "InviteVCID" || self.visibleViewController?.restorationIdentifier == "WalletVCID")//PaymentVCID//
//        {
//        self.view.endEditing(true)
//        self.findHamburguerViewController()?.view.endEditing(true)
//        
//        // pass gesture to hamburguer view controller.
//        self.findHamburguerViewController()?.panGestureRecognized(sender)
//        }
//    }
    
}
