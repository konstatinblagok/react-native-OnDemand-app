//
//  TransactionViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 14/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class TransactionViewController: RootViewController,UIWebViewDelegate {

    @IBOutlet var TransationWebView: UIWebView!
    @IBOutlet var titleLbl: UILabel!

    @IBOutlet var Webload_progress: UIProgressView!
    var constant:Constant=Constant()
    var themes:Themes=Themes()
    
   
    @IBOutlet var backbtn: UIButton!
    var theBool: Bool=Bool()
    var myTimer: Timer=Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLbl.text = themes.setLang("transactions_caps")

 
        
        themes.Back_ImageView.image=UIImage(named: "")
        
        backbtn.addSubview(themes.Back_ImageView)
        
       
        
        Webload_progress.tintColor=themes.ThemeColour()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        if(Transaction_Stat.StripeStatus == true)
        {
        let url = URL (string: "\(constant.AppbaseUrl)/mobile/wallet-recharge/payform?user_id=\(themes.getUserID())&total_amount=\(Transaction_Stat.total_Amt)");
        let requestObj = URLRequest(url: url!);
        TransationWebView.loadRequest(requestObj);
        }
        else
        
        {
            
            let url = URL (string:Transaction_Stat.wallet_rechargeurl as String);
            let requestObj = URLRequest(url: url!);
            TransationWebView.loadRequest(requestObj);

            
        }
        

        self.Webload_progress.progress = 0.0
         TransationWebView.delegate=self
        
        let transform:CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 2.0);
        Webload_progress.transform = transform;
         // Do any additional setup after loading the view.
    }
    


    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let URL:NSString=(request.url?.absoluteString)! as NSString
        
        if (Transaction_Stat.StripeStatus == true)
        {

    
        if(URL.contains("/wallet-recharge/pay-cancel"))
        {
            themes.AlertView("\(Appname)", Message: themes.setLang("payment_is_cancelled"), ButtonTitle: kOk)
            self.navigationController?.popToRootViewController(animated: true)

            
        }
        else if(URL.contains("/mobile/payment/pay-completed"))
        {
            themes.AlertView(themes.setLang("Message"), Message: themes.setLang("payment_success"), ButtonTitle: kOk)
              self.navigationController?.popToRootViewController(animated: true)

        }
      else if(URL.contains("/mobile/mobile/failed"))
        {
            themes.AlertView("\(Appname)", Message:themes.setLang("payment_failed"), ButtonTitle: kOk)
            self.navigationController?.popToRootViewController(animated: true)

        }
        }
        else{
            
                if (URL.contains("mobile/mobile/paypalsucess"))
                {
                    themes.AlertView(themes.setLang("Message"), Message: themes.setLang("payment_success"), ButtonTitle: themes.setLang("ok"))
                    self.navigationController?.popToRootViewController(animated: true)
                    
                }
                else if (URL.contains("checkout/payment/paypal/cancel"))
                {
                    self.navigationController?.popToRootViewController(animated: true)
                    
                }
                else if (URL.contains("mobile/mobile/paypalsucess"))
                {
                    themes.AlertView("\(Appname)", Message: themes.setLang("payment_failed"), ButtonTitle: themes.setLang("ok"))
                    self.navigationController?.popToRootViewController(animated: true)
                    
                    
                }
                
            
        }
 
          return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
       funcToCallWhenStartLoadingYourWebview()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
    funcToCallCalledWhenUIWebViewFinishesLoading()
        
    }
    
    func funcToCallWhenStartLoadingYourWebview() {
        self.theBool = false
        self.myTimer = Timer.scheduledTimer(timeInterval: 0.01667, target: self, selector: #selector(TransactionViewController.timerCallback), userInfo: nil, repeats: true)
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
