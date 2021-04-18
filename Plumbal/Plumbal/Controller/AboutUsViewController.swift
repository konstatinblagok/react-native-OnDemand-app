//
//  AboutUsViewController.swift
//  Plumbal
//
//  Created by Casperon on 03/10/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit

class AboutUsViewController: RootViewController {

    @IBOutlet weak var headerlable: CustomLabelHeader!
      @IBOutlet var Titlelable: UILabel!
    @IBOutlet var versionlabl: UILabel!
    @IBOutlet var abtwebview: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        headerlable.text = themes.setLang("about_us")
        let version = ( Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
        

        Titlelable.text = "\(themes.setLang("powered_by")) : \(Appname) (\(version))"

        
        let url = URL (string:constant.about_usUrl as String);
        let requestObj = URLRequest(url: url!);
     abtwebview.loadRequest(requestObj);
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuuact(_ sender: AnyObject) {
        self.findHamburguerViewController()?.showMenuViewController()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
