//
//  WalkThroughViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 11/12/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class WalkThroughViewController: RootViewController {

    @IBOutlet weak var HeaderImage: UIImageView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var descLbl: UILabel!
    var pageIndex: NSInteger = 0
    var titleText: NSString?
    var imgText: NSString?
    var descText: NSString?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        HeaderImage.image = UIImage(named: titleText as! String)
        descLbl.text=descText! as String;
         imgView.image=UIImage(named: imgText as! String)
         descLbl.textAlignment = .center

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
