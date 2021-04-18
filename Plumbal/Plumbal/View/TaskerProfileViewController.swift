 //
//  TaskerProfileViewController.swift
//  Plumbal
//
//  Created by Casperon on 27/09/17.
//  Copyright © 2017 Casperon Tech. All rights reserved.
//

import UIKit
import DGElasticPullToRefresh

class TaskerProfileViewController: RootViewController,UITableViewDelegate,UITableViewDataSource,BookingViewDelegate,UIViewControllerTransitioningDelegate {
    var url_handler:URLhandler=URLhandler()
    
    @IBOutlet var additionalViewheight: NSLayoutConstraint!
    var availabilityDict : NSMutableArray = NSMutableArray()
    var AvailableDaysArray :NSMutableArray = NSMutableArray()
    var CategoryArray : NSMutableArray = NSMutableArray()
    var CategoryAmountArray : NSMutableArray = NSMutableArray()
     var ProfileContentArray:NSMutableArray = [];
      var reviewsArray:NSMutableArray = [];
    var nextPageStr:NSInteger!
    var providerid:String = ""
    var taskid : String = ""
    var minCost : String = ""
    var hourlyCost : String = ""
    var getlat : String = ""
    var getlng : String = ""
    var hideView : String = ""
    
    var fullAddress : String = String()
    
    
    @IBOutlet var book: UIButton!
    @IBOutlet var chat: UIButton!


    @IBOutlet var categorytable_height: NSLayoutConstraint!
    @IBOutlet var categorytable: UITableView!
    @IBOutlet var workingloctitle: UILabel!
    @IBOutlet var categtitle: UILabel!
    @IBOutlet var addtitle: UILabel!
    @IBOutlet var titlelbl: UILabel!
    @IBOutlet var reviewtableview: UITableView!
    @IBOutlet var segmentView: UIView!
    @IBOutlet var minview: UIView!
    @IBOutlet var taskerimg: UIImageView!
    @IBOutlet var taskername: UILabel!
    @IBOutlet var taskeremail: UILabel!
    @IBOutlet var taskermobile: UILabel!
    @IBOutlet var avgrating: UILabel!
    @IBOutlet var ratingview: SetColorView!
    @IBOutlet var radiusview: UIView!
    @IBOutlet var hourlyview: UIView!
    @IBOutlet var radiustitle: UILabel!
    @IBOutlet var hourlytitle: UILabel!
    @IBOutlet var mincosttitle: UILabel!
    @IBOutlet var mincost: UILabel!
    @IBOutlet var hourcost: UILabel!
    @IBOutlet var radius: UILabel!
    
    @IBOutlet var addresslabl: UILabel!
    
    @IBOutlet var workinglocation: UILabel!
    @IBOutlet var taskerscroll: UIScrollView!
    
    fileprivate var loading = false {
        didSet {
            
        }
    }
    var bottomBorder = CALayer()
    override func viewDidLoad() {
        super.viewDidLoad()
        chat.setTitle(themes.setLang("chat"), for: UIControlState())
        book.setTitle(themes.setLang("book"), for: UIControlState())

        
        if hideView == "0"
        {
            self.additionalViewheight.constant = 0
        }
        else{
            
        }
        titlelbl.text = "\(themes.setLang("tasker_pro"))"
        radiustitle.text = "\(themes.setLang("radius"))"
        hourlytitle.text = "\(themes.setLang("hour_cost"))"
        mincosttitle.text = "\(themes.setLang("min_cost"))"
        addtitle.text = "\(themes.setLang("addres"))"
        workingloctitle.text = "\(themes.setLang("working_loc"))"
        categtitle.text = "\(themes.setLang("Category"))"
        
        

        
    taskerscroll.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        taskerimg.layer.cornerRadius = taskerimg.frame.width/2;
        taskerimg.layer.masksToBounds = true;
        
        let segmentedControl1 = HMSegmentedControl(sectionTitles: ["\(themes.setLang("profiles"))", "\(themes.setLang("reviews"))"])
        segmentedControl1?.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]

        segmentedControl1?.frame = CGRect(x: 0, y:0, width: segmentView.frame.size.width, height: segmentView.frame.size.height)
        segmentedControl1?.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10)
        segmentedControl1?.selectionStyle = HMSegmentedControlSelectionStyle.fullWidthStripe
        segmentedControl1?.selectionIndicatorLocation = .down
        segmentedControl1?.selectionIndicatorColor = PlumberThemeColor
        segmentedControl1?.isVerticalDividerEnabled = true
        segmentedControl1?.verticalDividerColor = UIColor.white
        segmentedControl1?.verticalDividerWidth = 1.0
        segmentedControl1?.verticalDividerWidth = 1.0
        
        let titleDict: NSDictionary = [NSFontAttributeName: PlumberLargeFont!, NSForegroundColorAttributeName:UIColor.black]
        segmentedControl1?.titleTextAttributes = titleDict as! [AnyHashable: Any]
        let selectitleDict: NSDictionary = [NSFontAttributeName: PlumberLargeFont!, NSForegroundColorAttributeName:PlumberThemeColor]

        segmentedControl1?.selectedTitleTextAttributes = selectitleDict as! [AnyHashable: Any]
        
//        let titleFormatterBlock: HMTitleFormatterBlock = {(control: AnyObject!, title: String!, index: UInt, selected: Bool) -> NSAttributedString in
//            let attString = NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIColor.blackColor()
//                ])
//            return attString;
//        }
        segmentedControl1?.addTarget(self, action: #selector(TaskerProfileViewController.segmentedControlChangedValue(_:)), for: .valueChanged)


       // segmentedControl1.addTarget(self, action: #selector(self.segmentedControlChangedValue), for: .valueChanged)
        self.segmentView.addSubview(segmentedControl1!)
        radiusview.layer.cornerRadius = 27
        radiusview.layer.masksToBounds = true;
        hourlyview.layer.cornerRadius = 27;
        hourlyview.layer.masksToBounds = true;
        minview.layer.cornerRadius = 27;
        minview.layer.masksToBounds = true;
        ratingview.layer.cornerRadius = 15;
        ratingview.layer.masksToBounds = true;
      
        
        reviewtableview.register(UINib(nibName: "TaskerReviewCell", bundle: nil), forCellReuseIdentifier: "ReviewsTblIdentifier")
        reviewtableview.estimatedRowHeight = 120
        reviewtableview.rowHeight = UITableViewAutomaticDimension
        reviewtableview.tableFooterView = UIView()
        reviewtableview.delegate = self
        reviewtableview.dataSource = self
        
        categorytable.register(UINib(nibName: "TaskerdetailTableViewCell", bundle: nil), forCellReuseIdentifier: "taskercell")
        categorytable.estimatedRowHeight = 50
        categorytable.rowHeight = UITableViewAutomaticDimension
        categorytable.tableFooterView = UIView()
        categorytable.delegate = self
        categorytable.dataSource = self
        
        self.GetReviews()
        self.GetUserDetails()
        
     
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reviewtableview.isHidden=true
        nextPageStr=1
        if(ProfileContentArray.count>0){
            ProfileContentArray.removeAllObjects()
            self.availabilityDict.removeAllObjects()
            self.AvailableDaysArray.removeAllObjects()
            self.CategoryArray.removeAllObjects()
            self.CategoryAmountArray.removeAllObjects()
            self.reviewsArray.removeAllObjects()
        }
        
          }

    func segmentedControlChangedValue(_ segmentedControl: HMSegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0
        {
             self.reviewtableview.isHidden = true
                   }
        else{
            self.reviewtableview.isHidden = false
            if self.reviewsArray.count == 0  {
                themes.AlertView("\(Appname)", Message:themes.setLang("not_yet_reviews"), ButtonTitle: kOk)
            }

        }
        print("Selected index \(Int(segmentedControl.selectedSegmentIndex)) (via UIControlEventValueChanged)")
    }
    
    func uisegmentedControlChangedValue(_ segmentedControl: UISegmentedControl) {
        print("Selected index \(Int(segmentedControl.selectedSegmentIndex))")
    }


    @IBAction func didclickback(_ sender: AnyObject) {
        self.navigationController?.popViewControllerWithFlip(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
       func GetUserDetails(){
        self.showProgress()
        let Param: Dictionary = ["provider_id":"\(providerid)"]
        
        url_handler.makeCall(constant.viewProfile, param: Param as NSDictionary) {
            (responseObject, error) -> () in
            
            self.DismissProgress()
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
            }
            else
            {
                if(responseObject != nil && (responseObject?.count)!>0)
                {
                    let status=themes.CheckNullValue(responseObject?.object(forKey: "status"))!
                    
                    if(status == "1")
                    {
                        
                        
                        self.taskername.text=themes.CheckNullValue((responseObject?.object(forKey: "response") as AnyObject).object(forKey: "provider_name"))
                        
                        let Doublerat =  Double(themes.CheckNullValue((responseObject?.object(forKey: "response")! as AnyObject).object(forKey: "avg_review"))!)
                        let doubleStr = String(format: "%.1f", Doublerat!)
                        if doubleStr == "0.0"
                        {
                             self.avgrating.text = "0"
                        }
                        else{
                            self.avgrating.text = doubleStr

                        }
                       
                        
                        self.taskeremail.text = themes.CheckNullValue((responseObject?.object(forKey: "response")! as AnyObject).object(forKey: "email"))
                        
                        let code = themes.CheckNullValue((responseObject?.object(forKey: "response")! as AnyObject).object(forKey: "dial_code"))
                        let mob = themes.CheckNullValue((responseObject?.object(forKey: "response")! as AnyObject).object(forKey: "mobile_number"))
                        self.taskermobile.text = "\(code!) \(mob!)"
                        self.radius.text = themes.CheckNullValue((responseObject?.object(forKey: "response")! as AnyObject).object(forKey: "radius"))
                        self.hourcost.text = "\(themes.getCurrencyCode()) \(self.hourlyCost)"
                        self.mincost.text = "\(themes.getCurrencyCode()) \(self.minCost)"
                        
                        
                        
                        
               
                        self.addresslabl.numberOfLines = 0
                        self.addresslabl.sizeToFit()
                        self.workinglocation.numberOfLines=0
                        self.workinglocation.sizeToFit()
                      ///  self.category.numberOfLines=0
                       // self.category.sizeToFit()
                        
                        self.addresslabl.text = themes.CheckNullValue((responseObject?.object(forKey: "response")! as AnyObject).object(forKey: "address"))!
                        self.workinglocation.text = themes.CheckNullValue((responseObject?.object(forKey: "response")! as AnyObject).object(forKey: "Working_location"))!
                      //  self.category.text = themes.CheckNullValue(responseObject?.objectForKey("response")!.objectForKey("category"))!


                        
                        let Dict : NSDictionary = (responseObject?.object(forKey: "response"))! as! NSDictionary
                        self.taskerimg.sd_setImage(with: URL(string:(Dict.object(forKey: "image")as! NSString as String)), placeholderImage: UIImage(named: "PlaceHolderSmall"))
                        
                        if(((responseObject?.object(forKey: "response") as AnyObject).object(forKey: "category_Details")! as AnyObject).count>0){
                            let cat_array : NSArray = (responseObject?.object(forKey: "response") as AnyObject).object(forKey: "category_Details") as! NSArray
                            
                            
                            for (_,element) in cat_array.enumerated()
                            {
                                self.CategoryArray.add(themes.CheckNullValue((element as AnyObject).object(forKey: "categoryname"))!)
                                self.CategoryAmountArray.add(themes.CheckNullValue((element as AnyObject).object(forKey: "hourlyrate"))!)
                                
                            }
                        }
                        self.categorytable_height.constant = CGFloat (self.CategoryArray.count * 50 + 5)
                        
                        self.categorytable.reload()
                        
                        if(((responseObject?.object(forKey: "response") as AnyObject).object(forKey: "details")! as AnyObject).count>0){
                            let  listArr:NSArray=(responseObject?.object(forKey: "response") as AnyObject).object(forKey: "details") as! NSArray
                            
                            self.availabilityDict = (responseObject?.object(forKey: "response") as AnyObject).object(forKey: "availability_days") as! NSMutableArray
                            for (_, element) in listArr.enumerated() {
                                
                                
                                
                                if themes.CheckNullValue((element as AnyObject).object(forKey: "desc"))! == ""
                                {
                                    
                                    print("remove bio field")
                                }
                                else{
                                    if themes.CheckNullValue((element as AnyObject).object(forKey: "title"))! == "Email" || themes.CheckNullValue((element as AnyObject).object(forKey: "title"))! == "Mobile" ||  themes.CheckNullValue((element as AnyObject).object(forKey: "title"))! == "Bio" || themes.CheckNullValue((element as AnyObject).object(forKey: "title"))! == "Experience" || themes.CheckNullValue((element as AnyObject).object(forKey: "title"))! == "Radius"
                                    {
                                        
                                    }
                                    else{
                                        let result1 = themes.CheckNullValue((element as AnyObject).object(forKey: "desc"))!.replacingOccurrences(of: "\n", with:",")
                                    
                                    let rec = ProfileContentRecord(userTitle: themes.CheckNullValue((element as AnyObject).object(forKey: "title"))!, desc: result1)
                                    
                                  
                                    self.ProfileContentArray .add(rec)
                                    }
                                    
                                    
                                }
                                
                            }
                            
                           
                            
                            let record  = AvailableRecord (dayrec: themes.setLang("days")
                                ,mornigrec:themes.setLang("morning")
                                ,Afterrec:themes.setLang("afternoon")
                                ,eveningrec:themes.setLang("evening"))
                            self.AvailableDaysArray.add(record)
                            
                            
                            for (_, element) in self.availabilityDict.enumerated() {
                                let result1 = themes.CheckNullValue((element as AnyObject).object(forKey: "day"))!
                                
                                let avaialbletime  : String = themes.CheckNullValue((((element as AnyObject).object(forKey: "hour"))! as AnyObject).object(forKey: "morning"))!
                                let avaialbleAftertime  : String =  themes.CheckNullValue((((element as AnyObject).object(forKey: "hour"))! as AnyObject).object(forKey: "afternoon"))!
                                let avaialbleevetime  : String = themes.CheckNullValue((((element as AnyObject).object(forKey: "hour"))! as AnyObject).object(forKey: "evening"))!
                                let record  = AvailableRecord (dayrec: result1,mornigrec: avaialbletime ,Afterrec: avaialbleAftertime,eveningrec: avaialbleevetime)
                                self.AvailableDaysArray.add(record)
                                
                                
                                
                            }
                            print(self.AvailableDaysArray.count)
//                            self.tbl_Height.constant = CGFloat(self.AvailableDaysArray.count*56)

                        }else{
                            //self.view.makeToast(message:kErrorMsg, duration: 3, position: HRToastPositionCenter, title: appNameJJ)
                        }
                        
                        
                        
                        
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
    
    
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if(tableView==reviewtableview){
            return reviewsArray.count
        }
        else if tableView == categorytable
       {
         return CategoryArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->     UITableViewCell {
        
        var cell3:UITableViewCell = UITableViewCell()
        
        if tableView == reviewtableview

        {
                  let cell:TaskerReviewCell = tableView.dequeueReusableCell(withIdentifier: "ReviewsTblIdentifier") as! TaskerReviewCell
            
            if (reviewsArray.count > 0)
            {
                cell.loadReviewTableCell((reviewsArray .object(at: indexPath.row) as! ReviewRecords), currentView:MyProfileViewController() as UIViewController)
                
            }
            cell.selectionStyle=UITableViewCellSelectionStyle.none
            cell3=cell
        
        }
        else{
            
            let cell:TaskerdetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "taskercell") as! TaskerdetailTableViewCell
            
              cell.categorylabl.text = self.CategoryArray.object(at: indexPath.row) as? String
            cell.cat_amount.text = "\(themes.getCurrencyCode())\(self.CategoryAmountArray.object(at: indexPath.row))/hr"
            cell.cat_amount.layer.borderWidth = 1.0
            cell.cat_amount.layer.borderColor = UIColor.init(red:40.0/255.0, green: 186.0/255.0, blue: 225.0/255.0, alpha: 1.0).cgColor
            
            cell.selectionStyle=UITableViewCellSelectionStyle.none
            cell3=cell

        }
        

        
        return cell3
           }
    
    


    func GetReviews(){
     
     
     
      let Param: Dictionary = ["provider_id":"\(providerid)",
       
          "page":"\(nextPageStr)" as String,
          "perPage":kPageCount]
     
      url_handler.makeCall(constant.reviewsUrl, param: Param as NSDictionary) {
          (responseObject, error) -> () in
         
          self.DismissProgress()
         
         
          self.reviewtableview.dg_stopLoading()
          self.loading = false
          if(error != nil)
          {
              self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault as AnyObject, title: Appname)
          }
          else
          {
              if(responseObject != nil && (responseObject?.count)!>0)
              {
                  let responseObject = responseObject!
               
                  let status=themes.CheckNullValue(responseObject.object(forKey: "status") as? NSString)! as NSString
                 
                  if(status == "1")
                  {
                        let Dict:NSDictionary=responseObject.object(forKey: "response") as! NSDictionary
                      if((Dict.object(forKey: "rated_users") as AnyObject).count>0){
                          let  listArr:NSArray=Dict.object(forKey: "rated_users") as! NSArray
                          if(self.nextPageStr==1){
                              self.reviewsArray.removeAllObjects()
                          }
                          for (_, element) in listArr.enumerated() {
                              let rec = ReviewRecords(name: themes.CheckNullValue((element as AnyObject).object(forKey: "user_name") as AnyObject)!, time: themes.CheckNullValue((element as AnyObject).object(forKey: "rating_time") as AnyObject)!, desc: themes.CheckNullValue((element as AnyObject).object(forKey: "comments") as AnyObject)!, rate:themes.CheckNullValue((element as AnyObject).object(forKey: "ratings") as AnyObject)!, img: themes.CheckNullValue((element as AnyObject).object(forKey: "user_image") as AnyObject)!,ratting:themes.CheckNullValue((element as AnyObject).object(forKey: "ratting_image") as AnyObject)!,jobid :themes.CheckNullValue((element as AnyObject).object(forKey: "job_id") as AnyObject)!)
                             
                              self.reviewsArray.add(rec)
                          }
                         
                          self.reviewtableview.reload()
                          self.nextPageStr=self.nextPageStr+1
                      }else{
                          if(self.nextPageStr>1){
                              self.view.makeToast(message:themes.setLang("no_leads"), duration: 3, position: HRToastPositionDefault as AnyObject, title:"\(Appname)")
                          }
                      }
                  }
                  else
                  {
                     
                      //  themes.AlertView("\(Appname)", Message:"\(themes.CheckNullValue("\(Dict.objectForKey("response"))")!)", ButtonTitle:kOk)
                  }
              }
              else
              {
                  self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault as AnyObject, title: Appname)
              }
          }
         
      }
  }
    
    let loadingView = DGElasticPullToRefreshLoadingViewCircle()
    func refreshNewLeads(){
        
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        reviewtableview.dg_addPullToRefreshWithActionHandler({
            self.nextPageStr=1
            self.GetReviews()
            
            }, loadingView: loadingView)
        reviewtableview.dg_setPullToRefreshFillColor(PlumberLightGrayColor)
        reviewtableview.dg_setPullToRefreshBackgroundColor(reviewtableview.backgroundColor!)
    }
    @IBAction func didclickChat(_ sender: AnyObject) {
        
        
        let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController (withIdentifier: "MessageVC") as? MessageViewController
        Message_details.taskid = taskid
        Message_details.providerid = providerid
       // let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MessageVC") as! MessageViewController
        self.navigationController!.pushViewController(withFlip: chatVC!, animated: true)
        
    }
    
    @IBAction func didclickBook(_ sender: AnyObject) {
           self.displayViewController(.bottomBottom)
        
    }
    
    func displayViewController(_ animationType: SLpopupViewAnimationType) {
        let book:BookingView = BookingView(nibName:"BookingView", bundle: nil)
        book.delegate = self
      
        book.taskernamestr = self.taskername.text!
      
        book.transitioningDelegate = self
        book.modalPresentationStyle = .custom;
        
        self.navigationController?.present(book, animated: true, completion: nil)
    }

    
    func pressedCancel(_ sender: BookingView) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func pressBooking(_ confimDate: NSString, Confirmtime: NSString, Instructionstr: NSString) {
        
        
        var getinst = String()
        
        getinst = Instructionstr as String
        if getinst == "\(themes.setLang("enter_instruc"))"
        {
            themes.AlertView("\(Appname)", Message:"\(themes.setLang("enter_instruc"))", ButtonTitle: kOk)
        }
        else{
            self.dismiss(animated: true, completion: nil)
            self.showProgress()
         
            
            var  param = NSDictionary()
          
                
            
                let fullAddressstr = getAddressForLatLng(getlat, longitude: getlng)
            
            let getaddress = fullAddressstr.replacingOccurrences(of: "$", with:" ")
                let tempAddArray = fullAddressstr.components(separatedBy: "$")
            
                param = ["user_id":"\(themes.getUserID())",
                         "street":"\(tempAddArray[0])",
                         "city":"\(tempAddArray[2])",
                         "state":"\(tempAddArray[3])",
                         "country":"\(tempAddArray[4])",
                         "zipcode":"\(tempAddArray[5])",
                         "lng":"\(getlng)",
                         "lat":"\(getlat)",
                         "locality":"\(getaddress)",
                         "taskerid":"\(providerid)",
                         "taskid":"\(taskid)",
                         "instruction" :"\(getinst)",
                         "pickup_date":"\(confimDate)",
                         "pickup_time":"\(Confirmtime)"]
            
            
            url_handler.makeCall(constant.MapOrder_confirm, param: param) { (responseObject, error) -> () in
                self.DismissProgress()
                if(error != nil){
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                } else{
                    
                    
                    if(responseObject != nil){
                        let Dict:NSDictionary=responseObject!
                        let Status=themes.CheckNullValue(Dict.object(forKey: "status"))!
                        if(Status == "1"){
                            let response:NSDictionary=Dict.object(forKey: "response") as! NSDictionary
                            let jobID=response.object(forKey: "job_id") as! String
                            Schedule_Data.JobID="\(jobID)"
                            Schedule_Data.orderDate = response.object(forKey: "booking_date") as! String
                            Schedule_Data.service = response.object(forKey: "service_type") as! String
                            Schedule_Data.jobDescription = response.object(forKey: "description") as! String
                            
                            let secondViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController (withIdentifier: "ConfirmPageVCID") as? OrderConfirmationViewController
                            self.navigationController?.pushViewController(withFlip: secondViewController!, animated: true)
                            
                        }
                        else {
                            
                            let Response = themes.CheckNullValue(Dict.object(forKey: "response"))!
                            themes.AlertView("\(Appname)", Message: Response, ButtonTitle: themes.setLang("ok"))
                        }
                    }
                    else {
                        themes.AlertView("\(Appname)", Message: themes.setLang("No Reasons available"), ButtonTitle: themes.setLang("ok"))
                    }
                }
            }
        }
    }
    
    func getAddressForLatLng(_ latitude: String, longitude: String)->String {
        let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=\(constant.GooglemapAPI)&language=\(themes.getAppLanguage())")
        let data = try? Data(contentsOf: url!)
        if data != nil{
            let json = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            if let result = json["results"] as? NSArray {
                if(result.count != 0){
                    var result1 = NSArray()
                  
                        if let address = (result[0] as AnyObject)["address_components"] as? NSArray{
                            result1 = address
                        }
                        
                   
                    if result1.count != 0 {
                        
                        
                        var street : String = ""
                        var sublocality : String = ""
                        var city : String = ""
                        var state : String = ""
                        var country : String = ""
                        var zipcode : String = ""
                        
                        let streetNameStr : NSMutableString = NSMutableString()
                        
                        for item in result1{
                            let item1 = (item as AnyObject)["types"] as! NSArray
                            
                            if((item1.object(at: 0) as! String == "street_number") || (item1.object(at: 0) as! String == "premise") || (item1.object(at: 0) as! String == "route")) {
                                let number1 = (item as AnyObject)["long_name"] as! String
                                streetNameStr.append(number1)
                                street = streetNameStr  as String
                                
                            }
                            else if (item1.object(at: 0) as! String == "political" || item1.object(at: 0) as! String == "sublocality" || item1.object(at: 0) as! String == "sublocality_level_1")
                            {
                                let city1 = (item as AnyObject)["long_name"]
                                sublocality = city1 as! String
                            }else if(item1.object(at: 0) as! String == "locality"){
                                let city1 = (item as AnyObject)["long_name"]
                                city = city1 as! String
                            }else if(item1.object(at: 0) as! String == "administrative_area_level_1" || item1.object(at: 0) as! String == "political") {
                                let city1 = (item as AnyObject)["long_name"]
                                state = city1 as! String
                            }else if(item1.object(at: 0) as! String == "country")  {
                                let city1 = (item as AnyObject)["long_name"]
                                country = city1 as! String
                            }else if(item1.object(at: 0) as! String == "postal_code" ) {
                                let city1 = (item as AnyObject)["long_name"]
                                zipcode = city1 as! String
                            }
                        }
                        
                        fullAddress = "\(street)$\(sublocality)$\(city)$\(state)$\(country)$\(zipcode)"
                        
                        return fullAddress
                        
                        
                    }
                }
            }
        }
        return ""
        
          }

    

    
    func refreshNewLeadsandLoad(){
        if (!loading) {
            loading = true
            GetReviews()
        }
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
