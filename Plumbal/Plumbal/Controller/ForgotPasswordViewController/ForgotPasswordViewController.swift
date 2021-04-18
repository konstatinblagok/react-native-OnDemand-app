//
//  ForgotPasswordViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 15/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: RootViewController {
    
    @IBOutlet weak var forg_desc: CustomLabelWhite!
    @IBOutlet var send_Btn: UIButton!
    @IBOutlet var EmailID_TextField: UITextField!
    @IBOutlet var Header_lbl: UILabel!
    @IBOutlet var Tellus: UILabel!
    @IBOutlet var ForgotPas_Lbl: UILabel!
    @IBOutlet var Close_bt: UIButton!
    @IBOutlet var Wrapper_View: UIView!

    
    let themes:Themes=Themes()
    var URL_handler:URLhandler=URLhandler()
    
    //MARK: -Override Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Wrapper_View.layer.borderWidth=1.0
        Wrapper_View.layer.borderColor=UIColor.lightGray.cgColor
        Wrapper_View.layer.cornerRadius=3.0

        send_Btn.layer.cornerRadius = 5
        send_Btn.setTitle(themes.setLang("reset_password"), for: UIControlState())
//        send_Btn.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
//        send_Btn.titleLabel?.numberOfLines = 2
        ForgotPas_Lbl.text=themes.setLang("forgot_password")
      forg_desc.text = themes.setLang("reset_instruct")
        EmailID_TextField.backgroundColor = UIColor.clear
        

        
        EmailID_TextField.placeholder = themes.setLang("email_placeholder")
        OTP_sta.OTP_Paging="ForgotPassword"
        //        EmailID_TextField.layer.borderColor=themes.Lightgray().cgColor
        //        EmailID_TextField.layer.borderWidth=0.8
        EmailID_TextField.delegate=self
        let paddingView : UIView = UIView.init(frame:CGRect(x: 0, y: 0, width: 15, height: 20) )
        EmailID_TextField.leftView = paddingView
        EmailID_TextField.leftViewMode = .always
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == EmailID_TextField) {
            EmailID_TextField.resignFirstResponder()
        }
        return true
    }
    
    //MARK: - Button Action
    
    
    @IBAction func didClickoption(_ sender: UIButton) {
        if(sender.tag == 10){
            self.navigationController?.popViewControllerWithFlip(animated: false)
        }else if(sender.tag == 1) {
            _=themes.isValidEmail(EmailID_TextField.text!)
            if(EmailID_TextField.text == "") {
                themes.AlertView("\(Appname)", Message: themes.setLang("enter_email_alert"), ButtonTitle: kOk)
            }
              //  else if(Email_ID == false) {
//                themes.AlertView("\(Appname)", Message: themes.setLang("valid_email_alert"), ButtonTitle: kOk)
//            }
                
                else {
                self.send_Btn.isEnabled=false
                self.showProgress()
                let parameter=["email":"\(EmailID_TextField.text!)"]
                URL_handler.makeCall(constant.Reset_Password.trimmingCharacters(in: CharacterSet.whitespaces), param: parameter as NSDictionary, completionHandler: { (responseObject, error) -> () in
                    self.send_Btn.isEnabled=true
                    if(error != nil) {
                        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    } else{
                        if(responseObject != nil){
                            let dict:NSDictionary=responseObject!
                            let response=self.themes.CheckNullValue(dict.object(forKey: "response"))!
                            if(response == "Reset Code Sent Successfully!"){
                                let verification_code=dict.object(forKey: "verification_code") as! String
                                let OTP_Status=dict.object(forKey: "sms_status") as! String
                                let OTP_Email=dict.object(forKey: "email_address") as! String
                                if((OTP_Status as NSString).length>0){
                                    OTP_sta.OTP_Status=OTP_Status
                                    OTP_sta.OTP=verification_code
                                    OTP_sta.OTP_EmaiID=OTP_Email
                                    self.DismissProgress()
                                    let otpview : OTPViewController = OTPViewController()
                                    otpview.otpstring = "\(self.themes.CheckNullValue(dict.object(forKey: "verification_code"))!)"
                                    otpview.otpstatus_str = self.themes.CheckNullValue(dict.object(forKey: "sms_status"))!
                                    otpview.otpemail = self.themes.CheckNullValue(dict.object(forKey: "email_address"))!
                                    self.performSegue(withIdentifier: "OTP", sender: nil)
                                }
                            }else{
                                self.themes.AlertView("\(Appname)",Message: "\(response)",ButtonTitle: kOk)
                                self.DismissProgress()
                            }
                        } else{
                            self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                            self.DismissProgress()
                        }
                    }
                })
            }
        }
    }
}

extension ForgotPasswordViewController:UITextFieldDelegate
{
    
}
