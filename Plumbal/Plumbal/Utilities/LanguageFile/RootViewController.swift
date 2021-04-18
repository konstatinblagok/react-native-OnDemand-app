//
//  RootViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 30/11/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit
import MPGNotification
import NVActivityIndicatorView
import JTAlertView
class RootViewController: UIViewController {
    
    var Window:UIWindow=UIWindow()
    var notification:MPGNotification=MPGNotification()
    var buttonArray:NSArray=NSArray()
    let activityTypes: [NVActivityIndicatorType] = [
        .ballPulse]
    let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 75, height: 100),
                                                        type: .ballSpinFadeLoader)
    let activityforLoadServices = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 75, height: 100),
                                                                type: .ballRotateChase)

    var AlertView:JTAlertView=JTAlertView()
    var Is_alertshown:Bool=Bool()
    
    //MARK: - Override Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if(themes.Check_userID() != "") {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPayment"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowRating"), object: nil)
            NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "Message_notify"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceiveChatToRootView"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceivePushChatToRootView"), object: nil)
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPushNotification"), object: nil)
            NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushRating"), object: nil)
            NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushPayment"), object: nil)
            
            
            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.showPopup(_:)), name: NSNotification.Name(rawValue: "ShowPayment"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.Show_Alert(_:)), name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.Show_rating(_:)), name: NSNotification.Name(rawValue: "ShowRating"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.ConfigureNotification(_:)), name: NSNotification.Name(rawValue: "Message_notify"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Language_Notification as String as String), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.methodOfReceivedMessagePushNotification(_:)), name:NSNotification.Name(rawValue: "ReceivePushChatToRootView"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.methodOfReceivedMessageNotification(_:)), name:NSNotification.Name(rawValue: "ReceiveChatToRootView"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.methodofReceivePushNotification(_:)), name:NSNotification.Name(rawValue: "ShowPushNotification"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.methodofReceiveRatingNotification(_:)), name:NSNotification.Name(rawValue: "ShowPushRating"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.methodofReceivePaymentNotification(_:)), name:NSNotification.Name(rawValue: "ShowPayment"), object: nil)
        }else
        {
            
            
            
        }
        


        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if(themes.Check_userID() != "") {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPayment"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowRating"), object: nil)
            NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "Message_notify"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceiveChatToRootView"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceivePushChatToRootView"), object: nil)

            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPushNotification"), object: nil)
            NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushRating"), object: nil)
            NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushPayment"), object: nil)

            
            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.showPopup(_:)), name: NSNotification.Name(rawValue: "ShowPayment"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.Show_Alert(_:)), name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.Show_rating(_:)), name: NSNotification.Name(rawValue: "ShowRating"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.ConfigureNotification(_:)), name: NSNotification.Name(rawValue: "Message_notify"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Language_Notification as String as String), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.methodOfReceivedMessagePushNotification(_:)), name:NSNotification.Name(rawValue: "ReceivePushChatToRootView"), object: nil)

            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.methodOfReceivedMessageNotification(_:)), name:NSNotification.Name(rawValue: "ReceiveChatToRootView"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.methodofReceivePushNotification(_:)), name:NSNotification.Name(rawValue: "ShowPushNotification"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.methodofReceiveRatingNotification(_:)), name:NSNotification.Name(rawValue: "ShowPushRating"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.methodofReceivePaymentNotification(_:)), name:NSNotification.Name(rawValue: "ShowPushRating"), object: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       // NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    //MARK: - Function
    
    func showProgress(){
        self.activityIndicatorView.color = themes.DarkRed()
        self.activityIndicatorView.center=CGPoint(x: self.view.frame.size.width/2,y: self.view.frame.size.height/2);
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.view.addSubview(activityIndicatorView)
    }
    
    func DismissProgress(){
        self.activityIndicatorView.stopAnimating()
         self.view.isUserInteractionEnabled = true
        self.activityIndicatorView.removeFromSuperview()
    }
    
    func showServiceProgress(rect : CGRect){
        self.activityforLoadServices.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.activityforLoadServices.color = themes.DarkRed()
        self.activityforLoadServices.center=CGPoint(x: rect.width/2,y: (rect.height/2)-20);
        self.activityforLoadServices.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.view.addSubview(activityforLoadServices)
    }
    
    func DismissServiceProgress(){
        self.activityforLoadServices.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.activityforLoadServices.removeFromSuperview()
    }
    
    func Logout(){
       // Appdel.CheckDisconnect()
        self.DismissProgress()
        let _: String = Bundle.main.bundleIdentifier!

        Appdel.MakeRootVc("SplashPage")
    }
    
    
    //MARK: - Notification Function
    
    func ConfigureNotification(_ notif:Notification)  {
        if(Is_alertshown == false) {
            Is_alertshown=true
            let userInfo:Dictionary<String,String> = notif.userInfo as! Dictionary<String,String>
            let Job_Id = userInfo["Order_id"]
            let username = userInfo["username"]
            let MessageString = userInfo["Message"]
            buttonArray=["Reply"]
            notification=MPGNotification()
            notification = MPGNotification(title: username, subtitle: MessageString, backgroundColor: themes.ThemeColour(), iconImage: UIImage(named:"chaticon"))
            notification.setButtonConfiguration(MPGNotificationButtonConfigration(rawValue: buttonArray.count)! , withButtonTitles: buttonArray as! [NSArray])
            notification.duration = 4.0;
            notification.swipeToDismissEnabled = true;
            notification.titleColor=UIColor.white
            notification.subtitleColor=UIColor.white
            notification.animationType=MPGNotificationAnimationType.drop
            notification.buttonHandler = {(notification: MPGNotification!, buttonIndex: Int) -> Void in
                Order_data.job_id=Job_Id!
                var mainView: UIStoryboard!
                mainView = UIStoryboard(name: "Main", bundle: nil)
                let secondViewController = mainView.instantiateViewController(withIdentifier: "MessageVC") as! MessageViewController
                self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)
            }
            notification.show()
        }
    }
    
    
    func methodOfReceivedMessagePushNotification(_ notification: Notification){
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        // or as! Sting or as! Int
        
        
        
        let check_userid = userInfo["from"]
        _ = userInfo["message"]
        let taskid=userInfo["task"]
        
        
        
        if (check_userid == themes.getUserID())
        {
            
        }
        else
        {
            if let activeController = navigationController?.visibleViewController {
                if activeController.isKind(of: MessageViewController.self){
                    
                }else{
                    
                    
                    if activeController.isKind(of: MessageViewController.self){
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "Dismisskeyboard"), object: nil, userInfo: ["message":"","from":"","task":"","msgid":"" ,"taskerstus":""])
                        
                    }
                    
                    
                    Message_details.taskid = taskid!
                    Message_details.providerid = check_userid!
                    let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageVC") as! MessageViewController
                    
                    self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)
                    
                    
                    
                    
                }
                
            }
        }
        
        
        
        
        
        
        
    }

    func methodofReceivePaymentNotification(_ notification: Notification){
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        let Order_id = userInfo["Order_id"]
        if(Order_id != nil) {
            Root_Base.Job_ID=Order_id!
            Order_data.job_id = Order_id!
        }
        if let activeController = navigationController?.visibleViewController {
            if activeController.isKind(of: MessageViewController.self){
                NotificationCenter.default.post(name: Notification.Name(rawValue: "Dismisskeyboard"), object: nil, userInfo: ["message":"","from":"","task":"","msgid":"" ,"taskerstus":""])
            }
    
        let Controller:PaymentViewController=self.storyboard?.instantiateViewController(withIdentifier: "payment") as! PaymentViewController
        self.navigationController?.pushViewController(withFlip: Controller, animated: true)
        }
    }
    
    func methodofReceiveRatingNotification(_ notification: Notification){
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        let Order_id = userInfo["Order_id"]
        if(Order_id != nil) {
            Root_Base.Job_ID=Order_id!
            Order_data.job_id = Order_id!
        }
         if let activeController = navigationController?.visibleViewController {
        if activeController.isKind(of: MessageViewController.self){
            NotificationCenter.default.post(name: Notification.Name(rawValue: "Dismisskeyboard"), object: nil, userInfo: ["message":"","from":"","task":"","msgid":"" ,"taskerstus":""])
        }
        let Controller:RatingsViewController=self.storyboard?.instantiateViewController(withIdentifier: "ReviewPoup") as! RatingsViewController
        self.navigationController?.pushViewController(withFlip: Controller, animated: true)
        }
    }
    
    
    func methodofReceivePushNotification(_ notification: Notification){
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        let Order_id = userInfo["Order_id"]
        if(Order_id != nil) {
            Root_Base.Job_ID=Order_id!
            Order_data.job_id = Order_id!
        }
        if let activeController = navigationController?.visibleViewController {
            if activeController.isKind(of: OrderDetailViewController.self){
            }
            else{
                if activeController.isKind(of: MessageViewController.self){
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "Dismisskeyboard"), object: nil, userInfo: ["message":"","from":"","task":"","msgid":"" ,"taskerstus":""])
                }
                let Controller:OrderDetailViewController=self.storyboard?.instantiateViewController(withIdentifier: "OrderDetail") as! OrderDetailViewController
                self.navigationController?.pushViewController(withFlip: Controller, animated: true)
            }
        }
    }
    
    func methodOfReceivedMessageNotification(_ notification: Notification){
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        let check_userid = userInfo["from"]
        let _ = userInfo["message"]
        let taskid=userInfo["task"]
        if (check_userid != themes.getUserID())  {
            if let activeController = navigationController?.visibleViewController {
                if activeController.isKind(of: MessageViewController.self){
                }else{
//                    if activeController.isKindOfClass(MessageViewController){
//                        NSNotificationCenter.defaultCenter().postNotificationName("Dismisskeyboard", object: nil, userInfo: ["message":"","from":"","task":"","msgid":"" ,"taskerstus":""])
//                    }
                    let alertView = UNAlertView(title: Appname, message:themes.setLang("message_from_provider"))
                    alertView.addButton(themes.setLang("ok"), action: {
                        Message_details.taskid = taskid!
                        Message_details.providerid = check_userid!
                        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageVC") as! MessageViewController
                        self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)
                    })
              AudioServicesPlayAlertSound(1315);

                    alertView.show()
                }
            }
        }
    }
    
    func Show_rating(_ notification: Notification) {
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        let messageString = userInfo["Message"]
        let Order_id = userInfo["Order_id"]
        if(Order_id != nil) {
            Root_Base.Job_ID=Order_id!
            Order_data.job_id = Order_id!
        }
        if let activeController = navigationController?.visibleViewController {
            if activeController.isKind(of: RatingsViewController.self){
            }else{
                if activeController.isKind(of: MessageViewController.self){
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "Dismisskeyboard"), object: nil, userInfo: ["message":"","from":"","task":"","msgid":"" ,"taskerstus":""])
                }
                let alertView = UNAlertView(title: Appname, message:messageString!)
                alertView.addButton(themes.setLang("ok"), action: {
                    let Controller:RatingsViewController=self.storyboard?.instantiateViewController(withIdentifier: "ReviewPoup") as! RatingsViewController
                    self.navigationController?.pushViewController(withFlip: Controller, animated: true)
                    
                })
               AudioServicesPlayAlertSound(1315);

                alertView.show()
            }
        }
    }
    
    func showPopup(_ notification: Notification) {
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        let messageString = userInfo["Message"]
        let Order_id = userInfo["Order_id"]
        if(Order_id != nil){
            Root_Base.Job_ID=Order_id!
            Order_data.job_id = Order_id!
        }
        
        if let activeController = navigationController?.visibleViewController {
           
                if activeController.isKind(of: MessageViewController.self){
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "Dismisskeyboard"), object: nil, userInfo: ["message":"","from":"","task":"","msgid":"" ,"taskerstus":""])
                }
                let alertView = UNAlertView(title: Appname, message:messageString!)
                alertView.addButton(themes.setLang("ok"), action: {
                    let Controller:PaymentViewController=self.storyboard?.instantiateViewController(withIdentifier: "payment") as! PaymentViewController
                    self.navigationController?.pushViewController(withFlip: Controller, animated: true)
                })
                AudioServicesPlayAlertSound(1315);

                alertView.show()
            
        }
    }
    
    func Show_Alert(_ notification:Notification){
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        let messageString = userInfo["Message"]
        let Order_id = userInfo["Order_id"]
        let action = userInfo["Action"]

        if(Order_id != nil) {
            Root_Base.Job_ID=Order_id!
            Order_data.job_id = Order_id!
        }
        if let activeController = navigationController?.visibleViewController {
            if activeController.isKind(of: OrderDetailViewController.self){
                
            }else{
                
                if activeController.isKind(of: MessageViewController.self){
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "Dismisskeyboard"), object: nil, userInfo: ["message":"","from":"","task":"","msgid":"" ,"taskerstus":""])

                    let alertView = UNAlertView(title: Appname, message:messageString!)
                    alertView.addButton(themes.setLang("ok"), action: {
                        if action != "admin_notification"{

                        let Controller:OrderDetailViewController=self.storyboard?.instantiateViewController(withIdentifier: "OrderDetail") as! OrderDetailViewController
                        self.navigationController?.pushViewController(withFlip: Controller, animated: true)
                    
                        }
                    })
                   AudioServicesPlayAlertSound(1315);

                    alertView.show()

                }else if activeController.isKind(of: LocationViewController.self){
                    let alertView = UNAlertView(title: Appname, message:messageString!)
                    alertView.addButton(themes.setLang("ok"), action: {
                        if action != "admin_notification"{

                        self.navigationController!.popViewControllerWithFlip(animated: true)
                        }
                    })
                  AudioServicesPlayAlertSound(1315);

                    alertView.show()
                    
                }else{
                let alertView = UNAlertView(title: Appname, message:messageString!)
                alertView.addButton(themes.setLang("ok"), action: {
                    if action != "admin_notification"{

                    let Controller:OrderDetailViewController=self.storyboard?.instantiateViewController(withIdentifier: "OrderDetail") as! OrderDetailViewController
                    self.navigationController?.pushViewController(withFlip: Controller, animated: true)
                    }
                    })
                   AudioServicesPlayAlertSound(1315);

                alertView.show()
                }
            }
        }
    }
    
    
    func notificationView(_ notification: MPGNotification, didDismissWithButtonIndex buttonIndex: Int) {
        NSLog("Button Index = %ld", Int(buttonIndex))
    }
    
    //MARK: - Button Action
    
    @IBAction func didDismissSegue(_ segue: UIStoryboardSegue) {
        
    }
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
}

extension UITextField {
    func isMandatory(){
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 10,height: self.frame.height)
        label.text = "*"
        label.textColor = UIColor.red
        self.rightView = label
        self.rightViewMode = UITextFieldViewMode .always
    }
}
