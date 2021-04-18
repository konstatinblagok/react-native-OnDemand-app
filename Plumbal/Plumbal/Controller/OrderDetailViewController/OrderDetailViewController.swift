//
//  OrderDetailViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 05/11/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import MPGNotification
import JTAlertView
import NVActivityIndicatorView

protocol OrderDetailViewControllerDelegate {
    //    func pressOK(sender: MyPopupViewController)
    func ReloadData(_ sender: OrderDetailViewController)
}

class OrderDetailViewController: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate,MyPopupViewControllerDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate,UIAlertViewDelegate,UIViewControllerTransitioningDelegate {
    var Window:UIWindow=UIWindow()
    var notification:MPGNotification=MPGNotification()
    var buttonArray:NSArray=NSArray()
    var tField: UITextField!
    var AlertView:JTAlertView=JTAlertView()
    var Is_alertshown:Bool=Bool()
    let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 0, height: 0),
                                                        type: .ballSpinFadeLoader)
    
    
    @IBOutlet var dotView_3: SetColorView!
    
    
    @IBOutlet var cancellationReason_Lbl: CustomLabel!
    @IBOutlet var cancellationReasonVal_Lbl: CustomLabelGray!
    
    @IBOutlet var cancellationReason_View: UIView!
    @IBOutlet weak var lblProffes: UILabel!
    @IBOutlet weak var lblRequest: UILabel!
    
    @IBOutlet weak var lblServiceDel: UILabel!
    @IBOutlet weak var openinMapview: UIView!
    
    @IBOutlet var openInMapsBtn: UIButton!
    @IBOutlet var paymentBtn: UIButton!
    @IBOutlet var viewSummeryBtn: UIButton!
    var delegate:OrderDetailViewControllerDelegate?
    @IBOutlet var Location_lbl: UILabel!
    @IBOutlet var Date_Lbl: UILabel!
    @IBOutlet var Cancel_Btn: UIButton!
    @IBOutlet var No_data: UILabel!
    @IBOutlet var Date_Time_Lab: UILabel!
    @IBOutlet var service_type_lbl: UILabel!

    @IBOutlet var Detail_Tableview: UITableView!
    @IBOutlet var Provider_Bio: UILabel!
    @IBOutlet var Provider_Image: UIImageView!
    @IBOutlet var Provider_Name: UILabel!
    @IBOutlet var Step1_detail: UIImageView!
    @IBOutlet var Step3_detail: UIImageView!
    @IBOutlet var Step2_detail: UIImageView!
    @IBOutlet var Address_Lab: UILabel!
    @IBOutlet var ratingView: TPFloatRatingView!
    var margin: CGFloat = 0.0
    @IBOutlet var MapView: GMSMapView!
    @IBOutlet var Call_btn: UIButton!
    @IBOutlet var Message_btn: UIButton!
    @IBOutlet var user_Image: UIImageView!
    @IBOutlet var Detail_WrapperView: UIView!
    @IBOutlet var Detail_View: UIView!
    @IBOutlet var Dot_View1: UIView!
    @IBOutlet var Dot_View3: UIView!

    @IBOutlet var Dot_View2: UIView!
    @IBOutlet var OrderDetail_ScrollView: UIScrollView!
    @IBOutlet var Back_bt: UIButton!
    var items = [String]()
    
    
    @IBOutlet var Header_Lab: UILabel!
    @IBOutlet var lblServiceType: UILabel!

    let locationManager = CLLocationManager()
    var CurLaat:Double!
    var CurLong:Double!
    var themes:Themes=Themes()
    var Timeline_Date:NSMutableArray=NSMutableArray()
    var Timeline_Time:NSMutableArray=NSMutableArray()
    var Timeline_title:NSMutableArray=NSMutableArray()
    var Detail_ProcessArray:NSMutableArray=NSMutableArray()
    var ReasonDetailArray:NSMutableArray=NSMutableArray()
    var  ReasonidArray:NSMutableArray=NSMutableArray()
    var  ChoosedReasonid:String=String()
    @IBOutlet var Response_View: UIView!
    var BlackWarpper_View:UIView=UIView()
    var URL_Handler:URLhandler=URLhandler()
    override func viewDidLoad() {
        self.openinMapview.isHidden = true
        super.viewDidLoad()
        items = [themes.setLang("detail")
            ,themes.setLang("response")
        ]

     lblProffes.text = themes.setLang("request_submitted")
     lblServiceDel.text = themes.setLang("service_delivery")
     cancellationReason_Lbl.text = themes.setLang("cancel_reason")
        
     lblRequest.text = themes.setLang("professional_assigned")
        lblServiceType.text = themes.setLang("service_type")
        //   self.locationManager.requestAlwaysAuthorization()
        openInMapsBtn.setTitle(themes.setLang("open_maps")
            , for: UIControlState())
        Date_Lbl.text = themes.setLang("date_time")
        Location_lbl.text = themes.setLang("location")
        Call_btn.setTitle(themes.setLang("call"), for: UIControlState())
        Message_btn.setTitle(themes.setLang("chat"), for: UIControlState())

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        OrderDetail_ScrollView.delegate=self
        Schedule_Data.Schedule_header=themes.setLang("reason")
        
        
        Provider_Image.layer.cornerRadius = Provider_Image.frame.size.height / 2;
        Provider_Image.clipsToBounds=true
        Provider_Image.layer.masksToBounds = true;
        Provider_Image.layer.borderWidth = 0;
        Provider_Image.contentMode = UIViewContentMode.scaleAspectFill
        //Provider_Image.layer.borderWidth=2.0
        Provider_Image.layer.borderColor=UIColor.white.cgColor
        
        
        Detail_WrapperView.layer.borderColor=UIColor.white.cgColor
        Detail_WrapperView.layer.borderWidth=1.0
        Detail_WrapperView.layer.cornerRadius=5.0
        
        //Back_bt.setTitle("\(Workname)", forState: UIControlState.Normal)
        
        BlackWarpper_View.backgroundColor=UIColor.black
        
        BlackWarpper_View.frame=CGRect(x: 0, y: 0, width: MapView.frame.size.width, height: MapView.frame.size.height+60)
        BlackWarpper_View.alpha=0.5
        MapView.addSubview(BlackWarpper_View)
        themes.Back_ImageView.image=UIImage(named: "")
        Back_bt.addSubview(themes.Back_ImageView)
        Dot_View3.layer.cornerRadius=Dot_View3.frame.width/2

        Dot_View1.layer.cornerRadius=Dot_View1.frame.width/2
        Dot_View2.layer.cornerRadius=Dot_View2.frame.width/2
        
        dotView_3.layer.cornerRadius=Dot_View1.frame.width/2
        let nibName = UINib(nibName: "DetailTableViewCell", bundle:nil)
        self.Detail_Tableview.register(nibName, forCellReuseIdentifier: "DetailCell")
        Detail_Tableview.estimatedRowHeight = 90
        Detail_Tableview.rowHeight = UITableViewAutomaticDimension
        
        
        let TapGesture:UITapGestureRecognizer=UITapGestureRecognizer(target: self, action: #selector(OrderDetailViewController.ProviderInfo))
        TapGesture.numberOfTapsRequired=1
        TapGesture.delegate=self
        self.Detail_WrapperView.addGestureRecognizer(TapGesture)
        
        let Selection_Segment: CustomSegmentControl=CustomSegmentControl(items: items)
        
        
        Selection_Segment.frame=CGRect(x: self.margin, y:MapView.frame.size.height+MapView.frame.origin.y, width: self.view.frame.size.width - self.margin*2, height: 40)
        Selection_Segment.selectedSegmentIndex=0
        Selection_Segment.tintColor=themes.ThemeColour()
        Selection_Segment.setTitleTextAttributes([NSFontAttributeName: PlumberMediumFont!, NSForegroundColorAttributeName: PlumberThemeColor], for: UIControlState())
        Selection_Segment.addTarget(self, action: #selector(OrderDetailViewController.SegmentAction(_:)), for: .valueChanged)
        self.OrderDetail_ScrollView.addSubview(Selection_Segment);
        
        // Do any additional setup after loading the view.
        
        
        OrderDetail_ScrollView.isHidden=true
        Cancel_Btn.isHidden=true
        
        Selection_Segment.layer.borderColor=themes.ThemeColour().cgColor;
        Selection_Segment.layer.cornerRadius = 0.0;
        Selection_Segment.layer.borderWidth = 1.5;
        
        No_data.text=themes.setLang("no_response")
        
        
    }
    
    
    
    @IBAction func didClickOpenInMapsBtn(_ sender: AnyObject) {
        
        
        moveToLocVc(false)
    }
    
    func moveToLocVc(_ isShowArriveBtn:Bool){//LocationVCSID
        let ObjLocVc=self.storyboard!.instantiateViewController(withIdentifier: "LocationVCSID")as! LocationViewController
        ObjLocVc.isShowArriveBtn=isShowArriveBtn
        ObjLocVc.mapLaat=OrderDetail_data.lat
        ObjLocVc.mapLong=OrderDetail_data.lon
        trackingDetail.userLat = (OrderDetail_data.provider_lat as NSString).doubleValue
        trackingDetail.userLong = (OrderDetail_data.provider_long as NSString).doubleValue
        ObjLocVc.addressStr = Address_Lab.text!
        ObjLocVc.phoneStr = OrderDetail_data.provider_mobile
        ObjLocVc.getUsername =  OrderDetail_data.provider_name
        ObjLocVc.jobId=OrderDetail_data.task_id
        ObjLocVc.providerId = OrderDetail_data.provider_id
        self.navigationController?.pushViewController(withFlip: ObjLocVc, animated: true)
    }
    
    @IBAction func paymentAct(_ sender: AnyObject) {
        
        if sender.tag == 1{
        Root_Base.Job_ID=Order_data.job_id
        Root_Base.task_id = OrderDetail_data.task_id
        
        
        let Controller:PaymentViewController=self.storyboard?.instantiateViewController(withIdentifier: "payment") as! PaymentViewController
        self.navigationController?.pushViewController(withFlip: Controller, animated: true)
        }else if sender.tag == 2{
            let objFarevc = self.storyboard!.instantiateViewController(withIdentifier: "FareSummaryVCSID") as! FareSummaryViewController
            objFarevc.jobIDStr=Order_data.job_id
            self.navigationController!.pushViewController(withFlip: objFarevc, animated: true)

        }
        
        
        
    }
    
    func paymentAction(){
        
    }
    @IBAction func summeryAct(_ sender: AnyObject) {
        if sender.tag == 1{
        let objFarevc = self.storyboard!.instantiateViewController(withIdentifier: "FareSummaryVCSID") as! FareSummaryViewController
        objFarevc.jobIDStr=Order_data.job_id
        self.navigationController!.pushViewController(withFlip: objFarevc, animated: true)
        }else if sender.tag == 2{
            
            Root_Base.Job_ID=Order_data.job_id
            let Controller:RatingsViewController=self.storyboard?.instantiateViewController(withIdentifier: "ReviewPoup") as! RatingsViewController
            self.navigationController?.pushViewController(withFlip: Controller, animated: true)

        }
        
    }
    
    func SegmentAction(_ sender: CustomSegmentControl) {
        let segmentIndex:NSInteger = sender.selectedSegmentIndex;
        
        if(segmentIndex == 0)
        {
            UIView.transition(from: Response_View, to: self.Detail_View, duration: 1, options: UIViewAnimationOptions.transitionFlipFromLeft.union(UIViewAnimationOptions.showHideTransitionViews), completion: nil)
            SetFrameAccordingToSegmentIndex(0)
            
        }
        if(segmentIndex == 1)
        {
            UIView.transition(from: Detail_View, to: self.Response_View, duration: 1, options: UIViewAnimationOptions.transitionFlipFromRight.union(UIViewAnimationOptions.showHideTransitionViews), completion: nil)
            SetFrameAccordingToSegmentIndex(1)
            
            
        }
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPayment"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowRating"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceiveChatToRootView"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceivePushChatToRootView"), object: nil)
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPushNotification"), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "Message_notify"), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushRating"), object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "ShowPushPayment"), object: nil)
        
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: Language_Notification), object: nil)
        
        NotificationCenter.default.removeObserver(self);
        
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowPayment"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowRating"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Language_Notification), object: nil)
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
        _ = userInfo["message"]
        let taskid = userInfo["task"]
        
        
        
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
        _ = userInfo["message"]
        let taskid = userInfo["task"]
        
        
        
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

        let alertView = UNAlertView(title: Appname, message:messageString!)
        alertView.addButton(self.themes.setLang("ok"), action: {
            if action != "admin_notification"{
                Order_data.job_id=Order_id!
            self.GetDetail()
            }
            
            
            
        })
        AudioServicesPlayAlertSound(1315);

        alertView.show()
        
        
    }
    
    
    
    
    func GetDetail()
    {
        self.showProgress()
        let Param=["user_id":"\(themes.getUserID())","job_id":"\(Order_data.job_id)"]
        
        URL_Handler.makeCall(constant.GetOrderdetail, param: Param as NSDictionary) { (responseObject, error) -> () in
            self.DismissProgress()
            self.OrderDetail_ScrollView.isHidden=false
            self.Cancel_Btn.isHidden=false
            
            
            
            
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                
                //  self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                
            }
            else
            {
                
                if(responseObject != nil)
                {
                    let Dict:NSDictionary=responseObject!
                    let Status=self.themes.CheckNullValue(Dict.object(forKey: "status"))!
                    if(Status != "")
                    {
                        
                        
                        if(Status == "1")
                        {
                            
                            let Response:NSDictionary?=(Dict.object(forKey: "response")! as AnyObject).object(forKey: "info") as? NSDictionary
                            
                            
                            if(Response != nil)
                            {
                                
                                
                                let CancelbtnStatus=Response!.object(forKey: "do_cancel") as! String
                                let need_payment=Response!.object(forKey: "need_payment") as! String
                                OrderDetail_data.task_id = Response!.object(forKey: "task_id") as! String
                                let submittratingStatus = Response!.object(forKey: "submit_ratings") as! String
                                //OrderDetail_data.booking_address=Response!.objectForKey("booking_address") as! NSDictionary
                                
                                OrderDetail_data.userJobLocation = self.themes.CheckNullValue(Response!.object(forKey: "booking_address"))!.replacingOccurrences(of: ", ,", with: ",")
                                
                                OrderDetail_data.provider_lat = self.themes.CheckNullValue(Response!.value(forKeyPath: "provider_location.provider_lat"))!
                                OrderDetail_data.provider_long = self.themes.CheckNullValue(Response!.value(forKeyPath: "provider_location.provider_lng"))!
                                
                                
                                
                                OrderDetail_data.job_id=Response!.object(forKey: "job_id") as! String
                                OrderDetail_data.job_status=Response!.object(forKey: "job_status") as! String
                                OrderDetail_data.lat=self.themes.CheckNullValue(Response!.object(forKey: "lat"))!
                                //  OrderDetail_data.location=Response!.objectForKey("booking_address") as! NSString
                                
                                OrderDetail_data.lon=self.themes.CheckNullValue(Response!.object(forKey: "lng"))!
                                let exactaddress = self.themes.CheckNullValue(Response!.object(forKey: "exactaddress"))!
                                if exactaddress != ""
                                {
                                    OrderDetail_data.location=exactaddress
                                }
                                else
                                {
                                    OrderDetail_data.location=self.themes.getAddressForLatLng(OrderDetail_data.lat, longitude: OrderDetail_data.lon)
                                }
                                OrderDetail_data.time=Response!.object(forKey: "time") as! String
                                OrderDetail_data.date=Response!.object(forKey: "date") as! String
                                
                                
                                if(CancelbtnStatus == "Yes")
                                {
                                    
                                    self.Cancel_Btn.isEnabled=true
                                    self.Call_btn.isHidden = false
                                    self.Cancel_Btn.tag=3
                                    self.Cancel_Btn.setTitle(self.themes.setLang("cancel"), for: UIControlState())
                                    self.paymentBtn.isEnabled = false
                                    self.viewSummeryBtn.isEnabled = false
                                    self.paymentBtn.isHidden = true
                                    self.viewSummeryBtn.isHidden = true
                                }
                                    
                                else if(need_payment == "Yes")
                                {
                                  
                                    
                                    
                                    self.Cancel_Btn.isEnabled=false
                                    self.Cancel_Btn.isHidden = true
                                    self.Cancel_Btn.tag=4
                                    self.paymentBtn.setTitle(self.themes.setLang("payment")
                                        , for: UIControlState())
                                    self.paymentBtn.tag = 1
                                     self.viewSummeryBtn.tag = 1
                                    self.viewSummeryBtn.setTitle(self.themes.setLang("view_summary")
                                        , for: UIControlState())
                                    self.paymentBtn.isEnabled = true
                                    self.viewSummeryBtn.isEnabled = true
                                    self.paymentBtn.isHidden = false
                                    self.viewSummeryBtn.isHidden = false
                                    
                                }
                                else
                                {
                                    
                                    self.paymentBtn.isEnabled = false
                                    self.viewSummeryBtn.isEnabled = false
                                    self.paymentBtn.isHidden = true
                                    self.viewSummeryBtn.isHidden = true
                                    
                                    self.Cancel_Btn.isEnabled=true
                                    self.Call_btn.isHidden = false
                                    if(OrderDetail_data.job_status == "Completed")
                                    {
                                         if submittratingStatus == "Yes" && need_payment == "No"{
                                            
                                            self.paymentBtn.tag = 2
                                            self.viewSummeryBtn.tag = 2
                                            
                                            
                                            self.Cancel_Btn.isHidden = true
                                            
                                            self.paymentBtn.setTitle(self.themes.setLang("more_info")
                                                , for: UIControlState())
                                            self.viewSummeryBtn.setTitle("RATING"
                                                , for: UIControlState())
                                            self.paymentBtn.isEnabled = true
                                            self.viewSummeryBtn.isEnabled = true
                                            self.paymentBtn.isHidden = false
                                            self.viewSummeryBtn.isHidden = false
                                        }
                                         else{
                                        self.Cancel_Btn.setTitle(self.themes.setLang("more_info")
                                            , for: UIControlState())
                                        
                                        self.Cancel_Btn.tag=6
                                        }
                                    }
                                    else if (OrderDetail_data.job_status == "StartJob")
                                        
                                    {
                                        self.Cancel_Btn.setTitle(self.themes.setLang("started_job"), for: UIControlState())
                                        
                                        self.Cancel_Btn.tag=5
                                    }
                                        
                                    else
                                    {
                                        self.Cancel_Btn.tag=5
                                        
                                        self.Cancel_Btn.setTitle("\(OrderDetail_data.job_status)", for: UIControlState())
                                    }
                                    
                                }
                                
                            }
                            let Response_Timeline:NSArray?=(Dict.object(forKey: "response")! as AnyObject).object(forKey: "timeline") as? NSArray
                            if(self.Timeline_Date.count != 0)
                            {
                                self.Timeline_Date.removeAllObjects()
                                self.Timeline_Time.removeAllObjects()
                                self.Timeline_title.removeAllObjects()
                            }
                            
                            if(Response_Timeline != nil)
                            {
                                for  Dict in Response_Timeline!
                                {
                                    
                                    self.Timeline_Date.add((Dict as AnyObject).object(forKey: "date")!)
                                    self.Timeline_Time.add((Dict as AnyObject).object(forKey: "time")!)
                                    self.Timeline_title.add((Dict as AnyObject).object(forKey: "title")!)
                                    
                                }
                                
                                print("the text is \(self.Timeline_Date.count)")
                                
                                self.Detail_Tableview.reload()
                                
                            }
                            //                        else
                            //                        {
                            //                             self.Timeline_Date.addObject("Your Order has been Sucessfully Submitted")
                            //                             self.Timeline_Time.addObject("")
                            //                             self.Timeline_title.addObject("")
                            //                            self.Detail_Tableview.reload()
                            //
                            //
                            //                        }
                            
                            
                            
                            
                            
                            
                            let Provide_Response:NSDictionary?=Response!.object(forKey: "provider") as? NSDictionary
                            
                            
                            
                            
                            if(Provide_Response != nil)
                            {
                                
                                OrderDetail_data.provider_name=Provide_Response!.object(forKey: "provider_name") as! String
                                
                                if(OrderDetail_data.provider_name != "")
                                {
                                    
                                    self.No_data.isHidden=true
                                    self.Detail_WrapperView.isHidden=false
                                    OrderDetail_data.provider_email=Provide_Response!.object(forKey: "provider_email") as! String
                                    OrderDetail_data.provider_image=Provide_Response!.object(forKey: "provider_image") as! String
                                    OrderDetail_data.provider_mobile=self.themes.CheckNullValue(Provide_Response!.object(forKey: "provider_mobile"))!
                                    
                                    //                                let ratingInt : Float = Provide_Response!.objectForKey("provider_ratings") as! Float
                                    //                                let strProviderRating = "\(ratingInt)"
                                    OrderDetail_data.avg_rating=self.themes.CheckNullValue(Provide_Response!.object(forKey: "provider_ratings"))!
                                    //OrderDetail_data.avg_rating=self.themes.convertIntToString(Provide_Response!.objectForKey("provider_ratings") as! Int)
                                    //OrderDetail_data.avg_rating=Provide_Response!.objectForKey("provider_ratings") as! NSString
                                    OrderDetail_data.provider_email=Provide_Response!.object(forKey: "provider_email") as! String
                                    OrderDetail_data.provider_id=Provide_Response!.object(forKey: "provider_id") as! String
                                    OrderDetail_data.min_amount = self.themes.CheckNullValue(Provide_Response!.object(forKey: "provider_minimumhourlyrate"))!
                                    OrderDetail_data.hourly_amount = self.themes.CheckNullValue(Provide_Response!.object(forKey: "provider_hourlyrate"))!
                                    OrderDetail_data.Provider_service_type=Response!.object(forKey: "service_type") as! String
                                    OrderDetail_data.cancel_Reason=Response!.object(forKey: "cancelreason") as! String
                                }
                                else
                                {
                                    self.No_data.isHidden=false
                                    
                                    self.Detail_WrapperView.isHidden=true
                                }
                                //      let Locationarray:NSArray=responseObject?.objectForKey("response")!.objectForKey("locations") as! NSArray
                                
                            }
                            else
                            {
                                self.Detail_WrapperView.isHidden=true
                            }
                            
                            self.set_Data()
                            
                            
                        }
                        else
                        {
                            let Response:NSString=Dict.object(forKey: "response") as! NSString
                            
                            self.themes.AlertView("\(Appname)", Message: "\(Response)", ButtonTitle: "OK")
                            
                        }
                    }
                    else
                    {
                        
                        self.themes.AlertView("\(Appname)", Message: self.themes.setLang("cant_cancel"), ButtonTitle: kOk)
                        
                        
                    }
                    
                }
                else
                {
                    self.themes.AlertView("\(Appname)", Message: self.themes.setLang("cant_cancel"), ButtonTitle: kOk)
                }
            }
            
            self.SetFrameAccording_ToSegmentIndex(0)
            
        }
    }
    
    func ProviderInfo()
    {
//        let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MYProfileVCSID") as! MyProfileViewController
//        secondViewController.providerid = OrderDetail_data.provider_id
//        secondViewController.minCost = OrderDetail_data.min_amount
//        secondViewController.hourlyCost = OrderDetail_data.hourly_amount
//
//        self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)
        
        let taskerpro:TaskerProfileViewController = TaskerProfileViewController(nibName:"TaskerProfileViewController", bundle: nil)
        taskerpro.providerid = OrderDetail_data.provider_id
        taskerpro.minCost = OrderDetail_data.min_amount
        taskerpro.hourlyCost = OrderDetail_data.hourly_amount
        taskerpro.hideView = "0"
        self.navigationController?.pushViewController(withFlip: taskerpro, animated: true)
    
    }
    
    
    func set_Data()
    {
        Header_Lab.text="\(themes.setLang("order_id")): \(OrderDetail_data.job_id)"
        //self.set_mapView(OrderDetail_data.lat,long: OrderDetail_data.lon)
        service_type_lbl.text="\(OrderDetail_data.Provider_service_type)"
       if  OrderDetail_data.cancel_Reason == ""{
        cancellationReason_View.isHidden = true
        self.Detail_Tableview.frame  = CGRect(x: self.Detail_Tableview.frame.origin.x, y: self.Address_Lab.frame.maxY+5,width: self.Detail_Tableview.frame.size.width , height: self.Detail_Tableview.frame.size.height)
        
        
       }
       else{
        cancellationReason_View.isHidden = false
        cancellationReasonVal_Lbl.text = "\(OrderDetail_data.cancel_Reason)"
        
        }
       
        Date_Time_Lab.text="\(OrderDetail_data.date), \(OrderDetail_data.time)"
        let longitude :CLLocationDegrees =  (OrderDetail_data.lon as NSString).doubleValue
        let latitude :CLLocationDegrees =  (OrderDetail_data.lat as NSString).doubleValue
        let location = CLLocation(latitude: latitude, longitude: longitude) //changed!!!
        
        
        if OrderDetail_data.job_status == "StartOff"
        {
          openinMapview.isHidden = false
        }
        else{
            openinMapview.isHidden = true
        }
        
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                print(pm.locality!)
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
        
        
        
        
        
            Address_Lab.text = OrderDetail_data.location
        //        Address_Lab.text = themes.getAddressForLatLng(OrderDetail_data.lat, longitude: OrderDetail_data.lon)
        if(OrderDetail_data.provider_name != "")
        {
            Provider_Name.text="\(OrderDetail_data.provider_name)"
            self.Provider_Image.sd_setImage(with: URL(string:"\(OrderDetail_data.provider_image)"), placeholderImage: UIImage(named: "PlaceHolderSmall"))
            
            //Provider_Image.sd_setImageWithURL(NSURL(string: "\(OrderDetail_data.provider_image)"), completed: themes.block)
            Provider_Bio.text="\(OrderDetail_data.provider_email)"
            let n = NumberFormatter().number(from: OrderDetail_data.avg_rating)
            Set_StarRating(CGFloat(n!))
        }
        
        self.set_mapView()
        
        
        if(OrderDetail_data.job_status == "Cancelled")
        {
            Step1_detail.image=UIImage(named: "tick_green")
            Step2_detail.image=UIImage(named: "circle")
            Step3_detail.image=UIImage(named: "circle")
            
        }
        else if(OrderDetail_data.job_status == "Completed")
        {
            Step1_detail.image=UIImage(named: "tick_green")
            Step2_detail.image=UIImage(named: "tick_green")
            Step3_detail.image=UIImage(named: "tick_green")
        }
            else if(OrderDetail_data.job_status == "Onprogress")
        {
            Step1_detail.image=UIImage(named: "tick_green")
            Step2_detail.image=UIImage(named: "circle")
            Step3_detail.image=UIImage(named: "circle")

        }
        else
            
        {
            Step1_detail.image=UIImage(named: "tick_green")
            Step2_detail.image=UIImage(named: "tick_green")
            Step3_detail.image=UIImage(named: "circle")
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
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(OrderDetailViewController.showPopup(_:)), name: NSNotification.Name(rawValue: "ShowPayment"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OrderDetailViewController.Show_Alert(_:)), name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OrderDetailViewController.Show_rating(_:)), name: NSNotification.Name(rawValue: "ShowRating"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OrderDetailViewController.ConfigureNotification(_:)), name: NSNotification.Name(rawValue: "Message_notify"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OrderDetailViewController.methodofReceivePushNotification(_:)), name:NSNotification.Name(rawValue: "ShowPushNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OrderDetailViewController.methodofReceiveRatingNotification(_:)), name:NSNotification.Name(rawValue: "ShowPushRating"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OrderDetailViewController.methodofReceivePaymentNotification(_:)), name:NSNotification.Name(rawValue: "ShowPushPayment"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(OrderDetailViewController.methodOfReceivedMessageNotification(_:)), name:NSNotification.Name(rawValue: "ReceiveChatToRootView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OrderDetailViewController.methodOfReceivedMessagePushNotification(_:)), name:NSNotification.Name(rawValue: "ReceivePushChatToRootView"), object: nil)
        self.GetDetail()
        
        
        
    }
    
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
        
       

        
        let Controller:OrderDetailViewController=self.storyboard?.instantiateViewController(withIdentifier: "OrderDetail") as! OrderDetailViewController
        self.navigationController?.pushViewController(withFlip: Controller, animated: true)
        
        
        
        
        
        
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
        
        
        if let activeController = navigationController?.visibleViewController {
            if activeController.isKind(of: RatingsViewController.self){
                
            }else{
                
                let Controller:RatingsViewController=self.storyboard?.instantiateViewController(withIdentifier: "ReviewPoup") as! RatingsViewController
                self.navigationController?.pushViewController(withFlip: Controller, animated: true)
                
                
            }
            
        }
        
    }
    
    
    
    
    
    func Set_StarRating(_ Rating:CGFloat)
    {
        self.ratingView.emptySelectedImage = UIImage(named: "Star")
        self.ratingView.fullSelectedImage = UIImage(named: "StarSelected")
        self.ratingView.contentMode = UIViewContentMode.scaleAspectFill
        self.ratingView.maxRating = 5
        self.ratingView.minRating = 1
        self.ratingView.rating = Rating
        self.ratingView.editable = false;
        self.ratingView.halfRatings = true;
        self.ratingView.floatRatings = false;
        
    }
    
    
    
    func set_mapView()
    {
        let latitude = (OrderDetail_data.lat as NSString).doubleValue
        let longitude = (OrderDetail_data.lon as NSString).doubleValue
        let camera = GMSCameraPosition.camera(withLatitude: latitude,
                                                          longitude:longitude, zoom:constant.mapZoomIn)
        
        MapView.camera=camera
        MapView.frame=MapView.frame
        MapView.delegate=self
        let marker = GMSMarker()
        marker.position = camera.target
        marker.appearAnimation = .pop
        marker.icon = UIImage(named: "MapPin")
        marker.map = MapView
        // MapView.settings.setAllGesturesEnabled(false)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        CurLaat=locValue.latitude
        CurLong=locValue.longitude
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                themes.AlertView("", Message: "\(themes.setLang("location_service_disabled"))\n \(themes.setLang("to_reenable_location")) ", ButtonTitle: kOk)
                break
                
            case .authorizedAlways, .authorizedWhenInUse: break
                
            }
        } else {
            themes.AlertView("", Message: "\(themes.setLang("location_service_disabled"))\n \(themes.setLang("to_reenable_location")) ", ButtonTitle: kOk)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func SetFrameAccordingToSegmentIndex(_ IndexPath:Int){
        
        
        
        DispatchQueue.main.async {
            
            
            
            //This code will run in the main thread:
            var frame: CGRect = self.Detail_Tableview.frame
            frame.size.height = self.Detail_Tableview.contentSize.height;
            //            frame.origin.y=
            self.Detail_Tableview.frame = frame;
            self.Detail_View.frame = CGRect(x: self.Detail_View.frame.origin.x, y: self.Detail_View.frame.origin.y, width: self.Detail_View.frame.size.width, height: self.Detail_Tableview.frame.origin.y+self.Detail_Tableview.frame.size.height);
            if(IndexPath==0){
                self.OrderDetail_ScrollView.contentSize=CGSize(width: self.OrderDetail_ScrollView.frame.size.width, height: self.Detail_View.frame.origin.y+self.Detail_View.frame.size.height+5)
            }else{
                self.OrderDetail_ScrollView.contentSize=CGSize(width: self.OrderDetail_ScrollView.frame.size.width, height: self.Response_View.frame.origin.y+self.Response_View.frame.size.height+5)
            }
            
            
        }
    }
    
    func SetFrameAccording_ToSegmentIndex(_ IndexPath:Int){
        
        
        
        DispatchQueue.main.async {
            
            
            
            //This code will run in the main thread:
            var frame: CGRect = self.Detail_Tableview.frame
            frame.size.height = self.Detail_Tableview.contentSize.height;
            //            frame.origin.y=
            self.Detail_Tableview.frame = frame;
            self.Detail_View.frame = CGRect(x: self.Detail_View.frame.origin.x, y: self.Detail_View.frame.origin.y, width: self.Detail_View.frame.size.width, height: self.Detail_Tableview.frame.origin.y+self.Detail_Tableview.frame.size.height);
            if(IndexPath==0){
                self.OrderDetail_ScrollView.contentSize=CGSize(width: self.OrderDetail_ScrollView.frame.size.width, height: self.Detail_View.frame.origin.y+self.Detail_View.frame.size.height)
            }
            
        }
    }
    
    
    //TableViewDelegate
    
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return  Timeline_title.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let Cell:DetailTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "DetailCell") as! DetailTableViewCell
        Cell.selectionStyle=UITableViewCellSelectionStyle.none
        Cell.Detail_Lab.numberOfLines=0
        Cell.Detail_Lab.text="\(Timeline_title[indexPath.row])"
        
        Cell.Time_Lab.text="\(Timeline_Date[indexPath.row])  \(Timeline_Time[indexPath.row])"
        Cell.Time_Lab.sizeToFit()
        if indexPath.row == 0
        {
            Cell.borderlable.isHidden = true
        }
        if(indexPath.row == Timeline_title.count-1)
        {
            Cell.Last_VertLine.isHidden=true
        }
        return Cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView == OrderDetail_ScrollView)
        {
            //             let offset: CGFloat = scrollView.contentOffset.y
            //            let percentage: CGFloat = (offset / CGFloat(223))
            //            let value: CGFloat = CGFloat(223) * percentage
            //            MapView.frame = CGRectMake(0, value, MapView.bounds.size.width, CGFloat(223) - value)
            //            BlackWarpper_View.frame.size.height=MapView.frame.size.height+60
            
            
        }
        //            let alphaValue: CGFloat = 1 - fabs(percentage)
        //            userInfoTopView.alpha = alphaValue * alphaValue * alphaValue
        
    }
    
    
    
    func ShowReason()
    {
        
        self.showProgress()
        
        
        let param=["user_id":"\(themes.getUserID())"]
        
        URL_Handler.makeCall(constant.Get_Reasons, param: param as NSDictionary) { (responseObject, error) -> () in
            
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
                            let Reason_Str=self.themes.CheckNullValue((ReasonDict as AnyObject).object(forKey: "reason"))!
                            self.ReasonDetailArray.add(Reason_Str)
                            Schedule_Data.ScheduleAddressArray.add(Reason_Str)
                            let Reasonid=self.themes.CheckNullValue((ReasonDict as AnyObject).object(forKey: "id"))!
                            self.ReasonidArray.add(Reasonid)
                            Schedule_Data.ScheduleAddressNameArray.add(Reasonid)
                            
                            
                        }
                        
                        
                        let Reason_Str:NSString="Others"
                        self.ReasonDetailArray.add(Reason_Str)
                        Schedule_Data.ScheduleAddressArray.add(Reason_Str)
                        let Reasonid:NSString="1"
                        self.ReasonidArray.add(Reasonid)
                            Schedule_Data.ScheduleAddressNameArray.add(Reasonid)
                        self.displayViewController(.bottomBottom)
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
    
    
    func displayViewController(_ animationType: SLpopupViewAnimationType) {
        let myPopupViewController:MyPopupViewController = MyPopupViewController(nibName:"MyPopupViewController", bundle: nil)
        myPopupViewController.delegate = self
        myPopupViewController.isDetailViewcontroller = true
        myPopupViewController.transitioningDelegate = self
        myPopupViewController.modalPresentationStyle = .custom;
        self.navigationController?.present(myPopupViewController, animated: true, completion: nil)
    }
    func pressCancel(_ sender: MyPopupViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    func pressAdd(_ sender: MyPopupViewController) {
        
    }
    
    func PassSelectedAddress(_ Address: String, AddressIndexvalue: Int, latitudestr: String, longtitudestr: String,localitystr:String,fulladdress:String) {

        self.dismiss(animated: true, completion: nil)
        if (Address == "Others")
        {
            
            
            let alert = UIAlertController(title:self.themes.setLang("reason"), message: "", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: configurationTextField)
            alert.addAction(UIAlertAction(title:self.themes.setLang("cancel"), style: .cancel, handler:handleCancel))
            alert.addAction(UIAlertAction(title: self.themes.setLang("done"), style: .default, handler:{ (UIAlertAction) in
                
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
            
            
            let alert = UIAlertController(title:self.themes.setLang("cancel_confirmation"), message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title:self.themes.setLang("yes"), style: .default, handler:{(action : UIAlertAction) in
                self.cancelRequest()
            }))
            alert.addAction(UIAlertAction(title: self.themes.setLang("no"), style: .cancel, handler:nil))
            self.present(alert, animated: true, completion:nil)
        }
        
    }
    
    
    
    
    func configurationTextField(_ textField: UITextField!)
    {
        
        textField.placeholder = "Enter Your Reason"
        
        tField = textField
    }
    
    func handleCancel(_ alertView: UIAlertAction!)
    {
        print("Cancelled !!")
    }
    
    
    func cancelRequest()
    {
        
        self.showProgress()
        let param=["user_id":"\(themes.getUserID())","reason":"\(ChoosedReasonid)","job_id":"\(OrderDetail_data.job_id)"]
        
        
        
        URL_Handler.makeCall(constant.Cancel_Reasons, param: param as NSDictionary) { (responseObject, error) -> () in
            
            
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
                        self.dismiss(animated: true, completion: nil)
                        
                        self.navigationController?.popViewControllerWithFlip(animated: true)
                        self.delegate?.ReloadData(self)
                        
                    }
                    else
                    {
                        let Response:NSString=Dict.object(forKey: "response") as! NSString
                        
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
    
    
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func didClickoption(_ sender: UIButton) {
        if(sender.tag == 0)
        {
            
            self.navigationController?.popViewControllerWithFlip(animated: true)
            
            self.dismiss(animated: true, completion: nil)
            self.delegate?.ReloadData(self)
            
        }
        if(sender.tag == 1)
        {
            var getproviderarray : NSMutableArray = NSMutableArray()
            
            getproviderarray = dbfileobj.arr("Provider_Table")
            if getproviderarray.count != 0
            {
                
                let providerid = (getproviderarray.object(at: 0) as AnyObject).object(forKey: "providerid")
                
                Message_details.providerid = providerid as! String
            }
            Message_details.taskid = OrderDetail_data.task_id
            Message_details.providerid = OrderDetail_data.provider_id
            
            
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageVC") as! MessageViewController
            
            self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)
            
            
            
            
        }
        if(sender.tag == 2)
        {
            
        print("get mobile no\(OrderDetail_data.provider_mobile)")
            UIApplication.shared.open(URL(string:"telprompt:\(OrderDetail_data.provider_mobile)")!, options: [:], completionHandler: nil)
            
        }
        if(sender.tag == 3)
        {
            ShowReason()
        }
        if(sender.tag == 4)
        {
            
            
            
            
        }
        if(sender.tag == 5)
        {
            
            /*Root_Base.Job_ID=Order_data.job_id
             Root_Base.task_id = OrderDetail_data.task_id
             
             
             var mainView: UIStoryboard!
             mainView = UIStoryboard(name: "Main", bundle: nil)
             let presentingController: UIViewController = mainView.instantiateViewControllerWithIdentifier("ReviewPoup")
             //        Window.rootViewController=presentingController
             let popup: CCMPopupTransitioning = CCMPopupTransitioning.sharedInstance()
             if self.view.bounds.size.height <= 568 {
             popup.destinationBounds = CGRectMake(0, 0, UIScreen.main.bounds.size.width-20, UIScreen.main.bounds.size.height-50)
             }
             else {
             popup.destinationBounds = CGRectMake(0, 0, UIScreen.main.bounds.size.width-20, UIScreen.main.bounds.size.height-50)
             }
             
             popup.presentedController = presentingController
             popup.presentingController = self
             
             //            self.popupController = presentingController
             self.presentViewController(presentingController, animated: true, completion: nil)*/
        }
        
        if (sender.tag == 6)
        {
           
            
            let objFarevc = self.storyboard!.instantiateViewController(withIdentifier: "FareSummaryVCSID") as! FareSummaryViewController
            objFarevc.jobIDStr=Order_data.job_id
            self.navigationController!.pushViewController(withFlip: objFarevc, animated: true)
            
            
        }
        
        if(sender.tag == 100)
        {
            
            
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

class CustomViewFlowLayout : UICollectionViewFlowLayout {
    
    let cellSpacing:CGFloat = 0
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let attributes = super.layoutAttributesForElements(in: rect) {
            for i in 1..<attributes.count 
            {
                let currentLayoutAttributes = attributes[i]
                let prevLayoutAttributes = attributes[i - 1]
                let maxSpacing = cellSpacing
                let origin = prevLayoutAttributes.frame.maxX
                if (origin + maxSpacing + currentLayoutAttributes.frame.size.width < self.collectionViewContentSize.width) {
                    var frame = currentLayoutAttributes.frame
                    frame.origin.x = origin + maxSpacing
                    currentLayoutAttributes.frame = frame
                }
            }
            return attributes
        }
        return nil
    }
}
