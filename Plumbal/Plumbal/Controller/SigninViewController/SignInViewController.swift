//
//  SignInViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 01/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import SwiftyJSON
class SignInViewController: RootViewController,UINavigationControllerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var lblSignIn: UILabel!
    @IBOutlet var Forgot_Btn: UIButton!
    @IBOutlet var Signupnow_Btn: UIButton!
     @IBOutlet var user_name_img: UIImageView!
     @IBOutlet var Passworrd_img: UIImageView!
    @IBOutlet var Not_Lbl: UILabel!
    @IBOutlet var Signin_ScrollView: UIScrollView!
    @IBOutlet var Signin_But: TKTransitionSubmitButton!
    @IBOutlet weak var facebook_btn: TKTransitionSubmitButton!
    
    var loginManager = LoginManager()

    @IBOutlet var Wrapper_View: UIView!
    @IBOutlet var PasswordTextfield: UITextField!
    @IBOutlet var EmaiidTextfield: UITextField!
    var themes:Themes=Themes()
    var Emailid:String=String()
    var Password:String=String()
    var validateemail:Bool=Bool()
    var validatepasswd : Bool = Bool()
    var URL_handler:URLhandler=URLhandler()
    
    //MARK: - Override Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.user_name_img.image = self.user_name_img.changeImageColor(color: PlumberThemeColor)
        self.Passworrd_img.image = self.Passworrd_img.changeImageColor(color: PlumberThemeColor)
        
        self.facebook_btn.returnToOriginalState()
        self.Signin_But.returnToOriginalState()

        Signin_But.backgroundColor = PlumberThemeColor
        Signin_But.setTitleColor(UIColor.white, for: UIControlState())
        Signin_But.titleLabel?.font = PlumberLargeFont
        Signin_But.titleLabel?.adjustsFontSizeToFitWidth = true

        facebook_btn.setTitleColor(UIColor.white, for: UIControlState())
        facebook_btn.titleLabel?.font = PlumberLargeFont
        facebook_btn.titleLabel?.adjustsFontSizeToFitWidth = true

        Wrapper_View.layer.borderWidth=1.0
        Wrapper_View.layer.borderColor=UIColor.lightGray.cgColor
        Wrapper_View.layer.cornerRadius=3.0

       
        Signin_But.isEnabled=true
        Signin_But.layer.cornerRadius = 5
        facebook_btn.layer.cornerRadius = 5
        lblSignIn.text = themes.setLang("login")
        Forgot_Btn.setTitle(themes.setLang("forgot_password_btn"), for: UIControlState())
        Signin_But.setTitle(themes.setLang("login"), for: UIControlState())
        Signupnow_Btn.setTitle(themes.setLang("register"), for: UIControlState())
        EmaiidTextfield.autocapitalizationType = .none;
        EmaiidTextfield.placeholder=themes.setLang("email_placeholder")
        PasswordTextfield.placeholder=themes.setLang("password_placeholder")
        facebook_btn.setTitle(themes.setLang("facebook"), for: UIControlState())
        let tapgesture:UITapGestureRecognizer=UITapGestureRecognizer(target:self, action: #selector(SignInViewController.DismissKeyboard(_:)))
        view.addGestureRecognizer(tapgesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Signin_But.isEnabled=true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: TextField Delegate
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == EmaiidTextfield) {
            EmaiidTextfield.resignFirstResponder()
            PasswordTextfield.becomeFirstResponder()
        } else {
            PasswordTextfield.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == EmaiidTextfield {
            if let _ = string.rangeOfCharacter(from: CharacterSet.uppercaseLetters) {
               // return false
            }
            return true
        }else {
            return true
        }
    }
    
    //MARK: - Button Action
    
    
    @IBAction func didclickFacebook(_ sender: AnyObject) {
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
    
    @IBAction func DidClickoptions(_ sender: UIButton) {
        self.view.endEditing(true)
        if(sender.tag == 2){
            self.login_account()
        }
        if(sender.tag == 4) {
            self.performSegue(withIdentifier: "SignupVC", sender: nil)
        }
        
        if(sender.tag == 10){
            if self.themes.getaddresssegue() ==  "1" {
                self.performSegue(withIdentifier: "ScheduleVC", sender: nil)
            } else{
                Appdel.MakeRootVc("RootVCID")
            }
        }
    }
    
    //MARK: - Function
    
    func DismissKeyboard(_ sender:UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func returnUserData(){
        Signin_But.isEnabled=false
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
                    let param=["email_id":"\(FB_Regis.FB_mailid)","deviceToken":"\(Device_Token)","fb_id":"\(FB_Regis.FB_UserId)","prof_pic":"\(FB_Regis.FB_Picture)","langcode":"\(self.themes.getAppLanguage())"]
                    self.facebook_btn.startLoadingAnimation()
                    self.URL_handler.makeCall(constant.Social_login, param: param as NSDictionary, completionHandler:{ (responseObject, error) -> () in
                        self.Signin_But.isEnabled=true
                        self.DismissProgress()
                        if(error != nil) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                self.facebook_btn.returnToOriginalState()
                            })
                            self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                        }  else {
                            if(responseObject != nil) {
                                let dict:NSDictionary=responseObject!
                                signup.status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                                if(signup.status == "0")  {
                                    let messagestr = self.themes.CheckNullValue(dict.object(forKey: "message"))!
                                    if messagestr == "Your account is currently unavailable" {
                                        self.performSegue(withIdentifier: "FacebookVC", sender: nil)
                                    }
                                }
                                
                                if (signup.status == "1")  {
                                    signup.Check_Live=dict.object(forKey: "is_alive_other") as! String
                                    if(signup.Check_Live == "Yes"){
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
                                    signup.currency_Sym=self.themes.Currency_Symbol(signup.currency)
                                    // signup.soc_key=dict.objectForKey("soc_key") as! NSString
                                    signup.user_id=dict.object(forKey: "user_id") as! String
                                    if (dict.object(forKey: "location_id") != nil) {
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
                                    self.facebook_btn.startFinishAnimation(1, completion:{
                                        if self.themes.getaddresssegue() ==  "1" {
                                            self.performSegue(withIdentifier: "ScheduleVC", sender: nil)
                                            
                                        }else {
                                            Appdel.MakeRootVc("RootVCID")
                                        }
                                        
                                    })
                                }
                                if(signup.status == "2"){
                                    self.facebook_btn.returnToOriginalState()
                                    self.performSegue(withIdentifier: "FacebookVC", sender: nil)
                                }
                            } else {
                                self.facebook_btn.returnToOriginalState()
                                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                            }
                        }
                    })
                }
                break
            case .failed(let error):
                self.facebook_btn.returnToOriginalState()
                print(error)
            }
            
            
        }
    }
    
    func login_account(){
//        EmaiidTextfield.text = "vivekuser"
//        PasswordTextfield.text = "Pa1111"
        
        Emailid=EmaiidTextfield.text!
        Password=PasswordTextfield.text!
        validateemail=themes.isValidEmail(Emailid)
        validatepasswd = themes.validpasword(Password)
        if(EmaiidTextfield.text == "") {
            themes.AlertView("\(Appname)",Message: themes.setLang("enter_email_alert"),ButtonTitle: kOk)
        }else if (PasswordTextfield.text == ""){
            themes.AlertView("\(Appname)",Message:themes.setLang("enter_password_alert") ,ButtonTitle: kOk)
        }  else if((Password as NSString).length < 6 ) {
            themes.AlertView("\(Appname)",Message: themes.setLang("valid_password"),ButtonTitle: kOk)
        } else{
            self.Signin_But.startLoadingAnimation()
            Signin_But.isEnabled=false
            let parameter=[ "email":"\(Emailid)","password":"\(Password)" ,"deviceToken":"\(Device_Token)","gcm_id":"","langcode":"\(self.themes.getAppLanguage())"]
            URL_handler.makeCall(constant.Login.trimmingCharacters(in: CharacterSet.whitespaces), param: parameter as NSDictionary, completionHandler: { (responseObject, error) -> () in
              self.Signin_But.finishAnimation(0, completion: {})
                self.Signin_But.isEnabled=true
                self.DismissProgress()
                if(error != nil) {
                    self.Signin_But.setOriginalState()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.Signin_But.returnToOriginalState()
                    })
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                } else {
                    self.Signin_But.setOriginalState()
                    if(responseObject != nil) {
                        let dict:NSDictionary=responseObject!
                        signup.status = self.themes.CheckNullValue(dict.object(forKey: "status"))!
                        if (signup.status == "1") {
                            signup.Check_Live=dict.object(forKey: "is_alive_other") as! String
                            if(signup.Check_Live == "Yes") {
                                self.themes.AlertView("\(Appname)", Message:self.themes.setLang("sign_out_all_device"), ButtonTitle: kOk)
                            }
                            
                            signup.username=dict.object(forKey: "user_name") as! String
                            signup.Email=dict.object(forKey: "email") as! String
                            signup.Password=self.Password
                            signup.Contact_num=self.themes.CheckNullValue(dict.object(forKey: "phone_number"))!
                            signup.currency=dict.object(forKey: "currency") as! String
                            signup.Walletamt = self.themes.CheckNullValue(dict.object(forKey: "wallet_amount"))!
                            signup.Userimage=dict.object(forKey: "user_image") as! String
                            signup.Userid=dict.object(forKey: "user_id") as! String
                            signup.Locationname=dict.object(forKey: "location_name") as! String
                            signup.Country_Code=self.themes.CheckNullValue(dict.object(forKey: "country_code"))!
                            signup.currency_Sym=self.themes.Currency_Symbol(signup.currency)
                            // signup.soc_key=dict.objectForKey("soc_key") as! NSString
                            signup.user_id=dict.object(forKey: "user_id") as! String
                            if (dict.object(forKey: "location_id") != nil) {
                                signup.Locationid=dict.object(forKey: "location_id") as! String
                            }
                            self.themes.saveCountryCode(signup.Country_Code)
                            self.themes.saveLocationname(signup.Locationname)
                            self.themes.saveLocationname(signup.Locationname)
                            self.themes.saveCurrency(signup.Walletamt)
                            self.themes.saveCurrencyCode(signup.currency_Sym)
                            self.themes.saveUserID(signup.Userid)
                            self.themes.saveUserName(signup.username)
                            self.themes.saveEmailID(signup.Email)
                            self.themes.saveUserPasswd(signup.Password)
                            self.themes.saveuserDP(signup.Userimage)
                            self.themes.saveMobileNum(signup.Contact_num)
                            self.themes.saveWalletAmt(signup.Walletamt)
                            self.themes.saveLocationID(signup.Locationid)
                            self.themes.saveJaberID(signup.user_id)
                            self.themes.saveJaberPassword(signup.soc_key)
                            SocketIOManager.sharedInstance.establishConnection()
                            SocketIOManager.sharedInstance.establishChatConnection()
                            self.Signin_But.startFinishAnimation(1, completion: {
                                if self.themes.getaddresssegue() ==  "1" {
                                    self.performSegue(withIdentifier: "ScheduleVC", sender: nil)
                                    
                                } else {
                                    Appdel.MakeRootVc("RootVCID")
                                }
                            })
                           
                        } else{
                            self.Signin_But.returnToOriginalState()
                            signup.message =  self.themes.CheckNullValue(dict.object(forKey: "message"))!
                            self.themes.AlertView("\(Appname)",Message: signup.message  ,ButtonTitle: kOk)
                        }
                    } else {
                        self.Signin_But.returnToOriginalState()
                        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    }
                }
                return
            })
        }
    }
    
}



