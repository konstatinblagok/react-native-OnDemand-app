//
//  PaymentViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 30/11/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class PaymentViewController: UIViewController,UIAlertViewDelegate {
    
    @IBOutlet var discountlabl: UILabel!
    @IBOutlet var couponview: UIView!
    @IBOutlet var checkmark: UIButton!
    @IBOutlet var JobIdLable: UILabel!
    
    @IBOutlet var paymentbtn: ButtonColorView!
    @IBOutlet var Jobtime: UILabel!
    @IBOutlet var Jobdate: UILabel!
    @IBOutlet var Amountbtn: UIButton!
    
    var tField: UITextField!
    
    var Globalindex:String=String()
    @IBOutlet var Amount_Lab: UILabel!
    @IBOutlet var Payment_List: UITableView!
    @IBOutlet var Payment_ScrollView: UIScrollView!
    var getPaymentmode: String = String()
    
    
    var Payment_DetailArray:NSMutableArray=NSMutableArray()
    var Payment_Inactive : NSMutableArray = NSMutableArray()
    var Payment_Active : NSMutableArray = NSMutableArray()
    var taskid: String = ""
    var themes:Themes=Themes()
    var PaymentArray:NSMutableArray=NSMutableArray()
    var URL_handler:URLhandler=URLhandler()
    let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 75, height: 100),
                                                        type: .ballSpinFadeLoader)

    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblPayment: UILabel!
    
    @IBOutlet weak var lblIhaveaCoupenCode: UILabel!
    @IBOutlet weak var lblJobDate: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var lblAgreeTerms: UILabel!
    @IBOutlet weak var lblSelectPaymentMode: UILabel!

    
    override func viewDidLoad()
    {
        
        paymentbtn.setTitle(themes.setLang("payment"), for: UIControlState())
        lblTime.text = themes.setLang("time")
        lblPayment.text = themes.setLang("payment")
        lblIhaveaCoupenCode.text = themes.setLang("have_coupon_code")
        lblJobDate.text = themes.setLang("job_date")
        lblAgreeTerms.text = themes.setLang("agree_terms")
        lblSelectPaymentMode.text = themes.setLang("select_payment_mode")
        btnClose.setTitle(themes.setLang("close"), for: UIControlState())

        StripeStatus="Provider_Payment"
        
        self.view.layer.cornerRadius = 8.0;
        self.view.clipsToBounds=true
        self.view.layer.borderColor = UIColor.lightGray.cgColor;
        self.view.layer.borderWidth=2.0;
        
        Amountbtn.backgroundColor = PlumberThemeColor
        Amountbtn.layer.cornerRadius=Amountbtn.frame.size.width/2
        Amountbtn.clipsToBounds=true
        
        
        
        let Nb=UINib(nibName: "PaymentTableViewCell", bundle: nil)
        
        Payment_List.register(Nb, forCellReuseIdentifier: "PaymentCell")
        
        SetFrameAccordingToSegmentIndex()
        
       
        self.SetFrameAccordingToSegmentIndex()
        
        let Tap:UITapGestureRecognizer=UITapGestureRecognizer()
        Tap.addTarget(self, action: #selector(PaymentViewController.Addcoupon(_:)))
        couponview.addGestureRecognizer(Tap)
        
        
    }
    
    func Addcoupon(_ sender:UITapGestureRecognizer)
    {
        
        
        
        let alert = UIAlertController(title:themes.setLang("add_coupen_code")
            , message: "", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title:themes.setLang("cancel"), style: .cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: themes.setLang("done"), style: .default, handler:{ (UIAlertAction) in
            self.applycoupon()

        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationLanguageChangeNotification:"), name: Language_Notification as String, object: nil)
        SetFrameAccordingToSegmentIndex()
        
        if(themes.Check_userID() != "")
        {
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPayment"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowRating"), object: nil)
            NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "Message_notify"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceiveChatToRootView"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceivePushChatToRootView"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPushNotification"), object: nil)
            NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushRating"), object: nil)
            NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushPayment"), object: nil)
            
            
            
            NotificationCenter.default.addObserver(self, selector: #selector(PaymentViewController.showPopup(_:)), name: NSNotification.Name(rawValue: "ShowPayment"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(PaymentViewController.Show_Alert(_:)), name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(PaymentViewController.Show_rating(_:)), name: NSNotification.Name(rawValue: "ShowRating"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Language_Notification as String as String), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(PaymentViewController.methodOfReceivedMessageNotification(_:)), name:NSNotification.Name(rawValue: "ReceiveChatToRootView"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(PaymentViewController.methodOfReceivedMessagePushNotification(_:)), name:NSNotification.Name(rawValue: "ReceivePushChatToRootView"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(PaymentViewController.methodofReceivePushNotification(_:)), name:NSNotification.Name(rawValue: "ShowPushNotification"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(PaymentViewController.methodofReceiveRatingNotification(_:)), name:NSNotification.Name(rawValue: "ShowPushRating"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(PaymentViewController.methodofReceivePaymentNotification(_:)), name:NSNotification.Name(rawValue: "ShowPushRating"), object: nil)
            
            
        }
        
        
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPayment"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowRating"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Language_Notification as String as String), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "Message_notify"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceiveChatToRootView"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceivePushChatToRootView"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPushNotification"), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushRating"), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushPayment"), object: nil)
        
        NotificationCenter.default.removeObserver(self);
        
        
        
        
    }
    
    deinit
    {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPayment"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowRating"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Language_Notification as String as String), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "Message_notify"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceiveChatToRootView"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceivePushChatToRootView"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPushNotification"), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushRating"), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushPayment"), object: nil)
        
        NotificationCenter.default.removeObserver(self);
        
    }
    
    func methodofReceivePaymentNotification(_ notification: Notification){
        
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        // or as! Sting or as! Int
        
        
        // let messageString = userInfo["Message"]
        let Order_id = userInfo["Order_id"]
        
        if(Order_id != nil)
        {
            Root_Base.Job_ID=Order_id!
            Order_data.job_id = Order_id!
        }
        
        
        let Controller:PaymentViewController=self.storyboard?.instantiateViewController(withIdentifier: "payment") as! PaymentViewController
        self.navigationController?.pushViewController(withFlip: Controller, animated: true)
        
        
        
        
        
        
    }
    func methodofReceiveRatingNotification(_ notification: Notification){
        
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        // or as! Sting or as! Int
        
        
        // let messageString = userInfo["Message"]
        let Order_id = userInfo["Order_id"]
        
        if(Order_id != nil)
        {
            Root_Base.Job_ID=Order_id!
            Order_data.job_id = Order_id!
        }
        
        
        
        let Controller:RatingsViewController=self.storyboard?.instantiateViewController(withIdentifier: "ReviewPoup") as! RatingsViewController
        self.navigationController?.pushViewController(withFlip: Controller, animated: true)
        
        
        
        
        
        
    }
    
    func methodofReceivePushNotification(_ notification: Notification){
        
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        // or as! Sting or as! Int
        
        
        // let messageString = userInfo["Message"]
        let Order_id = userInfo["Order_id"]
        
        if(Order_id != nil)
        {
            Root_Base.Job_ID=Order_id!
            Order_data.job_id = Order_id!
        }
        
        
        if let activeController = navigationController?.visibleViewController {
            if activeController.isKind(of: OrderDetailViewController.self){
                
            }else{
                
                let Controller:OrderDetailViewController=self.storyboard?.instantiateViewController(withIdentifier: "OrderDetail") as! OrderDetailViewController
                self.navigationController?.pushViewController(withFlip: Controller, animated: true)
                
                
            }
            
        }
        
    }
    
    
    
    func methodOfReceivedMessagePushNotification(_ notification: Notification){
        
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        // or as! Sting or as! Int
        
        
        
        let check_userid = userInfo["from"]!
        _ = userInfo["message"]
        let taskid=userInfo["task"]
        
        
        
        if (check_userid == themes.getUserID())
        {
            
        }
        else
        {
            
            Message_details.taskid = taskid!
            Message_details.providerid = check_userid
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageVC") as! MessageViewController
            
            self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)
        }
        
        
        
    }
    
    
    func methodOfReceivedMessageNotification(_ notification: Notification){
        
        
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
                    let alertView = UNAlertView(title: Appname, message:themes.setLang("You have a message from Tasker"))
                    alertView.addButton(self.themes.setLang("ok"), action: {
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func Show_rating(_ notification: Notification)
    {
        
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        // or as! Sting or as! Int
        
        
        let messageString = userInfo["Message"]
        let Order_id = userInfo["Order_id"]
        
        if(Order_id != nil)
        {
            Root_Base.Job_ID=Order_id!
            Order_data.job_id = Order_id!
        }
        
        
        let alertView = UNAlertView(title: Appname, message:messageString!)
        alertView.addButton(self.themes.setLang("ok"), action: {
            let Controller:RatingsViewController=self.storyboard?.instantiateViewController(withIdentifier: "ReviewPoup") as! RatingsViewController
            self.navigationController?.pushViewController(withFlip: Controller, animated: true)
            
            
        })
      AudioServicesPlayAlertSound(1315);

        alertView.show()
        
    }
    
    func showPopup(_ notification: Notification)
    {
        
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        // or as! Sting or as! Int
        
        
        let messageString = userInfo["Message"]
        let Order_id = userInfo["Order_id"]
        
        if(Order_id != nil)
        {
            Root_Base.Job_ID=Order_id!
            Order_data.job_id = Order_id!
        }
        
        
        
        let alertView = UNAlertView(title: Appname, message:messageString!)
        alertView.addButton(self.themes.setLang("ok"), action: {
            
            self.get_Payment()
            
            
        })
      AudioServicesPlayAlertSound(1315);

        alertView.show()
        
        
    }
    
    func Show_Alert(_ notification:Notification)
    {
        
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        // or as! Sting or as! Int
        
        
        let messageString = userInfo["Message"]
        let Order_id = userInfo["Order_id"]
        let action = userInfo["Action"]

        
        if(Order_id != nil)
        {
            Root_Base.Job_ID=Order_id!
            Order_data.job_id = Order_id!
        }
        
        
        
        if let activeController = navigationController?.visibleViewController {
            if activeController.isKind(of: OrderDetailViewController.self){
                
            }else{
                let alertView = UNAlertView(title: Appname, message:messageString!)
                alertView.addButton(self.themes.setLang("ok"), action: {
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
    
    
    func applycoupon()
    {
        
        
        
        self.showProgress()
        let Param:NSDictionary=["user_id":"\(themes.getUserID())","booking_id":"\(Root_Base.Job_ID)","code":"\(self.tField.text!)"]
        URL_handler.makeCall(constant.Apply_Coupon_code, param: Param as NSDictionary) { (responseObject, error) -> () in
            
            self.DismissProgress()
            
            if(error != nil)
            {
                
                
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                
            }
            else
            {
                let Dict:NSDictionary=responseObject!
                let Status=self.themes.CheckNullValue(Dict.object(forKey: "status"))!
                if(Status != "")
                {
                    if(Status == "1")
                    {
                        //constant.showProgress()
                        self.couponview.isHidden = true
                        self.couponview.isUserInteractionEnabled = false
                        self.discountlabl.isHidden = false
                        self.discountlabl.text = "Your Discount Amount is \(self.themes.Currency_Symbol(Payment_Detail.currency as String))\(self.themes.CheckNullValue(Dict.object(forKey: "discount"))!)"
                        let Response:NSString?=Dict.object(forKey: "response") as? NSString
                        self.themes.AlertView(self.themes.setLang("Message"), Message: "\(Response!)", ButtonTitle: self.themes.setLang("ok"))
                        
                        
                        self.get_Payment()
                    }
                    else
                    {
                       
                        let Response:NSString?=Dict.object(forKey: "response") as? NSString
                        self.themes.AlertView(self.themes.setLang("Message"), Message: "\(Response!)", ButtonTitle: self.themes.setLang("ok"))
                    }
                    
                }
            }
        }
    }
    
    
    func configurationTextField(_ textField: UITextField!)
    {
        print("generating the TextField")
        textField.placeholder = themes.setLang("enter_coupen_code")
        
        tField = textField
    }
    
    func handleCancel(_ alertView: UIAlertAction!)
    {
        print("Cancelled !!")
    }
    
    
    override func  viewWillAppear(_ animated: Bool) {
       // constant.DismissProgress()
         get_Payment()
    }
    @IBAction func makepayment(_ sender: AnyObject) {
        
        
    }
    @IBAction func didclickoption(_ sender: AnyObject) {
        
        if(sender.tag == 0)
        {
            
            if(checkmark.isSelected == true)
            {
                checkmark.isSelected = false
                checkmark.setImage(UIImage(named: "check"), for: UIControlState())
            }
            else
            {
                checkmark.isSelected = true
                checkmark.setImage(UIImage(named: "tick"), for: UIControlState())
            }
        }
        
        
    }
    
    @IBAction func paymentAction(_ sender: AnyObject) {
        if(checkmark.isSelected == false)
        {
            themes.AlertView("\(Appname)", Message: themes.setLang("accept_terms"), ButtonTitle: kOk)
        }
       else if ( Payment_Detail.payment_amount == "0.00")
        {
            self.Compelte_Payment()
        }

       else if (getPaymentmode == "")
        {
            themes.AlertView("\(Appname)", Message: themes.setLang("select_paymentmode"), ButtonTitle: kOk)
        }
       
        else
        {
            if(getPaymentmode == "cash")
            {
                
                pay_cash()
            }
                
            else if(getPaymentmode == "auto_detect")
            {
                Pay_Card()
                
            }
                
            else if(getPaymentmode == "wallet")
            {
                pay_Wallet()
            }
            else if (getPaymentmode == "paypal")
            {
                Paypal_Transaction(getPaymentmode as String)
            }
            else if getPaymentmode == "remita"
            {
                payment_Transaction(getPaymentmode as String)
            }
            else
            {
                payment_Transaction(getPaymentmode as String)
            }
            
            
        }
        
    }
    
    
    func  Compelte_Payment()
        {
            
            self.showProgress()
            
            let Param:NSDictionary=["user_id":"\(themes.getUserID())","job_id:":Root_Base.Job_ID ]
            URL_handler.makeCall(constant.Complete_Payment, param: Param) { (responseObject, error) -> () in
                
                self.DismissProgress()
                
                if(error != nil)
                {
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    
                    // self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                    
                }
                else
                {
                    
                    
                    let Dict:NSDictionary=responseObject!
                    let Status=self.themes.CheckNullValue(Dict.object(forKey: "status"))!
                    if(Status != "")
                    {
                        
                        if(Status == "1")
                        {
                            //  Payment_Detail.Mobile_id=self.themes.CheckNullValue(Dict.objectForKey("mobile_id") )!
                        
                            self.performSegue(withIdentifier: "RatingVC", sender: nil)
                            
                        }
                        else
                        {
                           
                            let Response=self.themes.CheckNullValue(Dict.object(forKey: "errors"))!
                            self.themes.AlertView(self.themes.setLang("Message"), Message: Response, ButtonTitle: self.themes.setLang("ok"))
                            
                        }
                    }
                }
            }

        
    }
    @IBOutlet var makepayment: ButtonColorView!
    @IBAction func DidclickOption(_ sender: UIButton) {
        if(sender.tag == 0)
        {
            self.navigationController?.popViewControllerWithFlip(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func get_Payment()
    {
        self.showProgress()
        
        
        
        let Param:NSDictionary=["user_id":"\(themes.getUserID())","job_id":"\(Root_Base.Job_ID)"]
        URL_handler.makeCall(constant.Get_Summary_Details, param: Param) { (responseObject, error) -> () in
            
            
            self.DismissProgress()
            
            if(error != nil)
            {
              //  self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                
                //self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                
            }
            else
            {
                
                self.PaymentArray = NSMutableArray ()
                self.Payment_DetailArray = NSMutableArray()
                self.Payment_Inactive = NSMutableArray()
                self.Payment_Active = NSMutableArray()
                let Dict:NSDictionary=responseObject!
                let Status=self.themes.CheckNullValue(Dict.object(forKey: "status"))!
                if(Status != "")
                {
                    
                    if(Status == "1")
                    {
                        let Response:NSDictionary?=(Dict.object(forKey: "response")! as AnyObject).object(forKey: "info") as? NSDictionary
                        
                          self.Globalindex = String()
                        self.getPaymentmode = ""
                        if(Response != nil)
                        {
                            Payment_Detail.job_date=Response!.object(forKey: "job_date") as! String
                            Payment_Detail.job_time=Response!.object(forKey: "job_time") as! String
                            let _ : String = self.themes.CheckNullValue(Response!.object(forKey: "payment_amount"))!
                            // let str = "\(myInt)"
                           // Payment_Detail.payment_amount=str
                            Root_Base.task_id = self.themes.CheckNullValue(Response!.object(forKey: "task_id"))!
                            //Payment_Detail.payment_amount=Response!.objectForKey("payment_amount") as! NSString
                            Payment_Detail.currency=Response!.object(forKey: "currency") as! String
                            Payment_Detail.category_image=Response!.object(forKey: "category_image") as! String
                            Payment_Detail.user_image=Response!.object(forKey: "user_image") as! String
                            
                            // let longInt : Float = Response!.objectForKey("longitude") as! Float
                            // let strLong = "\(longInt)"
                            // Payment_Detail.longitude = strLong
                            // Payment_Detail.longitude=Response!.objectForKey("longitude") as! NSString
                            //
                            //let latInt : Float = Response!.objectForKey("latitude") as! Float
                            //let strLat = "\(latInt)"
                            // Payment_Detail.latitude = strLat
                            //Payment_Detail.latitude=Response!.objectForKey("latitude") as! NSString
                            //  self.set_mapView(Payment_Detail.latitude,long: Payment_Detail.longitude)
                        }
                        
                        let Response_Payment:NSArray?=(Dict.object(forKey: "response")! as AnyObject).object(forKey: "payment") as? NSArray
                        Payment_Detail.payment_amount = self.themes.CheckNullValue((Dict.object(forKey: "response")! as AnyObject).object(forKey: "balancetotal"))!
                        self.setdata()
                        if(Response_Payment != nil)
                        {
                            for  Dict in Response_Payment!
                            {
                                self.PaymentArray.add((Dict as AnyObject).object(forKey: "name")!)
                                self.Payment_DetailArray.add((Dict as AnyObject).object(forKey: "code")!)
                                
                                let inactiveimage : String = self.themes.CheckNullValue((Dict as AnyObject).object(forKey: "in_active"))!
                                //let replacedinactive = (inactiveimage as NSString).stringByReplacingOccurrencesOfString("localhost", withString: "192.168.1.251")
                                let activeimage: String = self.themes.CheckNullValue((Dict as AnyObject).object(forKey: "active"))!
                                //let reaplacedactive = (activeimage as NSString).stringByReplacingOccurrencesOfString("localhost", withString:"192.168.1.251")
                                
                                self.Payment_Inactive.add(inactiveimage)
                                self.Payment_Active.add(activeimage)
                            }
                            
                          if  ( Payment_Detail.payment_amount == "0.00")
                          {
                            self.PaymentArray.removeAllObjects()
                            self.Payment_DetailArray.removeAllObjects()
                            
                            
                            self.Payment_Inactive.removeAllObjects()
                            self.Payment_Active.removeAllObjects()
                            
                            self.paymentbtn.setTitle(self.themes.setLang("Complete Payment"), for:UIControlState())


                            }
                            
                            self.Payment_List.reload()
                            self.SetFrameAccordingToSegmentIndex()
                            
                        }
                        
                        
                        
                    }
                    else
                    {
                        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                        
                        //  self.themes.AlertView("Network Failure", Message:Dict.objectForKey("response") as! String, ButtonTitle: "Ok")
                    }
                    
                    
                }
            }
            
            
        }
    }
    
    
    func setdata()
    {
        Jobdate.text="\(Payment_Detail.job_date)"
        Jobtime.text = "\(Payment_Detail.job_time)"
        self.themes.saveCurrencyCode("\(self.themes.Currency_Symbol(Payment_Detail.currency as String))")
        let amount: Double =  Double(Payment_Detail.payment_amount)!
        let roundofval = String(format: "%.2f", amount)

        Amountbtn .setTitle(" \(self.themes.Currency_Symbol(Payment_Detail.currency as String))\(roundofval)", for: UIControlState())
        JobIdLable.text = "\(Root_Base.Job_ID)"
    }
    
    
    func SetFrameAccordingToSegmentIndex(){
        
        DispatchQueue.main.async {
            //            //This code will run in the main thread:
            //            var frame: CGRect = self.Payment_List.frame
            //            frame.size.height = self.Payment_List.contentSize.height;
            //            //            frame.origin.y=
            //            self.Payment_List.frame = frame;
            self.Payment_ScrollView.contentSize=CGSize(width: self.Payment_ScrollView.frame.size.width, height: self.Payment_List.frame.origin.y+self.Payment_List.frame.size.height+30)
            
        }
    }
    
    
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return 83
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        SetFrameAccordingToSegmentIndex()
        
        return PaymentArray.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let Cell:PaymentTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "PaymentCell") as! PaymentTableViewCell
        Cell.selectionStyle=UITableViewCellSelectionStyle.none
        
        
        if Payment_DetailArray[indexPath.row] as! String == "stripe"
        {
            Cell.Payment_Lab.text="card"
            
        }
        else
        {
            
            Cell.Payment_Lab.text="\(Payment_DetailArray[indexPath.row])"
        }
        
        
        
        
        
        // self.UserImage.sd_setImageWithURL(NSURL(string: "\(themes.getuserDP())"), placeholderImage: UIImage(named: "PlaceHolderSmall"))
        
        if(Globalindex as String == "\(indexPath.row)")
        {
            
            Cell.Wallet_ImageView.sd_setImage(with: URL(string: "\(Payment_Active[indexPath.row])"), placeholderImage: UIImage(named: "PlaceHolderSmall"))
            
        }
        else
        {
            
            Cell.Wallet_ImageView.sd_setImage(with: URL(string: "\(Payment_Inactive[indexPath.row])"), placeholderImage: UIImage(named: "PlaceHolderSmall"))
        }
        
        
        return Cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        Globalindex="\(indexPath.row)"
        
        getPaymentmode = "\(Payment_DetailArray[indexPath.row])"
        self.Payment_List.reload()
        
        //        self.Payment_List.reload()
        
    }
    
    func showProgress()
    {
        self.activityIndicatorView.color = PlumberThemeColor
        self.activityIndicatorView.center=CGPoint(x: self.view.frame.size.width/2,y: self.view.frame.size.height/2);
        self.activityIndicatorView.startAnimating()
        self.view.addSubview(activityIndicatorView)
    }
    func DismissProgress()
    {
        self.activityIndicatorView.stopAnimating()
        
        self.activityIndicatorView.removeFromSuperview()
        
    }
    
    func Paypal_Transaction(_ code:String)
    {
        self.showProgress()
        
        let Param:NSDictionary=["user":"\(themes.getUserID())","task":Root_Base.task_id ]
        URL_handler.makeCall(constant.Pay_Paypal, param: Param) { (responseObject, error) -> () in
            
            self.DismissProgress()
            
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                
                // self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                
            }
            else
            {
                
                
                let Dict:NSDictionary=responseObject!
                let Status=self.themes.CheckNullValue(Dict.object(forKey: "status"))!
                if(Status != "")
                {
                    
                    if(Status == "1")
                    {
                        //  Payment_Detail.Mobile_id=self.themes.CheckNullValue(Dict.objectForKey("mobile_id") )!
                        
                        Payment_Detail.PaymentUrl = self.themes.CheckNullValue(Dict.object(forKey: "redirectUrl"))!
                        Payment_Detail.paymentmode = self.themes.CheckNullValue(Dict.object(forKey: "payment_mode"))!
                        
                        self.themes.amount =  Payment_Detail.payment_amount as String
                        self.performSegue(withIdentifier: "TransactionVC", sender: nil)
                        
                    }
                    else
                    {
                      
                        let Response=self.themes.CheckNullValue(Dict.object(forKey: "errors"))!
                        self.themes.AlertView(self.themes.setLang("Message"), Message: Response, ButtonTitle: self.themes.setLang("ok"))
                        
                    }
                }
            }
        }
        
    }
    func payment_Transaction(_ code:String)
    {
        
        self.showProgress()
        let Param:NSDictionary=["user_id":"\(themes.getUserID())","job_id":"\(Root_Base.Job_ID)","gateway":"\(code)"]
        URL_handler.makeCall(constant.Pay_Transaction, param: Param) { (responseObject, error) -> () in
            
            self.DismissProgress()
            
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                
                // self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                
            }
            else
            {
                
                
                let Dict:NSDictionary=responseObject!
                let Status=self.themes.CheckNullValue(Dict.object(forKey: "status"))!
                if(Status != "")
                {
                    
                    if(Status == "1")
                    {
                        Payment_Detail.Mobile_id=self.themes.CheckNullValue(Dict.object(forKey: "mobile_id") )!
                        
                        Payment_Detail.PaymentUrl = "\(constant.Pay_Creditcard)mobileId=\(self.themes.CheckNullValue(Dict.object(forKey: "mobile_id") )!)"
                        Payment_Detail.paymentmode = self.getPaymentmode
                        self.themes.amount =  Payment_Detail.payment_amount as String
                        self.performSegue(withIdentifier: "TransactionVC", sender: nil)
                        
                    }
                    else
                    {
                        
                        let Response=self.themes.CheckNullValue(Dict.object(forKey: "errors"))!
                        self.themes.AlertView(self.themes.setLang("Message"), Message: Response, ButtonTitle: self.themes.setLang("ok"))
                        
                    }
                }
            }
        }
        
    }
    
    func pay_Wallet()
    {
        
        self.showProgress()
        let Param:NSDictionary=["user_id":"\(themes.getUserID())","job_id":"\(Root_Base.Job_ID)"]
        URL_handler.makeCall(constant.Pay_Wallet, param: Param) { (responseObject, error) -> () in
            self.DismissProgress()
           
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                
                //self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                
            }
            else
            {
                
                let Dict:NSDictionary=responseObject!
                let Status=self.themes.CheckNullValue(Dict.object(forKey: "status"))!
                if(Status != "")
                {
                    
          
                    if(Status == "1")
                    {
                      
                        let due_amout: String = self.themes.CheckNullValue(Dict.object(forKey: "due_amount"))!
                        self.themes.saveCurrency(self.themes.CheckNullValue(Dict.object(forKey: "available_wallet_amount"))!)
                        
                        NSLog("Get due amount=%@", due_amout)
                        if due_amout.isEmpty {
                            
                            
                            //self.Payment_List.reload()
                            
                            self.themes.AlertView("\(Appname)", Message: self.themes.CheckNullValue(Dict.object(forKey: "response"))!, ButtonTitle: self.themes.setLang("ok"))
                            
                            
                            self.performSegue(withIdentifier: "RatingVC", sender: nil)
                        }
                        else
                        {
                            self.themes.AlertView("\(Appname)", Message: self.themes.CheckNullValue(Dict.object(forKey: "response"))!, ButtonTitle: self.themes.setLang("ok"))
                            
                            self.get_Payment()
                            self.Payment_List.reload()
                            self.themes.saveCurrency("0")
                            
                        }
                    }
                    else if (Status == "2"){
                        
                        self.themes.saveCurrency(self.themes.CheckNullValue(Dict.object(forKey: "available_wallet_amount"))!)

                        self.themes.AlertView(self.themes.setLang("Message"), Message: self.themes.CheckNullValue(Dict.object(forKey: "response"))!, ButtonTitle: self.themes.setLang("ok"))
                         self.get_Payment()
                       
                    }
                    else
                    {
                        
                       
                        
                        let Response:NSString?=Dict.object(forKey: "response") as? NSString
                        
                        self.themes.AlertView(self.themes.setLang("Message"), Message: "\(Response!)", ButtonTitle: self.themes.setLang("ok"))
                        
                    }
                }
            }
        }
        
    }
    
    func pay_auto_detect()
    {
        self.showProgress()
        let Param:NSDictionary=["user_id":"\(themes.getUserID())","job_id":"\(Root_Base.task_id)"]
        URL_handler.makeCall(constant.Pay_Autodetect, param: Param) { (responseObject, error) -> () in
            self.DismissProgress()
            
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                
                //self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                
            }
            else
            {
                
                let Dict:NSDictionary=responseObject!
                let Status=self.themes.CheckNullValue(Dict.object(forKey: "status"))!
                if(Status != "")
                {
                    
                    if(Status == "1")
                    {

                        
                    }
                    else
                    {
                        
                        let Response:NSString?=Dict.object(forKey: "response") as? NSString
                        
                        self.themes.AlertView(self.themes.setLang("Message"), Message: "\(Response!)", ButtonTitle: self.themes.setLang("ok"))
                        
                    }
                }
            }
        }
    }
    
    func Pay_Card()
    {
        
        let param=["user_id":themes.getUserID()]
        
        self.showProgress()
        
        URL_handler.makeCall(constant.GetStripeStatus, param: param as NSDictionary) { (responseObject, error) -> () in
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
                    let Staus=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                    
                    
                    if (Staus == "1")
                    {
                        MyWallet.stripe_keys=(dict.object(forKey: "response")! as AnyObject).object(forKey: "stripe_keys") as! NSDictionary
                        MyWallet.mode=MyWallet.stripe_keys.object(forKey: "mode") as! String
                        MyWallet.secret_key=MyWallet.stripe_keys.object(forKey: "secret_key") as! String
                        MyWallet.publishable_key=MyWallet.stripe_keys.object(forKey: "publishable_key") as! String
                        MyWallet.cards=(dict.object(forKey: "response")! as AnyObject).object(forKey: "cards") as! NSDictionary
                        
                        MyWallet.card_status=MyWallet.cards.object(forKey: "card_status") as! String
                        if(MyWallet.card_status == "1")
                        {
                            MyWallet.result=MyWallet.cards.object(forKey: "result") as! NSArray
                            
                            if(MyWallet.card_number.count != 0)
                            {
                                MyWallet.card_number.removeAllObjects()
                                MyWallet.exp_month.removeAllObjects()
                                MyWallet.exp_year.removeAllObjects()
                                MyWallet.card_type.removeAllObjects()
                                MyWallet.customer_id.removeAllObjects()
                                MyWallet.card_id.removeAllObjects()
                            }
                            
                            for Dic in MyWallet.result
                            {
                                MyWallet.card_number.add((Dic as AnyObject).object(forKey: "card_number")!)
                                MyWallet.exp_month.add((Dic as AnyObject).object(forKey: "exp_month")!)
                                MyWallet.exp_year.add((Dic as AnyObject).object(forKey: "exp_year")!)
                                MyWallet.card_type.add((Dic as AnyObject).object(forKey: "card_type")!)
                                MyWallet.customer_id.add((Dic as AnyObject).object(forKey: "customer_id")!)
                                MyWallet.card_id.add((Dic as AnyObject).object(forKey: "card_id")!)
                                
                                
                                
                            }
                            
                            let Controller:CardListViewController=self.storyboard?.instantiateViewController(withIdentifier: "cardListVC") as! CardListViewController
                            self.navigationController?.pushViewController(withFlip: Controller, animated: true)
                            
                            
                            
                        }
                        else
                        {
                            //                            let Storyboard:UIStoryboard=UIStoryboard(name: "Main", bundle: nil)
                            //                            let vc = Storyboard.instantiateViewControllerWithIdentifier("StripeVC")
                            //                            self.presentViewController(vc, animated: true, completion: nil)
                            
                            let Controller:StripeViewController=self.storyboard?.instantiateViewController(withIdentifier: "StripeVC") as! StripeViewController
                            self.navigationController?.pushViewController(withFlip: Controller, animated: true)
                            
                            
                        }
                        
                        
                        
                    }
                    else
                    {
                        
                        self.themes.AlertView("\(Appname)",Message: "\(String(describing: dict.object(forKey: "response")))",ButtonTitle: self.themes.setLang("ok"))
                        self.navigationController?.popViewControllerWithFlip(animated: true)
                        
                    }
                    
                }
                else
                {
                    
                    
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    
                    
                    
                }
                
            }
        }
        
    }
    
    
    
    func pay_cash()
    {
        self.showProgress()
        let Param:NSDictionary=["user_id":"\(themes.getUserID())","job_id":"\(Root_Base.Job_ID)"]
        URL_handler.makeCall(constant.Pay_Cash, param: Param) { (responseObject, error) -> () in
            self.DismissProgress()
            
            
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                
                //self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                
            }
            else
            {
                let Dict:NSDictionary=responseObject!
                let Status=self.themes.CheckNullValue(Dict.object(forKey: "status"))!
                if(Status != "")
                {
                    if(Status == "1")
                    {

                        let Controller:RatingsViewController=self.storyboard?.instantiateViewController(withIdentifier: "ReviewPoup") as! RatingsViewController
                        self.navigationController?.pushViewController(withFlip: Controller, animated: true)
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                    }
                    else
                    {
                        
                        self.themes.AlertView(self.themes.setLang("Message"), Message: "\(String(describing: Dict.object(forKey: "response")))", ButtonTitle: self.themes.setLang("ok"))
                    }
                    
                }
            }
        }
    }
    
    @IBAction func didClickption(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
