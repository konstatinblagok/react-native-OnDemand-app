

//
//  OrdrsViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 01/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit
import Foundation
import NVActivityIndicatorView
import JTAlertView

class OrdersViewController: UIViewController,MyPopupViewControllerDelegate,UIScrollViewDelegate,OrderDetailViewControllerDelegate,PopupSortingViewControllerDelegate,UIViewControllerTransitioningDelegate
{
    var Is_alertshown:Bool=Bool()
    var tField: UITextField!
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var Selection_Segment: CustomSegmentControl!
    @IBOutlet var Myorder_lbl: UILabel!
    @IBOutlet var Order_Tableview: UITableView!
    @IBOutlet var SlideinMenu_But: UIButton!
    var margin: CGFloat = 0.0
    var URL_handler:URLhandler=URLhandler()
    var themes:Themes=Themes()
    var isSegmentChanged = false
    @IBOutlet weak var lblFilter: UIButton!
    
    var JobidArray:NSMutableArray=NSMutableArray()
    var JobtypeArray:NSMutableArray=NSMutableArray()
    var ServiceIconArray:NSMutableArray=NSMutableArray()
    var BookingDateArray:NSMutableArray=NSMutableArray()
    var JobStatusArray:NSMutableArray=NSMutableArray()
    var ContactNumArray:NSMutableArray=NSMutableArray()
    var MessageStatusArray:NSMutableArray=NSMutableArray()
    var CancelStatusArray:NSMutableArray=NSMutableArray()
    var CallStatusArray : NSMutableArray = NSMutableArray()
    var OrderCompleteDetailArray:NSMutableArray=NSMutableArray()
    var service_typeArray : NSMutableArray = NSMutableArray()
    var ReasonDetailArray:NSMutableArray=NSMutableArray()
    var ReasonidArray:NSMutableArray=NSMutableArray()
    var TaskidArray:NSMutableArray=NSMutableArray()
    var TaskeridArray:NSMutableArray=NSMutableArray()
    
    var Choosedid:String=String()
    var ChoosedReasonid:String=String()
    
    var PageCount:NSInteger=0
    var PageStatus:String=String()
    var SupportStatusArray:NSMutableArray=NSMutableArray()
    var ContactNumber:String=String()
    var refreshControl:UIRefreshControl=UIRefreshControl()
    
    
    let activityTypes: [NVActivityIndicatorType] = [
        .ballPulse]
    
    let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 75, height: 100),
                                                        type: .ballSpinFadeLoader)
    var AlertView:JTAlertView=JTAlertView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
              // Do any additional setup after loading the view.
    }
    @IBAction func menuButtonTouched(_ sender: AnyObject) {
        self.findHamburguerViewController()?.showMenuViewController()
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
    
    
    @IBAction func SegmentAction(_ sender: CustomSegmentControl) {
        let segmentIndex:NSInteger = sender.selectedSegmentIndex;
        Order_Tableview.isHidden = true
        if(segmentIndex == 0)
        {
            isSegmentChanged = true
            PageCount=0
            PageStatus="1"
            GetOrderDetails("\(PageStatus)",Page_Count: PageCount,ShowProgress: true)
            
        }
        if(segmentIndex == 1)
        {
            isSegmentChanged = true
            
            PageCount=0
            PageStatus="4"
            GetOrderDetails("\(PageStatus)",Page_Count: PageCount,ShowProgress: true)
            
            
        }
        if(segmentIndex == 2)
        {
            isSegmentChanged = true
            
            PageCount=0
            PageStatus="5"
            GetOrderDetails("\(PageStatus)",Page_Count: PageCount,ShowProgress: true)
            
            
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        lblFilter.setTitle(themes.setLang("filtercap"), for: UIControlState())
        lblFilter.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblFilter.titleLabel?.numberOfLines = 2
        
        Myorder_lbl.text = themes.setLang("my_orders")
        
        Selection_Segment.frame=CGRect(x: 5, y: headerView.frame.height+2, width: view.frame.size.width-10, height: 43)
        Selection_Segment.setTitle(themes.setLang("open"), forSegmentAt: 0)
        Selection_Segment.setTitle(themes.setLang("completed"), forSegmentAt: 1)
        Selection_Segment.setTitle(themes.setLang("cancelled"), forSegmentAt: 2)
        Selection_Segment.selectedSegmentIndex=0
        Selection_Segment.tintColor=PlumberGreenColor
        
        Selection_Segment.setTitleTextAttributes([NSFontAttributeName: UIFont(name: plumberMediumFontStr, size: 14.0)!, NSForegroundColorAttributeName:PlumberGreenColor], for: UIControlState())
        Selection_Segment.setTitleTextAttributes([NSFontAttributeName: UIFont(name: plumberMediumFontStr, size: 14.0)!, NSForegroundColorAttributeName:UIColor.white], for: .selected)

        // .Selected
    
        
        let nibName = UINib(nibName: "OrderTableViewCell", bundle:nil)
        self.Order_Tableview.register(nibName, forCellReuseIdentifier: "OrderCell")
        Order_Tableview.estimatedRowHeight = 178
        Order_Tableview.rowHeight = UITableViewAutomaticDimension
        Order_Tableview.separatorColor=UIColor.clear
        Order_Tableview.frame = CGRect(x: Order_Tableview.frame.origin.x, y: Selection_Segment.frame.origin.y+Selection_Segment.frame.height+3, width: Order_Tableview.frame.width, height: Order_Tableview.frame.height)
        
        PageStatus="all"
        Schedule_Data.Schedule_header="Reason"
        GetOrderDetails("1",Page_Count: 0,ShowProgress: true)
        configurePulltorefresh()
        
        
        
    }
    
    func applicationLanguageChangeNotification(_ notification:Notification)
    {
        
        //        themes.setLang(
        
        //        themes.setLang("Full Name")
        Myorder_lbl.text=themes.setLang("My order")
        
        
        
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
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(OrdersViewController.showPopup(_:)), name: NSNotification.Name(rawValue: "ShowPayment"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OrdersViewController.Show_Alert(_:)), name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OrdersViewController.Show_rating(_:)), name: NSNotification.Name(rawValue: "ShowRating"), object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("ConfigureNotification:"), name: "Message_notify", object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OrdersViewController.methodOfReceivedMessageNotification(_:)), name:NSNotification.Name(rawValue: "ReceiveChatToRootView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OrdersViewController.methodOfReceivedMessagePushNotification(_:)), name:NSNotification.Name(rawValue: "ReceivePushChatToRootView"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(OrdersViewController.methodofReceivePushNotification(_:)), name:NSNotification.Name(rawValue: "ShowPushNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OrdersViewController.methodofReceiveRatingNotification(_:)), name:NSNotification.Name(rawValue: "ShowPushRating"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OrdersViewController.methodofReceivePaymentNotification(_:)), name:NSNotification.Name(rawValue: "ShowPushPayment"), object: nil)
        
        
        
        
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
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPayment"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowRating"), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "Message_notify"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceiveChatToRootView"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceivePushChatToRootView"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPushNotification"), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushRating"), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushPayment"), object: nil)
        
        
        NotificationCenter.default.removeObserver(self);
        
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
    
    
    
    func methodOfReceivedMessagePushNotification(_ notification: Notification){
        
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
    
    
    func methodOfReceivedMessageNotification(_ notification: Notification){
        
        
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
                    let alertView = UNAlertView(title: Appname, message:themes.setLang("msg_from_provider"))
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
    
    
    
    
    
    func configurePulltorefresh()
    {
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(OrdersViewController.Order_dataFeed), for: UIControlEvents.valueChanged)
        self.Order_Tableview.addSubview(refreshControl)
        
        //    let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        //    loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 0.5)
        //        loadingView.alpha=0.9
        //    Order_Tableview.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
        //
        //
        //
        //     }, loadingView: loadingView)
        //    Order_Tableview.dg_setPullToRefreshFillColor(themes.LightRed())
        //    Order_Tableview.dg_setPullToRefreshBackgroundColor(Order_Tableview.backgroundColor!)
    }
    
    func Order_dataFeed()
    {
        GetOrderDetails("\(self.PageStatus)",Page_Count: self.PageCount,ShowProgress:false)
        
    }
    
    
    override func viewDidLayoutSubviews() {
    }
    
    func GetOrderDetails(_ Status:String,Page_Count:NSInteger,ShowProgress:Bool)
    {
        let param=["user_id":"\(themes.getUserID())","type":"\(Status)","page":"\(Page_Count)","perPage":"20"]
        Selection_Segment.isEnabled=false
        self.Order_Tableview.backgroundView=nil
        if(ShowProgress)
        {
            self.showProgress()
        }
        
        URL_handler.makeCall(constant.Get_Orders, param: param as NSDictionary) { (responseObject, error) -> () in
            self.Order_Tableview.isHidden = false
            self.DismissProgress()
            self.refreshControl.endRefreshing()
            
            self.Selection_Segment.isEnabled=true
            
            
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                
                // self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                let nibView = Bundle.main.loadNibNamed("Nodata", owner: self, options: nil)![0] as! UIView
                nibView.frame = self.Order_Tableview.bounds;
                if(self.isSegmentChanged == true){
                    self.JobidArray.removeAllObjects()
                    self.Order_Tableview.backgroundView=nibView
                }else {
                    self.Order_Tableview.backgroundView=nil
                    
                }
                self.Order_Tableview.reload()
                self.isSegmentChanged = false
                
                
            }
                
            else
            {
                
                let dict:NSDictionary=responseObject!
                
                let Status:NSString=dict.object(forKey: "status") as! NSString
                self.isSegmentChanged = false
                
                if(Status == "1")
                {
                    
                    
                    
                    
                    
                    
                    let OrderDict:NSDictionary=responseObject?.object(forKey: "response")  as! NSDictionary
                    
                    let OrderArray:NSArray?=OrderDict.object(forKey: "jobs") as? NSArray
                    
                    //                    let total_jobs:NSString=OrderDict.objectForKey("total_jobs") as! NSString
                    //
                    //                    let current_page:NSString=OrderDict.objectForKey("current_page") as! NSString
                    //
                    //                    let perPage:NSString=OrderDict.objectForKey("perPage") as! NSString
                    
                    self.emptyArray()
                    
                    if(OrderArray != nil)
                    {
                        
                        if(OrderArray?.count != 0)
                        {
                            
                            for Dictionary in OrderArray!
                            {
                                let Dictionary = Dictionary as! NSDictionary
                                let job_id=Dictionary.object(forKey: "job_id") as! String
                                self.JobidArray.add(job_id)
                                let service_type=Dictionary.object(forKey: "service_type") as! String
                                self.JobtypeArray.add(service_type)
                                let service_icon=Dictionary.object(forKey: "service_icon") as! String
                                self.ServiceIconArray.add(service_icon)
                                let booking_date=Dictionary.object(forKey: "booking_date") as! String
                                let booking_time = self.themes.CheckNullValue(Dictionary.object(forKey: "job_time"))!

                                self.BookingDateArray.add(booking_date)
                                let job_status:String = self.themes.CheckNullValue(Dictionary.object(forKey: "job_status"))!
                                self.JobStatusArray.add(job_status)
                                let contact_number:String = self.themes.CheckNullValue(Dictionary.object(forKey: "contact_number"))!
                                let country_code : String = self.themes.CheckNullValue(Dictionary.object(forKey: "country_code"))!
                                self.ContactNumArray.add("\(country_code)\(contact_number)")
                                
                                self.ContactNumArray.add(contact_number)
                                let doMsg:String=Dictionary.object(forKey: "doMsg") as! String
                                self.MessageStatusArray.add(doMsg)
                                let doCancel:String=Dictionary.object(forKey: "doCancel") as! String
                                self.CancelStatusArray.add(doCancel)
                                let taskid:String=Dictionary.object(forKey: "task_id") as! String
                                self.TaskidArray.add(taskid)
                                let provider:String=self.themes.CheckNullValue(Dictionary.object(forKey: "tasker_id"))!
                                self.TaskeridArray.add(provider)
                                let docall : String = Dictionary.object(forKey: "doCall") as! String
                                self.CallStatusArray.add(docall)
                                
                                self.OrderCompleteDetailArray.add("\(booking_date), \(booking_time)")
                                self.service_typeArray.add(service_type)
                                //service_type
                                
                                let isSupport:String=Dictionary.object(forKey: "isSupport") as! String
                                self.SupportStatusArray.add(isSupport)
                                
                            }
                            
                            
                            let numArr :NSArray = NSArray(array: self.BookingDateArray)
                            
                            let max : NSString =  numArr.value(forKeyPath: "@max.self")! as! NSString
                            let min : NSString = numArr.value( forKeyPath: "@min.self")! as! NSString
                            
                            
                            print("  MAx =\(max) , min =\(min)")
                            
                            self.Order_Tableview.reload()
                            self.Order_Tableview.backgroundView=nil
                            
                        }
                        else
                        {
                            
                            let nibView = Bundle.main.loadNibNamed("Nodata", owner: self, options: nil)![0] as! UIView
                            nibView.frame = self.Order_Tableview.bounds;
                            self.Order_Tableview.backgroundView=nibView
                            
                            if(self.JobidArray.count != 0)
                            {
                                self.Order_Tableview.backgroundView=nil
                                
                            }
                            
                            self.present(self.themes.Showtoast("No more Orders"), animated: false, completion: nil)
                        }
                    }
                    
                }
                else
                {
                    
                    let Response:NSString=responseObject?.object(forKey: "response")  as! NSString
                    self.themes.AlertView("\(Appname)", Message: "\(Response)", ButtonTitle: self.themes.setLang("ok"))
                    self.emptyArray()
                    self.Order_Tableview.reload()
                }
            }
            
        }
    }
    
    
    func emptyArray()
    {
        if(self.PageCount == 0)
        {
            
            if(self.JobidArray.count != 0)
            {
                self.JobidArray.removeAllObjects()
            }
            if(self.JobtypeArray.count != 0)
            {
                self.JobtypeArray.removeAllObjects()
            }
            if(self.ServiceIconArray.count != 0)
            {
                self.ServiceIconArray.removeAllObjects()
            }
            if(self.BookingDateArray.count != 0)
            {
                self.BookingDateArray.removeAllObjects()
            }
            if(self.JobStatusArray.count != 0)
            {
                self.JobStatusArray.removeAllObjects()
            }
            if(self.TaskidArray.count != 0)
            {
                self.TaskidArray.removeAllObjects()
            }
            if(self.TaskeridArray.count != 0)
            {
                self.TaskeridArray.removeAllObjects()
            }
            if(self.ContactNumArray.count != 0)
            {
                self.ContactNumArray.removeAllObjects()
            }
            if(self.MessageStatusArray.count != 0)
            {
                self.MessageStatusArray.removeAllObjects()
            }
            if(self.CancelStatusArray.count != 0)
            {
                self.CancelStatusArray.removeAllObjects()
            }
            if (self.CallStatusArray.count  != 0)
            {
                self.CallStatusArray.removeAllObjects()
            }
            if(self.OrderCompleteDetailArray.count != 0)
            {
                self.OrderCompleteDetailArray.removeAllObjects()
            }
            if (self.service_typeArray.count  != 0)
            {
                self.service_typeArray.removeAllObjects()
            }
            if(self.SupportStatusArray.count != 0)
            {
                self.SupportStatusArray.removeAllObjects()
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //TableViewDelegate
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return JobidArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 10
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if(JobStatusArray.object(at: indexPath.section) as! NSString == "Completed" || JobStatusArray.object(at: indexPath.section) as! NSString == "Cancelled" )
            
        {
            
            return 120
        }
        else
        {
            return 150
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let Cell:OrderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "OrderCell") as! OrderTableViewCell
        
        Cell.frame.size.width=100.0
        Cell.bottomView.isHidden = false
        if(JobStatusArray.object(at: indexPath.section) as! NSString == "Completed" || JobStatusArray.object(at: indexPath.section) as! NSString == "Cancelled" ){
            Cell.bottomView.isHidden = true
            
        }
        Cell.selectionStyle = .none
        
        Cell.layer.cornerRadius = 5
        Cell.layer.shadowColor = UIColor.black.cgColor
        Cell.layer.shadowOpacity = 0.5
        Cell.layer.shadowRadius = 2
        Cell.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        //        let height_lab:CGFloat = self.themes.calculateHeightForString("\(OrderCompleteDetailArray.objectAtIndex(indexPath.section))")
        //
        //        Cell.Order_Detail.frame.size.height = height_lab+30.0
        
        Cell.orderID_label.text="\(themes.setLang("job_id")): \(JobidArray.object(at: indexPath.section))"
        Cell.Order_Detail.text="\(OrderCompleteDetailArray.object(at: indexPath.section))"
        Cell.Jobtitle.text="\(JobtypeArray.object(at: indexPath.section))"
        
        Cell.Status_label.text="\(JobStatusArray.object(at: indexPath.section))"
        Cell.Message_Btn.addTarget(self, action: #selector(OrdersViewController.PushtoChatView(_:)), for: UIControlEvents.touchUpInside)
        Cell.Call_Btn.addTarget(self, action: #selector(OrdersViewController.Callto(_:)), for: UIControlEvents.touchUpInside)
        Cell.Call_Btn.tag=indexPath.section
        Cell.Message_Btn.tag=indexPath.section
        Cell.Service_Image.layer.cornerRadius =  Cell.Service_Image.frame.width/2
        Cell.Service_Image.clipsToBounds = true
        
        if(ServiceIconArray.object(at: indexPath.section) as! NSString != "")
        {
            
            Cell.Service_Image.sd_setImage(with: URL(string: "\(ServiceIconArray.object(at: indexPath.section))"), completed: themes.block)
        }
        
        if(CancelStatusArray.object(at: indexPath.section) as! NSString == "Yes")
        {
            Cell.Cancel_But.isHidden=false
            
            Cell.Cancel_But.addTarget(self, action: #selector(OrdersViewController.ShowReason(_:)), for: UIControlEvents.touchUpInside)
            
            Cell.Cancel_But.tag=indexPath.section
        }
        else
        {
            
            Cell.Cancel_But.isHidden=true
            
        }
        
        if(MessageStatusArray.object(at: indexPath.section) as! NSString == "Yes")
        {
            Cell.Message_Btn.isHidden=false
            Cell.chatimg.isHidden = false
            Cell.Message_Btn.addTarget(self, action: #selector(OrdersViewController.PushtoChatView(_:)), for: UIControlEvents.touchUpInside)
            
            Cell.Message_Btn.tag=indexPath.section
        }
        else
        {
            
            Cell.Message_Btn.isHidden=true
            Cell.chatimg.isHidden = true
        }
        
        if(CallStatusArray.object(at: indexPath.section) as! NSString == "Yes")
        {
            Cell.Call_Btn.isHidden=false
            
            Cell.phoneimg.isHidden = false
            
            Cell.Call_Btn.tag=indexPath.section
        }
        else
        {
            
            Cell.Call_Btn.isHidden=true
            Cell.phoneimg.isHidden = true
        }
        
        
        
        
        Cell.Status_label.backgroundColor=nil
        
        if(JobStatusArray.object(at: indexPath.section) as! NSString == "Confirmed")
        {
            Cell.Status_label.textColor=UIColor.purple
            // 0.0, 1.0, and 0.0 and whose alpha value is 1.0.
        }
            
        else if(JobStatusArray.object(at: indexPath.section) as! NSString == "Completed")
        {
            Cell.Status_label.textColor=UIColor.green
            
            // 0.0, 1.0, and 0.0 and whose alpha value is 1.0.
        }
            
        else if(JobStatusArray.object(at: indexPath.section) as! NSString == "Cancelled")
        {
            Cell.Status_label.textColor=UIColor.red
            // 1.0, 0.0, and 0.0 and whose alpha value is 1.0.
            
        }
            
        else  if(JobStatusArray.object(at: indexPath.section) as! NSString == "Closed")
        {
            Cell.Status_label.textColor=UIColor(red: 34.0/2555.0, green: 139/255.0, blue: 34/255.0, alpha: 1.0)
            
        }
            
        else
            
        {
            Cell.Status_label.textColor=PlumberThemeColor
            
        }
        
        
        
        Cell.Order_Detail.sizeToFit()
        
        
        
        if(CallStatusArray.object(at: indexPath.section) as! NSString == "No"  && CancelStatusArray.object(at: indexPath.section) as! NSString == "No" && MessageStatusArray.object(at: indexPath.section) as! NSString == "No")
        {
            Cell.topborder.isHidden = true
            Cell.sidebarf.isHidden = true
            Cell.sidebarse.isHidden = true
            
        }
        
        
        return Cell
        
    }
    
    
    func PushtoChatView(_ sender:UIButton)
    {
        
        Order_data.job_id="\(JobidArray[sender.tag])"
        
        //
        //        self.performSegueWithIdentifier("ChatVC", sender: nil)
        
        if(SupportStatusArray.object(at: sender.tag) as! String == "Yes")
        {
            ContactNumber="\(ContactNumArray[sender.tag])" as String
            
            let AlertView:UIAlertView=UIAlertView()
            AlertView.delegate=self
            AlertView.title="No Provider Assigned"
            AlertView.message="Are you sure you want to chat with the Support team?"
            AlertView.addButton(withTitle: "Yes")
            AlertView.addButton(withTitle: "No")
            AlertView.tag = 3
            AlertView.show()
            
        }
        else
        {
            var getproviderarray : NSMutableArray = NSMutableArray()
            
            getproviderarray = dbfileobj.arr("Provider_Table")
            if getproviderarray.count != 0
            {
                
                let providerid : String = (getproviderarray.object(at: 0) as AnyObject).object(forKey: "providerid") as! String
                
                Message_details.providerid = providerid
            }
            Message_details.taskid = TaskidArray[sender.tag] as! String
            Message_details.providerid = TaskeridArray[sender.tag] as! String
            Message_details.name = TaskidArray[sender.tag] as! String
            Message_details.image = TaskeridArray[sender.tag] as! String
            
            
            
            
            
            
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageVC") as! MessageViewController
            
            self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)
            //        }
        }
        
    }
    
    func Callto(_ sender:UIButton)
    {
        Order_data.job_id="\(JobidArray[sender.tag])" as String
        
        if(SupportStatusArray.object(at: sender.tag) as! String == "Yes")
        {
            ContactNumber="\(ContactNumArray[sender.tag])" as String
            
            let AlertView:UIAlertView=UIAlertView()
            AlertView.delegate=self
            AlertView.title = themes.setLang("No Provider Assigned")
            AlertView.message = themes.setLang("Are you sure you want to Call the Support team?")
            AlertView.addButton(withTitle: themes.setLang("Yes"))
            AlertView.addButton(withTitle: themes.setLang("No"))
            AlertView.tag = 2
            AlertView.show()
            
        }
        else
        {
            
            let Number:String="\(ContactNumArray[sender.tag])"
            let trimmedString = Number.replacingOccurrences(of: "\\s", with: "", options: NSString.CompareOptions.regularExpression, range: nil)
            print("the number is  ...\(ContactNumArray[sender.tag])")
            
            UIApplication.shared.open(URL(string:"telprompt:\(trimmedString)")!, options: [:], completionHandler: nil)
        }
        
        
    }
    
    
    func ShowReason(_ sender:UIButton)
    {
        
        self.showProgress()
        
        Choosedid="\(JobidArray[sender.tag])"
        
        let param=["user_id":"\(themes.getUserID())"]
        
        URL_handler.makeCall(constant.Get_Reasons, param: param as NSDictionary) { (responseObject, error) -> () in
            self.DismissProgress()
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                
                //self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
            }
            else
            {
                if(responseObject != nil)
                {
                    let Dict:NSDictionary=responseObject!
                    
                    let Status = self.themes.CheckNullValue( Dict.object(forKey: "status"))!
                    
                    
                    self.ReasonDetailArray.removeAllObjects()
                    Schedule_Data.ScheduleAddressNameArray.removeAllObjects()
                    
                    
                    self.ReasonidArray.removeAllObjects()
                    Schedule_Data.ScheduleAddressArray.removeAllObjects()
                    
                    
                    
                    if(Status == "1")
                    {
                        //let ReasonArray:NSArray=Dict.objectForKey("response")!.objectForKey("reason") as! NSArray
                        let ResponseDic:NSDictionary=Dict.object(forKey: "response") as! NSDictionary
                        let ReasonArray : NSArray = ResponseDic.object(forKey: "reason") as! NSArray
                        
                        for ReasonDict in ReasonArray
                        {
                            let ReasonDict = ReasonDict as! NSDictionary
                            let Reason_Str=self.themes.CheckNullValue(ReasonDict.object(forKey: "reason"))!
                            self.ReasonDetailArray.add(Reason_Str)
                            Schedule_Data.ScheduleAddressArray.add(Reason_Str)
                            let Reasonid=self.themes.CheckNullValue(ReasonDict.object(forKey: "id"))!
                            self.ReasonidArray.add(Reasonid)
                            Schedule_Data.ScheduleAddressNameArray.add(Reasonid)
                            
                            
                        }
                        
                        
                        
                        let Reason_Str:NSString="Others"
                        self.ReasonDetailArray.add(Reason_Str)
                        Schedule_Data.ScheduleAddressArray.add(Reason_Str)
                        let Reasonid:NSString="1"
                        self.ReasonidArray.add(Reasonid)
                        Schedule_Data.ScheduleAddressNameArray.add(Reasonid)
                        
                        
                        
                        NSLog("get count=%d and another count=%d", Schedule_Data.ScheduleAddressNameArray.count,Schedule_Data.ScheduleAddressArray.count)
                        
                        self.displayReasonViewController(.bottomBottom)
                    }
                    else
                    {
                        self.themes.AlertView("\(Appname)", Message: self.themes.setLang("no_reasons_available"), ButtonTitle: kOk)
                        
                    }
                    
                }
                else
                {
                    self.themes.AlertView("\(Appname)", Message: self.themes.setLang("no_reasons_available"), ButtonTitle: kOk)
                }
            }
            
        }
        
        
        
    }
    
    func displayReasonViewController(_ animationType: SLpopupViewAnimationType){
        let myPopupViewController:MyPopupViewController = MyPopupViewController(nibName:"MyPopupViewController", bundle: nil)
        myPopupViewController.delegate = self
        myPopupViewController.isDetailViewcontroller = true
        myPopupViewController.transitioningDelegate = self
        myPopupViewController.modalPresentationStyle = .custom;
        self.navigationController?.present(myPopupViewController, animated: true, completion: nil)
    }
    
    func displayViewController(_ animationType: SLpopupViewAnimationType) {
        
        let Popupsortcontroller : PopupSortingViewController = PopupSortingViewController(nibName:"PopupSortingViewController",bundle: nil)
        
        
        if    Selection_Segment.selectedSegmentIndex == 1 ||  Selection_Segment.selectedSegmentIndex == 2{
            Popupsortcontroller.selecIndex = 1
        }else{
            Popupsortcontroller.selecIndex = 0
        }
        
        Popupsortcontroller.delegate = self;
        
        Popupsortcontroller.transitioningDelegate = self
        Popupsortcontroller.modalPresentationStyle = .custom;
        self.navigationController?.present(Popupsortcontroller, animated: true, completion: nil)

    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        Order_data.job_id="\(JobidArray[indexPath.section])" as String
        
        self.performSegue(withIdentifier: "OrderDetailVC", sender: nil)
    }
    
    func pressCancel(_ sender: MyPopupViewController) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func pressAdd(_ sender: MyPopupViewController) {
        
    }
    func  pressedCancel(_ sender: PopupSortingViewController) {
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    func passRequiredParametres(_ fromdate: NSString, todate: NSString, isAscendorDescend: Int,isToday:Int,isSortby:NSString) {
        
        
        if(isToday == 3){
            
            var from = fromdate
            var tod = todate
            var typests : NSString  = NSString ()
            if    Selection_Segment.selectedSegmentIndex == 0
                
            {
                typests = "1"
            }
            else if  Selection_Segment.selectedSegmentIndex == 1
            {
                typests = "4"
                
            }
            else if  Selection_Segment.selectedSegmentIndex == 2
            {
                typests = "5"
                
                
            }
            
            if from == "From Date" || tod == "To Date"
            {
                from  = ""
                tod = ""
            }
            
            let param=["user_id":"\(themes.getUserID())","type":"\(typests)","page":"\(self.PageCount)","perPage":"20","from":"\(from)","to":"\(tod)","orderby":"\(isAscendorDescend)","sortby":isSortby] as [String : Any]
            
            self.showProgress()
            
            
            URL_handler.makeCall(constant.Get_SortingOrders, param: param as NSDictionary) { (responseObject, error) -> () in
                self.DismissProgress()
                self.refreshControl.endRefreshing()
                
                
                
                if(error != nil)
                {
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    
                    //self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                    let nibView = Bundle.main.loadNibNamed("Nodata", owner: self, options: nil)![0] as! UIView
                    nibView.frame = self.Order_Tableview.bounds;
                    self.Order_Tableview.backgroundView=nibView
                    self.Order_Tableview.reload()
                    
                }
                    
                else
                {
                    
                    let dict:NSDictionary=responseObject!
                    
                    let Status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                    
                    if(Status == "1")
                    {
                        
                        let OrderDict:NSDictionary=responseObject?.object(forKey: "response")  as! NSDictionary
                        
                        let OrderArray:NSArray?=OrderDict.object(forKey: "jobs") as? NSArray
                        self.emptyArray()
                        
                        if(OrderArray != nil)
                        {
                            
                            if(OrderArray?.count != 0)
                            {
                                
                                for Dictionary in OrderArray!
                                {
                                    let Dictionary = Dictionary as! NSDictionary
                                    let job_id:NSString=Dictionary.object(forKey: "job_id") as! NSString
                                    self.JobidArray.add(job_id)
                                    let service_type:NSString=Dictionary.object(forKey: "service_type") as! NSString
                                    self.JobtypeArray.add(service_type)
                                    let service_icon:NSString=Dictionary.object(forKey: "service_icon") as! NSString
                                    self.ServiceIconArray.add(service_icon)
                                    let booking_date:NSString=Dictionary.object(forKey: "booking_date") as! NSString
                                    let booking_time = self.themes.CheckNullValue(Dictionary.object(forKey: "job_time"))!
                                    self.BookingDateArray.add("\(booking_date)")
                                    let job_status = self.themes.CheckNullValue(Dictionary.object(forKey: "job_status"))!
                                    self.JobStatusArray.add(job_status)
                                    let contact_number:NSString=Dictionary.object(forKey: "contact_number") as! NSString
                                    self.ContactNumArray.add(contact_number)
                                    let doMsg:NSString=Dictionary.object(forKey: "doMsg") as! NSString
                                    self.MessageStatusArray.add(doMsg)
                                    let doCancel:NSString=Dictionary.object(forKey: "doCancel") as! NSString
                                    self.CancelStatusArray.add(doCancel)
                                    let docall : NSString = Dictionary.object(forKey: "doCall") as! NSString
                                    self.CallStatusArray.add(docall)
                                    let taskid:NSString=Dictionary.object(forKey: "task_id") as! NSString
                                    self.TaskidArray.add(taskid)
                                    let provider:NSString=Dictionary.object(forKey: "tasker_id") as! NSString
                                    self.TaskeridArray.add(provider)
                                    
                                    
                                    self.OrderCompleteDetailArray.add("\(booking_date), \(booking_time)")
                                    self.service_typeArray.add(service_type)
                                    
                                    let isSupport:NSString=Dictionary.object(forKey: "isSupport") as! NSString
                                    self.SupportStatusArray.add(isSupport)
                                    
                                }
                                
                                self.Order_Tableview.backgroundView=nil
                                
                            }
                            else
                            {
                                
                                let nibView = Bundle.main.loadNibNamed("Nodata", owner: self, options: nil)![0] as! UIView
                                nibView.frame = self.Order_Tableview.bounds;
                                self.Order_Tableview.backgroundView=nibView
                                self.Order_Tableview.reload()
                                if(self.JobidArray.count != 0)
                                {
                                    self.Order_Tableview.backgroundView=nil
                                    
                                }
                                
                                self.present(self.themes.Showtoast("No more Orders"), animated: false, completion: nil)
                            }
                        }
                        
                        self.Order_Tableview.reload()
                    }
                    else
                    {
                        
                        let Response=self.themes.CheckNullValue(responseObject?.object(forKey: "response"))!
                        self.themes.AlertView("\(Appname)", Message: "\(Response)", ButtonTitle: self.themes.setLang("ok"))
                        self.emptyArray()
                        self.Order_Tableview.reload()
                    }
                }
                
            }
        }else{
            dayFilter(isToday, isAsc: isAscendorDescend)
        }
    }
    
    
    func dayFilter(_ type:Int,isAsc:Int){
        var types = String()
        
        if(type == 0){
            types = "today"
        }else if(type == 1){
            types = "recent"
        }else if(type == 2){
            types = "upcoming"
        }
        
        let param=["user_id":"\(themes.getUserID())","type":"\(types)","page":"\(self.PageCount)","perPage":"20","orderby":"\(isAsc)","sortby":""]
        
        self.showProgress()
        
        
        URL_handler.makeCall(constant.Get_Todays_Orders, param: param as NSDictionary) { (responseObject, error) -> () in
            self.DismissProgress()
            self.refreshControl.endRefreshing()
            
            
            
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                
                //self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                let nibView = Bundle.main.loadNibNamed("Nodata", owner: self, options: nil)![0] as! UIView
                nibView.frame = self.Order_Tableview.bounds;
                self.Order_Tableview.backgroundView=nibView
                self.Order_Tableview.reload()
                
            }
                
            else
            {
                
                let dict:NSDictionary=responseObject!
                
                let Status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                
                if(Status == "1")
                {
                    
                    let OrderDict:NSDictionary=responseObject?.object(forKey: "response")  as! NSDictionary
                    
                    let OrderArray:NSArray?=OrderDict.object(forKey: "jobs") as? NSArray
                    self.emptyArray()
                    
                    if(OrderArray != nil)
                    {
                        
                        if(OrderArray?.count != 0)
                        {
                            
                            for Dictionary in OrderArray!
                            {
                                let Dictionary = Dictionary as! NSDictionary
                                let job_id:NSString=Dictionary.object(forKey: "job_id") as! NSString
                                self.JobidArray.add(job_id)
                                let service_type=self.themes.CheckNullValue(Dictionary.object(forKey: "service_type"))!
                                self.JobtypeArray.add(service_type)
                                let service_icon=self.themes.CheckNullValue(Dictionary.object(forKey: "service_icon"))!
                                self.ServiceIconArray.add(service_icon)
                                let booking_date=self.themes.CheckNullValue(Dictionary.object(forKey: "booking_date"))!
                                self.BookingDateArray.add(booking_date)
                                let booking_time = self.themes.CheckNullValue(Dictionary.object(forKey: "job_time"))!
                                let job_status = self.themes.CheckNullValue(Dictionary.object(forKey: "job_status"))!
                                self.JobStatusArray.add(job_status)
                                let contact_number=self.themes.CheckNullValue(Dictionary.object(forKey: "contact_number"))!
                                self.ContactNumArray.add(contact_number)
                                let doMsg=self.themes.CheckNullValue(Dictionary.object(forKey: "doMsg"))!
                                self.MessageStatusArray.add(doMsg)
                                let doCancel=self.themes.CheckNullValue(Dictionary.object(forKey: "doCancel"))!
                                self.CancelStatusArray.add(doCancel)
                                let docall = self.themes.CheckNullValue(Dictionary.object(forKey: "doCall"))!
                                self.CallStatusArray.add(docall)
                                let taskid=self.themes.CheckNullValue(Dictionary.object(forKey: "task_id"))!
                                self.TaskidArray.add(taskid)
                                let provider=self.themes.CheckNullValue(Dictionary.object(forKey: "tasker_id"))!
                                self.TaskeridArray.add(provider)
                                
                                
                                self.OrderCompleteDetailArray.add("\(booking_date), \(booking_time)")
                                self.service_typeArray.add(service_type)
                                
                                let isSupport=self.themes.CheckNullValue(Dictionary.object(forKey: "isSupport"))!
                                self.SupportStatusArray.add(isSupport)
                                
                            }
                            
                            self.Order_Tableview.backgroundView=nil
                            
                        }
                        else
                        {
                            
                            let nibView = Bundle.main.loadNibNamed("Nodata", owner: self, options: nil)![0] as! UIView
                            nibView.frame = self.Order_Tableview.bounds;
                            self.Order_Tableview.backgroundView=nibView
                            self.Order_Tableview.reload()
                            if(self.JobidArray.count != 0)
                            {
                                self.Order_Tableview.backgroundView=nil
                                
                            }
                            
                            self.present(self.themes.Showtoast("No more Orders"), animated: false, completion: nil)
                        }
                    }
                    
                    self.Order_Tableview.reload()
                }
                else
                {
                    
                    let Response=self.themes.CheckNullValue(responseObject?.object(forKey: "response"))!
                    self.themes.AlertView("\(Appname)", Message: "\(Response)", ButtonTitle: self.themes.setLang("ok"))
                    self.emptyArray()
                    self.Order_Tableview.reload()
                }
            }
            
        }
        
        
    }
    
    func PassSelectedAddress(_ Address: String, AddressIndexvalue: Int, latitudestr: String, longtitudestr: String,localitystr:String,fulladdress:String) {

        self.dismiss(animated: true, completion: nil)
        
        
        
        
        if (Address == "Others")
        {
            let alert = UIAlertController(title:themes.setLang("reason"), message: "", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: configurationTextField)
            alert.addAction(UIAlertAction(title: themes.setLang("cancel"), style: .cancel, handler:handleCancel))
            alert.addAction(UIAlertAction(title: themes.setLang("done"), style: .default, handler:{ (UIAlertAction) in
                if self.tField.text == ""
                {
                    self.themes.AlertView("\(Appname)", Message:"\(self.themes.setLang("reason_mand"))", ButtonTitle: kOk)
                }
                else
                {
                self.ChoosedReasonid = self.tField.text!
                self.cancelRequest()
                }
                
            }))
            self.present(alert, animated: true, completion: {
                print("completion block")
            })
            
            
        }
        else
        {
            
            ChoosedReasonid=Address
            let AlertView:UIAlertView=UIAlertView()
            AlertView.delegate=self
            AlertView.title=themes.setLang("cancel_confirmation")
            AlertView.addButton(withTitle: themes.setLang("yes"))
            AlertView.addButton(withTitle: themes.setLang("no"))
            AlertView.tag = 1
            AlertView.show()
        }
        
        
    }
    
    
    func configurationTextField(_ textField: UITextField!)
    {
        
        textField.placeholder = themes.setLang("Enter Your Reason")
        
        tField = textField
    }
    
    func handleCancel(_ alertView: UIAlertAction!)
    {
        print("Cancelled !!")
    }
    
    
    func alertView(_ View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        if(View.tag == 1)
        {
            
            switch buttonIndex{
                
            case 0:
                self.cancelRequest()
                break;
            default:
                break;
                //Some code here..
                
            }
        }
        if(View.tag == 2)
        {
            
            switch buttonIndex{
                
            case 0:
                let Number:String="\(ContactNumber)"
                let trimmedString = Number.replacingOccurrences(of: "\\s", with: "", options: NSString.CompareOptions.regularExpression, range: nil)
                print("the number is  ...\(ContactNumber)")
                UIApplication.shared.open(URL(string:"telprompt:\(trimmedString)")!, options: [:], completionHandler: nil)
                break;
            default:
                break;
                //Some code here..
                
            }
            
            
        }
        if(View.tag == 3)
        {
            
            switch buttonIndex{
                
            case 0:
                if (themes.canSendText()) {
                    // Obtain a configured MFMessageComposeViewController
                    let messageComposeVC = themes.configuredMessageComposeViewController("",number:"\(ContactNumber)")
                    // Present the configured MFMessageComposeViewController instance
                    // Note that the dismissal of the VC will be handled by the messageComposer instance,
                    // since it implements the appropriate delegate call-back
                    present(messageComposeVC, animated: true, completion: nil)
                } else {
                    // Let the user know if his/her device isn't able to send text messages
                    let errorAlert = UIAlertView(title: themes.setLang("Cannot Send Text Message") , message: themes.setLang("Your device is not able to send text messages."), delegate: self, cancelButtonTitle: self.themes.setLang("ok"))
                    errorAlert.show()
                }
                
                
                break;
            default:
                break;
                //Some code here..
                
            }
            
            
        }
        
        
    }
    
    func cancelRequest()
    {
        
        self.showProgress()
        let param=["user_id":"\(themes.getUserID())","reason":"\(ChoosedReasonid)","job_id":"\(Choosedid)"]
        
        
        
        URL_handler.makeCall(constant.Cancel_Reasons, param: param as NSDictionary) { (responseObject, error) -> () in
            
            
            self.DismissProgress()
            
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                
                //self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                
            }
            else
            {
                if(responseObject != nil)
                {
                    let Dict:NSDictionary=responseObject!
                    
                    let Status=self.themes.CheckNullValue(Dict.object(forKey: "status"))!
                    
                    
                    if(Status == "1")
                    {
                        
                        
                        self.GetOrderDetails("\(self.PageStatus)", Page_Count:self.PageCount,ShowProgress: true)
                    }
                    else
                    {
                        let Response=Dict.object(forKey: "response") as! String
                        self.themes.AlertView("\(Appname)", Message: "\(Response)", ButtonTitle: self.themes.setLang("ok"))
                    }
                    
                }
                else
                {
                    self.themes.AlertView("\(Appname)", Message: self.themes.setLang("cant_cancel"), ButtonTitle: kOk)
                }
            }
            
        }
        
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func ReloadData(_ sender: OrderDetailViewController) {
        self.GetOrderDetails(PageStatus, Page_Count: PageCount,ShowProgress: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "OrderDetailVC"{
            let vc = segue.destination as! OrderDetailViewController
            vc.delegate = self
        }
    }
    
    @IBAction func didclickfilteroption(_ sender: AnyObject) {
        self.PageCount = 0
        self.displayViewController(.bottomBottom)
    }
    
    //    #pragma mark - UIViewControllerTransitionDelegate -
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return PresentingAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return DismissingAnimationController()
    }
    
    
}
