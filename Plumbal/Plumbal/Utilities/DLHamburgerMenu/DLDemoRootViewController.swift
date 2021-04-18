//
//  DLDemoRootViewController.swift
//  DLHamburguerMenu
//
//  Created by Nacho on 5/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

class DLDemoRootViewController: DLHamburguerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.SetRootView(notifi:)), name: NSNotification.Name(rawValue: "MakerootView"), object: nil)
        
        // Do any additional setup after loading the view.
    }
    func SetRootView(notifi:NSNotification)
    {
        self.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "\(notifi.object!)")
        self.menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuVCID")

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        self.contentViewController = (self.storyboard?.instantiateViewController(withIdentifier: "HomePageVCID"))! as UIViewController
        self.menuViewController = (self.storyboard?.instantiateViewController(withIdentifier:"MenuVCID"))! as UIViewController
    }
}
