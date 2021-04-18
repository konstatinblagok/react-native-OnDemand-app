//
//  ScheduleViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 01/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit
import CoreLocation
import AKPickerView

class ScheduleViewController: RootViewController,CGCalendarViewDelegate,UITextFieldDelegate,AKPickerViewDataSource,AKPickerViewDelegate,UITextViewDelegate,MyPopupViewControllerDelegate,UIViewControllerTransitioningDelegate {
    
    @IBOutlet var Month_Slot: UIButton!
    @IBOutlet var BookNow_Btn: CustomButton!
    @IBOutlet var calendarView: CGCalendarView!
    @IBOutlet var SelectDateTime_Lbl: UILabel!
    @IBOutlet var Schedule_Lbl: UIButton!
    @IBOutlet var Address_tableView: UITableView!
    @IBOutlet var Back_But: UIButton!
    @IBOutlet var scheduleDateView: UIView!
    @IBOutlet var Schedule_ScrollView: UIScrollView!
    
    var alert = UIAlertController()
    var SelectedAddress:String=String()
    var calendar:Calendar?
    var Timearray:NSMutableArray=NSMutableArray()
    var ReferenceTimeArray:NSMutableArray=NSMutableArray()
    var ReferenceTimeArray1:NSMutableArray=NSMutableArray()
    var TimeDictionary:NSDictionary=NSDictionary()
    var Date_Formatter:DateFormatter=DateFormatter()
    var Confirmation_date:String=String()
    var Globalindex:String=String()
    var UpdatedAddress:String=String()
    var fullAddress: String = String()
    var TextViewPlaceHolder = ""
    var themes:Themes=Themes()
    var URL_Handler:URLhandler=URLhandler()
    var AddressIDArray:NSMutableArray=NSMutableArray()
    var NameArray:NSMutableArray=NSMutableArray()
    var EmailIDArray:NSMutableArray=NSMutableArray()
    var MobileNumArray:NSMutableArray=NSMutableArray()
    var CountryCodeArray:NSMutableArray=NSMutableArray()
    var StreetArray:NSMutableArray=NSMutableArray()
    var line1array: NSMutableArray = NSMutableArray()
    var stateArray : NSMutableArray = NSMutableArray()
    var countryArray: NSMutableArray = NSMutableArray()
    var LandmarkArray:NSMutableArray=NSMutableArray()
    var LocalityArray:NSMutableArray=NSMutableArray()
    var ZipCodeArray:NSMutableArray=NSMutableArray()
    var CityArray:NSMutableArray=NSMutableArray()
    var LongitudeArray:NSMutableArray = NSMutableArray()
    var LatitudeArray:NSMutableArray = NSMutableArray()
    var CompleteAddressArray:NSMutableArray=NSMutableArray()
    var CompleteListAddressArray : NSMutableArray = NSMutableArray()
    var Confirmed_Time:String=String()
    var Latitude:String=String()
    var Longitude:String=String()
    var SelectedAddressID:String=String()
    var height_Cell:CGFloat=CGFloat()
    var MonthYearStr:String=String()
    var  headerCell = AddressHeaderTableViewCell()
    var Reference_TimeArray_Modified:NSMutableArray=NSMutableArray()
    var InstructionTextField:UITextView=UITextView()
    var date_Start = Date()
    //MARK: - Override Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
          Schedule_ScrollView.isScrollEnabled = true
        TextViewPlaceHolder=themes.setLang("enter_instruc")
        Schedule_Lbl.setTitle(themes.setLang("schedule_appointment"), for: UIControlState())
        SelectDateTime_Lbl.text=themes.setLang("schedule_appointment")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Timearray.removeAllObjects()
        setPage()
        
        InstructionTextField.textColor=PlumberThemeColor
        calendarView.calendar=calendar
        calendarView.rowCellClass=CGCalendarCell.classForCoder()
        calendarView.backgroundColor = UIColor.white
        calendarView.firstDate = Date(timeIntervalSinceNow: -60 * 60 * 24 * 0)
        calendarView.lastDate = Date(timeIntervalSinceNow:60 * 60 * 24 * 1000)
    calendarView.delegate=self
        print(date_Start)
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = PlumberThemeColor.cgColor
        border.frame = CGRect(x: 0, y: calendarView.frame.size.height - width, width:  414, height: calendarView.frame.size.height)
        border.borderWidth = width
        //calendarView.layer.addSublayer(border)
        calendarView.layer.masksToBounds = true
        let Registernib=UINib(nibName: "AddressTableViewCell", bundle: nil)
        Address_tableView.register(Registernib, forCellReuseIdentifier: "AddressCell")
        headerCell = Address_tableView.dequeueReusableCell(withIdentifier: "AddressHeader") as! AddressHeaderTableViewCell
        Address_tableView.separatorColor=UIColor.clear
        
        self.Date_Formatter=DateFormatter()
        self.Date_Formatter.date(from: "yyyy-MM-dd")
        //Set image for backarraow
        themes.Back_ImageView.image=UIImage(named: "")
        Back_But.addSubview(themes.Back_ImageView)
        Schedule_Data.Schedule_header=themes.setLang("choose_address")
        Address_tableView.isScrollEnabled = false
        
        
        self.SetFrameAccordingToSegmentIndex()
        loadAddress()
        
        if self.Latitude == "" || self.Longitude == ""
        {
            
        }
        else{
            self.getAddressForLatLng(self.Latitude as String, longitude: self.Longitude as String)
        }
        
        
        calendarView(calendarView, didSelect:date_Start)
        // calendarView.frame = CGRect(x: -1, y: TimeSchedule_View.frame.maxY+6, width: calendarView.frame.width, height: calendarView.frame.height)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: - Function
    
    func SetFrameAccordingToSegmentIndex(){
        DispatchQueue.main.async {
            var frame: CGRect = self.Address_tableView.frame
            frame.size.height = self.Address_tableView.contentSize.height;
            self.Address_tableView.frame = frame;
            if(self.AddressIDArray.count != 0) {
                frame.size.height = self.Address_tableView.contentSize.height+30;
            }else {
                frame.size.height = self.Address_tableView.contentSize.height+20;
            }
            self.Address_tableView.frame = frame;
            self.Schedule_ScrollView.contentSize=CGSize(width: self.Schedule_ScrollView.frame.size.width, height: self.Address_tableView.frame.origin.y+self.Address_tableView.frame.size.height)
        }
    }
    
    func setPage(){
        scheduleDateView.layer.borderWidth = 1
        scheduleDateView.layer.borderColor = PlumberThemeColor.cgColor
        scheduleDateView.layer.cornerRadius = 5
    }
    
    func loadAddress(){
        
        self.showProgress()
        self.CompleteListAddressArray = NSMutableArray()
        self.AddressIDArray = NSMutableArray()
        self.NameArray = NSMutableArray()
        self.EmailIDArray = NSMutableArray()
        self.CountryCodeArray = NSMutableArray()
        self.MobileNumArray = NSMutableArray()
        self.StreetArray = NSMutableArray()
        self.line1array = NSMutableArray()
        self.LandmarkArray = NSMutableArray()
        self.stateArray = NSMutableArray()
        self.countryArray = NSMutableArray()
        self.LatitudeArray = NSMutableArray()
        self.LongitudeArray = NSMutableArray()
        self.ZipCodeArray = NSMutableArray()
        Address_tableView.isHidden=true
        BookNow_Btn.isEnabled=false
        BookNow_Btn.setTitle(themes.setLang("search_now"), for: UIControlState())
        
        let param:NSDictionary=["user_id":"\(themes.getUserID())"]
        URL_Handler.makeCall(constant.List_address, param: param) { (responseObject, error) -> () in
            self.DismissProgress()
            self.BookNow_Btn.isEnabled=true
            self.Address_tableView.isHidden=false
            if(error != nil){
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
            } else {
                if(responseObject != nil){
                    let Dict:NSDictionary=responseObject!
                    let Status:String = self.themes.CheckNullValue(Dict.object(forKey: "status"))!
                    if(Status == "1"){
                        Schedule_Data.ScheduleAddressNameArray = NSMutableArray ()
                        Schedule_Data.scheduleAddressid = String()
                        self.Address_tableView.isHidden=false
                        let AddressArray:NSArray=Dict.object(forKey: "response") as! NSArray
                        for AddressDictionary in AddressArray{
                            let address_name=self.themes.convertIntToString((AddressDictionary as AnyObject).object(forKey: "address_name") as! Int)
                            self.AddressIDArray.add(address_name)
                            let name=self.themes.CheckNullValue( (AddressDictionary as AnyObject).object(forKey: "name"))!
                            self.NameArray.add(name)
                            let email=self.themes.CheckNullValue((AddressDictionary as AnyObject).object(forKey: "email"))!
                            self.EmailIDArray.add(email)
                            let country_code=self.themes.CheckNullValue((AddressDictionary as AnyObject).object(forKey: "country_code"))!
                            self.CountryCodeArray.add(country_code)
                            let mobile=self.themes.CheckNullValue((AddressDictionary as AnyObject).object(forKey: "mobile"))!
                            self.MobileNumArray.add(mobile)
                            let line1str = self.themes.CheckNullValue((AddressDictionary as AnyObject).object(forKey: "line1"))!
                            self.line1array.add(line1str)
                            let street=self.themes.CheckNullValue((AddressDictionary as AnyObject).object(forKey: "street"))!
                            self.StreetArray.add(street)
                            let city=self.themes.CheckNullValue((AddressDictionary as AnyObject).object(forKey: "city"))!
                            self.CityArray.add(city)
                            let statestr = self.themes.CheckNullValue((AddressDictionary as AnyObject).object(forKey: "state"))!
                            self.stateArray.add(statestr)
                            let countrystr = self.themes.CheckNullValue((AddressDictionary as AnyObject).object(forKey: "country"))!
                            self.countryArray.add(countrystr)
                            let landmark=self.themes.CheckNullValue((AddressDictionary as AnyObject).object(forKey: "landmark"))!
                            self.LandmarkArray.add(landmark)
                            let zipcode=self.themes.CheckNullValue((AddressDictionary as AnyObject).object(forKey: "zipcode"))!
                            self.ZipCodeArray.add(zipcode)
                            let lng=self.themes.CheckNullValue((AddressDictionary as AnyObject).object(forKey: "lng"))!
                            self.LongitudeArray.add(lng)
                            let lat=self.themes.CheckNullValue((AddressDictionary as AnyObject).object(forKey: "lat"))!
                            self.LatitudeArray.add(lat)
                            let Locality=self.themes.CheckNullValue((AddressDictionary as AnyObject).object(forKey: "locality"))!
                            let fullladdress = self.themes.CheckNullValue((AddressDictionary as AnyObject).object(forKey: "fulladdress"))!
                            let jobaddress = "\(line1str)$\(landmark)$\(city)$\(statestr)$\(countrystr)$\(zipcode)"
                            var CompleteAddress = String()
                            CompleteAddress = "\(line1str) \((landmark))\n"+"\(city) \(statestr)\n"+"\(countrystr) \(zipcode)"

                            CompleteAddress = CompleteAddress.replacingOccurrences(of: "\n \n", with:"\n")
                             CompleteAddress = CompleteAddress.replacingOccurrences(of: "\n ", with:"\n")
                            CompleteAddress = CompleteAddress.replacingOccurrences(of: " \n", with:"\n")

                             CompleteAddress = CompleteAddress.replacingOccurrences(of: "  \n", with:"\n")
                            CompleteAddress = CompleteAddress.replacingOccurrences(of: "\n\n\n", with:"\n")
                            CompleteAddress = CompleteAddress.replacingOccurrences(of: "\n\n", with: "\n")
                            CompleteAddress = CompleteAddress.replacingOccurrences(of: "\n ", with:"\n")
                            self.CompleteListAddressArray.add(CompleteAddress)
                            Schedule_Data.ScheduledisplayAddArray.removeAllObjects()
                            Schedule_Data.ScheduledlistaddArray.removeAllObjects()
                            if self.CompleteListAddressArray.count > 0
                            {
                                Schedule_Data.ScheduledisplayAddArray.add(jobaddress)
                                Schedule_Data.ScheduledlistaddArray.add(fullladdress)
                            }
                            
                        }
                        Schedule_Data.ScheduleAddressNameArray = self.AddressIDArray
                    }
                    else{
                        
                    }
                    
                } else{
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                }
            }
        }
    }
    
    func getAddressForLatLng(_ latitude: String, longitude: String){
        self.CompleteAddressArray = NSMutableArray()
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
                        print("get current location \((result[1] as AnyObject)["address_components"])")
                        var street : String = ""
                        var sublocality : String = ""
                        var city : String = ""
                        var state  : String = ""
                        var country : String = ""
                        var zipcode  : String = ""
                        
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
                        Home_Data.jobaddress = "\(street)$\(sublocality)$\(city)$\(state)$\(country)$\(zipcode)"
                        Home_Data.fulladdress = "\(street) \(sublocality) \(city) \(state) \(country) \(zipcode)"

                        fullAddress = "\(street) \(sublocality)\n"+"\(city) \(state)\n"+"\(country) \(zipcode)"
                        fullAddress = fullAddress.replacingOccurrences(of: "\n \n", with:"\n")
                        fullAddress = fullAddress.replacingOccurrences(of: "\n\n\n", with:"\n")
                        fullAddress = fullAddress.replacingOccurrences(of: "\n\n", with: "\n")
                        self.CompleteAddressArray.add(fullAddress)
                        self.height_Cell = self.themes.calculateHeightForString("\(fullAddress))")
                        
                        self.UpdatedAddress=fullAddress
                        self.SelectedAddress=fullAddress
                        self.SelectedAddressID=""
                        Schedule_Data.scheduleAddressid = ""
                        self.Address_tableView.reload()
                        
                        self.SetFrameAccordingToSegmentIndex()
                        
                    }
                }
            }
        }
        
    }
    
    func applicationLanguageChangeNotification(_ notification:Notification){
        Schedule_Lbl.setTitle(themes.setLang("schedule_appointment"), for: UIControlState())
        SelectDateTime_Lbl.text=themes.setLang("schedule_appointment")
    }
    
    
    func ShowmoreAddress() {
        
        if self.AddressIDArray.count > 0
        {
            
            Schedule_Data.ScheduleAddressArray = NSMutableArray ()
            Schedule_Data.ScheduleLatitudeArray = NSMutableArray()
            Schedule_Data.ScheduleLongtitudeArray = NSMutableArray()
            if(CompleteListAddressArray.count != 0){
                Schedule_Data.ScheduleAddressArray=CompleteListAddressArray
                Schedule_Data.ScheduleLatitudeArray = LatitudeArray
                Schedule_Data.ScheduleLongtitudeArray = LongitudeArray
            }
            self.displayViewController(.bottomBottom)
        }
        else{
            self.performSegue(withIdentifier: "AddaddressVC", sender: nil)
        }
        
        // NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
    }
    
    func displayViewController(_ animationType: SLpopupViewAnimationType) {
        let myPopupViewController:MyPopupViewController = MyPopupViewController(nibName:"MyPopupViewController", bundle: nil)
        myPopupViewController.delegate = self
        myPopupViewController.Globalindex =  self.SelectedAddressID
        myPopupViewController.transitioningDelegate = self
        myPopupViewController.modalPresentationStyle = .custom;
        self.navigationController?.present(myPopupViewController, animated: true, completion: nil)

    }
    
    func doneButtonAction() {
        Schedule_ScrollView.isScrollEnabled = true
        view.endEditing(true)
    }
    
    func PushtoAddadrressVC(_ sender:UITapGestureRecognizer){
        if (themes.getEmailID() == "") {   themes.saveaddresssegue("1")
            Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "signinVCID")
        } else {
            self.performSegue(withIdentifier: "AddaddressVC", sender: nil)
        }
    }
    
    
    func bookingconfim(){
        if Schedule_Data.scheduleAddressid == ""
        {
        }else{
            self.UpdateAddress( Int(Schedule_Data.scheduleAddressid as String)!)
            
        }
        BookNow_Btn.isEnabled=false
        self.showProgress()
        let dateAsString = Confirmed_Time
        let dateFormatter = DateFormatter()
        let timeZone : NSTimeZone = NSTimeZone.local as NSTimeZone
        dateFormatter.timeZone = timeZone as TimeZone!
       
        let  uslocale = NSLocale.init(localeIdentifier:"en_US")
        dateFormatter.locale = uslocale as Locale! as Locale!
        dateFormatter.dateFormat = "h a"
        let date = dateFormatter.date(from: dateAsString as String)
        dateFormatter.dateFormat = "HH:mm"
        let date24 = dateFormatter.string(from: date!)
        Schedule_Data.RquiredAddressid = SelectedAddressID
        Schedule_Data.PickupDate = Confirmation_date
        Schedule_Data.pickupTime = date24
        Schedule_Data.GetScheduleIstr = InstructionTextField.text!
        Schedule_Data.getLatitude = self.Latitude
        Schedule_Data.getLongtitude = self.Longitude
        
        if Category_Data.CategoryID == ""{
            let Prefcategory : UserDefaults = UserDefaults.standard
            Category_Data.CategoryID = Prefcategory.object(forKey: "maincategory") as! NSString
        }
        let param=["user_id":"\(themes.getUserID())","address_name":"\(Schedule_Data.scheduleAddressid )","pickup_date":"\(Confirmation_date)","pickup_time":"\(date24)","instruction":"\(InstructionTextField.text!)","code":"","category":"\(Home_Data.Category_id)","service":"\(Category_Data.CategoryID)","lat":self.Latitude,"long":self.Longitude] as [String : Any]
        URL_Handler.makeCall(constant.Book_It, param: param as NSDictionary, completionHandler: { (responseObject, error) -> () in
            self.DismissProgress()
            self.BookNow_Btn.isEnabled=true
            if(error != nil) {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
            }  else {
                if(responseObject != nil) {
                    let dict:NSDictionary=responseObject!
                    let Status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                    if(responseObject != nil){
                        if(Status == "1") {
                            let responseArray:NSMutableArray=dict.object(forKey: "response") as! NSMutableArray
                            let taskID:NSString=dict.object(forKey: "task_id") as! NSString
                            Schedule_Data.TaskID="\(taskID)"
                            Schedule_Data.ProviderListIdArray.removeAllObjects()
                            Schedule_Data.ProviderListNameArray.removeAllObjects()
                            Schedule_Data.ProviderListImageArray.removeAllObjects()
                            Schedule_Data.ProviderListAvailableArray.removeAllObjects()
                            Schedule_Data.ProviderListCompanyArray.removeAllObjects()
                            Schedule_Data.ProviderListMinamountArray.removeAllObjects()
                            Schedule_Data.ProviderListHouramountArray.removeAllObjects()
                            Schedule_Data.ProviderListRatingArray.removeAllObjects()
                            if(responseArray.count != 0){
                                for Dictionary in responseArray {
                                    let job_id=(Dictionary as AnyObject).object(forKey: "taskerid")!
                                    Schedule_Data.ProviderListIdArray.add(job_id)
                                    let Name=(Dictionary as AnyObject).object(forKey: "name")!
                                    Schedule_Data.ProviderListNameArray.add(Name)
                                    let service_icon=(Dictionary as AnyObject).object(forKey: "image_url")!
                                    Schedule_Data.ProviderListImageArray.add(service_icon)
                                    let available=(Dictionary as AnyObject).object(forKey: "availability")!
                                    Schedule_Data.ProviderListAvailableArray.add(available)
                                    let company=(Dictionary as AnyObject).object(forKey: "company")!
                                    Schedule_Data.ProviderListCompanyArray.add(company)
                                    let rating=self.themes.convertFloatToString((Dictionary as AnyObject).object(forKey: "rating") as! Float)
                                    Schedule_Data.ProviderListRatingArray.add(rating)
                                    let min_amount=self.themes.CheckNullValue((Dictionary as AnyObject).object(forKey: "min_amount"))!
                                    Schedule_Data.ProviderListMinamountArray.add(min_amount)
                                    let hour_amount=self.themes.CheckNullValue((Dictionary as AnyObject).object(forKey: "hourly_amount"))!
                                    
                                    Schedule_Data.ProviderListHouramountArray.add(hour_amount)
                                    let reviews=self.themes.CheckNullValue((Dictionary as AnyObject).object(forKey: "reviews"))
                                    Schedule_Data.ProviderLisreviewsArray.add(reviews!)
                                    let dist=self.themes.CheckNullValue((Dictionary as AnyObject).object(forKey: "distance_km"))
                                    Schedule_Data.ProviderdistanceArray.add(dist!)
                                    
                                }
                                
                                Schedule_Data.tasker_lat = self.Latitude as String
                                Schedule_Data.tasker_lng = self.Longitude as String
                                print("get hour amount array\(Schedule_Data.ProviderListHouramountArray)")
                                self.performSegue(withIdentifier: "ProviderConfirmVC", sender: nil)//OrderConfirmVC
                            }
                        }  else {
                            let response:NSString=dict.object(forKey: "response") as! NSString
                            self.themes.AlertView("\(Appname) ", Message: "\(response)", ButtonTitle: self.themes.setLang("ok"))
                        }
                    }
                }
                else {
                    self.themes.AlertView(self.themes.setLang("Sorry for the inconvenience"), Message: self.themes.setLang("Please try again"), ButtonTitle: self.themes.setLang("ok"))
                }
            }
        })
    }
    
    func applyCoupon(_ Couponstr:String){
        BookNow_Btn.isEnabled=false
        if(Couponstr == ""){
            self.themes.AlertView("\(Appname)", Message: themes.setLang("enter_coupen"), ButtonTitle: kOk)
        } else {
            let param=["user_id":"\(themes.getUserID())","code":"\(Couponstr)","pickup_date":"\(Confirmation_date)"]
            URL_Handler.makeCall(constant.Coupon_Call, param: param as NSDictionary, completionHandler: { (responseObject, error) -> () in
                self.BookNow_Btn.isEnabled=true
                if(error != nil) {
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                } else {
                    if(responseObject != nil) {
                        let Dict:NSDictionary=responseObject!
                        let Status=self.themes.CheckNullValue(Dict.object(forKey: "status"))!
                        if(Status == "1") {
                            self.alert.dismiss(animated: true, completion: nil)
                        }else {
                            let Response=Dict.object(forKey: "message") as! String
                            self.themes.AlertView("\(Appname)", Message: Response, ButtonTitle: self.themes.setLang("ok"))
                        }
                    }  else {
                        self.themes.AlertView("\(Appname)", Message: self.themes.setLang("invalid_coupon"), ButtonTitle: kOk)
                    }
                }
            })
        }
    }
    
    func pressAdd(_ sender: MyPopupViewController) {
        self.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "AddaddressVC", sender: nil)
    }
    
    func pressCancel(_ sender: MyPopupViewController) {
        self.dismiss(animated: true, completion: nil)
        self.loadAddress()
    }
    
    
    func PassSelectedAddress(_ Address: String, AddressIndexvalue: Int, latitudestr: String, longtitudestr: String, localitystr: String,fulladdress:String) {
        UpdatedAddress=Address
        self.Latitude = latitudestr
        self.Longitude = longtitudestr
        Home_Data.jobaddress = localitystr
        Home_Data.fulladdress = fulladdress
        print("the latitude =\(AddressIndexvalue) and longtitude =\(longtitudestr)")
        self.UpdateAddress(AddressIndexvalue)
        DispatchQueue.main.async(execute: {
            self.Address_tableView.reload()
        })
        self.dismiss(animated: true, completion: nil)
    }
    
    func  UpdateAddress(_ addressindex: Int){
        let Param: Dictionary = ["user_id":themes.getUserID(),"address_name":"\(addressindex)"]
        URL_Handler.makeCall(constant.List_address, param: Param as NSDictionary) {
            (responseObject, error) -> () in
            if(error != nil){
            }
            else{
                if(responseObject != nil && (responseObject?.count)!>0) {
                    let status=self.themes.CheckNullValue(responseObject?.object(forKey: "status"))!
                    if(status == "1"){
                    }
                    else
                    {
                    }
                }
            }
        }
    }
    
    
    //MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      
        headerCell.Timepicker.isHidden = false
        if  CompleteAddressArray.count != 0{
            headerCell.AddAddress_View.isHidden = true
            headerCell.backgroundColor = UIColor.clear
        }  else {
            let Tap:UITapGestureRecognizer=UITapGestureRecognizer()
            Tap.addTarget(self, action: #selector(ScheduleViewController.PushtoAddadrressVC(_:)))
            headerCell.AddAddress_View.addGestureRecognizer(Tap)
        }
        return headerCell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(CompleteAddressArray.count != 0) {
            return 80
        }else {
            return 127
        }
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if(CompleteAddressArray.count != 0){
            height_Cell = self.themes.calculateHeightForString("\(UpdatedAddress)")
            if(indexPath.row == 0) {
                if(CompleteAddressArray.count == 1) {
                    return height_Cell + 30
                } else {
                    return height_Cell + 40
                }
            } else {
                return 150
            }
        }else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(CompleteAddressArray.count != 0) {
            return 2
        } else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let Cell:AddressTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AddressCell") as! AddressTableViewCell
        Cell.selectionStyle = .none
       
        Cell.More_address_btn.addTarget(self,action:#selector(ScheduleViewController.ShowmoreAddress),for:UIControlEvents.touchUpInside)
        if(CompleteAddressArray.count != 0) {
            if(indexPath.row == 0) {
                Cell.DeleteIcon.isHidden=true
                InstructionTextField.isHidden=true
                Cell.Address_Label.isHidden=false
                Cell.More_address_btn.isHidden=false
                Cell.More_address_btn.setTitle(themes.setLang("ur_address"), for: UIControlState())
                Cell.More_icon.isHidden=false
                Cell.backgroundColor=UIColor.white
                Cell.Address_Label.text="\(UpdatedAddress)"
                let height:CGFloat = self.themes.calculateHeightForString("\(UpdatedAddress)")
                Cell.Address_Label.frame.size.height=height+20
            } else if(indexPath.row == 1) {
                InstructionTextField.isHidden=false
                Cell.Address_Label.isHidden=true
                Cell.More_address_btn.isHidden=true
                Cell.More_icon.isHidden=true
                Cell.DeleteIcon.isHidden=true
                Cell.backgroundColor=UIColor.clear
                InstructionTextField.frame=CGRect(x: 4, y: 30, width: self.view.frame.width-13, height: 120)
                InstructionTextField.backgroundColor=UIColor.white
                InstructionTextField.delegate=self
                InstructionTextField.layer.borderWidth=1.0
                InstructionTextField.layer.cornerRadius = 5
                InstructionTextField.layer.borderColor=PlumberThemeColor.cgColor
                InstructionTextField.font=PlumberMediumFont
                var done_Toolbar: UIToolbar=UIToolbar()
                done_Toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
                done_Toolbar.backgroundColor=UIColor.white
                let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
                let done: UIBarButtonItem = UIBarButtonItem(title: themes.setLang("done"), style: UIBarButtonItemStyle.done, target: self, action: #selector(ScheduleViewController.doneButtonAction))
                done_Toolbar.items = [flexSpace,done]
                done_Toolbar.sizeToFit()
                InstructionTextField.inputAccessoryView = done_Toolbar
                Cell.addSubview(InstructionTextField)
                if(InstructionTextField.text == "") {
                    InstructionTextField.text=TextViewPlaceHolder
                }
            }
        }
        return Cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        Globalindex="\(indexPath.row)"
        SelectedAddress=UpdatedAddress
        
        
    }
    
    //MARK:- TextView Delegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
       
        if(InstructionTextField.text == TextViewPlaceHolder) {
            InstructionTextField.textColor=UIColor.black
            InstructionTextField.text=""
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        if(InstructionTextField.text == "") {
            InstructionTextField.textColor=PlumberThemeColor
            InstructionTextField.text=TextViewPlaceHolder
        }
        return true
    }
    
    
    //MARK: - PickerView Delegates
    
    func numberOfItems(in pickerView: AKPickerView!) -> UInt {
        return UInt(Timearray.count)
    }
    
    func pickerView(_ pickerView: AKPickerView!, titleForItem item: Int) -> String! {
        return Timearray[item] as! String
    }
    
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
        Confirmed_Time="\(Timearray[item])"
        Confirmed_Time="\(Reference_TimeArray_Modified[item])"
    }
    
    //MARK: -  CGCalendar View Delegate
    func calendarView(_ calendarView: CGCalendarView!, didSelect date: Date!) {
        Timearray=["8 AM - 9 AM","9 AM - 10 AM","10 AM - 11 AM","11 AM - 12 PM","12 PM - 1 PM","1 PM - 2 PM","2 PM - 3 PM","3 PM - 4 PM","4 PM - 5 PM","5 PM - 6 PM","6 PM - 7 PM","7 PM - 8 PM"]
        ReferenceTimeArray1=["","","","","","","","","8 AM - 9 AM","9 AM - 10 AM","10 AM - 11 AM","11 AM - 12 PM","12 PM - 1 PM","1 PM - 2 PM","2 PM - 3 PM","3 PM - 4 PM","4 PM - 5 PM","5 PM - 6 PM","6 PM - 7 PM","7 PM - 8 PM"]
        ReferenceTimeArray=["12 AM","01 AM","02 AM","03 AM","04 AM","05 AM","06 AM","07 AM","08 AM","09 AM","10 AM","11 AM","12 PM","01 PM","02 PM","03 PM","04 PM","05 PM","06 PM","07 PM"]
        Reference_TimeArray_Modified=["12 AM","01 AM","02 AM","03 AM","04 AM","05 AM","06 AM","07 AM","08 AM","09 AM","10 AM","11 AM","12 PM","01 PM","02 PM","03 PM","04 PM","05 PM","06 PM","07 PM"]
        TimeDictionary=["8 AM":"8 AM - 9 AM","9 AM":"9 AM - 10 AM","10 AM":"10 AM - 11 AM","11 AM":"11 AM - 12 PM","12 PM":"12 AM - 1 AM","1 PM":"1 PM - 2 PM","2 PM":"2 PM - 3 PM","3 PM":"3 PM - 4 PM","4 PM":"4 PM - 5 PM","5 PM":"5 PM - 6 PM","6 PM":"6 PM - 7 PM","7 PM":"7 PM - 8 PM"]

        date_Start = date
        print(date)
        let components: DateComponents = (Calendar.current as NSCalendar).components(NSCalendar.Unit.day.union(NSCalendar.Unit.month).union(NSCalendar.Unit.year), from: date)
        let monthNumber: Int = components.month!
        let Year:Int=components.year!
        Confirmation_date="\(String(describing: components.month!))/\(String(describing: components.day!))/\(String(describing: components.year!))"
        let dateAsString = Confirmation_date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/dd/yyyy"
        let date = dateFormatter.date(from: dateAsString as String)
        dateFormatter.dateFormat = "MM/dd/yyyy"
        Confirmation_date = dateFormatter.string(from: date!)
        print("the date issssss \(Confirmation_date)")
        let df: DateFormatter = DateFormatter()
        let monthName: String = df.monthSymbols[(monthNumber - 1)]
        MonthYearStr = "\(monthName), \(Year)"
        Month_Slot.setTitle("\(MonthYearStr)", for: UIControlState())
        Month_Slot.setTitleColor(UIColor.orange, for:UIControlState())
        let HourFromat:Locale=Locale(identifier: "en_US_POSIX")
        df.locale = HourFromat
        df.dateFormat = "a"
        dateFormatter.dateFormat = "hh"
        var dateComp = dateFormatter.string(from: NSDate() as Date).uppercased()
        let currentAMPMFormat = df.string(from: NSDate() as Date).uppercased()
        let currentdate:Date=Date()
        let datefromatter:DateFormatter=DateFormatter()
        datefromatter.dateFormat = "d.M.yyyy";
        let CurrentdateString:NSString=datefromatter.string(from: currentdate) as NSString
        let SelecteddateString:NSString=datefromatter.string(from: date!) as NSString
        headerCell.Timepicker.delegate = self
        headerCell.Timepicker.dataSource = self
        if(CurrentdateString == SelecteddateString) {
            
            switch dateComp{
            case "13":
                dateComp = "01"
                break;
            case "14":
                dateComp = "02"
                break;
            case "15":
                dateComp = "03"
                break;
            case "16":
                dateComp = "04"
                break;
            case "17":
                dateComp = "05"
                break;
            case "18":
                dateComp = "06"
                break;
            case "19":
                dateComp = "07"
                break;
            case "20":
                dateComp = "08"
                break;
            case "21":
                dateComp = "09"
                break;
            case "22":
                dateComp = "10"
                break;
            case "23":
                dateComp = "11"
                break;
            case "24":
                dateComp = "12"
                break;
            default:
                break;
            }
            
            let CurrentHour:NSString="\(dateComp) \(currentAMPMFormat)" as NSString
            if(ReferenceTimeArray.contains(CurrentHour))
            {
                let indexpath:NSInteger=ReferenceTimeArray.index(of: CurrentHour)
                
                print("get indexpath of  refeerane time\(indexpath)")
                
                if indexpath > 8
                    
                {
                    if(Timearray.count != 0)
                    {
                        Timearray.removeAllObjects()
                        Reference_TimeArray_Modified.removeAllObjects()
                    }
                    for i in indexpath+1 ..< ReferenceTimeArray.count
                    {
                        Reference_TimeArray_Modified.add("\(ReferenceTimeArray[i])")
                        Timearray.add("\(ReferenceTimeArray1[i])")
                    }
                    
                }
                else
                {
                    ReferenceTimeArray1=["8 AM - 9 AM","9 AM - 10 AM","10 AM - 11 AM","11 AM - 12 PM","12 PM - 1 PM","1 PM - 2 PM","2 PM - 3 PM","3 PM - 4 PM","4 PM - 5 PM","5 PM - 6 PM","6 PM - 7 PM","7 PM - 8 PM","8 PM - 9 PM"]
                    ReferenceTimeArray=["08 AM","09 AM","10 AM","11 AM","12 PM","01 PM","02 PM","03 PM","04 PM","05 PM","06 PM","07 PM","08 PM"]
                    
                    
                    if(Timearray.count != 0)
                    {
                        Timearray.removeAllObjects()
                        Reference_TimeArray_Modified.removeAllObjects()
                    }
                    for i in 0 ..< ReferenceTimeArray.count
                    {
                        Reference_TimeArray_Modified.add("\(ReferenceTimeArray[i])")
                    }
                    
                    for i in 0 ..< ReferenceTimeArray1.count
                    {
                        Timearray.add("\(ReferenceTimeArray1[i])")
                    }
                }
                
            }
            else
            {
                Timearray.removeAllObjects()
                Reference_TimeArray_Modified.removeAllObjects()
                themes.AlertView(self.themes.setLang("Sorry no time slot available today"), Message: self.themes.setLang("Please choose another date"), ButtonTitle: self.themes.setLang("ok"))
                
            }
            
            Timearray.remove("")
            headerCell.Timepicker.reloadData()
            
        }else{
            Timearray=["8 AM - 9 AM","9 AM - 10 AM","10 AM - 11 AM","11 AM - 12 PM","12 PM - 1 PM","1 PM - 2 PM","2 PM - 3 PM","3 PM - 4 PM","4 PM - 5 PM","5 PM - 6 PM","6 PM - 7 PM","7 PM - 8 PM","8 PM - 9 PM"]
            Reference_TimeArray_Modified=["08 AM","09 AM","10 AM","11 AM","12 PM","01 PM","02 PM","03 PM","04 PM","05 PM","06 PM","07 PM","08 PM"]
            headerCell.Timepicker.reloadData()
        }
        
        
      
        print(" Get Time Array \(Timearray) Get Time Array\(Reference_TimeArray_Modified)>>>>>>>>")
        
        if Reference_TimeArray_Modified.count > 0 {
            Confirmed_Time = "\(Reference_TimeArray_Modified[0])"
        }
    }
    
    //MARK: - Button Action
    
    @IBAction func didClickOptions(_ sender: UIButton) {
        let InstructionField_Data:NSString=InstructionTextField.text! as NSString
        let whitespace:CharacterSet = CharacterSet.whitespacesAndNewlines
        let trimmed:NSString =  InstructionField_Data.trimmingCharacters(in: whitespace) as NSString
        if(sender.tag == 0) {
            
            //let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HomePageVCID") as! HomepageViewController
            //self.navigationController?.poptoViewControllerWithFlip(controller:secondViewController, animated: true)
            
            Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "HomePageVCID")
        }
        if(sender.tag == 2){
            if(Confirmation_date == ""){
                themes.AlertView(Appname, Message: themes.setLang("choose_date"), ButtonTitle: kOk)
            }else if(Confirmed_Time == "") {
                themes.AlertView(Appname, Message: themes.setLang("choose_time"), ButtonTitle: kOk)
            } else if(CompleteAddressArray.count == 0)  {
                if themes.getEmailID() == ""{
                    themes.saveaddresssegue("1")
                    Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "signinVCID")
                } else{
                    self.performSegue(withIdentifier: "AddaddressVC", sender: nil)
                }
            } else if(trimmed as String == "" || InstructionField_Data as String == TextViewPlaceHolder){
                themes.AlertView(Appname, Message: themes.setLang("enter_instruc"), ButtonTitle: kOk)
                InstructionTextField.becomeFirstResponder()
            } else{
                self.bookingconfim()
                
            }
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
