//
//  ChangePasswordViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 12/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class ChangePasswordViewController: RootViewController {

    
    
    @IBOutlet weak var pass1_img: UIImageView!
    @IBOutlet weak var pass2_img: UIImageView!
    @IBOutlet weak var pass3_img: UIImageView!
    @IBOutlet var Done_Btn: UIButton!
    @IBOutlet var Change_Pass_ScrollView: UIScrollView!
    @IBOutlet var Wrapper_View: UIView!

    @IBOutlet var old_TextField: UITextField!

    @IBOutlet var New_TextField: UITextField!
    @IBOutlet var Confirm_textField: UITextField!
    
    @IBOutlet var Back_But: UILabel!
    
  var Appdel=UIApplication.shared.delegate as! AppDelegate
    
    let themes:Themes=Themes()
    
    var URL_handler:URLhandler=URLhandler()
    override func viewDidLoad() {
        super.viewDidLoad()
        
      self.pass1_img.image = pass1_img.changeImageColor(color: PlumberThemeColor)
        self.pass2_img.image = pass2_img.changeImageColor(color: PlumberThemeColor)
        self.pass3_img.image = pass3_img.changeImageColor(color: PlumberThemeColor)
        Wrapper_View.layer.borderWidth=1.0
        Wrapper_View.layer.borderColor=UIColor.lightGray.cgColor
        Wrapper_View.layer.cornerRadius=3.0
        old_TextField.placeholder=themes.setLang("old_password")
        New_TextField.placeholder=themes.setLang("confirm_password")
        Confirm_textField.placeholder=themes.setLang("new_password")
        Done_Btn.setTitle(themes.setLang("done"), for: UIControlState())
        themes.Back_ImageView.image=UIImage(named: "")
        Back_But.text = themes.setLang("change_password")
old_TextField.delegate=self
Confirm_textField.delegate=self
New_TextField.delegate=self
        let tapgesture:UITapGestureRecognizer=UITapGestureRecognizer(target:self, action: #selector(ChangePasswordViewController.DismissKeyboard(_:)))
        view.addGestureRecognizer(tapgesture)
    }
    
    func DismissKeyboard(_ sender:UITapGestureRecognizer) {
        
        
        
        
        view.endEditing(true)
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        // Dispose of any resources that can be recreated.
    }
    
    
    func applicationLanguageChangeNotification(_ notification:Notification)
    {
        
        //        themes.setLang(
        
        //        themes.setLang("Full Name",comment: nil)
        
        
        

        
    }

    
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
              
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == old_TextField)
        {
            old_TextField.resignFirstResponder()
            New_TextField.becomeFirstResponder()
        }
        if(textField == New_TextField)
        {
            New_TextField.resignFirstResponder()
            Confirm_textField.becomeFirstResponder()
        }
        if(textField == Confirm_textField)
        {
            Confirm_textField.resignFirstResponder()
         }
            return true

    }
    
    
    func changeName()
    {
        
    }
    
    
    
    @IBAction func didClickoptions(_ sender: AnyObject) {
        
        if(sender.tag == 0)
        {
            
            self.navigationController?.popToRootViewController(animated: true)
            
        }
        if(sender.tag == 1)
        {
            let Password : NSString = New_TextField.text! as NSString
            
            if(old_TextField.text == "")
            {
                themes.AlertView("\(Appname)", Message: self.themes.setLang("old_password_empty"), ButtonTitle: kOk)
            }
            else if(New_TextField.text == "")
            {
                themes.AlertView("\(Appname)", Message: self.themes.setLang("new_password_empty"), ButtonTitle: kOk)

            }
            else if(Password.length < 6 )
            {
                themes.AlertView("\(Appname)",Message: self.themes.setLang("valid_password"),ButtonTitle: kOk)
            }

                
            else if (Confirm_textField.text == "")
            {
                themes.AlertView("\(Appname)", Message: self.themes.setLang("confirm_password_empty"), ButtonTitle: kOk)

            }
                
                
                else if(New_TextField.text != Confirm_textField.text)
            {
                themes.AlertView("\(Appname)", Message:self.themes.setLang("password_unmatch"), ButtonTitle: kOk)

            }
            else
            {
                self.Done_Btn.isEnabled=false
                self.showProgress()

                
                let param=["user_id":"\(themes.getUserID())","password":"\(old_TextField.text!)","new_password":"\(New_TextField.text!)"]
                
                URL_handler.makeCall(constant.Change_pass.trimmingCharacters(in: CharacterSet.whitespaces), param: param as NSDictionary, completionHandler: { (responseObject, error) -> () in
                    self.Done_Btn.isEnabled=true
                    self.DismissProgress()

                    
                    if(error != nil)
                    {
                        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)

                       // self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                    }
                        
                    else
                    {
                        

                    
                    if(responseObject != nil)
                    {
                    let dict:NSDictionary=responseObject!
                    
                    
                    Changepass.status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                    
                    Changepass.response=dict.object(forKey: "response") as! String

                    
                    if(Changepass.status == "1")
                    {
                        self.themes.AlertView("Hurray", Message: "\(Changepass.response)", ButtonTitle: self.themes.setLang("ok"))

                        
                     //   self.Appdel.CheckDisconnect()
                        
                        
                        SocketIOManager.sharedInstance.LeaveRoom(self.themes.getUserID())
                        
                        
                        SocketIOManager.sharedInstance.LeaveChatRoom(self.themes.getUserID())
                        
                        
                        SocketIOManager.sharedInstance.RemoveAllListener();
                        
                        dbfileobj.deleteUser("Provider_Table")
                        
                        
                        let _: String = Bundle.main.bundleIdentifier!
                       // NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
                        //        themes.saveJaberID("5630701bcae2aaa80700002c@casp83")
                        //        themes.saveJaberPassword("4b01f338bf8d22a55299b369dc3a8287")
//                        self.themes.saveLanguage("en")
//                        self.themes.SetLanguageToApp()
                        self.Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "signinVCID")



                    }
                    else
                    {
                        
                        
                        self.themes.AlertView("\(Appname)", Message: "\(Changepass.response)", ButtonTitle: self.themes.setLang("ok"))
 
                    }
                    }
                    else
                    {
                        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)

                    }
                        
                    }

                    
                
                })
                
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

extension ChangePasswordViewController:UINavigationControllerDelegate
{
    
}
extension ChangePasswordViewController:UITextFieldDelegate
{
    
}
