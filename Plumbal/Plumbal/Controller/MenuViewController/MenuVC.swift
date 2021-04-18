//
//  MenuViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 03/03/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//


import UIKit
import MessageUI
import DLHamburgerMenu
import NVActivityIndicatorView

class MenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource,MFMailComposeViewControllerDelegate  {
  
    @IBOutlet weak var animation_top_view: CSAnimationView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var btn_Signup: UIButton!
    var segues = [String]()
    let Icons = ["Support_Black", "Purchase Order","Wallet Filled","Transaction","notification","review","Talk","Warning Shield","chaticon","About-30","logout"]
    
    
    
    
    
    
    var Appdel=UIApplication.shared.delegate as! AppDelegate
    var URL_handler:URLhandler=URLhandler()
    var themes:Themes=Themes()
       var GetReceipientMail : String = ""
    var Citylistarray:NSMutableArray=NSMutableArray()
    var Cityidarray:NSMutableArray=NSMutableArray()
    let activityTypes: [NVActivityIndicatorType] = [
        .ballPulse]
    let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 75, height: 100),
                                                        type: .ballSpinFadeLoader)
    var trimmed_Location:String=String()

    
    @IBOutlet var Email_But: UIButton!
    @IBOutlet var User_Name: UIButton!
    @IBOutlet var btnSignIn: UIButton!
    @IBOutlet var UserImage: UIImageView!
    @IBOutlet var signImage: UIImageView!
    @IBOutlet var Arrow_Indicator: UIImageView!
    
    
    //MARK: - Override Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        segues = [themes.setLang("home"),
                  themes.setLang("my_order"),
                  themes.setLang("my_money"),
                  themes.setLang("transactions_caps"),
                  themes.setLang("notifications_caps"),
                  themes.setLang("reviews_caps"),
                  themes.setLang("invite_friends"),
                  themes.setLang("report_issues"),
                  themes.setLang("chat_space"),
                
                  themes.setLang("about_us"),
                  
                 
                  themes.setLang("logout")
                  

        ]

        let nibName = UINib(nibName: "SlideCustomTableViewCell", bundle:nil)
        self.tableView.register(nibName, forCellReuseIdentifier: "SlideCustomTableViewCell")
        let nibName1 = UINib(nibName: "LocationTableViewCell", bundle:nil)
        self.tableView.register(nibName1, forCellReuseIdentifier: "Cell")
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView=UIView()
        tableView.separatorColor=UIColor.clear
        Setdata()
        self.getAppinformation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.themes.MakeAnimation(view: self.animation_top_view, animation_type: CSAnimationTypePop)
//            self.animation_top_view.type = CSAnimationTypePop
//            self.animation_top_view.duration = 0.5
//            self.animation_top_view.delay = 0
//            self.animation_top_view.startCanvasAnimation()
        })
        animateTable()
    }
    
    
    func animateTable() {
        tableView.reloadData()
        let cells = tableView.visibleCells
        for i in cells {
            let cell: SlideCustomTableViewCell = i as! SlideCustomTableViewCell
            cell.animation_view.transform = CGAffineTransform(translationX: -self.view.frame.size.width, y: 0)
        }
        var index = 0
        for a in cells {
            let cell: SlideCustomTableViewCell = a as! SlideCustomTableViewCell
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
                cell.animation_view.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            index += 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: -  Function
    
    func Setdata() {
        
        //Divya
        Menu_dataMenu.Choose_Location=themes.getLocationname()
        if themes.getEmailID() == ""{
            btn_Signup.isHidden = false
            btnSignIn.isHidden = false
            signImage.isHidden = false
            UserImage.isHidden = true
            btn_Signup.setTitle(themes.setLang("register_caps"), for: UIControlState())
            btnSignIn.setTitle(themes.setLang("login"), for: UIControlState())
            btnSignIn.layer.cornerRadius = 5
            btn_Signup.layer.cornerRadius = 5
        } else{
            btn_Signup.isHidden = true
            btnSignIn.isHidden = true
            signImage.isHidden = true
            UserImage.isHidden = false
            tableView.isUserInteractionEnabled = true
            Email_But.setTitle("(\(themes.getCountryCode()))\(themes.getMobileNum())", for: UIControlState())
            Email_But.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
            UserImage.layer.cornerRadius=UserImage.frame.size.width/2
            UserImage.clipsToBounds=true
            User_Name.setTitle("\(themes.getUserName())", for: UIControlState())
        }
        
        if themes.getMobileNum() ==  ""{
            Email_But.setTitle("", for: UIControlState())
        }
        
        trimmed_Location=Menu_dataMenu.Choose_Location.trimmingCharacters(in: CharacterSet.whitespaces)
        if themes.getuserDP().isEmpty{
            UserImage.image = UIImage(named:"user")!
        } else {
            UserImage.sd_setImage(with: URL(string: "\(themes.getuserDP())"), placeholderImage: UIImage(named: "PlaceHolderSmall"))
//            User_Name.setTitle("\(themes.getUserName())", forState: UIControlState.Normal)
//            User_Name.titleLabel?.sizeToFit()
        }
    }
    
    
    
    func  getAppinformation()
    {
        
        let URL_Handler:URLhandler=URLhandler()
        URL_Handler.makeCall(constant.Appinfo_url, param: [:]) {
            (responseObject, error) -> () in
            
            if(error != nil)
            {
                
            }
            else
            {
                if(responseObject != nil && (responseObject?.count)!>0)
                {
                    let status=self.themes.CheckNullValue(responseObject?.object(forKey: "status"))!
                    if(status == "1")
                    {
                        
                        self.GetReceipientMail = self.themes.CheckNullValue(responseObject?.object(forKey: "email_address"))!
                        
                        
                    }
                    else
                    {
                    }
                    
                    
                }
            }
        }
        
    }

    func showProgress() {
        self.activityIndicatorView.color = themes.DarkRed()
        self.activityIndicatorView.center=CGPoint(x: self.view.frame.size.width/2,y: self.view.frame.size.height/2);
        self.activityIndicatorView.startAnimating()
        self.view.addSubview(activityIndicatorView)
    }
    
    func DismissProgress() {
        self.activityIndicatorView.stopAnimating()
        self.activityIndicatorView.removeFromSuperview()
    }
    
    func LogoutoftheApp(){
        
        let AlertView = UIAlertController(title: themes.setLang("logout_alert"), message: "", preferredStyle: .alert)
        let ok = UIAlertAction(title: themes.setLang("ok"), style: .default) { (action : UIAlertAction) in
            self.LogoutMethod()
        }
        
        let cancel = UIAlertAction(title: themes.setLang("cancel"), style: .default) { (action : UIAlertAction) in
            
        }
        AlertView.addAction(ok)
        AlertView.addAction(cancel)
        self.present(AlertView, animated: true, completion: nil)
        //AlertView.tag = sender.tag

       // self.LogoutMethod()
    }
    
    func LogoutMethod(){
        self.showProgress()
        let Param: Dictionary = ["user_id":"\(themes.getUserID())","device_type":"ios"]
        URL_handler.makeCall(constant.Logout_url, param: Param as NSDictionary) { (responseObject, error) -> () in
            self.DismissProgress()
            if(error != nil)  {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
            } else {
                if(responseObject != nil) {
                    let status = self.themes.CheckNullValue(responseObject?.object(forKey: "status")!)
                    if(status! == "0") {
                    }
                  //  self.Appdel.CheckDisconnect()
                    SocketIOManager.sharedInstance.LeaveRoom(self.themes.getUserID())
                    SocketIOManager.sharedInstance.LeaveChatRoom(self.themes.getUserID())
                    SocketIOManager.sharedInstance.RemoveAllListener();
                    dbfileobj.deleteUser("Provider_Table")
                    let _: String = Bundle.main.bundleIdentifier!
                  //  NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
                    
                    //Divya
                    UserDefaults.standard.removeObject(forKey: "userID")
                    UserDefaults.standard.removeObject(forKey: "EmailID")

                    

                    self.Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "signinVCID")
                }  else {
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                }
            }
        }
    }
    
    func showSendMailErrorAlert() {
        themes.AlertView(themes.setLang("not_send_email"), Message: themes.setLang("device_not_send_email"), ButtonTitle: kOk)
    }
    //MARK: - Button Function
    
    @IBAction func didClickoptions(_ sender: UIButton) {
        if(sender.tag == 2) {
            if themes.getEmailID() == ""{
                Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "signinVCID")
            } else {
                Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "ProfileVCID")
            }
        }
        else if (sender.tag == 1){
            let signUp_VC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewControllerID") as! SignUpViewController
            signUp_VC.getPrev_VC = "From Side Menu"
            self.navigationController?.pushViewController(withFlip: signUp_VC, animated: true)
             //Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "SignUpVCID")
        }
        else{
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var Count:Int=Int()
        if themes.getEmailID() == "" {
            Count = 0;
        }  else{
            Count = segues.count
        }
        return Count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SlideCustomTableViewCell", for: indexPath) as! SlideCustomTableViewCell
        if themes.getEmailID() == "" {
            cell.Menulist.isHidden=true
            cell.MenuIcon.isHidden=true
        } else {
            cell.Menulist.isHidden=false
            cell.MenuIcon.isHidden=false
            cell.Menulist.text = segues[indexPath.row]
            cell.MenuIcon.image=UIImage(named:"\(Icons[indexPath.row])")
            
            cell.MenuIcon.image =  cell.MenuIcon.changeImageColor(color: .white)
            cell.SeperatorLab.isHidden=false
            if(indexPath.row == 2){
                cell.Wallet_Amount.isHidden=false
                NSLog("get currency name=%@ and value=%@ ",themes.getCurrencyCode(),themes.getCurrency() )
                if themes.getCurrency() == "" {
                    cell.Wallet_Amount.text="\(themes.getCurrencyCode())0"
                }else {
                    cell.Wallet_Amount.text="\(themes.getCurrencyCode())\(themes.getCurrency())"
                }
            } else {
                cell.Wallet_Amount.isHidden=true
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0) {
            Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "HomePageVCID")
        }
        if(indexPath.row == 1) {
            Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "OrderVCID")
            
        }
        if(indexPath.row == 2) {
            Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "WalletVCID") //PaymentVCID //ProfileVCID
        }
        
        if(indexPath.row == 3)
        {
            Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "TransactionVCID")
            
            
            
            
        }
  
        if (indexPath.row == 4)
        {
            Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "NotificationVCID")
        }
        
        if(indexPath.row == 5)
        {
            Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "ReviewVCID")
        }

//        if(indexPath.row == 6)  {
//            Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "EmergencyVCID")
//        }
        if(indexPath.row == 6) {
            Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "InviteVCID")
        }
        if(indexPath.row == 7) {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
        if (indexPath.row == 8){
            Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "ChatList")
//            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChatList") as! ChatListViewController
//            self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)

            
        }
//        if (indexPath.row == 9){
//            Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "LanguageVCID")
//        }
        if (indexPath.row == 9){
            Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "AboutusVCID")
        }
        else if (indexPath.row ==  10)
        {
            self.LogoutoftheApp()
            
        }
    }
    
    //MARK: - MFMailComposeViewController
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients(["\(self.GetReceipientMail)"])
        mailComposerVC.setSubject("\(themes.setLang("report_on")) \(Appname) \(themes.setLang("ios_app"))")
        //            mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    func mainNavigationController() -> DLHamburguerNavigationController {
        return self.storyboard?.instantiateViewController(withIdentifier: "HomePageVCID") as! DLHamburguerNavigationController
    }


    
}

extension UIImageView {
    func changeImageColor( color:UIColor) -> UIImage
    {
        image = image!.withRenderingMode(.alwaysTemplate)
        tintColor = color
        return image!
    }
}

