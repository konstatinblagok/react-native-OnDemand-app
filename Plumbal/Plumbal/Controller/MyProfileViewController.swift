//
//  MyProfileViewController.swift
//  PlumberJJ
//
//  Created by Casperon Technologies on 11/6/15.
//  Copyright © 2015 Casperon Technologies. All rights reserved.
//

import UIKit
import DGElasticPullToRefresh

let IMAGE_HEIGHT = 273
class MyProfileViewController: RootViewController,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,SMSegmentViewDelegate,UITextViewDelegate {
    var url_handler:URLhandler=URLhandler()
 //   var theme:Theme=Theme()
    var availabilityDict : NSMutableArray = NSMutableArray()
    var AvailableDaysArray :NSMutableArray = NSMutableArray()
    var nextPageStr:NSInteger!
    var segmentView: SMSegmentView!
    
    @IBOutlet var segment: CustomSegmentControl!
      var getCatagoryArr : NSArray = NSArray()
    var providerid:NSString!
    var minCost : String!
    var hourlyCost : String!

    @IBOutlet var backbtn: UIButton!
    @IBOutlet var availabletable: UITableView!
    @IBOutlet weak var topView: SetColorView!
    @IBOutlet weak var segmentContainerView: UIView!
    @IBOutlet weak var bannerImg: UIImageView!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var reviewsView: UIView!
    @IBOutlet weak var totalContainer: UIView!
    @IBOutlet weak var profileScrollView: UIScrollView!
    @IBOutlet weak var reviewsTblView: UITableView!
    @IBOutlet weak var userInfoTopView: UIView!
    @IBOutlet weak var myProfileTblView: UITableView!
    @IBOutlet weak var userCatLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    var ProfileContentArray:NSMutableArray = [];
    var reviewsArray:NSMutableArray = [];
    var catagoryarrcount : NSMutableArray = [];
    @IBOutlet weak var lblMyProfile: UILabel!
    @IBOutlet var lblMail: UILabel!

    @IBOutlet var lblMi9n: UILabel!
    @IBOutlet var lblHourly: UILabel!
    @IBOutlet var lblRadius: UILabel!
    @IBOutlet var lblMobile: UILabel!
    @IBOutlet var ratingCount: UILabel!
    @IBOutlet var lblMi9n1: UILabel!
    @IBOutlet var lblHourly1: UILabel!
    @IBOutlet var lblRadius1: UILabel!

    @IBAction func didclickoption(_ sender: AnyObject) {
         self.navigationController?.popViewControllerWithFlip(animated: true)
    }
    @IBOutlet weak var profileTopView: UIView!
    fileprivate var loading = false {
        didSet {
           
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        backbtn.addSubview(themes.Back_ImageView)
        lblMyProfile.text = themes.setLang("my_profile")

        segment.setTitle(themes.setLang("detail"), forSegmentAt: 0)
        segment.setTitle(themes.setLang("availability"), forSegmentAt: 1)
        segment.selectedSegmentIndex=0
        segment.tintColor=themes.ThemeColour()
        segment.isHidden = true
        
        lblMi9n1.text = themes.setLang("min_cost")
        
        lblMi9n1.adjustsFontSizeToFitWidth = true
        lblHourly1.text = themes.setLang("hourly_rate1")
        lblRadius1.text = themes.setLang("radius")

        
        
        segment.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 14.0)!, NSForegroundColorAttributeName: PlumberThemeColor], for: UIControlState())
              myProfileTblView.register(UINib(nibName: "ProfileDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileDetailTableIdentifier")
        myProfileTblView.estimatedRowHeight = 100
        myProfileTblView.rowHeight = UITableViewAutomaticDimension
        
        availabletable.register(UINib(nibName:"AvailableDaysTableCell", bundle: nil), forCellReuseIdentifier: "availabledayscell")
        availabletable.estimatedRowHeight = 20
        availabletable.rowHeight = UITableViewAutomaticDimension

        availabletable.isHidden = false

       // barButton.addTarget(self, action: #selector(MyProfileViewController.openmenu), forControlEvents: .TouchUpInside)
        reviewsTblView.register(UINib(nibName: "ReviewsTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewsTblIdentifier")
        reviewsTblView.estimatedRowHeight = 120
        reviewsTblView.rowHeight = UITableViewAutomaticDimension
        myProfileTblView.tableFooterView = UIView()
        availabletable.tableFooterView = UIView()
        reviewsTblView.tableFooterView = UIView()
        blurBannerImg()
        loadSegmentControl()
        
    }
       override func viewWillAppear(_ animated: Bool) {
        reviewsTblView.isHidden=true
        nextPageStr=1
        if(ProfileContentArray.count>0){
            ProfileContentArray.removeAllObjects()
            self.availabilityDict.removeAllObjects()
            self.AvailableDaysArray.removeAllObjects()
            self.reviewsArray.removeAllObjects()
            self.catagoryarrcount.removeAllObjects()
        }
  
        refreshNewLeads()
        showProgress()
        loadProfileTblView()
        GetReviews()
        GetUserDetails()
    }
    func loadProfileTblView(){
        self.profileScrollView.frame=CGRect(x: self.profileScrollView.frame.origin.x, y: self.profileScrollView.frame.origin.y, width: self.profileScrollView.frame.size.width, height: self.profileScrollView.frame.size.height);
        self.myProfileTblView.frame = CGRect(x: self.myProfileTblView.frame.origin.x, y: self.segment.frame.origin.y+self.segment.frame.size.height, width: self.myProfileTblView.frame.size.width,height: self.myProfileTblView.contentSize.height)
        self.availabletable.frame = CGRect(x: self.availabletable.frame.origin.x, y: self.segment.frame.origin.y+self.segment.frame.size.height, width: self.availabletable.frame.size.width, height: CGFloat(AvailableDaysArray.count*56))
        self.profileScrollView.contentSize=CGSize( width: self.profileScrollView.frame.width,height: self.myProfileTblView.frame.origin.y + self.myProfileTblView.frame.size.height+25)
        self.myProfileTblView.isHidden = false
        self.availabletable.isHidden = true
        print(self.profileScrollView.frame);
        print(self.myProfileTblView.frame);
        print(self.availabletable.frame);
        print(self.profileScrollView.contentSize);
    }
    
    func blurBannerImg(){
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            bannerImg.backgroundColor = UIColor.clear
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = bannerImg.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            bannerImg.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            bannerImg.backgroundColor = UIColor.black
        }
        userImg.layer.cornerRadius=userImg.frame.size.width/2
        userImg.layer.masksToBounds=true
    }
    
    func loadSegmentControl(){
        self.segmentView = SMSegmentView(frame: CGRect(x: 0, y: 0, width: segmentContainerView.frame.size.width, height: segmentContainerView.frame.size.height), separatorColour: UIColor(white: 0.95, alpha: 0.3), separatorWidth: 0.5, segmentProperties: [keySegmentTitleFont: UIFont.boldSystemFont(ofSize: 15.0), keySegmentOnSelectionColour: PlumberThemeColor,keySegmentOffSelectionTextColour:UIColor.darkGray, keySegmentOffSelectionColour: UIColor.white, keyContentVerticalMargin: Float(10.0) as AnyObject])
        self.segmentView.delegate = self
        self.segmentView.layer.cornerRadius = 0.0
        self.segmentView.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        self.segmentView.layer.borderWidth = 1.0
        // Add segments
        self.segmentView.addSegmentWithTitle(themes.setLang("profiles")
            , onSelectionImage: UIImage(named: "MyProfileSelect"), offSelectionImage: UIImage(named: "MyProfileUnSelect"))
        self.segmentView.addSegmentWithTitle(themes.setLang("reviews")
            , onSelectionImage: UIImage(named: "ReviewsSelect"), offSelectionImage: UIImage(named: "ReviewsUnSelect"))
        //segmentView.selectSegmentAtIndex(0)
        self.segmentView.selectSegmentAtIndex(0)
        segmentContainerView.addSubview(self.segmentView)
    }

    func segmentView(_ segmentView: SMSegmentView, didSelectSegmentAtIndex index: Int) {
        switch (index){
        case 0:
            swapViews(false)
            break
        case 1:
            swapViews(true)
            break
        default:
            break
        }
    }
    
    func swapViews(_ isReviews:Bool){
        let transition = CATransition()
        transition.type = "fade";
        transition.duration = 0.4;
        transition.repeatCount = 1;
        self.totalContainer.layer.add(transition, forKey: " ")
        if(isReviews==true){
            profileView.isHidden=true
            reviewsView.isHidden=false
            if self.reviewsArray.count == 0  {
                themes.AlertView("\(Appname)", Message:themes.setLang("not_yet_reviews"), ButtonTitle: kOk)
            }
        }else{
            profileView.isHidden=false
            reviewsView.isHidden=true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView==profileScrollView){
            let offset: CGFloat = scrollView.contentOffset.y
            let percentage: CGFloat = (offset / CGFloat(IMAGE_HEIGHT))
            let value: CGFloat = CGFloat(IMAGE_HEIGHT) * percentage
            bannerImg.frame = CGRect(x: 0, y: value, width: bannerImg.bounds.size.width, height: CGFloat(IMAGE_HEIGHT) - value)
            let alphaValue: CGFloat = 1 - fabs(percentage)
            userInfoTopView.alpha = alphaValue * alphaValue * alphaValue
        }
    }
    
    @IBAction func didClickEditProfile(_ sender: AnyObject) {
        let objEditProfVc = self.storyboard!.instantiateViewController(withIdentifier: "EditProfileVCSID") as! EditProfileViewController
        self.navigationController!.pushViewController(withFlip: objEditProfVc, animated: true)
    }
    @IBAction func didClickBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewControllerWithFlip(animated: true)
    }
   
    @IBAction func didClickSegment(_ sender: AnyObject) {
        let segmentIndex:NSInteger = sender.selectedSegmentIndex;
        
        if(segmentIndex == 0)
        {
            self.availabletable.isHidden=true
            self.myProfileTblView.isHidden=false
        }
        if(segmentIndex == 1)
        {
            
            self.availabletable.isHidden=false
            self.myProfileTblView.isHidden=true
            
        }
    }

      func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {   let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 20))

        if tableView .isEqual(availabletable)
        {
           
            let headerlable : UILabel = UILabel.init(frame:CGRect(x: headerView.frame.origin.x+10,y: 10,width: headerView.frame.size.width-10,height: 25))
            
            if (AvailableDaysArray.count > 0)
            {
                headerlable.text = themes.setLang("available_days")
            }
            headerlable.textColor = UIColor(red: 255/255.0, green: 70/255.0, blue: 63/255.0, alpha: 1)
            headerlable.font = UIFont.init(name: "Roboto-Regular", size:14.0)
        
            headerView.addSubview(headerlable)
    
        return headerView
        }
        else
        {
            return headerView
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView==myProfileTblView){
            
                  return ProfileContentArray.count
        }else if(tableView==reviewsTblView){
             return reviewsArray.count
        }
        else if (tableView ==  availabletable)
        {
            
            return AvailableDaysArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->     UITableViewCell {

        let cell3:UITableViewCell
        
        if(tableView==myProfileTblView){
            
           
                
            
            let cell1:ProfileDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ProfileDetailTableIdentifier") as! ProfileDetailTableViewCell
            if ProfileContentArray.count > 0
            {
            cell1.loadProfileTableCell(ProfileContentArray .object(at: indexPath.row) as! ProfileContentRecord)
            }
            cell1.selectionStyle=UITableViewCellSelectionStyle.none
            cell3=cell1
            
        }
            else if (tableView == availabletable)
        {
           let avialCell:AvailableDaysTableCell = tableView.dequeueReusableCell(withIdentifier: "availabledayscell") as! AvailableDaysTableCell
            
            if indexPath.row == 0
            {
             avialCell.Morning.isHidden = false
                 avialCell.afternoon.isHidden = false
                 avialCell.Evning.isHidden = false
                avialCell.mrnbtn.isHidden = true
                avialCell.afternbtn.isHidden = true
                avialCell.evebtn.isHidden = true
            }
            else
            {
                avialCell.Morning.isHidden = true
                avialCell.afternoon.isHidden = true
                avialCell.Evning.isHidden = true
                avialCell.mrnbtn.isHidden = false
                avialCell.afternbtn.isHidden = false
                avialCell.evebtn.isHidden = false
            }
            
            
            if AvailableDaysArray.count > 0
            {
        avialCell.loadProfileTableCell(self.AvailableDaysArray .object(at: indexPath.row) as! AvailableRecord)
            
            }
           avialCell.selectionStyle=UITableViewCellSelectionStyle.none
           
            cell3=avialCell
        

        }
        else{
            let cell:ReviewsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ReviewsTblIdentifier") as! ReviewsTableViewCell
            
            if (reviewsArray.count > 0)
            {
                cell.loadReviewTableCell((reviewsArray .object(at: indexPath.row) as! ReviewRecords), currentView:MyProfileViewController() as UIViewController)

            }
            cell.selectionStyle=UITableViewCellSelectionStyle.none
           cell3=cell
        }
       
        return cell3
    }
   
   

    func GetUserDetails(){
     
      //  let objUserRecs:UserInfoRecord=theme.GetUserDetails()
        let Param: Dictionary = ["provider_id":"\(providerid)"]
        // print(Param)
        
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
                        
                     
                            self.ProfileContentArray.removeAllObjects()
                            self.availabilityDict.removeAllObjects()
                            self.AvailableDaysArray.removeAllObjects()
                        self.catagoryarrcount.removeAllObjects()
                        
                        self.profileTopView.isHidden=false
                        self.userNameLbl.text=themes.CheckNullValue((responseObject?.object(forKey: "response") as AnyObject).object(forKey: "provider_name"))
                        
                        self.ratingCount.text = themes.CheckNullValue((responseObject?.object(forKey: "response") as AnyObject).object(forKey: "avg_review"))
                        self.lblMail.text = themes.CheckNullValue((responseObject?.object(forKey: "response") as AnyObject).object(forKey: "email"))
                        
                        let code = themes.CheckNullValue((responseObject?.object(forKey: "response") as AnyObject).object(forKey: "dial_code"))
                        let mob = themes.CheckNullValue((responseObject?.object(forKey: "response") as AnyObject).object(forKey: "mobile_number"))
                        self.lblMobile.text = "\(code!) \(mob!)"
                        self.lblRadius.text = themes.CheckNullValue((responseObject?.object(forKey: "response") as AnyObject).object(forKey: "radius"))
                        self.lblHourly.text = "\(themes.getCurrencyCode()) \(self.hourlyCost)"
                        self.lblMi9n.text = "\(themes.getCurrencyCode()) \(self.minCost)"

                        
                        let Dict : NSDictionary = (responseObject?.object(forKey: "response"))! as! NSDictionary
                         self.userImg.sd_setImage(with: URL(string:(Dict.object(forKey: "image")as! NSString as String)), placeholderImage: UIImage(named: "PlaceHolderSmall"))
                        
                      //  self.theme.saveUserImage(self.theme.CheckNullValue(Dict.objectForKey("image")!)!)

                      
                        self.bannerImg.sd_setImage(with: URL(string:((responseObject?.object(forKey: "response") as AnyObject).object(forKey: "image"))as! String), placeholderImage: UIImage(named: "PlaceHolderBig"))
                        
                        if(((responseObject?.object(forKey: "response") as AnyObject).object(forKey: "details")! as AnyObject).count>0){
                            let  listArr:NSArray=(responseObject?.object(forKey: "response") as AnyObject).object(forKey: "details") as! NSArray
                            
                            self.availabilityDict = (responseObject?.object(forKey: "response") as AnyObject).object(forKey: "availability_days") as! NSMutableArray
                            for (_, element) in listArr.enumerated() {
                                
                                
                                
                                if themes.CheckNullValue((element as AnyObject).object(forKey: "desc"))! == ""
                                {
                                    
                                    print("remove bio field")
                                }
                                else{
                                    
                                    let result1 = themes.CheckNullValue((element as AnyObject).object(forKey: "desc"))!.replacingOccurrences(of: "\n", with:",")
                                    
                                    let rec = ProfileContentRecord(userTitle: themes.CheckNullValue((element as AnyObject).object(forKey: "title"))!, desc: result1)
                                    
                                    
                                    if themes.CheckNullValue((element as AnyObject).object(forKey: "title"))! == "Category"
                                    {
                                        
                                        self.getCatagoryArr = result1.components(separatedBy: ",") as NSArray
                                        
                                    }
                                    
                                    
                                    //
                                    //
                                    
                                    print("category array count \(self.getCatagoryArr.count)")
                                    self.ProfileContentArray .add(rec)
                                    
                                    
                                }
                                
                            }
                           
                            
                            
                            
                            let record  = AvailableRecord (dayrec: themes.setLang("days")
                                ,mornigrec:themes.setLang("morning")
                                ,Afterrec:themes.setLang("afternoon")
                                ,eveningrec:themes.setLang("evening"))
                            self.AvailableDaysArray.add(record)

                            
                            for (_, element) in self.availabilityDict.enumerated() {
                                let result1 = themes.CheckNullValue((element as AnyObject).object(forKey: "day"))!
                                
let avaialbletime  : String = themes.CheckNullValue(((element as AnyObject).object(forKey: "hour") as AnyObject).object(forKey: "morning"))!
let avaialbleAftertime  : String =  themes.CheckNullValue(((element as AnyObject).object(forKey: "hour") as AnyObject).object(forKey: "afternoon"))!
let avaialbleevetime  : String = themes.CheckNullValue(((element as AnyObject).object(forKey: "hour") as AnyObject).object(forKey: "evening"))!
      let record  = AvailableRecord (dayrec: result1,mornigrec: avaialbletime ,Afterrec: avaialbleAftertime,eveningrec: avaialbleevetime)
        self.AvailableDaysArray.add(record)
                               
                                
                                
                                                           }
                            
                           
                           
                        }else{
                            //self.view.makeToast(message:kErrorMsg, duration: 3, position: HRToastPositionCenter, title: appNameJJ)
                        }
                        
                      
                         self.myProfileTblView.reload()
                        self.availabletable.reload()
                        
                        self.segment.isHidden=false
                        
                        self.loadProfileTblView()

                        
                       
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
    
    func GetReviews(){
        
        
        let Param: Dictionary = ["user_id":"\(providerid)",
                                 "role":"tasker",
                                 "page":"\(nextPageStr)" as String,
                                 "perPage":kPageCount]
        // print(Param)
        
        url_handler.makeCall(constant.GetUserreviews, param: Param as NSDictionary) {
            (responseObject, error) -> () in
            
            self.DismissProgress()
            
            self.reviewsTblView.isHidden=false
            self.reviewsTblView.dg_stopLoading()
            self.loading = false
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
            }
            else
            {
                if(responseObject != nil && (responseObject?.count)!>0)
                {
                    let Dict:NSDictionary=responseObject!.object(forKey: "data") as! NSDictionary
                    let status=themes.CheckNullValue(Dict.object(forKey: "status"))!
                    
                    if(status == "1")
                    {
                        if(((Dict.object(forKey: "response") as AnyObject).object(forKey: "reviews")! as AnyObject).count>0){
                            let  listArr:NSArray=(Dict.object(forKey: "response") as AnyObject).object(forKey: "reviews") as! NSArray
                            if(self.nextPageStr==1){
                                self.reviewsArray.removeAllObjects()
                            }
                            for (_, element) in listArr.enumerated() {
                                let rec = ReviewRecords(name: themes.CheckNullValue((element as AnyObject).object(forKey: "user_name"))!, time: themes.CheckNullValue((element as AnyObject).object(forKey: "date"))!, desc: themes.CheckNullValue((element as AnyObject).object(forKey: "comments"))!, rate:themes.CheckNullValue((element as AnyObject).object(forKey: "rating"))!, img: themes.CheckNullValue((element as AnyObject).object(forKey: "user_image"))!,ratting:themes.CheckNullValue((element as AnyObject).object(forKey: "image"))!,jobid :themes.CheckNullValue((element as AnyObject).object(forKey: "booking_id"))!)
                                
                                self.reviewsArray.add(rec)
                            }
                            self.reviewsTblView.reload()
                            self.nextPageStr=self.nextPageStr+1
                        }else{
                            if(self.nextPageStr>1){
                                self.view.makeToast(message:themes.setLang("no_leads"), duration: 3, position: HRToastPositionDefault, title:"\(Appname)")
                            }
                        }
                    }
                    else
                    {
                        //                        self.view.makeToast(message:kErrorMsg, duration: 5, position: HRToastPositionDefault, title: "Network Failure !!!")
                    }
                }
                else
                {
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                }
            }
            
        }
    }
    let loadingView = DGElasticPullToRefreshLoadingViewCircle()
    func refreshNewLeads(){
        
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        reviewsTblView.dg_addPullToRefreshWithActionHandler({
            self.nextPageStr=1
            self.GetReviews()
            
            }, loadingView: loadingView)
        reviewsTblView.dg_setPullToRefreshFillColor(PlumberLightGrayColor)
        reviewsTblView.dg_setPullToRefreshBackgroundColor(reviewsTblView.backgroundColor!)
    }
    func refreshNewLeadsandLoad(){
        if (!loading) {
            loading = true
            GetReviews()
        }
    }
    func UITableView_Auto_Height()
    {
        if(self.myProfileTblView.contentSize.height > self.myProfileTblView.frame.height){
            
        }
    }
    deinit {
       // reviewsTblView.dg_removePullToRefresh()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
