//
//  FacebookRegisterViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 14/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class FacebookRegisterViewController: RootViewController,UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var firstname: UITextField!
    @IBOutlet var lastname: UITextField!
    @IBOutlet var username: UITextField!
 //   @IBOutlet var ShowPas_Lbl: UILabel!
    @IBOutlet var Signup_Btn: TKTransitionSubmitButton!
    @IBOutlet var Email_TextField: UITextField!
    @IBOutlet var CountryCode_Picker: UIPickerView!
    @IBOutlet var UserImage: UIImageView!
    @IBOutlet var Picker_Wrapper: UIView!
    
    @IBOutlet var FB_ScrollView: UIScrollView!
    @IBOutlet var CountryCode_TextField: UITextField!
    @IBOutlet var ContactField: UITextField!
    var URL_handler:URLhandler=URLhandler()
    @IBOutlet var Wrapper_view: UIView!
    
    @IBOutlet var checkBox_Btn: UIButton!
    
    @IBOutlet var termsAndConditions_TxtView: UITextView!


    
    var themes:Themes=Themes()
    override func viewDidLoad() {
        super.viewDidLoad()
        Signup_Btn.returnToOriginalState()
        Signup_Btn.backgroundColor = PlumberThemeColor
        Signup_Btn.setTitleColor(UIColor.white, for: UIControlState())
        Signup_Btn.titleLabel?.font = PlumberLargeFont
        Signup_Btn.titleLabel?.adjustsFontSizeToFitWidth = true

        //Status For paging.
        Wrapper_view.layer.borderWidth=1.0
        Wrapper_view.layer.borderColor=UIColor.lightGray.cgColor
        Wrapper_view.layer.cornerRadius=3.0

        FB_ScrollView.isScrollEnabled = true;
        titleLbl.text = themes.setLang("register")
        FB_ScrollView.contentSize = CGSize(width: self.FB_ScrollView.frame.size.width, height: Signup_Btn.frame.origin.y+Signup_Btn.frame.size.height+30)

        if(themes.getCounrtyphone() != ""){
            CountryCode_TextField.text = "+ \(themes.getCounrtyphone())"
            
        }
Email_TextField.isMandatory()
        firstname.isMandatory()
        lastname.isMandatory()
        username.isMandatory()
        ContactField.isMandatory()
        
        //Text Field Delegate
      
        Email_TextField.autocapitalizationType = .none;
        
//        CountryCode_Picker.showsSelectionIndicator = true
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
//        let doneButton = UIBarButtonItem(title: themes.setLang("done"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(FacebookRegisterViewController.donePicker))
//        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
//        doneButton.tintColor=themes.ThemeColour()
//        toolBar.setItems([spaceButton, doneButton], animated: false)
//        toolBar.isUserInteractionEnabled = true
//        Picker_Wrapper.addSubview(toolBar)
        
        
        Signup_Btn.isEnabled=true
        Signup_Btn.layer.cornerRadius = 5
        Signup_Btn.layer.cornerRadius = 5
        firstname.attributedPlaceholder=NSAttributedString(string:themes.setLang("firstname"), attributes: [NSForegroundColorAttributeName:UIColor(red:213.0/255.0, green:212.0/255.0, blue:210.0/255.0, alpha: 1.0) ])
        lastname.attributedPlaceholder=NSAttributedString(string:themes.setLang("lastname"), attributes: [NSForegroundColorAttributeName:UIColor(red:213.0/255.0, green:212.0/255.0, blue:210.0/255.0, alpha: 1.0) ])
        username.attributedPlaceholder=NSAttributedString(string:themes.setLang("user_name"), attributes: [NSForegroundColorAttributeName:UIColor(red:213.0/255.0, green:212.0/255.0, blue:210.0/255.0, alpha: 1.0) ])
        Email_TextField.attributedPlaceholder=NSAttributedString(string:themes.setLang("email_id_smal"), attributes: [NSForegroundColorAttributeName:UIColor(red:213.0/255.0, green:212.0/255.0, blue:210.0/255.0, alpha: 1.0) ])
        ContactField.attributedPlaceholder=NSAttributedString(string: themes.setLang("phone_no"), attributes:[NSForegroundColorAttributeName:UIColor(red:213.0/255.0, green:212.0/255.0, blue:210.0/255.0, alpha: 1.0) ])
//        CountryCode_TextField.attributedPlaceholder=NSAttributedString(string: "", attributes:[NSForegroundColorAttributeName:UIColor(red:213.0/255.0, green:212.0/255.0, blue:210.0/255.0, alpha: 1.0) ])
        Signup_Btn.setTitle(themes.setLang("register"), for: UIControlState())
//        ShowPas_Lbl.text=themes.setLang("show_password")
        

        
        
        if(FB_Regis.FB_mailid != "")
        {
            Email_TextField.text=FB_Regis.FB_mailid as String
            
        }
        
        if(FB_Regis.FB_Firstname != "")
        {
        firstname.text = FB_Regis.FB_Firstname as String
        }
        
        if(FB_Regis.FB_lastname != "")
        {
            lastname.text = FB_Regis.FB_lastname as String
        }
        if(FB_Regis.FB_Username != "")
        {
            username.text = FB_Regis.FB_Username as String
        }

      
        if(FB_Regis.FB_Picture != "")
        {
            
            self.UserImage.sd_setImage(with: URL(string:"\(FB_Regis.FB_Picture)"), placeholderImage: UIImage(named: "PlaceHolderSmall"))

        }
        
        UserImage.layer.cornerRadius=themes.RoundView(UserImage.frame.size.width)
        
        UserImage.clipsToBounds=true
        UserImage.layer.borderWidth=3.0
        
        UserImage.layer.borderColor=themes.ThemeColour().cgColor
        
//        Picker_Wrapper.removeFromSuperview()
        
        print(self.FB_ScrollView.contentSize);

        let tapgesture:UITapGestureRecognizer=UITapGestureRecognizer(target:self, action: #selector(FacebookRegisterViewController.DismissKeyboard(_:)))
        
        view.addGestureRecognizer(tapgesture)
        
    }
    
    
    
    func applicationLanguageChangeNotification(_ notification:Notification)
    {
        
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        let str:NSMutableAttributedString = NSMutableAttributedString.init(string:"\(self.themes.setLang("terms&condt")) \(self.themes.setLang("terms")) & \(self.themes.setLang("priv_poli")).")
        str.addAttribute(NSLinkAttributeName, value:"1", range: NSRange(location:29,length:21))
        str.addAttribute(NSLinkAttributeName, value:"2", range: NSRange(location:52,length:15))
        termsAndConditions_TxtView.attributedText = str
        termsAndConditions_TxtView.delegate = self
        termsAndConditions_TxtView.isSelectable = true
        
        OTP_sta.OTP_Paging="FacebookSignup"
        if(themes.getCounrtyphone() != ""){
            CountryCode_TextField.text = "+ \(themes.getCounrtyphone())"
            
        }
            if(signup.selectedCode != ""){
                let indexCode = themes.codename.index(of: signup.selectedCode)
                CountryCode_TextField.text = themes.code[indexCode] as? String
            }

    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
         if(textField == firstname)
        {
            
            firstname.resignFirstResponder()
            lastname.becomeFirstResponder()
            
            
        }
         else if (textField == lastname){
            
            lastname.resignFirstResponder()
            username.becomeFirstResponder()
            

        }
         else if (textField == username){
            
            username.resignFirstResponder()
            Email_TextField.becomeFirstResponder()
            
            
        }
         else if (textField == Email_TextField){
            
            Email_TextField.resignFirstResponder()
            CountryCode_TextField.becomeFirstResponder()
            
            
        }
         else if (textField == CountryCode_TextField){
            
            CountryCode_TextField.resignFirstResponder()
            ContactField.becomeFirstResponder()
            
            
        }


        
        
        
        
        
        return true
    }
    

    
    func DismissKeyboard(_ sender:UITapGestureRecognizer)
    {
        
//        self.donePicker()
        view.endEditing(true)
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if textField == Email_TextField
            
        {
            if let _ = string.rangeOfCharacter(from: CharacterSet.uppercaseLetters)
            {
                // Do not allow upper case letters
                return false
            }
            return true
        }
            
            
            
        else
        {
            return true
            
        }
        
    }
    

    
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
      
            
            if(textField == username)
            {
               
                
//                self.donePicker()
                
                
            }
            
            if(textField == Email_TextField)
            {
                
//                self.donePicker()
                
                
            }
        
                if(textField == CountryCode_TextField) {
                    view.endEditing(true)
                    let navig = self.storyboard?.instantiateViewController(withIdentifier: "SearchBarViewControllerID") as! SearchBarViewController
                    self.navigationController?.pushViewController(withFlip: navig, animated: true)
                    return false
                }

                
                
        
            
        
        
        return true
    }
    
//    func donePicker()
//    {
//        
//        UIView.animateWithDuration(0.2, animations: {
//            
//            self.Picker_Wrapper.frame = CGRectMake(0, UIScreen.main.bounds.size.height, UIScreen.main.bounds.size.width, 260.0)
//            
//            }, completion: { _ in
//                
//                self.Picker_Wrapper.removeFromSuperview()
//                
//        })
//        
//        
//    }
//    
    
    
    
    func showPicker()
    {
//        view.addSubview(self.Picker_Wrapper)
//        
//        UIView.animateWithDuration(0.2, animations: {
//            
//            self.Picker_Wrapper.frame = CGRectMake(0, UIScreen.main.bounds.size.height - 260.0, UIScreen.main.bounds.size.width, 260.0)
//            
//            } , completion: { _ in
//                
//                
//                
//        })
        
    }
    
    
    @IBAction func didClickoptions(_ sender: UIButton) {
        
       
        
        if(sender.tag == 1)
        {
            
            
            self.FB_Signup()
            
        }
        
        
        if(sender.tag == 2)
        {
            self.navigationController?.popToRootViewController(animated: true)
        }
        if(sender.tag == 10)
        {
                     self.navigationController?.popViewControllerWithFlip(animated: true)
        }

    }
    
    @IBAction func checkBoxBtn_Action(_ sender: UIButton) {
        let checkImage = UIImage(named: "checkbox_blue")
        let uncheck_Image = UIImage(named: "check")
        if checkBox_Btn.imageView?.image == UIImage(named:"checkbox_blue"){
            
            checkBox_Btn.setImage(uncheck_Image, for: UIControlState())
            
        }
        else{
            checkBox_Btn.setImage(checkImage, for: UIControlState())
            
        }
    }
    
    func FB_Signup()
    {
        
        print(Email_TextField.text!)
        let validateemail:Bool=themes.isValidEmail(Email_TextField.text!)
        
        let Contact:NSString=ContactField.text! as NSString
        
        
        if (username.text == ""){
            themes.AlertView("\(Appname)",Message: themes.setLang("enter_username"),ButtonTitle: kOk)
        }
        
        if(Email_TextField.text == "")
        {
            themes.AlertView("\(Appname)",Message: themes.setLang("enter_email_alert"),ButtonTitle: kOk)
        }
            
        else if(validateemail == false)
        {
            themes.AlertView("\(Appname)",Message: themes.setLang("valid_email_alert"),ButtonTitle: kOk)
            
        }
            
        else if(ContactField.text == "")
        {
            themes.AlertView("\(Appname)",Message: themes.setLang("enter_ur_num"),ButtonTitle: kOk)
        }
        else if(Contact.length >= 15 || Contact.length < 7)
        {
            themes.AlertView("\(Appname)",Message:themes.setLang( "enter_the_validnum"),ButtonTitle: kOk
            )
        }
            
            
        else if(CountryCode_TextField.text == "")
        {
            themes.AlertView("\(Appname)",Message: themes.setLang("Kindly enter the Country Code"),ButtonTitle: kOk)
        }
        else if (checkBox_Btn.imageView?.image == UIImage(named:"check"))
        {
            themes.AlertView("\(Appname)",Message: themes.setLang("TermsandConditValid"),ButtonTitle: kOk)
            
        }
            
            
             else
        {
            self.Signup_Btn.isEnabled=false

            
            self.Signup_Btn.startLoadingAnimation()
            
            
            let parameter=["user_name":"\(username.text!)","email_id":"\(Email_TextField.text!)","country_code":"\(CountryCode_TextField.text!)","phone":"\(ContactField.text!)","deviceToken":"\(Device_Token)","gcm_id":""]

            
            URL_handler.makeCall(constant.Social_Check, param: parameter as NSDictionary, completionHandler: { (responseObject, error) -> () in
                self.Signup_Btn.isEnabled=true

                self.DismissProgress()
                if(error != nil)
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.Signup_Btn.returnToOriginalState()
                    })
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)

                  //  self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: kOK)
                }
                    
                else
                {
                    

                if(responseObject != nil)
                {
                    
                     let dict:NSDictionary=responseObject!
                    
                    signup.status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                    
                    
                    if (signup.status == "1")
                    {
                        
                     signup.firstname = self.firstname.text!
                        signup.lastname = self.lastname.text!
                        signup.username=dict.object(forKey: "user_name") as! String
                        signup.Email=dict.object(forKey: "email") as! String
                        
                        signup.Contact_num=dict.object(forKey: "phone_number") as! String
                        signup.OTP=dict.object(forKey: "otp") as! String
                        signup.otpstatus=dict.object(forKey: "otp_status") as! String
                        signup.Country_Code=dict.object(forKey: "country_code") as! String
                        
                        
                        self.Signup_Btn.startFinishAnimation(1, completion: {
                            if((signup.OTP as NSString).length>0){
                                
                                OTP_sta.OTP=signup.OTP
                                OTP_sta.OTP_Status=signup.otpstatus
                                
                                let otpview : OTPViewController = OTPViewController()
                                otpview.otpstring = "\(self.themes.CheckNullValue(dict.object(forKey: "otp"))!)"
                                otpview.otpstatus_str = self.themes.CheckNullValue(dict.object(forKey: "otp_status"))!
                                self.performSegue(withIdentifier: "OTP", sender: nil)
                            }
                        })
                        
                        
                        
                    }
                    else
                    {
                        self.Signup_Btn.returnToOriginalState()

                        signup.message=dict.object(forKey: "message") as! String
                        
                        self.themes.AlertView("\(Appname)",Message: "\(signup.message)",ButtonTitle: kOk)
                        
                        
                    }
                    
                }
                    
                    
                    
                else
                {
                    self.Signup_Btn.returnToOriginalState()
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    
                    
                    
                }
                
                return
                }
                
            })

            
        }

    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return themes.codename.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (themes.codename[row] as! String)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        self.CountryCode_TextField.text="\(themes.code[row])"
        
    }
    
    
}

extension FacebookRegister:UIPickerViewDelegate
{
    
}
 
