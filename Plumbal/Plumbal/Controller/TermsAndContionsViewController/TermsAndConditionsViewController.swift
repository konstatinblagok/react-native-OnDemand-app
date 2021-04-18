//
//  TermsAndConditionsViewController.swift
//  Plumbal
//
//  Created by casperon_macmini on 04/08/17.
//  Copyright © 2017 Casperon Tech. All rights reserved.
//

import UIKit

class TermsAndConditionsViewController: UIViewController,UIWebViewDelegate  {
  @IBOutlet var Webload_progress: UIProgressView!
      @IBOutlet var termsWeb_View: UIWebView!
     @IBOutlet var back_Btn: UIButton!
    @IBOutlet var title_Lbl: UILabel!
    var url_String:String = String()
    override func viewDidLoad() {
        super.viewDidLoad()

          var loading_Url : String = String()
        
        if   url_String == " Terms and Conditions"{
           // title_Lbl.text = "\(url_String)"
            loading_Url = "termsandconditions"
            
        }
            
        else if   url_String == " Privacy Policy" {
            // title_Lbl.text = "\(url_String)"
            loading_Url = "privacypolicy"
            
        }
            
        else if  url_String == " AboutUs"{
            
            loading_Url = "aboutus"
        }
        
        title_Lbl.text = "\(url_String)"
        themes.Back_ImageView.image=UIImage(named: "")
        back_Btn.addSubview(themes.Back_ImageView)
        Webload_progress.tintColor=themes.ThemeColour()
        
        // Do any additional setup after loading the view, typically from a nib.
        
       //let form_Url = NSURL(string: "\(constant.AppbaseUrl)/mobile/:\(loading_Url))")

       //paymentUrl = Payment_Detail.PaymentUrl as String
        
       // NSLog("Get payment Url=%@", loading_Url)
        
        let url = URL(string:"\(constant.AppbaseUrl)/app/mobile/\(loading_Url)")
        
        let requestObj = URLRequest(url: url!);
        termsWeb_View.loadRequest(requestObj);
        self.Webload_progress.progress = 0.0
        termsWeb_View.delegate=self
        
        let transform:CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 2.0);
        Webload_progress.transform = transform;
        

        // Do any additional setup after loading the view.
    }

    @IBAction func backBtn_Action(_ sender: UIButton) {
        
        self.navigationController?.popViewControllerWithFlip(animated: true)
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
