//
//  ProviderListViewController.swift
//  Plumbal
//
//  Created by CASPERON on 20/07/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit
import CoreData
class ProviderListViewController: RootViewController,UITableViewDataSource,UITableViewDelegate,PopupFilterViewControllerDelegate,UIViewControllerTransitioningDelegate {

    @IBOutlet var provider_List: UITableView!
    
    @IBOutlet var btnBack: UIButton!
    
    var min : String = String()
    var max : String = String()
    var dbfileobj: DBFile!
    var dataArray : NSMutableArray!
    var appDelegate : AppDelegate!
    var  managedObjectContext :NSManagedObjectContext!
    var   dictRecords :NSMutableDictionary!
    @IBOutlet weak var lblFilter: UIButton!
    @IBOutlet weak var lbl_provider: UILabel!

    var ProviderListArray:NSMutableArray=NSMutableArray()
    var taskerid:NSString=NSString()
    let themes:Themes=Themes()
    var URL_handler:URLhandler=URLhandler()
//    let activityIndicatorView = NVActivityIndicatorView(frame: CGRectMake(0, 0, 0, 0),
//                                                        type: .BallSpinFadeLoader)
//    var AlertView:JTAlertView=JTAlertView()
    
    override func viewDidLoad() {
        
       // self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRect.zero];
        provider_List.tableFooterView = UIView.init(frame: CGRect.zero)
lbl_provider.text = themes.setLang("providers")
        lblFilter.setTitle(themes.setLang("filter"), for: UIControlState())
        lblFilter.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblFilter.titleLabel?.numberOfLines = 2

        dbfileobj = DBFile()
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        self.managedObjectContext = appDelegate.managedObjectContext
        dictRecords = NSMutableDictionary()
        dictRecords["providerid"] = ""

        themes.Back_ImageView.image=UIImage(named: "")
        
        btnBack.addSubview(themes.Back_ImageView)
        
        ProviderListArray = Schedule_Data.ProviderListIdArray
        super.viewDidLoad()
        let nibName = UINib(nibName: "ProviderListCell", bundle:nil)
        self.provider_List.register(nibName, forCellReuseIdentifier: "ProviderListCell")
        provider_List.estimatedRowHeight = 140
        provider_List.rowHeight = 140
        provider_List.separatorColor=UIColor.gray
        provider_List.reload()
        // Do any additional setup after loading the view.
        
        
        
        let numArr :NSArray = NSArray(array:  Schedule_Data.ProviderListHouramountArray)
        
        
        
        max =  numArr.value(forKeyPath: "@max.self")! as! String
        min = numArr.value( forKeyPath: "@min.self")! as! String
        
        
      
    }
    //TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func ShowFilter(_ sender: AnyObject) {
        if max == "0"
        {
        }
        else{
        self.displayViewController(.bottomBottom)
        }
        
        
    }
    
    func displayViewController(_ animationType: SLpopupViewAnimationType) {
        
        let popupFilter : PopupFilterViewController = PopupFilterViewController(nibName:"PopupFilterViewController",bundle: nil)
        popupFilter.delegate = self;
   popupFilter.minimumpriceval = min as NSString!
        popupFilter.maximumpriceval = max as NSString!
        popupFilter.transitioningDelegate = self
        popupFilter.modalPresentationStyle = .custom;
        self.navigationController?.present(popupFilter, animated: true, completion: nil)
    }
    
    func pressedCancel(_ sender: PopupFilterViewController) {
        self.dismiss(animated: true, completion: nil)
        
    }
    func  passParametres(_ RatingValue: CGFloat, Priceval: String ,MaxPrice : String,distancefilter:String) {
        
        
            self.showProgress()
        
      

            let param=["user_id":"\(themes.getUserID())","address_name":"\( Schedule_Data.RquiredAddressid)","pickup_date":"\( Schedule_Data.PickupDate )","pickup_time":"\( Schedule_Data.pickupTime)","instruction":"\( Schedule_Data.GetScheduleIstr)","code":"\( Schedule_Data.GetCoupenText)","category":"\(Home_Data.Category_id)","service":"\(Category_Data.CategoryID)","lat": Schedule_Data.getLatitude,"long": Schedule_Data.getLongtitude,"rating":RatingValue,"minrate":Priceval,"maxrate":MaxPrice,"distancefilter":distancefilter] as [String : Any]
            
            URL_handler.makeCall(constant.Book_It, param: param as NSDictionary, completionHandler: { (responseObject, error) -> () in
                self.DismissProgress()
                
                
                if(error != nil)
                {
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)

                 //   self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                }
                    
                else
                {
                    if(responseObject != nil)
                    {
                        
                        let dict:NSDictionary=responseObject!
                        
                        let Status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                        if(responseObject != nil)
                        {
                            
                          
                            
                                //let response:NSDictionary=dict.objectForKey("response") as! NSDictionary
                            
                          
                                if(Schedule_Data.ProviderListIdArray.count != 0)
                                {
                                    Schedule_Data.ProviderListIdArray.removeAllObjects()
                                }
                                if(Schedule_Data.ProviderListNameArray.count != 0)
                                {
                                    Schedule_Data.ProviderListNameArray.removeAllObjects()
                                }
                                if(Schedule_Data.ProviderListImageArray.count != 0)
                                {
                                    Schedule_Data.ProviderListImageArray.removeAllObjects()
                                }
                                if(Schedule_Data.ProviderListAvailableArray.count != 0)
                                {
                                    Schedule_Data.ProviderListAvailableArray.removeAllObjects()
                                }
                                if(Schedule_Data.ProviderListCompanyArray.count != 0)
                                {
                                    Schedule_Data.ProviderListCompanyArray.removeAllObjects()
                                }
                                if(Schedule_Data.ProviderListRatingArray.count != 0)
                                {
                                    Schedule_Data.ProviderListRatingArray.removeAllObjects()
                                }
                            
                            if(Schedule_Data.ProviderLisreviewsArray.count != 0)
                            {
                                Schedule_Data.ProviderLisreviewsArray.removeAllObjects()
                            }
                            
                            if(Schedule_Data.ProviderdistanceArray.count != 0)
                            {
                                Schedule_Data.ProviderdistanceArray.removeAllObjects()
                            }
                            
                            
                            if(Schedule_Data.ProviderListMinamountArray.count != 0)
                            {
                                Schedule_Data.ProviderListMinamountArray.removeAllObjects()
                            }
                            if(Schedule_Data.ProviderListHouramountArray.count != 0)
                            {
                                Schedule_Data.ProviderListHouramountArray.removeAllObjects()
                            }


                            if(Status == "1")
                            {
                                let responseArray:NSMutableArray=dict.object(forKey: "response") as! NSMutableArray
                                if(responseArray.count != 0)
                                {
                                    let taskID=self.themes.CheckNullValue(dict.object(forKey: "task_id"))!
                                    Schedule_Data.TaskID="\(taskID)"

                                    for Dictionary in responseArray
                                    {
                                        let job_id=(Dictionary as AnyObject).object(forKey: "taskerid") as! String
                                        Schedule_Data.ProviderListIdArray.add(job_id)
                                        let Name=(Dictionary as AnyObject).object(forKey: "name") as! String
                                        Schedule_Data.ProviderListNameArray.add(Name)
                                        let service_icon=(Dictionary as AnyObject).object(forKey: "image_url") as! String
                                        Schedule_Data.ProviderListImageArray.add(service_icon)
                                        let available=(Dictionary as AnyObject).object(forKey: "availability") as! String
                                        Schedule_Data.ProviderListAvailableArray.add(available)
                                        let company=(Dictionary as AnyObject).object(forKey: "company") as! String
                                        Schedule_Data.ProviderListCompanyArray.add(company)
                                        let rating=self.themes.CheckNullValue((Dictionary as AnyObject).object(forKey: "rating"))
                                        Schedule_Data.ProviderListRatingArray.add(rating!)
                                        let reviews=self.themes.CheckNullValue((Dictionary as AnyObject).object(forKey: "reviews"))!
                                        Schedule_Data.ProviderLisreviewsArray.add(reviews)
                                        let dist=self.themes.CheckNullValue((Dictionary as AnyObject).object(forKey: "distance_km"))!
                                        Schedule_Data.ProviderdistanceArray.add(dist)
                                        
                                        let min_amount=self.themes.CheckNullValue((Dictionary as AnyObject).object(forKey: "min_amount"))!
                                        Schedule_Data.ProviderListMinamountArray.add(min_amount)
                                        let hour_amount=self.themes.CheckNullValue((Dictionary as AnyObject).object(forKey: "hourly_amount"))!
                                        Schedule_Data.ProviderListHouramountArray.add(hour_amount)
                                        
                                        
                                        
                                        
                                    }
                                  
                                    
                                
                                    
                                }
                                
                            }
                            else
                            {
                                let response:NSString=dict.object(forKey: "response") as! NSString
                                self.themes.AlertView("\(Appname) ", Message: "\(response)", ButtonTitle: self.themes.setLang("ok"))
                            }
                            
                              self.provider_List.reload()
                        }
                        
                    }
                    else
                    {
                        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                        
                    }
                }
                
            })
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProviderListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let Cell:ProviderListCell = tableView.dequeueReusableCell(withIdentifier: "ProviderListCell") as! ProviderListCell
       
        Cell.selectionStyle = .none
        let strRating = "\(Schedule_Data.ProviderListRatingArray.object(at: indexPath.row))"
        let n = NumberFormatter().number(from: strRating)
        
       if n != nil
       {

        Cell.providerRating.emptySelectedImage = UIImage(named: "Star")
        Cell.providerRating.fullSelectedImage = UIImage(named: "StarSelected")
        Cell.providerRating.contentMode = UIViewContentMode.scaleAspectFill
        Cell.providerRating.maxRating = 5
        Cell.providerRating.minRating = 1
        Cell.providerRating.rating = CGFloat(n!)
        Cell.providerRating.editable = false;
        Cell.providerRating.halfRatings = true;
        Cell.providerRating.floatRatings = false;
        }
        Cell.backView.layer.cornerRadius = 5
        Cell.lblProviderName.text=" \(Schedule_Data.ProviderListNameArray.object(at: indexPath.row))"
        Cell.Mincost.text = "\(themes.getCurrencyCode())\(Schedule_Data.ProviderListMinamountArray.object(at: indexPath.row))"
        Cell.perhouramount.text = "\(themes.getCurrencyCode())\(Schedule_Data.ProviderListHouramountArray.object(at: indexPath.row))"
        Cell.lblDistance.text = "\(Schedule_Data.ProviderdistanceArray.object(at: indexPath.row))"
        Cell.lblReviewsCount.text = "\(self.themes.setLang("reviews")) \(Schedule_Data.ProviderLisreviewsArray.object(at: indexPath.row))"

        _="\(Schedule_Data.ProviderListAvailableArray.object(at: indexPath.row))"
        Cell.imgProvider.layer.cornerRadius = Cell.imgProvider.frame.width/2;
         Cell.imgProvider.layer.masksToBounds = true;
        Cell.imgProvider.sd_setImage(with: URL(string: "\(Schedule_Data.ProviderListImageArray.object(at: indexPath.row) )"), completed: themes.block)
       /* Cell.imgProvider.layer.borderWidth=5.0
        Cell.imgProvider.layer.cornerRadius=Cell.imgProvider.frame.size.width/2
        Cell.imgProvider.clipsToBounds=true
        Cell.imgProvider.layer.borderColor=themes.ThemeColour().cgColor*/
//        cell.imageView.tag = indexPath.row;
//        
//        //Sets up taprecognizer for each imageview
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
//            action:@selector(handleTap:)];
//        [cell.imageView addGestureRecognizer:tap];
//        
//        //Enable the image to be clicked
//        cell.imageView.isUserInteractionEnabled = YES;
        
        
    Cell.imgProvider.tag = indexPath.row
         Cell.imgProvider.isUserInteractionEnabled = true
        let tap :UITapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(ProviderListViewController.handleTap(_:)))
        Cell.imgProvider.addGestureRecognizer(tap)
       
        Cell.btnChat.addTarget(self, action: #selector(ProviderListViewController.PushtoMessageView(_:)), for: UIControlEvents.touchUpInside)
        Cell.btnChat.tag=indexPath.row
        
        Cell.btnOrderConfirm.addTarget(self, action: #selector(ProviderListViewController.OrderConfirm(_:)), for: UIControlEvents.touchUpInside)
        Cell.btnOrderConfirm.tag=indexPath.row
        Cell.backgroundColor = UIColor.clear
        
        return Cell
        
    }
    
    func  handleTap(_ recognizer:UITapGestureRecognizer)
    {
   // NSString *uid = testArray[recognizer.view.tag];
        
//        let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MYProfileVCSID") as! MyProfileViewController
//        secondViewController.providerid = Schedule_Data.ProviderListIdArray.objectAtIndex((recognizer.view?.tag)!) as! NSString
//        secondViewController.minCost = Schedule_Data.ProviderListMinamountArray.objectAtIndex((recognizer.view?.tag)!) as! NSString as String
//        secondViewController.hourlyCost = Schedule_Data.ProviderListHouramountArray.objectAtIndex((recognizer.view?.tag)!) as! NSString as String
//        self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)
//        
        
        let taskerpro:TaskerProfileViewController = TaskerProfileViewController(nibName:"TaskerProfileViewController", bundle: nil)
        taskerpro.providerid = Schedule_Data.ProviderListIdArray.object(at: (recognizer.view?.tag)!) as! String
        taskerpro.minCost = Schedule_Data.ProviderListMinamountArray.object(at: (recognizer.view?.tag)!) as! String
        taskerpro.hourlyCost = Schedule_Data.ProviderListHouramountArray.object(at: (recognizer.view?.tag)!) as! String
           taskerpro.hideView = "0"
        self.navigationController?.pushViewController(withFlip: taskerpro, animated: true)

        }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.provider_List.deselectRow(at: indexPath, animated:true)
    }

    @IBAction func btnBack(_ sender: AnyObject) {
         self.navigationController?.popViewControllerWithFlip(animated: true)
    }
    func PushtoMessageView(_ sender:UIButton)
    {
        
        
        Message_details.taskid = Schedule_Data.TaskID
        Message_details.providerid = Schedule_Data.ProviderListIdArray .object(at: sender.tag) as! String

        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageVC") as! MessageViewController
        
        self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)
    }
    
    
    
    func alertView(_ View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
            switch buttonIndex{
            case 0:
                bookOrder(View.tag)
                break;
            default:
                break;
                //Some code here..
                
            }
    }
    

    func bookOrder(_ tag:Int){
    self.showProgress()
    
    taskerid="\(ProviderListArray[tag])" as NSString
        let Splitaddress : NSArray = Home_Data.jobaddress.components(separatedBy:"$") as NSArray

        let param=["user_id":"\(themes.getUserID())",
            "location":Schedule_Data.scheduleAddressid,
            "taskerid":"\(taskerid)",
            "taskid":"\(Schedule_Data.TaskID)",
            "tasklat":"\( Schedule_Data.tasker_lat)",
            "tasklng":"\( Schedule_Data.tasker_lng)",
            "exactaddress":Home_Data.fulladdress,
            "zipcode" :Splitaddress.object(at:5),
            "country" :Splitaddress.object(at:4),
            "state":Splitaddress.object(at:3),
            "city":Splitaddress.object(at:2),
            "line1":Splitaddress.object(at:1),
            "line2":Splitaddress.object(at:0)] as [String : Any]
    URL_handler.makeCall(constant.Order_Confirm, param: param as NSDictionary) { (responseObject, error) -> () in
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
                    let response:NSDictionary=Dict.object(forKey: "response") as! NSDictionary
                    let jobID:NSString=response.object(forKey: "job_id") as! NSString
                    Schedule_Data.JobID="\(jobID)"
                    Schedule_Data.orderDate = response.object(forKey: "booking_date") as! String
                    Schedule_Data.service = response.object(forKey: "service_type") as! String
                    Schedule_Data.jobDescription = response.object(forKey: "description") as! String
                    let providerid : NSString =  self.taskerid
                    
                    var getproviderarray : NSMutableArray = NSMutableArray()
                    
                    getproviderarray = self.dbfileobj.arr("Provider_Table")
                    
                    if getproviderarray.count == 0
                    {
                        
                        let dict: NSMutableDictionary = NSMutableDictionary()
                        dict["providerid"] = providerid
                        
                        
                        self.dataArray = NSMutableArray()
                        self.dataArray.add(dict)
                        self.dbfileobj.saveData("Provider_Table", ValueStr: self.dataArray)
                        
                    }
                    else
                    {
                        let containdict: NSMutableDictionary = NSMutableDictionary()
                        containdict["providerid"] = providerid
                        
                        
                        
                        if getproviderarray.contains(containdict) {
                            
                            
                        }
                        else
                        {
                            
                            self.dbfileobj.UpdateData(providerid as String)
                            
                            
                            
                            
                        }
                    }
                    
                    self.performSegue(withIdentifier: "OrderConfirmVC", sender: nil)
                    
                    
                }
                else
                {
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    
                }
                
            }
            else
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
            }
        }
        
    }

}
    func OrderConfirm(_ sender:UIButton)
    {
 
        let AlertView:UIAlertView=UIAlertView()
        AlertView.delegate=self
        AlertView.title=themes.setLang("book_confirm")
        AlertView.addButton(withTitle: themes.setLang("confirm"))
        AlertView.addButton(withTitle: themes.setLang("cancel"))
        AlertView.show()
        AlertView.tag = sender.tag

        
        
    }
//    override func showProgress()
//    {
//        self.activityIndicatorView.color = themes.DarkRed()
//        self.activityIndicatorView.size = CGSize(width: 75, height: 100)
//        self.activityIndicatorView.center=CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height/2);
//        self.activityIndicatorView.startAnimating()
//        self.view.addSubview(activityIndicatorView)
//    }
//    override func DismissProgress()
//    {
//        self.activityIndicatorView.stopAnimating()
//        
//        self.activityIndicatorView.removeFromSuperview()
//        
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
