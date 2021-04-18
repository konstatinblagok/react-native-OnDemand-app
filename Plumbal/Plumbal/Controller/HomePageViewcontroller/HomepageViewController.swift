//
//  HomepageViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 01/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit
import SWRevealViewController

class HomepageViewController: RootViewController,CLLocationManagerDelegate
,UINavigationBarDelegate,UIGestureRecognizerDelegate {
    fileprivate var pTouchAreaEdgeInsets: UIEdgeInsets = UIEdgeInsets.zero
    @IBOutlet var SlideinMenu_But: UIButton!
    @IBOutlet var Home_tableView: UITableView!
    @IBOutlet var Header_Lab: UILabel!
    @IBOutlet var chat_icon: MIBadgeButton!
    
    var URL_handler:URLhandler=URLhandler()
    var Categoryid1Array:NSMutableArray=NSMutableArray()
    var Categoryid2Array:NSMutableArray=NSMutableArray()
    var Categoryimage1Array:NSMutableArray=NSMutableArray()
    var Categoryimage2Array:NSMutableArray=NSMutableArray()
    var Child_Status1Array:NSMutableArray=NSMutableArray()
    var Child_Status2Array:NSMutableArray=NSMutableArray()
    var Categoryname1Array:NSMutableArray=NSMutableArray()
    var Categoryname2Array:NSMutableArray=NSMutableArray()
    var sidebarMenuOpen:Bool=Bool()
    var themes:Themes=Themes()
    var View_Tapgesture:UITapGestureRecognizer=UITapGestureRecognizer()
    var nibView:UIView=UIView()
    var refreshControl:UIRefreshControl=UIRefreshControl()
    var app_delegate=UIApplication.shared.delegate as! AppDelegate
    var locationManager = CLLocationManager()
    
    //MARK: Override Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        chat_icon.badgeString = "0"
        chat_icon.badgeBackgroundColor=themes.ThemeColour()
        chat_icon.badgeTextColor = UIColor.white
        chat_icon.badgeEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 15)
        chat_icon.isHidden=true
        Home_tableView.separatorColor=UIColor.clear
        let nibName = UINib(nibName: "HomePageTableViewCell", bundle:nil)
        self.Home_tableView.register(nibName, forCellReuseIdentifier: "ListCell")
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
        }
        configurePulltorefresh()

        self.showProgress()
        Home_Datafeed()
    }
    

    
    //MARK: Function
    
    fileprivate func contentView(_ text: String) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 64))
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let label = UILabel(frame: view.bounds)
        label.frame.origin.x = 10
        label.frame.origin.y = 10
        label.frame.size.width -= label.frame.origin.x
        label.frame.size.height -= label.frame.origin.y
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.text = text
        label.numberOfLines = 2
        label.textColor = UIColor.white
        view.addSubview(label)
        return view
    }
    
    func settablebackground(){
        let nibView = Bundle.main.loadNibNamed("RefreshView", owner: self, options: nil)?[0] as! UIView
        nibView.frame = self.Home_tableView.bounds;
        self.Home_tableView.backgroundView=nibView
        
    }
    func configurePulltorefresh() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(HomepageViewController.Home_Datafeed), for: UIControlEvents.valueChanged)
        self.Home_tableView.addSubview(refreshControl)
    }
    
    func animateTable() {
        Home_tableView.reload()
        let cells = Home_tableView.visibleCells
        for i in cells {
            let cell: HomePageTableViewCell = i as! HomePageTableViewCell
            cell.Single_Label.transform = CGAffineTransform(translationX: self.view.frame.size.width, y: 0)
        }
        var index = 0
        for a in cells {
            let cell: HomePageTableViewCell = a as! HomePageTableViewCell
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
                cell.Single_Label.transform = CGAffineTransform(translationX: 0, y: 0);
                }, completion: nil)
            index += 1
        }
    }
    
    
    func PushtoSubcategory1(_ sender:UIButton) {
        Home_Data.Category_id="\(Categoryid1Array[sender.tag])" as NSString
        Home_Data.Category_image="\(Categoryimage1Array[sender.tag])" as NSString
        Home_Data.Category_name="\(Categoryname1Array[sender.tag])" as NSString
        self.performSegue(withIdentifier: "Category", sender: nil)
        self.revealViewController().revealToggle(animated: true)
    }
    
    func Home_Datafeed() {
        let param:Dictionary=["location_id":"\(themes.getLocationID())"]
        URL_handler.makeCall(constant.Get_Categories, param: param as NSDictionary) { (responseObject, error) -> () in
            self.DismissProgress()
            self.refreshControl.endRefreshing()
            
            if(error != nil){
                self.settablebackground()
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
            }  else {
                if(responseObject != nil) {
                    let dict:NSDictionary=responseObject!
                    let Status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                    if(Status != ""){
                        if(Status == "1")  {
                            if(self.Categoryid1Array.count != 0) {
                                self.Categoryid1Array.removeAllObjects()
                                self.Categoryimage1Array.removeAllObjects()
                                self.Categoryname1Array.removeAllObjects()
                                self.Child_Status1Array.removeAllObjects()
                            }
                            let CategoryArray:NSArray=((responseObject as AnyObject).object(forKey: "response") as AnyObject).object(forKey: "category") as! NSArray
                            for Dictionary in CategoryArray{
                                let Dictionary = Dictionary as! NSDictionary
                                let categoryid1:NSString=Dictionary.object(forKey: "cat_id") as! NSString
                                self.Categoryid1Array.add(categoryid1)
                                let categoryimage1:NSString=Dictionary.object(forKey: "image") as! NSString
                                self.Categoryimage1Array.add(categoryimage1)
                                let categoryname1:NSString=Dictionary.object(forKey: "cat_name") as! NSString
                                self.Categoryname1Array.add(categoryname1)
                                let childstatus1:NSString=Dictionary.object(forKey: "hasChild") as! NSString
                                self.Child_Status1Array.add(childstatus1)
                            }
                            self.Home_tableView.reload()
                            self.animateTable()
                            self.Home_tableView.backgroundView=nil
                        } else {
                            self.settablebackground()
                            if (responseObject?.object(forKey: "response") != nil) {
                                let Response:NSString=responseObject?.object(forKey: "response") as! NSString
                                self.themes.AlertView("\(Appname)", Message: "\(Response)", ButtonTitle: kOk)
                            }
                        }
                    }else {
                        self.settablebackground()
                        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    }
                }else {
                    self.settablebackground()
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                }
            }
        }
    }
    
    func PushtoSubcategory(_ sender:UIButton) {
        if(sidebarMenuOpen == true){
            self.revealViewController().revealToggle(animated: true)
        }
        Home_Data.Category_id="\(Categoryid1Array[sender.tag])" as NSString
        print("the category is \(Home_Data.Category_id)")
        Home_Data.Category_image="\(Categoryimage1Array[sender.tag])" as NSString
        Home_Data.Category_name="\(Categoryname1Array[sender.tag])" as NSString
        self.performSegue(withIdentifier: "Category", sender: nil)
    }
    
    //MARK: - Button Action
    
    @IBAction func menuButtonTouched(_ sender: AnyObject) {
        self.findHamburguerViewController()?.showMenuViewController()
    }
    
    @IBAction func didClickChatBtn(_ sender: MIBadgeButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatList") as! ChatListViewController
        self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)
    }
    
    
    //MARK: Table View Delegate
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 198
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("the sad is \(self.Categoryid1Array.count)")
        return Categoryid1Array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let Cell:HomePageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! HomePageTableViewCell
        Cell.selectionStyle=UITableViewCellSelectionStyle.none
        Cell.Single_Label.text="\(self.Categoryname1Array[indexPath.row])"
        Cell.Single_ImageView.sd_setImage(with: URL(string: "\(self.Categoryimage1Array[indexPath.row])"), completed: themes.block)
        Cell.Single_wrapperView.addTarget(self, action: #selector(HomepageViewController.PushtoSubcategory(_:)), for: UIControlEvents.touchUpInside)
        Cell.Single_wrapperView.tag=indexPath.row
        Cell.gradient.frame = Cell.Single_ImageView.bounds
        Cell.gradient.frame.size.width=view.frame.size.width+40
        Cell.gradient.frame.size.height = view.frame.size.height+80
        Cell.gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        Cell.gradient.locations = [0.0, 0.3]
        Cell.Single_ImageView.layer.insertSublayer(Cell.gradient, at: 0)
        Cell.Single_ImageView.layer.cornerRadius = 8.0
        Cell.Single_ImageView.clipsToBounds = true
        return Cell
    }
    
    
    //MARK: - Reveal View Controller Delegate
    
    func revealController(_ revealController: SWRevealViewController, willMoveToPosition position: FrontViewPosition) {
        if position == FrontViewPosition.left {
            sidebarMenuOpen = false
        } else {
            sidebarMenuOpen = true
        }
    }
    
    func revealController(_ revealController: SWRevealViewController, didMoveToPosition position: FrontViewPosition) {
        if position == FrontViewPosition.left {
            sidebarMenuOpen = false
        } else {
            sidebarMenuOpen = true
        }
    }
    //MARK: - Location Delegate
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _ = CLGeocoder()
        let current = locations[0]
        if current.coordinate.latitude != 0 {
            
         
            
            
            CLGeocoder().reverseGeocodeLocation(current, completionHandler:
                {(placemarks, error) in
                    if placemarks == nil {
                        return
                    }
                    let currentLocPlacemark = placemarks![0]
                    var code = currentLocPlacemark.isoCountryCode
                    let dictCodes : NSDictionary = self.themes.getCountryList()
                    code = (dictCodes.value(forKey: code!)as! NSArray)[1] as? String
                    self.themes.saveCounrtyphone(code!)
                    self.locationManager.stopUpdatingLocation()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


