//
//  ResetPasswordViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 15/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class ResetPasswordViewController: RootViewController {

    @IBOutlet var Password_Field: UITextField!
    @IBOutlet var Email_Field: UITextField!
    @IBOutlet var Wrapper_View: UIView!
    @IBOutlet var ShowPass_But: UIButton!
    @IBOutlet var Heder_lbl: UILabel!
     @IBOutlet var Show_passwrd: UILabel!
    @IBOutlet var Reset_Password_Btn: CustomButton!
    @IBOutlet var Reset_Password: UILabel!
    @IBOutlet var Reset_ScrollView: UIScrollView!
    var themes:Themes=Themes()
     var URL_handler:URLhandler=URLhandler()
    override func viewDidLoad() {
        super.viewDidLoad()
        Heder_lbl.text="\(Appname)"
        
        Email_Field.attributedPlaceholder=NSAttributedString(string:themes.setLang("enter_email"), attributes:[NSForegroundColorAttributeName: UIColor.black])
        
        Password_Field.attributedPlaceholder=NSAttributedString(string:themes.setLang("password_placeholder"), attributes:[NSForegroundColorAttributeName: UIColor.black])
        Reset_Password_Btn.setTitle(themes.setLang("reset_password"), for: UIControlState())
        if(OTP_sta.OTP_EmaiID != "")
        {
            Email_Field.text=OTP_sta.OTP_EmaiID as String
        }
        Reset_Password.text = themes.setLang("reset_password")
        Password_Field.isSecureTextEntry=true

Show_passwrd.text = themes.setLang("show_password")

Wrapper_View.layer.borderWidth=1.0
Wrapper_View.layer.borderColor=UIColor.lightGray.cgColor
Wrapper_View.layer.cornerRadius=3.0
        
        //Delegate Methods
        
        Password_Field.delegate=self
        Email_Field.delegate=self

        // Do any additional setup after loading the view.
        
        if(themes.screenSize.height == 480)
        {
            Reset_ScrollView.contentSize.height=550
        }
        
        if(themes.screenSize.height == 568)
        {
            Reset_ScrollView.contentSize.height=500
        }
        
        let tapgesture:UITapGestureRecognizer=UITapGestureRecognizer(target:self, action: #selector(ResetPasswordViewController.DismissKeyboard(_:)))
        
        view.addGestureRecognizer(tapgesture)


    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        if(textField == Email_Field)
        {
            
            Email_Field.resignFirstResponder()
            Password_Field.becomeFirstResponder()
         }
        
        if(textField == Password_Field)
        {
            
            Password_Field.resignFirstResponder()
         }
        
        
        return true

     }
    
    
    func DismissKeyboard(_ sender:UITapGestureRecognizer)
    {
        
        
        Reset_ScrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        
        view.endEditing(true)
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickoption(_ sender: UIButton) {
        
        if(sender.tag == 0)
            
        {
            
            self.navigationController?.popViewControllerWithFlip(animated: true)
            
        }

        
        if(sender.tag == 1)
        {
            
            
            if(ShowPass_But.isSelected == true)
            {
                
                
                Password_Field.isSecureTextEntry=true
                
                
                ShowPass_But.isSelected = false
                ShowPass_But.setImage(UIImage(named: "check"), for: UIControlState())
                Password_Field.font=UIFont(name: "Roboto-Regular", size: 14.0)

                
                
                
            }
            else
            {
                Password_Field.isSecureTextEntry=false
                
                ShowPass_But.isSelected = true
                
                ShowPass_But.setImage(UIImage(named: "tick"), for: UIControlState())
                Password_Field.font=UIFont(name: "Roboto-Regular", size: 14.0)

                
                
            }

            
        }
        
        if(sender.tag == 2)
        {
            
        Update_Password()
            
        }
        
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(themes.screenSize.height == 480)
        {
            
            if(textField == Email_Field)
            {
                Reset_ScrollView.setContentOffset(CGPoint(x: 0.0, y: 60), animated: true)
            }

      if(textField == Password_Field)
            {
                Reset_ScrollView.setContentOffset(CGPoint(x: 0.0, y: 80), animated: true)
            }

            
        }
        
        if(themes.screenSize.height == 568)
        {
            
            if(textField == Email_Field)
            {
                Reset_ScrollView.setContentOffset(CGPoint(x: 0.0, y: 60), animated: true)
            }
            
            if(textField == Password_Field)
            {
                Reset_ScrollView.setContentOffset(CGPoint(x: 0.0, y: 60), animated: true)
            }
            
            
        }

    }
    
    func Update_Password()
    {
        
        
        if(Email_Field.text == "")
        {
            themes.AlertView("\(Appname)", Message: themes.setLang("enter_email_alert"), ButtonTitle: kOk)
        }
      else if(Password_Field.text == "")
        {
            themes.AlertView("\(Appname)", Message: themes.setLang("enter_password_alert"), ButtonTitle: kOk)

        }
        
        else
        {
        
            self.Reset_Password.isEnabled=false

        let param=["email":"\(Email_Field.text!)","password":"\(Password_Field.text!)","reset":"\(OTP_sta.OTP)"]
        
        URL_handler.makeCall(constant.Update_Password, param: param as NSDictionary) { (responseObject, error) -> () in
            self.Reset_Password.isEnabled=true

            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)

               // self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
            }
                
            else
            {
            if(responseObject != nil)
            {
                
                self.showProgress()

                 
                let dict:NSDictionary=responseObject!
                
                let Status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                let response=dict.object(forKey: "response") as! String
                
                if(Status == "1")
                {
                    self.themes.AlertView(self.themes.setLang("hurray"), Message: "\(response)", ButtonTitle: kOk)
                    
                    
                    
                    
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller.isKind(of: SignInViewController.self) {
                            self.navigationController?.poptoViewControllerWithFlip(controller:controller as UIViewController, animated: true)
                            break
                        }
                    }
//                     self.navigationController?.popViewControllerAnimated(true)
                    
               
                                     self.DismissProgress()
                    
                }
                else
                {
                    self.themes.AlertView("\(Appname)", Message: "\(response)", ButtonTitle: self.themes.setLang("ok"))
                    self.DismissProgress()

                    
                }

            }
            
            else
            {
                
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                self.DismissProgress()


                
            }
            }
            
        }
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
extension ResetPasswordViewController:UITextFieldDelegate
{
    
}
