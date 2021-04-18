//
//  EditProfileViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 12/10/15.
//  Copyright (c) 2015 Casperon Tech. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import WDImagePicker
import SDWebImage
import DLHamburgerMenu

//import SwiftyJSON
import AssetsLibrary
extension NSMutableData {
    
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
class EditProfileViewController: RootViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,WDImagePickerDelegate {
    @IBOutlet var Code_textField: UITextField!
    @IBOutlet var numEditbtn: UIButton!
    @IBOutlet var nameEditBtn:UIButton!
    @IBOutlet var UserImage: UIImageView!
    @IBOutlet var CountryCode_Picker: UIPickerView!
    @IBOutlet weak var Username: UILabel!
    
    @IBOutlet var passwordlabl: UILabel!
    @IBOutlet var emailview: UIView!
    @IBOutlet var mydetailsView: UIView!
    @IBOutlet var mydetailslabl: UILabel!
    @IBOutlet var seperatorimg: UIImageView!
    @IBOutlet var passwdimg: UIImageView!
    @IBOutlet var editpasswordimg: UIButton!
    @IBOutlet var passwordbtn: UIButton!
    @IBOutlet var Edit_Signin_Lbl: UILabel!
    @IBOutlet var Edit_Contact_Lbl: UILabel!
    @IBOutlet var MyProfile_btn: UIButton!
    @IBOutlet var Picker_Wrapper: UIView!
    @IBOutlet var Background_Image: UIImageView!
    
    @IBOutlet var Passwd_TextField: UITextField!
    @IBOutlet var Edit_Btn: UIButton!
    @IBOutlet var Edit_Profile_View: UIView!
    
    @IBOutlet var Full_Name_TextField: UITextField!
    @IBOutlet var Email_TextField: UITextField!
    
    @IBOutlet var Contact_TextField: UITextField!
    
    @IBOutlet var Edit_Profile_ScollView: UIScrollView!
    
    @IBOutlet var Fullname_Editicon: UIImageView!
    
    @IBOutlet var Contact_Editicon: UIImageView!
    
    let picker = UIImagePickerController()
    @IBOutlet weak var lblMyProf: UILabel!
    @IBOutlet weak var lnlName: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var lblEmailid: UILabel!
    @IBOutlet weak var lblMobileno: UILabel!
    //  @IBOutlet var savebtn: UIButton!
    
    var imagedata : Data = Data()
    func Done_Toolbar()
    {
        
        //ADD Done button for Contatct Field
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        doneToolbar.backgroundColor=UIColor.white
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: themes.setLang("done"), style: UIBarButtonItemStyle.done, target: self, action: #selector(EditProfileViewController.doneButtonAction))
        doneToolbar.items = [flexSpace,done]
        
        doneToolbar.sizeToFit()
        
        Contact_TextField.inputAccessoryView = doneToolbar
        
    }
    
    @IBAction func editusername(_ sender: AnyObject) {
        Full_Name_TextField.becomeFirstResponder()
        Contact_TextField.resignFirstResponder()
    }
    
    @IBAction func editmobilenum(_ sender: AnyObject) {
        Full_Name_TextField.resignFirstResponder()
        Contact_TextField.becomeFirstResponder()
    }
    
    @IBAction func editName(_ sender: AnyObject) {
        Full_Name_TextField.becomeFirstResponder()
    }
    
    @IBAction func logout(_ sender: AnyObject) {
        
        
        
        
        SocketIOManager.sharedInstance.LeaveRoom(themes.getUserID())
        
        
        SocketIOManager.sharedInstance.LeaveChatRoom(themes.getUserID())
        
        dbfileobj.deleteUser("Provider_Table")
        let _: String = Bundle.main.bundleIdentifier!
        
        
        Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "signinVCID")
        
        
    }
    @IBOutlet var WrapperView: UIView!
    
    @IBOutlet var Slide_Menu_But: UIButton!
    var webData: Data = Data ()
    var dbfileobj: DBFile = DBFile()
    
    var imagePicker = WDImagePicker()
    var themes:Themes=Themes()
    var imgSearch: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    
    var URL_handler:URLhandler=URLhandler()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        picker.delegate = self
      
        lblEmailid.text = themes.setLang("email_id_smal")
        
        lblMyProf.text = themes.setLang("my_profile")
        mydetailslabl.text = themes.setLang("my_detail")
        lnlName.text = themes.setLang("name")
        lblCode.text = themes.setLang("code")
        Edit_Contact_Lbl.text = themes.setLang("user_details")
        lblMobileno.text = themes.setLang("mobile_no_small")
        // savebtn.setTitle(themes.setLang("save"), forState: UIControlState.Normal)
        passwordlabl.text = themes.setLang("change_password")
        
        OTP_sta.OTP_Paging="EditProfile"
        //Tool bar for Pickerview
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: themes.setLang("done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditProfileViewController.done_PickerView))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        doneButton.tintColor=themes.ThemeColour()
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        Picker_Wrapper.addSubview(toolBar)
        Picker_Wrapper.removeFromSuperview()
        imagePicker.delegate=self
        // UserImage.layer.borderWidth=3.0
        UserImage.layer.cornerRadius=UserImage.frame.size.width/2
        UserImage.clipsToBounds=true
        // UserImage.layer.borderColor=themes.ThemeColour().cgColor
        
        
        
        Edit_Profile_ScollView.contentSize.height = mydetailsView.frame.height+mydetailsView.frame.origin.y+20
        
        Full_Name_TextField.delegate=self
        Email_TextField.delegate=self
        Code_textField.delegate=self
        Contact_TextField.delegate=self
        
        Username.text = themes.getUserName()
        self.UserImage.sd_setImage(with: URL(string: "\(themes.getuserDP())"), placeholderImage: UIImage(named: "PlaceHolderSmall"))
        //UserImage.sd_setImageWithURL(NSURL(string: "\(themes.getuserDP())"), completed: themes.block)
        Full_Name_TextField.text=themes.getUserName()
        Email_TextField.text=themes.getEmailID()
        Passwd_TextField.text=themes.getUserPasswd()
        Contact_TextField.text=themes.getMobileNum()
        Email_TextField.isEnabled=false
        Code_textField.text=themes.getCountryCode()
        
        
        if themes.getUserPasswd() == "" {
            
            Passwd_TextField.isHidden = true
            seperatorimg.isHidden = true
            passwdimg.isHidden = true
            editpasswordimg.isHidden = true
            passwordlabl.isHidden = true
            emailview.frame = CGRect(x: emailview.frame.origin.x,y: emailview.frame.origin.y,width: emailview.frame.size.width,height: emailview.frame.size.height - (Passwd_TextField.frame.size.height+passwordlabl.frame.size.height-seperatorimg.frame.size.height))
            
            mydetailslabl.frame = CGRect(x: mydetailslabl.frame.origin.x,y: emailview.frame.origin.y+emailview.frame.size.height+Passwd_TextField.frame.size.height,width: mydetailslabl.frame.size.width,height: mydetailslabl.frame.size.height )
            mydetailsView.frame = CGRect(x: mydetailsView.frame.origin.x,y: mydetailslabl.frame.origin.y+mydetailslabl.frame.size.height+3,width: mydetailsView.frame.size.width, height: mydetailsView.frame.size.height)
            
        }
        Full_Name_TextField.autocorrectionType=UITextAutocorrectionType.no
        let tapgesture:UITapGestureRecognizer=UITapGestureRecognizer(target:self, action: #selector(EditProfileViewController.DismissKeyboard(_:)))
        view.addGestureRecognizer(tapgesture)
        //        Background_Image.sd_setImageWithURL(NSURL(string: "\(themes.getuserDP())"), completed: themes.block)
        Edit_Profile_ScollView.delegate=self
        Done_Toolbar()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func menuButtonTouched(_ sender: AnyObject) {
        self.findHamburguerViewController()?.showMenuViewController()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView == Edit_Profile_ScollView)
        {
            let offset: CGFloat = scrollView.contentOffset.y
            let percentage: CGFloat = (offset / CGFloat(223))
            let _: CGFloat = CGFloat(223) * percentage
            //Background_Image.frame = CGRectMake(0, value, Background_Image.bounds.size.width, CGFloat(179) - value)
            let alphaValue: CGFloat = 1 - fabs(percentage)
            UserImage.alpha = alphaValue * alphaValue * alphaValue
        }
        
    }
    
    
    
    func doneButtonAction()
    {
        Contact_TextField.resignFirstResponder()
        
        Edit_Prof.Contact_Number=Contact_TextField.text!
        Edit_Prof.Country_Code=Code_textField.text!
        
        self.GetOTP()
    }
    
    
    func GetOTP()
    {
        
        let Contact : NSString = self.Contact_TextField.text! as NSString
        
        if(Contact.length >= 15 || Contact.length < 6)
        {
            self.themes.AlertView("\(Appname)",Message: self.themes.setLang("enter_the_validnum"),ButtonTitle: self.themes.setLang("ok"))
        }
        else
            
        {
            
            self.showProgress()
            
            
            let parameters:NSDictionary=["user_id":"\(themes.getUserID())",
                "country_code":"\(Edit_Prof.Country_Code)",
                "phone_number":"\(Edit_Prof.Contact_Number)"]
            
            
            URL_handler.makeCall(constant.changemobilenumber, param: parameters) { (responseObject, error) -> () in
                self.DismissProgress()
                if(error != nil)
                {
                    // self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    
                }
                    
                else
                {
                    if(responseObject != nil)
                        
                    {
                        let Dict:NSDictionary=responseObject!
                        let Status=self.themes.CheckNullValue(Dict.object(forKey: "status"))!
                        if(Status == "1")
                        {
                            
                            let OTP=self.themes.CheckNullValue(Dict.object(forKey: "otp"))!
                            
                            if((OTP as NSString).length>0){
                                
                                
                                OTP_sta.OTP="\(OTP)"
                                OTP_sta.OTP_Status=self.themes.CheckNullValue(Dict.object(forKey: "otp_status"))!
                                let otpview : OTPViewController = OTPViewController()
                                otpview.otpstring = "\(OTP)"
                                otpview.otpstatus_str = self.themes.CheckNullValue(Dict.object(forKey: "otp_status"))!
                                self.performSegue(withIdentifier: "OTP", sender: nil)
                            }
                        }
                        else
                        {
                            let Reponse:NSString=Dict.object(forKey: "response") as! NSString
                            
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    func DismissKeyboard(_ sender:UITapGestureRecognizer)
    {
        
        // Edit_Profile_ScollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        
        
        
        view.endEditing(true)
        numEditbtn.isHidden = false
        // nameEditBtn.hidden = false
        
        
    }
    
    func  textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == Full_Name_TextField
        {
            numEditbtn.isHidden = false
            //nameEditBtn.hidden = false
            
        }
        else if textField == Contact_TextField
        {
            numEditbtn.isHidden = true
            // nameEditBtn.hidden = false
            
            
        }else if textField == Full_Name_TextField{
            //nameEditBtn.hidden = true
            
        }
        else if (textField == Code_textField)
        {
            
        }
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == Full_Name_TextField)
        {
            
            if (textField.text  == "")
            {
                themes.AlertView("", Message:  themes.setLang("enter_username"), ButtonTitle: kOk)
                textField.resignFirstResponder()
                
            }
            else
            {
                textField.resignFirstResponder()
                
                self.updateName()
                
            }
            
            
            
            
        }
        else if (textField==Contact_TextField)
        {
            
            if (textField.text  == "")
            {
                themes.AlertView("", Message: themes.setLang("emter_mbl"), ButtonTitle: kOk)
                textField.resignFirstResponder()
                
                
            }
            else
            {
                textField.resignFirstResponder()
                
                self.GetOTP()
            }
            
            
        }
        
        return true
    }
    
    
    func  textFieldDidEndEditing(_ textField: UITextField) {
        if (textField==Full_Name_TextField)
        {
            //nameEditBtn.hidden = false
            
            numEditbtn.isHidden = false
            
        }
        else if (textField==Contact_TextField)
        {
            //nameEditBtn.hidden = false
            
            numEditbtn.isHidden = false
            
            
        }else if textField == Full_Name_TextField{
            //nameEditBtn.hidden = true
            
        }
        
        
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if(textField == Full_Name_TextField)
        {
            // Fullname_Editicon.hidden=true
            donePicker()
            
            
            if(themes.screenSize.height == 480)
            {
                
                
                Edit_Profile_ScollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
            }
            
            if(themes.screenSize.height == 568)
            {
                
                
                Edit_Profile_ScollView.setContentOffset(CGPoint(x: 0.0,y: textField.frame.origin.y-50), animated: true)
                
                
            }
            
            
            
        }
        if(textField == Contact_TextField)
        {
            
            //  Contact_Editicon.hidden=true
            
            donePicker()
            
            
            if(themes.screenSize.height == 480)
            {
                
                
                Edit_Profile_ScollView.setContentOffset(CGPoint(x: 0, y: 280), animated: true)
            }
            if(themes.screenSize.height == 568)
            {
                Edit_Profile_ScollView.setContentOffset(CGPoint(x: 0, y: 190), animated: true)
            }
            
            if(themes.screenSize.height == 667)
            {
                Edit_Profile_ScollView.setContentOffset(CGPoint(x: 0, y: 140), animated: true)
            }
            if(themes.screenSize.height == 736)
            {
                Edit_Profile_ScollView.setContentOffset(CGPoint(x: 0, y: 120), animated: true)
            }
            
        }
        
        if(textField == Code_textField)
        {
            
            
            if(themes.screenSize.height == 480)
            {
                
                
                Edit_Profile_ScollView.setContentOffset(CGPoint(x: 0, y: 280), animated: true)
            }
            if(themes.screenSize.height == 568)
            {
                
                
                Edit_Profile_ScollView.setContentOffset(CGPoint(x: 0, y: 200), animated: true)
            }
            
            if(themes.screenSize.height == 667)
            {
                
                
                Edit_Profile_ScollView.setContentOffset(CGPoint(x: 0, y: 150), animated: true)
            }
            if(themes.screenSize.height == 736)
            {
                
                
                Edit_Profile_ScollView.setContentOffset(CGPoint(x: 0, y: 120), animated: true)
            }
            
            
            self.showPicker()
            
            
            view.endEditing(true)
            
            return false
            
            
            
            
        }
        
        return true
        
        
        
    }
    
    
    
    
    func donePicker()
    {
        self.Edit_Profile_ScollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.Picker_Wrapper.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 260.0)
            
        }, completion: { _ in
            
            self.Picker_Wrapper.removeFromSuperview()
            
            
            if(self.Contact_TextField.text == "")
            {
                self.Contact_TextField.becomeFirstResponder()
            }
            
            
            
        })
        
        
        
    }
    
    func done_PickerView()
    {
        self.Edit_Profile_ScollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.Picker_Wrapper.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 260.0)
            
        }, completion: { _ in
            
            self.Picker_Wrapper.removeFromSuperview()
            
            
            if(self.Contact_TextField.text == "")
            {
                self.Contact_TextField.becomeFirstResponder()
            }
                
            else
            {
                let Contact : NSString = self.Contact_TextField.text! as NSString
                
                if(Contact.length >= 15 || Contact.length < 7)
                {
                    self.themes.AlertView("\(Appname)",Message: self.themes.setLang("enter_the_validnum"),ButtonTitle: "Ok")
                }
                else
                    
                {
                    
                    Edit_Prof.Contact_Number=self.Contact_TextField.text!
                    Edit_Prof.Country_Code=self.Code_textField.text!
                    self.GetOTP()
                }
                
            }
            
            
        })
        
        
        
    }
    //ScrollView Delegate
    
    
    
    
    
    func showPicker()
    {
        
        
        
        view.addSubview(self.Picker_Wrapper)
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.Picker_Wrapper.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 260.0, width: UIScreen.main.bounds.size.width, height: 260.0)
            
        } , completion: { _ in
            
            
            
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
        
        Code_textField.text="\(themes.code[row])"
        Addaddress_Data.Country_code="\(themes.code[row])"
    }
    
    
    
    func updateName()
    {
        
        Full_Name_TextField.resignFirstResponder()
        
        if(Full_Name_TextField.text! == signup.username as String)
        {
            themes.AlertView("\(Appname)", Message: themes.setLang("made_no_changes"), ButtonTitle: kOk)
        }
        else
        {
            self.showProgress()
            let parameter=["user_id":"\(themes.getUserID())","user_name":"\(Full_Name_TextField.text!)"]
            
            URL_handler.makeCall(constant.Change_Name, param: parameter as NSDictionary, completionHandler: { (responseObject, error) -> () in
                self.DismissProgress()
                
                if(error != nil)
                {
                    // self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    
                }
                    
                else
                {
                    
                    
                    if(responseObject != nil)
                    {
                        let dict:NSDictionary=responseObject!
                        
                        Edit_Prof.status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                        
                        Edit_Prof.response=dict.object(forKey: "response") as! String
                        
                        if(Edit_Prof.status == "1")
                        {
                            self.themes.AlertView("\(Appname)", Message: "\(Edit_Prof.response)", ButtonTitle: self.themes.setLang("ok"))
                            
                            Edit_Prof.UserName_Updated=dict.object(forKey: "user_name") as! String
                            signup.username=Edit_Prof.UserName_Updated
                            
                            self.themes.saveUserName(signup.username as String)
                            
                            self.Username.text =  signup.username as String
                            
                        }
                            
                            
                        else
                        {
                            
                            
                            self.themes.AlertView("\(Appname)", Message: "\(Edit_Prof.response)", ButtonTitle: self.themes.setLang("ok"))
                            
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
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didClickoptions(_ sender: AnyObject) {
        
        
        if(sender.tag == 2)
        {
            let app_delegate=UIApplication.shared.delegate as! AppDelegate
            
            
            
            let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDel.MakeRootVc("SplashPage")
            
        }
        
        if(sender.tag == 3)
        {
            
            let ImagePicker_Sheet = UIAlertController(title: nil, message: themes.setLang("select_image")
                , preferredStyle: .actionSheet)
            
            let Camera_Picker = UIAlertAction(title: themes.setLang("camera")
                , style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.Camera_Pick()
            })
            let Gallery_Picker = UIAlertAction(title: themes.setLang("gallery")
                , style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    //
                    self.Gallery_Pick()
                    
            })
            
            let cancelAction = UIAlertAction(title: themes.setLang(themes.setLang("cancel")
                ), style: .cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
            })
            
            
            ImagePicker_Sheet.addAction(Camera_Picker)
            ImagePicker_Sheet.addAction(Gallery_Picker)
            ImagePicker_Sheet.addAction(cancelAction)
            
            self.present(ImagePicker_Sheet, animated: true, completion: nil)
        }
        
        if (sender.tag == 10)
        {
            Appdel.MakeRootVc("RootVCID")
            
        }
    }
    
    
    @IBAction func didclicksavebtn(_ sender: AnyObject) {
        
    }
    
    
    
    
    func Camera_Pick()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "Sorry, this device has no camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func Gallery_Pick()
    {
        picker.allowsEditing = false
        picker.sourceType = .savedPhotosAlbum
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum)!
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        UserImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let pickimage = info[UIImagePickerControllerOriginalImage] as? UIImage
        let pickedimage = self.themes.rotateImage(pickimage!)
        imagedata = UIImageJPEGRepresentation(pickedimage, 0.1)!;
        self.uploadImageAndData()
        dismiss(animated:true, completion: nil) //5
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
        
    }
     func hideImage_Picker(){
        self.hideImagePicker()
    }
    func hideImagePicker() {
        self.imagePicker.imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func uploadImageAndData(){
        
        let param : NSDictionary =  ["user_id"  : themes.getUserID()]
        let imageData = imagedata
        
        self.showProgress()
        
        let URL = try! URLRequest(url: constant.Image_Edit, method: .post, headers: ["apptype": "ios", "apptoken":"\(Device_Token)", "userid":"\(themes.getUserID())"])
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(imageData, withName: "file", fileName: "file.png", mimeType: "")
            
            for (key, value) in param {
                
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key as! String)
            }
            
        }, with: URL, encodingCompletion: { encodingResult in
            
            
            switch encodingResult {
                
            case .success(let upload, _, _):
                
                
                upload.responseJSON { response in
                    
                    
                    if let JSON = response.result.value {
                        self.DismissProgress()
                        print("JSON: \(JSON)")
                        
                        
                        let Status:String = self.themes.CheckNullValue((JSON as AnyObject).object(forKey: "status"))!
                        let response:NSDictionary = (JSON as AnyObject).object(forKey: "response") as! NSDictionary
                        if(Status == "1"){
                            self.view.makeToast(message:self.themes.CheckNullValue(response.object(forKey:"msg"))!, duration: 4, position: HRToastPositionDefault, title:"\(Appname)")
                            self.themes.saveuserDP(self.themes.CheckNullValue(response.object(forKey:"image")!)!)
                            signup.Userimage=self.themes.getuserDP()
                            
                        }
                        else  {
                            self.UserImage.sd_setImage(with: NSURL(string:self.themes.getuserDP()) as URL?, placeholderImage: UIImage(named: "PlaceHolderSmall"))
                            
                            
                            self.view.makeToast(message:self.themes.CheckNullValue(response.object(forKey: "msg"))!, duration: 4, position: HRToastPositionDefault, title: "")
                            
                        }
                        
                    }
                }
                
            case .failure(let encodingError):
                self.DismissProgress()
                self.UserImage.sd_setImage(with: NSURL(string:self.themes.getuserDP()) as URL?, placeholderImage: UIImage(named: "PlaceHolderSmall"))
                
                //                      self.themes.AlertView("Image Upload Failed", Message: "Please try again", ButtonTitle: "Ok")
                print(" the encodeing error is \(encodingError)")
            }
        })
    }
    
}










extension EditProfileViewController:UITextFieldDelegate
{
    
}

extension EditProfileViewController:UIScrollViewDelegate
{
    
}




