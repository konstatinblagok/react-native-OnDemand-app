//
//  WalletViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 01/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit
import SwiftyJSON



class WalletViewController: RootViewController
    
    
{
    
    @IBOutlet var displayWalletview: UIView!
    @IBOutlet var MyWallet_Lbl: UIButton!
    @IBOutlet var Recharge_Wallet_Lbl: UILabel!
    @IBOutlet var Slide_Menu_But: UIButton!
    @IBOutlet var Amount_1_But: UIButton!
    
    @IBOutlet var Amount_2_But: UIButton!
    
    @IBOutlet var Amount_3_But: UIButton!
    @IBOutlet var Wallet_View: UIView!
    
    @IBOutlet var paypalBtn: CustomButton!
    @IBOutlet var add_Amt_But: UIButton!
    @IBOutlet var Amount_textField: UITextField!
    @IBOutlet var Amount_Lab: UILabel!
    
    @IBOutlet var Wallet_ScrollView: UIScrollView!
    @IBOutlet weak var current_bal_lbl: UILabel!
    @IBOutlet weak var walletDisc: UILabel!

    @IBOutlet var lblOr: UILabel!
    
    var URL_handler:URLhandler=URLhandler()
    
    
    
    var themes:Themes=Themes()
    override func viewDidLoad() {
        super.viewDidLoad()
        setPage()
          }
    
    
    
    func setPage(){
        self.Wallet_ScrollView.isHidden = false

        Wallet_ScrollView.contentSize.height = add_Amt_But.frame.origin.y+add_Amt_But.frame.height+20
        MyWallet_Lbl.setTitle(themes.setLang("wallet_money"), for: UIControlState())
        Recharge_Wallet_Lbl.text=themes.setLang("recharge_wallet")
        walletDisc.text = themes.setLang("cash_less")
        add_Amt_But.setTitle(themes.setLang("add_wallet"), for: UIControlState())
        paypalBtn.setTitle(themes.setLang("add_paypal"), for: UIControlState())
        current_bal_lbl.text = themes.setLang("current_bal")
        lblOr.text = themes.setLang("or")

        //MyWallet_Lbl.setTitle(themes.setLang("\(Appname) Money"), forState: UIControlState.Normal)
        StripeStatus="Wallet"
        title = "\(Appname) Paypal Gateway"
        // Set up payPalConfig
        
        
        
        
        
        
        
        //Shadow offset for buttons
        
        Amount_1_But.layer.cornerRadius = 5
        Amount_1_But.layer.shadowColor = UIColor.black.cgColor
        Amount_1_But.layer.shadowOpacity = 0.5
        Amount_1_But.layer.shadowRadius = 2
        Amount_1_But.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        Amount_1_But.backgroundColor=UIColor.white
        
        
        Amount_2_But.layer.cornerRadius = 5
        Amount_2_But.layer.shadowColor = UIColor.black.cgColor
        Amount_2_But.layer.shadowOpacity = 0.5
        Amount_2_But.layer.shadowRadius = 2
        Amount_2_But.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        Amount_2_But.backgroundColor=UIColor.white
        
        
        
        Amount_3_But.layer.cornerRadius = 5
        Amount_3_But.layer.shadowColor = UIColor.black.cgColor
        Amount_3_But.layer.shadowOpacity = 0.5
        Amount_3_But.layer.shadowRadius = 2
        Amount_3_But.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        Amount_3_But.backgroundColor=UIColor.white
        
        add_Amt_But.setTitle(themes.setLang("add_wallet"), for: UIControlState())
        
        add_Amt_But.layer.cornerRadius = 5
        add_Amt_But.layer.shadowColor = UIColor.black.cgColor
        add_Amt_But.layer.shadowOpacity = 0.5
        add_Amt_But.layer.shadowRadius = 2
        add_Amt_But.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        
        
        paypalBtn.layer.cornerRadius = 5
        paypalBtn.layer.shadowColor = UIColor.black.cgColor
        paypalBtn.layer.shadowOpacity = 0.5
        paypalBtn.layer.shadowRadius = 2
        paypalBtn.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)

        
        //Corner Radius for
        Wallet_View.layer.cornerRadius=themes.RoundView(Wallet_View.frame.size.width)
        Wallet_View.clipsToBounds=true
        
        //        if(themes.screenSize.height == 480)
        //        {
        //            Wallet_ScrollView.contentSize.height=600
        //        }
        //
        //        if(themes.screenSize.height == 568)
        //        {
        //            Wallet_ScrollView.contentSize.height=500
        //        }
        //        if(themes.screenSize.height == 667)
        //        {
        //            Wallet_ScrollView.contentSize.height=600
        //        }
        
        let tapgesture:UITapGestureRecognizer=UITapGestureRecognizer(target:self, action: #selector(WalletViewController.DismissKeyboard(_:)))
        
        view.addGestureRecognizer(tapgesture)
        
        
        //
        Amount_textField.addTarget(self, action: #selector(WalletViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        Amount_textField.delegate=self
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        doneToolbar.backgroundColor=UIColor.white
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: themes.setLang("done"), style: UIBarButtonItemStyle.done, target: self, action: #selector(WalletViewController.doneButtonAction))
        
        
        doneToolbar.items = [flexSpace,done]
        
        doneToolbar.sizeToFit()
        
        Amount_textField.inputAccessoryView = doneToolbar
        
        
        let Tap:UITapGestureRecognizer=UITapGestureRecognizer()
        Tap.addTarget(self, action: #selector(WalletViewController.PushtoTransactionView(_:)))
        displayWalletview.addGestureRecognizer(Tap)
        // Do any additional setup after loading the view.

    }
    

    
    func PushtoTransactionView(_ sender:UITapGestureRecognizer)
    {
        self.performSegue(withIdentifier: "WalletDetailVC", sender: nil)
        
    }
    func applicationLanguageChangeNotification(_ notification:Notification)
    {
        
        //        themes.setLang(
        
        //        themes.setLang("Full Name")
        MyWallet_Lbl.setTitle(themes.setLang("   My Wallet"), for: UIControlState())
        Recharge_Wallet_Lbl.text=themes.setLang("Recharge Wallet money")
        add_Amt_But.setTitle(themes.setLang("Add to Wallet"), for: UIControlState())
    }
    
    
    
    func doneButtonAction()
    {
        if(themes.screenSize.size.height > 480)
        {
//            Wallet_ScrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        }
        Amount_textField.resignFirstResponder()
        
        
    }
    
    
    @IBAction func menuButtonTouched(_ sender: AnyObject) {
        self.findHamburguerViewController()?.showMenuViewController()
    }
    
    
    func DismissKeyboard(_ sender:UITapGestureRecognizer)
    {
        
//        Wallet_ScrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        
        
        
        view.endEditing(true)
        
        
    }
    
    
    
    func textFieldDidChange(_ textField: UITextField) {
        
        if(textField == Amount_textField)
        {
            if(Amount_textField.text == "\(MyWallet.middle_amount)")
            {
                
                Amount_1_But.backgroundColor=PlumberThemeColor
                
                
            }
            else
            {
                Amount_1_But.backgroundColor=UIColor.white            }
            if(Amount_textField.text == "\(MyWallet.middle_amount)")
            {
                Amount_2_But.backgroundColor=PlumberThemeColor
                
                
                
            }
            else
            {
                Amount_2_But.backgroundColor=UIColor.white
            }
            
            if(Amount_textField.text == "\(MyWallet.max_amount)")
            {
                Amount_3_But.backgroundColor=PlumberThemeColor
                
            }
            else
            {
                Amount_3_But.backgroundColor=UIColor.white
            }
            
            
        }
        
        //your code
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
//        if(themes.screenSize.height == 480)
//        {
        
//            if(textField == Amount_textField)
//            {
//                Wallet_ScrollView.setContentOffset(CGPoint(x: 0.0, y: 180), animated: true)
//                
//            }
//        }
//        else
//        {
//            if(textField == Amount_textField)
//            {
//                Wallet_ScrollView.setContentOffset(CGPoint(x: 0.0, y: 140), animated: true)
//                
//            }
//            
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
              walletData()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if(textField == Amount_textField)
        {
            
            if(NSString(string: string).length  == 0)
            {
                return true
            }
            
            
            let textfield_Count:Int=Int((Amount_textField.text! as NSString).replacingCharacters(in: range, with: string))!
            
            return textfield_Count <= MyWallet.max_amount
            
        }
        
        return true
        
        
    }
    
    
    
    
    
    @IBAction func didClickoption(_ sender: UIButton) {
        
        if(sender.tag == 4)
        {
            
            doneButtonAction()
            
            
            Transaction_Stat.StripeStatus=false
            Transaction_Stat.total_Amt=Amount_textField.text!
            
            if (Amount_textField.text == "")
            {
                themes.AlertView("\(Appname)", Message: themes.setLang("amunt_is_empty"), ButtonTitle: kOk)
                
            }
                
            else if(Int(Transaction_Stat.total_Amt as String)! < MyWallet.min_amount)
            {
                
                themes.AlertView("\(Appname)", Message: themes.setLang("amunt_is_low"), ButtonTitle: kOk)
            }
            else
            {
                themes.amount = Amount_textField.text!
                
                self.showProgress()
                
                let Param:NSDictionary=["user_id":"\(themes.getUserID())","total_amount":Transaction_Stat.total_Amt ]
                URL_handler.makeCall(constant.Wallet_Recharge_paypal, param: Param) { (responseObject, error) -> () in
                    
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
                                
                                Transaction_Stat.wallet_rechargeurl = self.themes.CheckNullValue(Dict.object(forKey: "redirectUrl"))!
                                
                                self.performSegue(withIdentifier: "TransactionVC", sender: nil)
                                
                            }
                            else
                            {
                               
                                let Response=self.themes.CheckNullValue(Dict.object(forKey: "errors"))!
                                self.themes.AlertView(self.themes.setLang("Message"), Message: "\(Response)", ButtonTitle: self.themes.setLang("ok"))
                                
                            }
                        }
                    }
                }
                

                
            }

            
                  }
        
        
        if(sender.tag == 0)
        {
            Amount_textField.text=nil
            Amount_textField.text="\(MyWallet.min_amount)"
            
            Amount_1_But.backgroundColor=PlumberThemeColor
            add_Amt_But.isEnabled=true
            
        }
        else
        {
            Amount_1_But.backgroundColor=UIColor.white
        }
        
        if(sender.tag == 1)
        {
            Amount_textField.text=nil
            Amount_textField.text="\(MyWallet.middle_amount)"
            Amount_2_But.backgroundColor=PlumberThemeColor
            add_Amt_But.isEnabled=true
            
            
        }
        else
        {
            Amount_2_But.backgroundColor=UIColor.white
        }
        
        if(sender.tag == 2)
        {
            Amount_textField.text=nil
            Amount_textField.text="\(MyWallet.max_amount)"
            Amount_3_But.backgroundColor=PlumberThemeColor
            add_Amt_But.isEnabled=true
            
            
        }
        else
        {
            Amount_3_But.backgroundColor=UIColor.white
        }
        
        
        if(sender.tag == 3)
        {
            //
            
            
            doneButtonAction()
            
            
            Transaction_Stat.StripeStatus=true
            Transaction_Stat.total_Amt=Amount_textField.text!
            
            if (Amount_textField.text == "")
            {
                themes.AlertView("\(Appname)", Message: themes.setLang("amunt_is_empty"), ButtonTitle: kOk)

            }
            
            else if(Int(Transaction_Stat.total_Amt as String)! < MyWallet.min_amount)
            {
                
                themes.AlertView("\(Appname)", Message: themes.setLang("amunt_is_low"), ButtonTitle: kOk)
            }
            else
            {
                themes.amount = Amount_textField.text!
                
                self.performSegue(withIdentifier: "TransactionVC", sender: nil)
                
            }
            
        }
        
        
        
        
        
    }
    
    
    func getStripeDetails()
    {
        add_Amt_But.isEnabled=false
        let param = NSDictionary()
        
        self.showProgress()
        let amount : String!
        amount = Amount_textField.text
        let paymentUrl : String = "\(constant.Wallet_Recharge)user_id=\(themes.getUserID())&total_amount=\(amount)"
        
        
        
        URL_handler.makeCall(paymentUrl, param: param) { (responseObject, error) -> () in
            self.add_Amt_But.isEnabled=true
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
                                MyWallet.card_number.add((Dic as AnyObject).object(forKey: "card_number") as! String)
                                MyWallet.exp_month.add((Dic as AnyObject).object(forKey: "exp_month") as! String)
                                MyWallet.exp_year.add((Dic as AnyObject).object(forKey: "exp_year") as! String)
                                MyWallet.card_type.add((Dic as AnyObject).object(forKey: "card_type") as! String)
                                MyWallet.customer_id.add((Dic as AnyObject).object(forKey: "customer_id") as! String)
                                MyWallet.card_id.add((Dic as AnyObject).object(forKey: "card_id") as! String)
                                
                                
                                
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
                        self.themes.AlertView("\(Appname)",Message: "\(dict.object(forKey: "response")!)",ButtonTitle: self.themes.setLang("ok"))
                        self.navigationController?.popViewControllerWithFlip(animated: true)
                        
                    }
                    
                }
                else
                {
                    self.DismissProgress()
                    
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    
                    
                    
                }
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPayment"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowRating"), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "Message_notify"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceiveChatToRootView"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceivePushChatToRootView"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPushNotification"), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushRating"), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushPayment"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(WalletViewController.showPopup(_:)), name: NSNotification.Name(rawValue: "ShowPayment"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WalletViewController.Show_Alert(_:)), name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WalletViewController.Show_rating(_:)), name: NSNotification.Name(rawValue: "ShowRating"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WalletViewController.methodofReceivePushNotification(_:)), name:NSNotification.Name(rawValue: "ShowPushNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WalletViewController.methodOfReceivedMessageNotification(_:)), name:NSNotification.Name(rawValue: "ReceiveChatToRootView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WalletViewController.methodOfReceivedMessagePushNotification(_:)), name:NSNotification.Name(rawValue: "ReceivePushChatToRootView"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(WalletViewController.methodofReceiveRatingNotification(_:)), name:NSNotification.Name(rawValue: "ShowPushRating"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WalletViewController.methodofReceivePaymentNotification(_:)), name:NSNotification.Name(rawValue: "ShowPushPayment"), object: nil)
        
  

        
        
        add_Amt_But.isEnabled=true
        
        
        
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPayment"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowRating"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceiveChatToRootView"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceivePushChatToRootView"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPushNotification"), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushRating"), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushPayment"), object: nil)
        
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "Message_notify"), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: Language_Notification as String as String), object: nil)
        
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
    
    
    
    override func Show_rating(_ notification: Notification)
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
        
        
        
        if let activeController = navigationController?.visibleViewController {
            if activeController.isKind(of: RatingsViewController.self){
                
            }else{
                let alertView = UNAlertView(title: Appname, message:messageString!)
                alertView.addButton(self.themes.setLang("ok"), action: {
                    
                    let Controller:RatingsViewController=self.storyboard?.instantiateViewController(withIdentifier: "ReviewPoup") as! RatingsViewController
                    self.navigationController?.pushViewController(withFlip: Controller, animated: true)
                  
                })
                AudioServicesPlayAlertSound(1315);
                alertView.show()
                
            }
            
        }
    }
    
    override func showPopup(_ notification: Notification)
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
        
        
        
        if let activeController = navigationController?.visibleViewController {
            if activeController.isKind(of: PaymentViewController.self){
                
            }else{
                let alertView = UNAlertView(title: Appname, message:messageString!)
                alertView.addButton(self.themes.setLang("ok"), action: {
                    
                    let Controller:PaymentViewController=self.storyboard?.instantiateViewController(withIdentifier: "payment") as! PaymentViewController
                    self.navigationController?.pushViewController(withFlip: Controller, animated: true)
                    
                    
                })
             AudioServicesPlayAlertSound(1315);

                alertView.show()
            }
        }
        
    }
    override func methodofReceivePaymentNotification(_ notification: Notification){
        
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
    override func methodofReceiveRatingNotification(_ notification: Notification){
        
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
    
    
    
    
    override func methodOfReceivedMessagePushNotification(_ notification: Notification){
        
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        // or as! Sting or as! Int
        
        
        
        let check_userid = userInfo["from"]
        let taskid=userInfo["task"]
        
        
        
        if (check_userid == themes.getUserID())
        {
            
        }
        else
        {
            
            Message_details.taskid = taskid!
            Message_details.providerid = check_userid!
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageVC") as! MessageViewController
            
            self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)
        }
        
        
        
    }
    
    
    override func methodOfReceivedMessageNotification(_ notification: Notification){
        
        
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        // or as! Sting or as! Int
        
        let check_userid = userInfo["from"]
        let taskid=userInfo["task"]
        
        
        
        if (check_userid == themes.getUserID())
        {
            
        }
        else
        {
            if let activeController = navigationController?.visibleViewController {
                if activeController.isKind(of: MessageViewController.self){
                    
                }else{
                    let alertView = UNAlertView(title: Appname, message:themes.setLang("message_from_provider"))
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
    
    override func Show_Alert(_ notification:Notification)
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
    
    func walletData(){
    Wallet_ScrollView.isHidden = true
        let param=["user_id":themes.getUserID()]
        self.showProgress()
        URL_handler.makeCall(constant.Mymoney, param: param as NSDictionary) { (responseObject, error) -> () in
            self.DismissProgress()
            
            if(error != nil)
            {
                self.Wallet_ScrollView.isHidden = true
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
            }
                
            else
            {
                
                
                if(responseObject != nil)
                {
                    
                    let json = JSON(responseObject!)
                    
                    
                    MyWallet.Status=json["status"].string!
                    
                    if(MyWallet.Status == "1")
                    {
                        self.Wallet_ScrollView.isHidden = false

                        self.DismissProgress()
                        
                        self.Wallet_ScrollView.isHidden = false
                        
                        //MyWallet.card_Type =
                        let cardType_Array =  json["Payment"].array
                          self.paypalBtn.isHidden = true
                        self.add_Amt_But.isHidden = true
                        for cardDtl in cardType_Array!{
                            let getCardDtl = cardDtl
                            MyWallet.card_Type.add(getCardDtl["code"].string!)
                            
                            
                            if getCardDtl["code"].string! == "paypal"{
                                
                                self.paypalBtn.isHidden = false
                               

                            }
                                
                            else if getCardDtl["code"].string! == "stripe"
                            {
                                self.add_Amt_But.isHidden = false
                                
                            }
                            else{
                                
                            }
                            
                        }
                        
                        if cardType_Array!.count >= 2{
                            
                            self.lblOr.isHidden = false
                            
                        }
                        else if  cardType_Array!.count == 0{
                            self.lblOr.isHidden = true
                            self.themes.AlertView("\(Appname)", Message: self.themes.setLang("No transaction available now"), ButtonTitle: kOk)
                        }
                        else{
                          if   MyWallet.card_Type.object(at: 0) as! String == "paypal"
                            {
                                    self.paypalBtn.frame = self.add_Amt_But.frame
                            }
                             self.lblOr.isHidden = true
                        }
                        
                       // MyWallet.card_Type = cardType_Array
                        MyWallet.auto_charge_status = json["auto_charge_status"].string!
                        MyWallet.currency = self.themes.Currency_Symbol(json["response"]["currency"].string!)
                        if (json["response"]["current_balance"].string != nil)
                        {
                            MyWallet.current_balance = json["response"]["current_balance"].string!
                        }
                        //                    MyWallet.recharge_boundary = json["response"]["recharge_boundary"].intValue
                        MyWallet.max_amount = json["response"]["recharge_boundary"]["max_amount"].intValue
                        
                        MyWallet.middle_amount = json["response"]["recharge_boundary"]["middle_amount"].intValue
                        MyWallet.min_amount = json["response"]["recharge_boundary"]["min_amount"].intValue
                        
                        self.Amount_Lab.text="\(MyWallet.currency)\(MyWallet.current_balance)"
                        
                        self.themes.saveCurrencyCode("\(self.themes.Currency_Symbol(json["response"]["currency"].string!))")
                        self.themes.saveCurrency("\(MyWallet.current_balance)")
                        self.Amount_1_But.setTitle("\(MyWallet.currency)\(MyWallet.min_amount)", for: UIControlState())
                        self.Amount_2_But.setTitle("\(MyWallet.currency)\(MyWallet.middle_amount)", for: UIControlState())
                        self.Amount_3_But.setTitle("\(MyWallet.currency)\(MyWallet.max_amount)", for: UIControlState())
                        self.Amount_textField.placeholder = "\(self.themes.setLang("wallet_amount")) \(MyWallet.currency)\(MyWallet.min_amount) - \(MyWallet.currency)\(MyWallet.max_amount)"
                        self.Amount_textField.text = "" 
                        //self.Amount_Lab.sizeToFit()
                        
                        
                    }
                    else
                    {
                        
                        self.DismissProgress()
                        self.Wallet_ScrollView.isHidden = true

                        self.themes.AlertView("\(Appname)", Message: self.themes.setLang("no_amount_credited"), ButtonTitle: kOk)
                        
                    }
                    
                    
                }
                    
                else
                {
                    self.DismissProgress()
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    
                }
            }
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension WalletViewController:UITextFieldDelegate
{
    
}
