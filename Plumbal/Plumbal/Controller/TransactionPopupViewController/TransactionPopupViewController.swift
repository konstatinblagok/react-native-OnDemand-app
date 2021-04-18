//
//  TransactionPopupViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 12/12/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class TransactionPopupViewController:RatingsViewController,UIWebViewDelegate {
    @IBOutlet var TransationWebView: UIWebView!
    @IBOutlet var Webload_progress: UIProgressView!
    var theBool: Bool=Bool()
    var myTimer: Timer=Timer()
    // var themes:Themes=Themes()
 
   
    @IBOutlet var backbtn: UIButton!

    @IBOutlet var Transaction_Lbl: UILabel!

    override func viewDidLoad() {
               
        themes.Back_ImageView.image=UIImage(named: "")
        
        backbtn.addSubview(themes.Back_ImageView)

        Webload_progress.tintColor=themes.ThemeColour()
        
        // Do any additional setup after loading the view, typically from a nib.
        
               let paymentUrl : String

        paymentUrl = Payment_Detail.PaymentUrl as String
        
        NSLog("Get payment Url=%@", paymentUrl)
             let url = URL (string:paymentUrl);
            let requestObj = URLRequest(url: url!);
            TransationWebView.loadRequest(requestObj);
         self.Webload_progress.progress = 0.0
        TransationWebView.delegate=self
        
        let transform:CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 2.0);
        Webload_progress.transform = transform;


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let URL:NSString=(request.url?.absoluteString)! as NSString
        
        
        print("contain Transaction \(URL)")
        
        
        if (Payment_Detail.paymentmode == "paypal")
        {
            if(URL.contains("/mobile/mobile/paypalsucess"))
            {
                themes.AlertView(themes.setLang("hurray"), Message: themes.setLang("payment_success"), ButtonTitle: kOk)
                // self.performSegueWithIdentifier("RatingVC", sender: nil)
                let Controller:RatingsViewController=self.storyboard?.instantiateViewController(withIdentifier: "ReviewPoup") as! RatingsViewController
                self.navigationController?.pushViewController(withFlip: Controller, animated: true)

                
            }
            else if (URL.contains("/payment/paypal/cancel"))
            {
                themes.AlertView("\(Appname)", Message: themes.setLang("payment_cancelled"), ButtonTitle: kOk)
                self.navigationController?.popToRootViewController(animated: true)
            }
                
           
          
        }
        
        else{
        
        if(URL.contains("/mobile/payment/pay-completed"))
        {
            themes.AlertView(themes.setLang("hurray"), Message:themes.setLang("payment_success"), ButtonTitle: kOk)
           // self.performSegueWithIdentifier("RatingVC", sender: nil)
            let Controller:RatingsViewController=self.storyboard?.instantiateViewController(withIdentifier: "ReviewPoup") as! RatingsViewController
            self.navigationController?.pushViewController(withFlip: Controller, animated: true)

            
        }
        
       else if(URL.contains("mobile/mobile/failed"))
        {
            themes.AlertView("\(Appname)", Message: themes.setLang("payment_failed"), ButtonTitle: kOk)
            self.navigationController?.popToRootViewController(animated: true)
            
            
        }
         else if(URL.contains("/mobile/payment/pay-cancelled"))
        {
            themes.AlertView("\(Appname)", Message: themes.setLang("payment_failed"), ButtonTitle: kOk)
            self.navigationController?.popToRootViewController(animated: true)
            
        }
        }
        
        return true
    }
    
    func applicationLanguageChangeNotification(_ notification:Notification)
    {
        
        //        themes.setLang(
        
        //        themes.setLang("Full Name",comment: nil)
        
        Transaction_Lbl.text=themes.setLang("Transaction")
        
    }

    
    func webViewDidStartLoad(_ webView: UIWebView) {
        funcToCallWhenStartLoadingYourWebview()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        funcToCallCalledWhenUIWebViewFinishesLoading()
        
    }
    
    func funcToCallWhenStartLoadingYourWebview() {
        self.theBool = false
        self.myTimer = Timer.scheduledTimer(timeInterval: 0.01667, target: self, selector: #selector(TransactionPopupViewController.timerCallback), userInfo: nil, repeats: true)
    }
    
    func funcToCallCalledWhenUIWebViewFinishesLoading() {
        self.theBool = true
    }
    
    func timerCallback() {
        if self.theBool {
            if self.Webload_progress.progress >= 1 {
                self.Webload_progress.isHidden = true
                self.myTimer.invalidate()
            } else {
                self.Webload_progress.progress += 0.1
            }
        } else {
            self.Webload_progress.progress += 0.05
            if self.Webload_progress.progress >= 0.95 {
                self.Webload_progress.progress = 0.95
            }
        }
    }
    

    
    
    @IBAction func didClickoption(_ sender: UIButton) {
        
        if(sender.tag == 0)
        {
            self.navigationController?.popToRootViewController(animated: true)
        }
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
