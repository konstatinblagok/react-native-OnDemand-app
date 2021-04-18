//
//  OTPViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 08/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class OTPViewController: RootViewController {
    
    @IBOutlet var Kindly_enter: UILabel!
    @IBOutlet var OTPText_Field: UITextField!
    @IBOutlet var Close_Btn: UIButton!
    @IBOutlet var Continue_Btn: TKTransitionSubmitButton!
    @IBOutlet var Header_Lbl: UILabel!
    
    var otpstring : String!
    var otpstatus_str: String!
    var otpemail : String!
    var themes:Themes=Themes()
    var URL_handler:URLhandler=URLhandler()
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        OTPText_Field.textAlignment = .center
        
        Continue_Btn.layer.cornerRadius = 5
        Header_Lbl.text="\(Appname)"
        
        OTPText_Field.placeholder="Enter OTP"
        
        
        if(OTP_sta.OTP_Status == "development")
        {
            OTPText_Field.text=OTP_sta.OTP as String
            
            OTPText_Field.isEnabled=false
        }
            
        else
        {
            OTPText_Field.isEnabled=true
        }
        
        if let _ :OTP = OTP_sta { // If casting, use, eg, if let var = abc as? NSString
            
            
        } else {
            if(otpstatus_str == "development")
            {
                OTPText_Field.text=otpstring as String
                
                OTPText_Field.isEnabled=false
            }
                
            else
            {
                OTPText_Field.isEnabled=true
            }
        }
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Continue_Btn.returnToOriginalState()
        Close_Btn.setTitle(themes.setLang("close"), for: UIControlState())
        Kindly_enter.text=themes.setLang("kindly_enter_otp")
        Continue_Btn.setTitle(themes.setLang("continue"), for: UIControlState())
        
        OTPText_Field.placeholder=themes.setLang("enter_otp")

        self.view.backgroundColor = PlumberThemeColor
        
        
        // Do any additional setup after loading the view.
    }
    
    func applicationLanguageChangeNotification(_ notification:Notification)
    {
        
        //        themes.setLang(
        
        //        themes.setLang("Full Name")
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickOption(_ sender: UIButton) {
        
        if(sender.tag == 0)
        {
            
            
            self.navigationController?.popViewControllerWithFlip(animated: true)
            
        }
        else if(sender.tag == 1)
        {
            
            
            self.DismissProgress()
            
            if(OTP_sta.OTP_Paging == "ForgotPassword")
            {
                
                if(OTP_sta.OTP_Status == "development")
                {
                   
                    self.performSegue(withIdentifier: "Reset_Password", sender: nil)
                    
                }
                else
                {
                    
                    if(OTP_sta.OTP as String == self.OTPText_Field.text!)
                    {
                        self.DismissProgress()
                        self.performSegue(withIdentifier: "Reset_Password", sender: nil)
                        
                    }
                        
                    else
                    {
                        self.themes.AlertView("\(Appname)",Message:themes.setLang("otp_not_match"),ButtonTitle: kOk)
                        
                        
                    }
                    
                }
                
                
                
            }
                
            else if(OTP_sta.OTP_Paging == "FacebookSignup")
            {
                
                
                if(OTP_sta.OTP_Status == "development")
                {
                    
                    
                    self.FB_register()
                }
                else
                {
                    if(OTP_sta.OTP as String == self.OTPText_Field.text!)
                    {
                        self.FB_register()
                        
                    }
                        
                    else
                    {
                        self.themes.AlertView("\(Appname)",Message:themes.setLang("otp_not_match"),ButtonTitle: kOk)
                        
                    }
                }
                
                
            }
                
            else if(OTP_sta.OTP_Paging == "SignUp")
            {
                
                
                if(OTP_sta.OTP_Status == "development")
                {
                    
                    self.register()
                }
                else
                {
                    if(OTP_sta.OTP as String == self.OTPText_Field.text!)
                    {
                        self.register()
                        
                    }
                        
                    else
                    {
                        self.themes.AlertView("\(Appname)",Message:themes.setLang("otp_not_match"),ButtonTitle: kOk)
                        
                    }
                    
                    
                }
                
                
                
            }
                
            else if(OTP_sta.OTP_Paging == "EditProfile")
            {
                
                
                if(OTP_sta.OTP_Status == "development")
                {
                    
                    
                    self.Change_MobileNum()
                }
                else
                {
                    if(OTP_sta.OTP as String == self.OTPText_Field.text!)
                    {
                        self.Change_MobileNum()
                        
                    }
                        
                    else
                    {
                        self.themes.AlertView("\(Appname)",Message:themes.setLang("otp_not_match"),ButtonTitle: kOk)
                        
                    }
                    
                    
                }
                
                
                
            }
            
            
            
        }
        
        
        
        
        
    }
    func Change_MobileNum()
    {
        
        self.showProgress()
        
        let parameters:NSDictionary=["user_id":"\(themes.getUserID())",
                                     "country_code":"\(Edit_Prof.Country_Code)",
                                     "phone_number":"\(Edit_Prof.Contact_Number)","otp":"\(OTPText_Field.text!)"]
        URL_handler.makeCall(constant.changemobilenumber, param: parameters) { (responseObject, error) -> () in
            self.DismissProgress()
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                
                //self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
            }
                
            else
            {
                
                if(responseObject != nil)
                    
                    
                {
                    
                    self.DismissProgress()
                    let Dict:NSDictionary=responseObject!
                    let Status=self.themes.CheckNullValue(Dict.object(forKey: "status"))!
                    if(Status  == "1")
                    {
                        
                        self.themes.saveMobileNum(Edit_Prof.Contact_Number as String)
                        self.themes.saveCountryCode(Edit_Prof.Country_Code as String)
                        let Reponse=self.themes.CheckNullValue(Dict.object(forKey: "response"))!
                        self.themes.AlertView("\(Appname)", Message: "\(Reponse)", ButtonTitle: self.themes.setLang("ok"))
                        self.navigationController?.popViewControllerWithFlip(animated: true)
                        
                    }
                    else
                    {
                        let Reponse=self.themes.CheckNullValue(Dict.object(forKey: "response"))!
                        self.themes.AlertView("\(Appname)", Message: "\(Reponse)", ButtonTitle: self.themes.setLang("ok"))
                        
                    }
                    
                }
                else
                {
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                }
            }
        }
        
        
    }
    
    func register()
    {
        let parameter=["first_name":"\(signup.firstname)","last_name":"\(signup.lastname)","user_name":"\(signup.username)","email":"\(signup.Email)","password":"\(signup.Password)","country_code":"\(signup.Country_Code)","phone_number":"\(signup.Contact_num)","unique_code":"\(signup.referralCode)","deviceToken":"\(Device_Token)","gcm_id":""]
        
        self.Continue_Btn.startLoadingAnimation()
        
        URL_handler.makeCall(constant.Register.trimmingCharacters(in: CharacterSet.whitespaces), param: parameter as NSDictionary, completionHandler: { (responseObject, error) -> () in
            
            if(error != nil)
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.Continue_Btn.returnToOriginalState()
                })
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                
                //self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
            }
                
            else
            {
                if(responseObject != nil)
                {
                    
                    
                    let dict:NSDictionary=responseObject!
                    
                    
                    
                    signup.status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                    
                    if (signup.status == "1")
                    {
                        
                        signup.username=dict.object(forKey: "user_name") as! String
                        signup.Email=dict.object(forKey: "email") as! String
                        // signup.Password=dict.objectForKey("key") as! NSString
                        signup.Contact_num=dict.object(forKey: "phone_number") as! String
                        signup.currency=dict.object(forKey: "currency") as! String
                        signup.Walletamt = self.themes.CheckNullValue(dict.object(forKey: "wallet_amount"))!
                        signup.Userimage=dict.object(forKey: "user_image") as! String
                        signup.Userid=dict.object(forKey: "user_id") as! String
                        signup.Country_Code = dict.object(forKey: "country_code") as! String
                        
                        signup.currency_Sym=self.themes.Currency_Symbol(signup.currency as String)
                        self.themes.saveCountryCode(signup.Country_Code as String!)
                        self.themes.saveLocationname(signup.Locationname as String)
                        self.themes.saveCurrency(signup.Walletamt as String)
                        self.themes.saveCurrencyCode(signup.currency_Sym as String)
                        self.themes.saveUserID(signup.Userid as String)
                        self.themes.saveUserPasswd(signup.Password as String)
                        self.themes.saveUserName(signup.username as String)
                        self.themes.saveEmailID(signup.Email as String)
                        self.themes.saveuserDP(signup.Userimage as String)
                        self.themes.saveMobileNum(signup.Contact_num as String)
                        self.themes.saveWalletAmt(signup.Walletamt as String)
                        self.themes.saveJaberID(signup.user_id as String)
                        self.themes.saveJaberPassword(signup.soc_key as String)
                        
                        SocketIOManager.sharedInstance.establishConnection()
                        
                        SocketIOManager.sharedInstance.establishChatConnection()
                        
                        self.Continue_Btn.startFinishAnimation(1, completion: {
                            Appdel.MakeRootVc("RootVCID")
                            
                        })
                        
                        
                    }
                    else
                    {
                        self.Continue_Btn.returnToOriginalState()
                        signup.message = self.themes.CheckNullValue(dict.object(forKey: "message"))!
                        
                        self.themes.AlertView("\(Appname)",Message: "\(signup.message)",ButtonTitle: self.themes.setLang("ok"))
                        
                    }
                    
                }
                    
                else
                {
                    self.Continue_Btn.returnToOriginalState()
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    
                    
                }
            }
            
            
            return
        })
    }
    
    func FB_register()
    {
        
        
        
        let parameter=["user_name":"\(signup.username)","fb_id":"\(FB_Regis.FB_UserId)","email_id":"\(signup.Email)","first_name":"\(signup.firstname)","country_code":"\(signup.Country_Code)","phone":"\(signup.Contact_num)","last_name":"\(signup.lastname)","deviceToken":"\(Device_Token)","gcm_id":"","prof_pic":"\(FB_Regis.FB_Picture)"]
        
        
        self.Continue_Btn.startLoadingAnimation()
        URL_handler.makeCall(constant.Social_Register.trimmingCharacters(in: CharacterSet.whitespaces), param: parameter as NSDictionary, completionHandler: { (responseObject, error) -> () in
            if(error != nil)
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.Continue_Btn.returnToOriginalState()
                })
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                
                //self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
            }
                
            else
            {
                if(responseObject != nil)
                {
                    
                    
                    let dict:NSDictionary=responseObject!
                    
                    
                    
                    signup.status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                    
                    if (signup.status == "1")
                    {
                        
                        
                        
                        
                        self.DismissProgress()
                        signup.username = self.themes.CheckNullValue(dict.object(forKey: "user_name"))!
                        // signup.Email = self.themes.CheckNullValue(dict.objectForKey("email") as! NSString
                        signup.Contact_num=self.themes.CheckNullValue(dict.object(forKey: "phone_number"))!
                        signup.currency=self.themes.CheckNullValue(dict.object(forKey: "currency"))!
                        signup.Walletamt=self.themes.CheckNullValue(dict.object(forKey: "wallet_amount"))!
                        signup.Userimage=self.themes.CheckNullValue(dict.object(forKey: "prof_pic"))!
                        signup.Userid=self.themes.CheckNullValue(dict.object(forKey: "user_id"))!
                        signup.Country_Code=self.themes.CheckNullValue(dict.object(forKey: "country_code"))!
                        
                        
                        
                        signup.currency_Sym=self.themes.Currency_Symbol(signup.currency as String)
                        self.themes.saveCountryCode(signup.Country_Code as String!)
                        self.themes.saveCurrency(signup.Walletamt as String)
                        self.themes.saveCurrencyCode(signup.currency_Sym as String)
                        self.themes.saveUserID(signup.Userid as String)
                        self.themes.saveUserName(signup.username as String)
                        self.themes.saveEmailID(signup.Email as String)
                        self.themes.saveuserDP(signup.Userimage as String)
                        self.themes.saveMobileNum(signup.Contact_num as String)
                        self.themes.saveWalletAmt(signup.Walletamt as String)
                        self.themes.saveJaberID(signup.user_id as String)
                        
                        SocketIOManager.sharedInstance.establishConnection()
                        
                        SocketIOManager.sharedInstance.establishChatConnection()
                        
                        self.Continue_Btn.startFinishAnimation(1, completion: {
                            Appdel.MakeRootVc("RootVCID")

                        })
                    }
                    else
                    {
                        self.Continue_Btn.returnToOriginalState()

                        signup.message=dict.object(forKey: "message") as! String
                        
                        self.themes.AlertView("\(Appname)",Message: "\(signup.message)",ButtonTitle: self.themes.setLang("ok"))
                        
                    }
                    
                }
                    
                else
                {
                    self.Continue_Btn.returnToOriginalState()

                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    self.DismissProgress()
                    
                    
                }
            }
            
            return
        })
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
