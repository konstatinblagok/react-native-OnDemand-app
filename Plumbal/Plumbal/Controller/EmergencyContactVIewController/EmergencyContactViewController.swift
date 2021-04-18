//
//  EmergencyContactViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 06/11/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class EmergencyContactViewController: RootViewController,CLLocationManagerDelegate {
    @IBOutlet var Code_Field: UITextField!

    @IBOutlet weak var emergencyScroll: UIScrollView!
    @IBOutlet var Reset_Btn: UIButton!
    @IBOutlet var Email_Field: UITextField!
    @IBOutlet var Mobile_Field: UITextField!
    @IBOutlet var Name_Field: UITextField!
    @IBOutlet var Wrapper_View: UIView!
    @IBOutlet var SlideinMenu_But: UIButton!
    @IBOutlet var emergency_button: UIButton!

    @IBOutlet var EmergencyCnt_Lbl: UILabel!
    
    @IBOutlet var Note_Your: UILabel!
    @IBOutlet var List_Your: UILabel!
    @IBOutlet var save_Btn: UIButton!
    @IBOutlet var Picker_Wrapper: UIView!
    @IBOutlet var Country_PickerView: UIPickerView!
    var Contact:NSString=NSString()
    var themes:Themes=Themes()
    
    var URL_handler:URLhandler=URLhandler()
    let locationManager = CLLocationManager()
    var latitude = String()
    var longitude = String()


    override func viewDidLoad() {
        super.viewDidLoad()
        emergencyScroll.isHidden = false
        EmergencyCnt_Lbl.text=themes.setLang("emergency_contact1")
        save_Btn.setTitle(themes.setLang("save"), for: UIControlState())
        Reset_Btn.setTitle(themes.setLang("reset_contact"), for: UIControlState())
        List_Your.text=themes.setLang("emergency_disc1")
        Note_Your.text=themes.setLang("emergency_disc2")
        Code_Field.attributedPlaceholder=NSAttributedString(string: themes.setLang("code"), attributes:[NSForegroundColorAttributeName: UIColor.black])
        Name_Field.attributedPlaceholder=NSAttributedString(string: themes.setLang("enter_name"), attributes:[NSForegroundColorAttributeName: UIColor.black])
        Mobile_Field.attributedPlaceholder=NSAttributedString(string: themes.setLang("emter_mbl"), attributes:[NSForegroundColorAttributeName: UIColor.black])
        emergency_button.setTitle(themes.setLang("send_mail"), for: UIControlState())
        Email_Field.attributedPlaceholder=NSAttributedString(string: themes.setLang("enter_email"), attributes:[NSForegroundColorAttributeName: UIColor.black])
Reset_Btn.isHidden = true
        emergency_button.isHidden = true

        Wrapper_View.layer.borderWidth=1.0
        Wrapper_View.layer.borderColor=themes.Lightgray().cgColor
        Wrapper_View.layer.cornerRadius=5.0
        Reset_Btn.layer.cornerRadius=5.0
        emergency_button.layer.cornerRadius = 5.0
        
        
        Name_Field.delegate=self
        Mobile_Field.delegate=self
        Email_Field.delegate=self
        Code_Field.delegate=self
       
        if(themes.getCounrtyphone() != ""){
            Code_Field.text = "+ \(themes.getCounrtyphone())"
            
        }
        let TapGesture:UITapGestureRecognizer=UITapGestureRecognizer(target: self, action: #selector(EmergencyContactViewController.DismissKeyboard))
        self.view.addGestureRecognizer(TapGesture)
        // Do any additional setup after loading the view.
        
        //Tool Bar for Picker View
        
        
        Country_PickerView.showsSelectionIndicator = true
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: themes.setLang("done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(EmergencyContactViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        doneButton.tintColor=themes.ThemeColour()
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        Picker_Wrapper.addSubview(toolBar)
        
        Picker_Wrapper.removeFromSuperview()
        
        
        //ADD Done button for Contact Field
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        doneToolbar.backgroundColor=UIColor.white
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: themes.setLang("done"), style: UIBarButtonItemStyle.done, target: self, action: #selector(EmergencyContactViewController.doneButtonAction))
        
        
        doneToolbar.items = [flexSpace,done]
        
        doneToolbar.sizeToFit()
        
        Mobile_Field.inputAccessoryView = doneToolbar
       self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
        }
       

    }
    
    // MARK: - Location Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D? = manager.location!.coordinate
        if(locValue != nil){
            print("locations = \(locValue!.latitude) \(locValue!.longitude)")
            latitude="\(locValue!.latitude)"
            longitude="\(locValue!.longitude)"
            self.locationManager.stopUpdatingLocation()
        }
    }
    

    
     func applicationLanguageChangeNotification(_ notification:Notification)
    {
        
        EmergencyCnt_Lbl.text=themes.setLang("emergency_contact1")
        save_Btn.setTitle(themes.setLang("save"), for: UIControlState())
        Reset_Btn.setTitle(themes.setLang("reset_contact"), for: UIControlState())
        List_Your.text=themes.setLang("emergency_disc1")
        Note_Your.text=themes.setLang("emergency_disc2")
        Code_Field.attributedPlaceholder=NSAttributedString(string: themes.setLang("code"), attributes:[NSForegroundColorAttributeName: UIColor.black])
        Name_Field.attributedPlaceholder=NSAttributedString(string: themes.setLang("enter_name"), attributes:[NSForegroundColorAttributeName: UIColor.black])
        Mobile_Field.attributedPlaceholder=NSAttributedString(string: themes.setLang("emter_mbl"), attributes:[NSForegroundColorAttributeName: UIColor.black])
        emergency_button.setTitle(themes.setLang("send_mail"), for: UIControlState())
        Email_Field.attributedPlaceholder=NSAttributedString(string: themes.setLang("enter_email"), attributes:[NSForegroundColorAttributeName: UIColor.black])
        
    }

    
    @IBAction func menuButtonTouched(_ sender: AnyObject) {
        self.findHamburguerViewController()?.showMenuViewController()
    }

    func doneButtonAction()
    {
        Mobile_Field.resignFirstResponder()
        
        donePicker()
        
        
     }
     
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        self.ViewContact()
        

    }
    
    
    
    func ViewContact()
    {
        
        self.showProgress()
        
        let Param:NSDictionary=["user_id":"\(themes.getUserID())"]
        
        URL_handler.makeCall(constant.view_emergency, param: Param) { (responseObject, error) -> () in
    
    self.DismissProgress()

    if(error != nil)
    {
        self.emergencyScroll.isHidden = true
        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)

        //self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
    }
        
    else
    {
        
        
        if(responseObject != nil)
        {
            
            self.emergencyScroll.isHidden = false

            let dict:NSDictionary=responseObject!
            
            let Status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
            
            if(Status == "1")
            {
                self.Reset_Btn.isHidden=false
                self.emergency_button.isHidden = false

                 let emergency_contactArray:NSDictionary=responseObject?.object(forKey: "emergency_contact") as! NSDictionary
                
                
                    let name=emergency_contactArray.object(forKey: "name") as! String
                    
                    self.Name_Field.text=name
                    
                     let email=emergency_contactArray.object(forKey: "email") as! String
                    
                    self.Email_Field.text=email

                     
                    let mobile=self.themes.CheckNullValue(emergency_contactArray.object(forKey: "mobile"))!
                    
                    self.Mobile_Field.text=mobile

                    let country_code=self.themes.CheckNullValue(emergency_contactArray.object(forKey: "code"))!

                    self.Code_Field.text=country_code
                
            }
                
            else
            {
                self.Reset_Btn.isHidden=true
             }
            
            
        }
        else
        {
            self.emergencyScroll.isHidden = true

            self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
            
        }
        
    }
    
        }


    }


    func showPicker()
    {
        view.addSubview(self.Picker_Wrapper)
        
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.Picker_Wrapper.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 260.0, width: UIScreen.main.bounds.size.width, height: 260.0)
            
            } , completion: { _ in
                
                
                
        })
        
    }
    
    func donePicker()
    {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.Picker_Wrapper.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 260.0)
            
            }, completion: { _ in
                
                self.Picker_Wrapper.removeFromSuperview()
                
        })
        
        
        
        
    }
    
    
    
    //PickerVView Delegate
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
        
        self.Code_Field.text="\(themes.code[row])"
        
    }
    
    
     func DismissKeyboard()
    {
        self.donePicker()

        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        if(textField == Name_Field)
        {
            Name_Field.resignFirstResponder()
            self.showPicker()

 
            
        }
        
        if(textField == Code_Field)
        {
            view.endEditing(true)
            
            return false
            
        }
        if(textField == Mobile_Field)
        {
            Mobile_Field.resignFirstResponder()

            Email_Field.becomeFirstResponder()
            
        }
        if(textField == Email_Field)
        {
            Email_Field.resignFirstResponder()
            
            
        }



        return true
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
            
            if(textField == Name_Field)
            {
                
                self.donePicker()
                
                
            }
            
            if(textField == Code_Field)
            {
                self.showPicker()
                
                view.endEditing(true)
                return false
 
            }
            if(textField == Mobile_Field)
            {
                
                
                self.donePicker()

                
                
            }
        if(textField == Email_Field)
        {
            
            
            self.donePicker()
            
            
            
        }

        return true
        
            
        }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == Name_Field)
        {
            
            let aSet = CharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            
            
            
            
            
            return string == numberFiltered
        }
            
            
            
        else
        {
            return true
            
        }
        
    }

    
    
    @IBAction func didClickOption(_ sender: UIButton) {
        
        view.endEditing(true)
        
        
        if(sender.tag == 0)
        {
            
            Contact = Mobile_Field.text! as NSString
            
            let validateemail:Bool=themes.isValidEmail(Email_Field.text!)

            if(Mobile_Field.text == "" || Name_Field.text == "" || Email_Field.text == "" || Code_Field.text == "" )
            
            {
                themes.AlertView("\(Appname)", Message: themes.setLang("enter_all_fields"), ButtonTitle: kOk)
            }
            else if(Mobile_Field.text == "")
            {
                themes.AlertView("\(Appname)",Message: themes.setLang("enter_the_num"),ButtonTitle: kOk)
            }
            else if(Contact.length >= 15 || Contact.length < 7)
            {
                themes.AlertView("\(Appname)",Message:themes.setLang("enter_the_validnum"),ButtonTitle: kOk)
            }

            else if(validateemail == false)
            {
                themes.AlertView("\(Appname)", Message:themes.setLang("valid_email_alert"), ButtonTitle: kOk)
                
            }
                
                

            else
            {

            
            self.showProgress()
            
            let Param:NSDictionary=["user_id":"\(themes.getUserID())","em_name":"\(Name_Field.text!)","em_email":"\(Email_Field.text!)","em_mobile_code":"\(Code_Field.text!)","em_mobile":"\(Mobile_Field.text!)"]
                
                print("\(Param)......\(constant.add_emergency)")
            
            URL_handler.makeCall(constant.add_emergency, param: Param) { (responseObject, error) -> () in
                
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
                        
                        let Status = self.themes.CheckNullValue(dict.object(forKey: "status"))!
                        let response=dict.object(forKey: "response") as! String

                        
                        if(Status == "1")
                        {
                            self.emergency_button.isHidden = false

                            self.themes.AlertView("\(Appname)", Message:"\(self.themes.CheckNullValue(dict.object(forKey: "response"))!)", ButtonTitle: self.themes.setLang("ok"))
                            self.Reset_Btn.isHidden=false

                        }
                            
                            
                        else
                        {
                            
                            self.themes.AlertView("\(Appname) ", Message: "\(response)", ButtonTitle: self.themes.setLang("ok"))

                        }
                        
                        
                    }
                    else
                    {
                        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                        
                    }
                    
                }
                
            }
            
            }
            
        }
        if(sender.tag == 1)
        {

            
            if(Mobile_Field.text == "" || Name_Field.text == "" || Email_Field.text == "")
            {
                themes.AlertView("\(Appname)", Message: themes.setLang("enter_all_fields"), ButtonTitle: kOk)
            }
            else
            {

            
            self.showProgress()
            
            let Param:NSDictionary=["user_id":"\(themes.getUserID())"]
            
            URL_handler.makeCall(constant.Delete_emergency, param: Param) { (responseObject, error) -> () in
                
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
                        
                        let Status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                        
                        if(Status == "1")
                        {
                            
                            
                            self.themes.AlertView("\(Appname)", Message:"\(self.themes.CheckNullValue(dict.object(forKey: "response"))!)", ButtonTitle: self.themes.setLang("ok"))
                            self.Reset_Btn.isHidden=true
                            self.emergency_button.isHidden = true
                            self.Mobile_Field.text = ""
                            self.Name_Field.text = ""
                            if(self.themes.getCounrtyphone() != ""){
                                self.Code_Field.text = "+ \(self.themes.getCounrtyphone())"
                                
                            }
                            else{
                                self.Code_Field.text = ""
                            }

                            self.Email_Field.text = ""
                        }
                        else
                        {
                         }
                        
                        
                    }
                    else
                    {
                        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                        
                    }
                    
                }
                
            }
            }

            
        }

    }
    
    
    @IBAction func didClickEmergency(_ sender: AnyObject) {
        self.showProgress()
        let Param:NSDictionary=["user_id":"\(themes.getUserID())","latitude":latitude,"longitude":longitude]
        URL_handler.makeCall(constant.contact_emergency, param: Param) { (responseObject, error) -> () in
            
            self.DismissProgress()
            if(error != nil) {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
            }else {
                if(responseObject != nil)  {
                    let dict:NSDictionary=responseObject!
                    let Status:NSNumber=dict.object(forKey: "status") as! NSNumber
                    let response=dict.object(forKey: "response") as! String
                    
                    if(Status == 1)  {
                        self.themes.AlertView(Appname, Message: response, ButtonTitle: self.themes.setLang("ok"))
                        
                    } else{
                        self.themes.AlertView("\(Appname) ", Message: response, ButtonTitle: self.themes.setLang("ok"))
                    }
                } else  {
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
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


extension  EmergencyContactViewController: UITextFieldDelegate {
}

