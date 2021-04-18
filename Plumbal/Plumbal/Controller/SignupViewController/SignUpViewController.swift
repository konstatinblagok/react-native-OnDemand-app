//
//  ViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 30/09/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit
import CoreTelephony
import FacebookCore
import FacebookLogin
import SwiftyJSON

class SignUpViewController: RootViewController,UITextFieldDelegate,UITextViewDelegate
{
    @IBOutlet var checkBox_Btn: UIButton!
    
    @IBOutlet var termsAndConditions_TxtView: UITextView!
    @IBOutlet var firstname_textfield: UITextField!
    @IBOutlet var lastname_testfield: UITextField!
    @IBOutlet var Signup_ScrollView: UIScrollView!
    
    @IBOutlet var cnfirmPasswordTextfield: CustomTextField!
    @IBOutlet var Register_But: TKTransitionSubmitButton!
    @IBOutlet var referraltextfield: UITextField!
    
    @IBOutlet var ContactnumberTextfield: UITextField!
    @IBOutlet var EmailidTextfield: UITextField!
    @IBOutlet var PasswordTextfield: UITextField!
    @IBOutlet var FullnameTextfield: UITextField!
   
    @IBOutlet var Country_Code_TextField: CustomTextField!
    @IBOutlet weak var facebook_but: TKTransitionSubmitButton!
    @IBOutlet weak var lblRegister: CustomLabelWhite!
    
    @IBOutlet var wrapperView: UIView!
    var FullName:String=String()
    var Emailid:String=String()
    var Contact:String=String()
    var Password:String=String()
    var validateemail:Bool=Bool()
    var validatepasswd : Bool = Bool()
    var URL_handler:URLhandler=URLhandler()
    var themes:Themes=Themes()
    var searchObj = SearchBarViewController()
    var getPrev_VC:String = String()
    var loginManager = LoginManager()
    //MARK: - Override Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wrapperView.layer.borderWidth=1.0
        wrapperView.layer.borderColor=UIColor.lightGray.cgColor
        wrapperView.layer.cornerRadius=3.0

        if(themes.getCounrtyphone() != ""){
            Country_Code_TextField.text = "+ \(themes.getCounrtyphone())"
        }
        EmailidTextfield.autocapitalizationType = .none;
        if(Device_Token == ""){
            Device_Token="Simulator Signup"
        }
        signup.selectedCode = ""
        let tapgesture:UITapGestureRecognizer=UITapGestureRecognizer(target:self, action: #selector(SignUpViewController.DismissKeyboard(_:)))
        view.addGestureRecognizer(tapgesture)
        
        //Tool Bar for Picker View
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = themes.ThemeColour()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title:themes.setLang("done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(SignUpViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        doneButton.tintColor=themes.ThemeColour()
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        LoadPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Register_But.returnToOriginalState()
        Register_But.backgroundColor = PlumberThemeColor
        Register_But.setTitleColor(UIColor.white, for: UIControlState())
        Register_But.titleLabel?.font = PlumberLargeFont
        Register_But.titleLabel?.adjustsFontSizeToFitWidth = true
        
        facebook_but.returnToOriginalState()
        facebook_but.setTitleColor(UIColor.white, for: UIControlState())
        facebook_but.titleLabel?.adjustsFontSizeToFitWidth = true
        
        LoadPage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Function
    
    func LoadPage(){
        if(themes.getCounrtyphone() != ""){
            Country_Code_TextField.text = "+ \(themes.getCounrtyphone())"
            
        }
        if(signup.selectedCode != "") {
            let indexCode = themes.codename.index(of: signup.selectedCode)
            Country_Code_TextField.text = themes.code[indexCode] as? String
        }
        
        OTP_sta.OTP_Paging="SignUp"
        EmailidTextfield.placeholder = themes.setLang("email_address")
        PasswordTextfield.placeholder = themes.setLang("password_placeholder")
        ContactnumberTextfield.placeholder = themes.setLang("phone_no")
        referraltextfield.placeholder = themes.setLang("referral_code")
        FullnameTextfield.placeholder = themes.setLang("user_name1")
        facebook_but.setTitle(themes.setLang("facebook"), for: UIControlState())
        Register_But.setTitle(themes.setLang("register"), for: UIControlState())
        lblRegister.text = themes.setLang("register")
        cnfirmPasswordTextfield.placeholder = themes.setLang("confirm_password")
        firstname_textfield.placeholder = themes.setLang("firstname")
        lastname_testfield.placeholder = themes.setLang("lastname")
        facebook_but.layer.cornerRadius = 5
        EmailidTextfield.isMandatory()
        PasswordTextfield.isMandatory()
        ContactnumberTextfield.isMandatory()
        FullnameTextfield.isMandatory()
        firstname_textfield.isMandatory()
        lastname_testfield.isMandatory()
        cnfirmPasswordTextfield.isMandatory()
        Signup_ScrollView.contentSize.height = Register_But.layer.frame.origin.y+Register_But.frame.height+5
//        
//        "terms&condt"="I have read and agreed to the";
//        "terms" = "Terms and Conditions";
//        "priv_poli" = "Privacy Policy";
        let str:NSMutableAttributedString = NSMutableAttributedString.init(string:"\(self.themes.setLang("terms&condt")) \(self.themes.setLang("terms")) & \(self.themes.setLang("priv_poli")).")
        str.addAttribute(NSLinkAttributeName, value:"1", range: NSRange(location:29,length:21))
        str.addAttribute(NSLinkAttributeName, value:"2", range: NSRange(location:52,length:15))
        termsAndConditions_TxtView.attributedText = str
        termsAndConditions_TxtView.delegate = self
        termsAndConditions_TxtView.isSelectable = true
    }
    
    func nextPressed(){
        referraltextfield.becomeFirstResponder()
    }
    
    
    func showPicker(){
        
//        view.addSubview(self.Picker_Wrapper)
//        UIView.animateWithDuration(0.2, animations: {
//            self.Picker_Wrapper.frame = CGRectMake(0, UIScreen.main.bounds.size.height - 260.0, UIScreen.main.bounds.size.width, 260.0)
//            } , completion: { _ in
//        })
    
    }
    
    func donePicker() {
        
//        UIView.animateWithDuration(0.2, animations: {
//            self.Picker_Wrapper.frame = CGRectMake(0, UIScreen.main.bounds.size.height, UIScreen.main.bounds.size.width, 260.0)
//            }, completion: { _ in
//                self.Picker_Wrapper.removeFromSuperview()
//        })
    
    }
    
    func DismissKeyboard(_ sender:UITapGestureRecognizer) {
        self.donePicker()
        view.endEditing(true)
    }
    
    func register()  {
        FullName=FullnameTextfield.text!
        Emailid=EmailidTextfield.text!
        Contact=ContactnumberTextfield.text!
        Password=PasswordTextfield.text!
        validateemail=themes.isValidEmail(Emailid)
        validatepasswd = themes.validpasword(Password)
        view.endEditing(true)
        if (firstname_textfield.text == ""){
            themes.AlertView("\(Appname)",Message: self.themes.setLang("enter_first_name"),ButtonTitle: self.themes.setLang("ok"))
        }
        else if ((firstname_textfield.text as! NSString).length >= 25){
            themes.AlertView("\(Appname)",Message:self.themes.setLang("name_below_25"),ButtonTitle: self.themes.setLang("ok"))
        }
        else if (lastname_testfield.text == ""){
            themes.AlertView("\(Appname)",Message: self.themes.setLang("enter_lastname"),ButtonTitle: self.themes.setLang("ok"))
        }
        else if ((lastname_testfield.text as! NSString).length >= 25){
            themes.AlertView("\(Appname)",Message: self.themes.setLang("last_below_25"),ButtonTitle: self.themes.setLang("ok"))
        }else if(EmailidTextfield.text == "") {
            themes.AlertView("\(Appname)",Message: themes.setLang("enter_emailid"),ButtonTitle: kOk)
        }else if(validateemail == false){
            themes.AlertView("\(Appname)",Message: themes.setLang("valid_email_alert"),ButtonTitle: kOk)
        }
            
        else if(FullnameTextfield.text == "") {
            themes.AlertView("\(Appname)",Message: themes.setLang("enter_username"),ButtonTitle: kOk)
        }
        else  if((FullName as NSString).length >= 25) {
            themes.AlertView("\(Appname)",Message: themes.setLang("username_below_30"),ButtonTitle: kOk)
        }else if(Country_Code_TextField.text == "") {
            themes.AlertView("\(Appname)",Message: themes.setLang("enter_country_code"),ButtonTitle: kOk)
        }else if(ContactnumberTextfield.text == ""){
            themes.AlertView("\(Appname)",Message:themes.setLang("enter_the_num"),ButtonTitle: kOk)
        } else if((Contact as NSString).length >= 15 || (Contact as NSString).length < 6)  {
            themes.AlertView("\(Appname)",Message: themes.setLang("enter_the_validnum"),ButtonTitle: kOk)
        }
            else if (checkBox_Btn.imageView?.image == UIImage(named:"check"))
        {
            themes.AlertView("\(Appname)",Message: themes.setLang("TermsandConditValid"),ButtonTitle: kOk)

        }
        else if((Password as NSString).length < 6 ){
            themes.AlertView("\(Appname)",Message: themes.setLang("valid_password"),ButtonTitle: kOk)
        }
        else if (Password as String != cnfirmPasswordTextfield.text){
            themes.AlertView("\(Appname)",Message: themes.setLang("passwd_match_error"),ButtonTitle: kOk)
            
        }
            
        else {
            Register_But.isEnabled=false
            self.Register_But.startLoadingAnimation()
            let parameter=["first_name":"\(firstname_textfield.text!)","last_name":"\(lastname_testfield.text!)","user_name":"\(FullName)","email":"\(Emailid)","password":"\(Password)","country_code":"\(Country_Code_TextField.text!)","phone_number":"\(Contact)","referal_code":"\(referraltextfield.text!)","deviceToken":"\(Device_Token)","gcm_id":"","langcode":"\(self.themes.getAppLanguage())"]
            URL_handler.makeCall(constant.RegisterAccount, param: parameter as NSDictionary, completionHandler: { (responseObject, error) -> () in
                self.Register_But.isEnabled=true
                self.DismissProgress()
                if(error != nil){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.Register_But.returnToOriginalState()
                    })
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                } else {
                    if(responseObject != nil){
                        let dict:NSDictionary=responseObject!
                        signup.status = self.themes.CheckNullValue(dict.object(forKey: "status"))!
                        if (signup.status == "1"){
                            signup.firstname=self.firstname_textfield.text!
                            signup.lastname=self.lastname_testfield.text!
                            signup.username=dict.object(forKey: "user_name") as! String
                            signup.Email=dict.object(forKey: "email") as! String
                            signup.Password=self.PasswordTextfield.text!
                            signup.Contact_num=dict.object(forKey: "phone_number") as! String
                            signup.OTP=dict.object(forKey: "otp") as! String
                            signup.otpstatus=dict.object(forKey: "otp_status") as! String
                            signup.Country_Code=dict.object(forKey: "country_code") as! String
                            signup.referralCode=self.referraltextfield.text!
                            self.Register_But.startFinishAnimation(1, completion: {
                                if((signup.OTP as NSString).length>0){
                                    OTP_sta.OTP=signup.OTP
                                    OTP_sta.OTP_Status=signup.otpstatus
                                    let otpview : OTPViewController = OTPViewController()
                                    otpview.otpstring = "\(self.themes.CheckNullValue(dict.object(forKey: "otp"))!)"
                                    otpview.otpstatus_str = self.themes.CheckNullValue(dict.object(forKey: "otp_status"))!
                                    self.performSegue(withIdentifier: "OTP", sender: nil)
                                }
                            })
                           
                        } else {
                            self.Register_But.returnToOriginalState()
                            if(dict.object(forKey: "response") != nil) {
                                signup.message = dict.object(forKey: "response") as! String
                                self.themes.AlertView("\(Appname)",Message: "\(signup.message)",ButtonTitle: kOk)
                                
                            } else {
                                signup.message = dict.object(forKey: "errors") as! String
                                self.themes.AlertView("\(Appname)",Message: "\(signup.message)",ButtonTitle: kOk)
                                
                            }
                        }
                    }else {
                        self.Register_But.returnToOriginalState()

                        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    }
                }
                return
            })
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       
        
        
    }
    func endEditingNow(){
        ContactnumberTextfield.endEditing(true)
    }
    
    func returnUserData() {
        Register_But.isEnabled=false
        let graphRequest : GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: .defaultVersion)
        graphRequest.start { (response, resultObj) in
        
            switch resultObj
            {
            case .success(let graphResponse):
                if let result = graphResponse.dictionaryValue {
                let json = JSON(result)
                print("the rres is \(json)")
                let userName = self.themes.CheckNullValue((result as AnyObject).value(forKey: "name"))!
                let userEmail = self.themes.CheckNullValue((result as AnyObject).value(forKey: "email"))!
                let firstName = self.themes.CheckNullValue((result as AnyObject).value(forKey: "first_name"))!
                let lastName = self.themes.CheckNullValue((result as AnyObject).value(forKey: "last_name"))!
                let userID = self.themes.CheckNullValue((result as AnyObject).value(forKey: "id"))!
                let Profie_Pic = json["picture"]["data"]["url"].string!
                let Pic_Status = json["picture"]["data"]["url"].string!
                
                if(Profie_Pic != "") {
                    FB_Regis.FB_Picture=Profie_Pic
                }
                if(Pic_Status != ""){
                    FB_Regis.FB_Pic_Status=Pic_Status
                }
                
                FB_Regis.FB_Firstname=firstName
                FB_Regis.FB_lastname=lastName
                FB_Regis.FB_Username=userName
                FB_Regis.FB_mailid=userEmail
                FB_Regis.FB_UserId=userID
                self.facebook_but.startLoadingAnimation()
                let param=["email_id":"\(FB_Regis.FB_mailid)","deviceToken":"\(Device_Token)","fb_id":"\(FB_Regis.FB_UserId)","prof_pic":"\(FB_Regis.FB_Picture)","langcode":"\(self.themes.getAppLanguage())"]
                self.URL_handler.makeCall(constant.Social_login, param: param as NSDictionary, completionHandler:{ (responseObject, error) -> () in
                    self.Register_But.isEnabled=true
                    self.DismissProgress()
                    if(error != nil){
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                            self.facebook_but.returnToOriginalState()
                        })
                        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    } else {
                        if(responseObject != nil) {
                            let dict:NSDictionary=responseObject!
                            signup.status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                            if(signup.status == "0") {
                                let messagestr = self.themes.CheckNullValue(dict.object(forKey: "message"))!
                                if messagestr == "Your account is currently unavailable" {
                                    self.performSegue(withIdentifier: "FacebookVC", sender: nil)
                                }
                            }
                            
                            if (signup.status == "1") {
                                signup.Check_Live=dict.object(forKey: "is_alive_other") as! String
                                if(signup.Check_Live == "Yes") {
                                    self.themes.AlertView("\(Appname)", Message:self.themes.setLang("sign_out_all_device"), ButtonTitle: kOk)
                                }
                                
                                signup.username=dict.object(forKey: "user_name") as! String
                                signup.Email=dict.object(forKey: "email") as! String
                                signup.Contact_num=self.themes.CheckNullValue(dict.object(forKey: "phone_number"))!
                                signup.currency=dict.object(forKey: "currency") as! String
                                signup.Walletamt = self.themes.CheckNullValue(dict.object(forKey: "wallet_amount"))!
                                signup.Userimage=dict.object(forKey: "prof_pic") as! String
                                signup.Userid=dict.object(forKey: "user_id") as! String
                                signup.Locationname=dict.object(forKey: "location_name") as! String
                                signup.Country_Code=self.themes.CheckNullValue(dict.object(forKey: "country_code"))!
                                signup.currency_Sym=self.themes.Currency_Symbol(signup.currency as String)
                                // signup.soc_key=dict.objectForKey("soc_key") as! NSString
                                signup.user_id=dict.object(forKey: "user_id") as! String
                                
                                if (dict.object(forKey: "location_id") != nil){
                                    signup.Locationid=dict.object(forKey: "location_id") as! String
                                }
                                
                                self.themes.saveCountryCode(signup.Country_Code as String!)
                                self.themes.saveLocationname(signup.Locationname as String)
                                self.themes.saveLocationname(signup.Locationname as String)
                                self.themes.saveCurrency(signup.Walletamt as String)
                                self.themes.saveCurrencyCode(signup.currency_Sym as String)
                                self.themes.saveUserID(signup.Userid as String)
                                self.themes.saveUserName(signup.username as String)
                                self.themes.saveEmailID(signup.Email as String)
                                self.themes.saveUserPasswd(signup.Password as String)
                                self.themes.saveuserDP(signup.Userimage as String)
                                self.themes.saveMobileNum(signup.Contact_num as String)
                                self.themes.saveWalletAmt(signup.Walletamt as String)
                                self.themes.saveLocationID(signup.Locationid as String)
                                self.themes.saveJaberID(signup.user_id as String)
                                self.themes.saveJaberPassword(signup.soc_key as String)
                                SocketIOManager.sharedInstance.establishConnection()
                                SocketIOManager.sharedInstance.establishChatConnection()
                                
                                self.facebook_but.startFinishAnimation(1, completion:{
                                    if self.themes.getaddresssegue() ==  "1" {
                                        self.performSegue(withIdentifier: "ScheduleVC", sender: nil)
                                        
                                    } else {
                                        Appdel.MakeRootVc("RootVCID")
                                    }
                                })
                               
                            }
                            if(signup.status == "2") {
                                self.facebook_but.returnToOriginalState()
                                self.performSegue(withIdentifier: "FacebookVC", sender: nil)
                            }
                            
                        }  else {
                            self.facebook_but.returnToOriginalState()
                            self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                            
                        }
                    }
                    
                    
                })
            }
                break
            case .failed(let error):
                self.facebook_but.returnToOriginalState()
                print(error)
            }

        }
    }
    
    
    
    
    //MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == EmailidTextfield){
            EmailidTextfield.resignFirstResponder()
            PasswordTextfield.becomeFirstResponder()
        }
        if(textField == PasswordTextfield) {
            PasswordTextfield.resignFirstResponder()
            FullnameTextfield.becomeFirstResponder()
        }
        if(textField == FullnameTextfield) {
            FullnameTextfield.resignFirstResponder()
            Country_Code_TextField.becomeFirstResponder()
        }
        if(textField == ContactnumberTextfield) {
            ContactnumberTextfield.resignFirstResponder()
            referraltextfield.becomeFirstResponder()
        }
        if(textField == referraltextfield){
            referraltextfield.resignFirstResponder()
        }
        return true
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if(textField == EmailidTextfield) {
            self.donePicker()
        }
        if(textField == ContactnumberTextfield)  {
            self.donePicker()
            let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
            toolBar.barStyle = UIBarStyle.default
            toolBar.isTranslucent = true
            toolBar.tintColor = themes.ThemeColour()
            toolBar.sizeToFit()
            let doneButton = UIBarButtonItem(title:themes.setLang("done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(SignUpViewController.endEditingNow))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            doneButton.tintColor=themes.ThemeColour()
            toolBar.setItems([spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            textField.inputAccessoryView = toolBar
            return true
            
        }
        if(textField == Country_Code_TextField) {
            view.endEditing(true)
            let navig = self.storyboard?.instantiateViewController(withIdentifier: "SearchBarViewControllerID") as! SearchBarViewController
            self.navigationController?.pushViewController(withFlip: navig, animated: true)
            return false
        }
        if(textField == referraltextfield){
            self.donePicker()
        }
        
        return true
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == FullnameTextfield) {
            let aSet = CharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
            
            
        }else if textField == EmailidTextfield {
            if let _ = string.rangeOfCharacter(from: CharacterSet.uppercaseLetters) {
                return false
            }
            return true
        } else {
            return true
        }
    }
    
    //MARK: - Button Action
    
    @IBAction func clickoption(_ sender: AnyObject) {
        themes.AlertView(themes.setLang("referral_scheme"),Message:themes.setLang("enter_referal_code"),ButtonTitle: kOk)
        
    }
    
    @IBAction func didClickoptions(_ sender: AnyObject) {
        if(sender.tag == 3) {
            self.register()
        }
        if(sender.tag == 4){
            self.donePicker()
            if(PasswordTextfield.text == "")  {
                PasswordTextfield.becomeFirstResponder()
            }
        }
        if(sender.tag == 122) {
            if self.navigationController!.viewControllers.contains(SignInViewController()) {
                self.navigationController?.poptoViewControllerWithFlip(controller:SignInViewController() as UIViewController, animated: true)
            } else{
                self.performSegue(withIdentifier: "Signin_VC", sender: nil)
            }
        }
        if(sender.tag == 12) {
            if getPrev_VC == "From Side Menu"{
                
                Appdel.MakeRootVc("RootVCID")

            }
            else{
                 self.navigationController?.popViewControllerWithFlip(animated: true)
            }
           
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
    
    @IBAction func didclickfacebook(_ sender: AnyObject) {
        
        view.endEditing(true)
        loginManager.loginBehavior = .web
        loginManager.logOut()
        loginManager.logIn([.publicProfile,.email, .userFriends], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
                self.loginManager.logOut()
            case .cancelled:
                print("User cancelled login.")
            case .success(_, _, _):
                print("Logged in!")
                self.returnUserData()
            }
        }
    }
    
    
    //MARK: - Picker View Delegate
    
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return themes.codename.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (themes.codename[row] as! String)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        self.Country_Code_TextField.text="\(themes.code[row])"
        
    }
    
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        print("get character range\(characterRange)")
     
        let get_String:NSString =  textView.text as NSString
        print(get_String.substring(with: NSMakeRange(characterRange.location, characterRange.length)))
      
        let selected_String =  get_String.substring(with: NSMakeRange(characterRange.location, characterRange.length))
       // let remove_Space = selected_String.stringByReplacingOccurrencesOfString(" ", withString: "")
        let termsAndCondtns_VC:TermsAndConditionsViewController=self.storyboard?.instantiateViewController(withIdentifier: "TermsAndConditionsViewController") as! TermsAndConditionsViewController
        termsAndCondtns_VC.url_String = selected_String
        self.navigationController?.pushViewController(withFlip: termsAndCondtns_VC, animated: true)
        
        return false
    }

}









