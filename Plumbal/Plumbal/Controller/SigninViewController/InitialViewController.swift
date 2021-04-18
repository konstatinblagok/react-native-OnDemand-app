
//  InitialViewController.swift
//  Plumbal
//
//  Created by Casperon iOS on 17/2/2017.
//  Copyright © 2017 Casperon Tech. All rights reserved.
//

//Divya
import UIKit
import GoogleMaps
import MapKit
import SDWebImage



class InitialViewController: RootViewController,GMSMapViewDelegate,UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource,MKMapViewDelegate,BookingViewDelegate,CLLocationManagerDelegate,TaskerListViewControllerDelegate,UIViewControllerTransitioningDelegate {
    var didselectCalled : Bool = Bool()
    @IBOutlet weak var menubtn: UIButton!
    @IBOutlet var bookview: UIView!
    @IBOutlet var viewMap:GMSMapView!
    @IBOutlet var viewService:UIView!
    @IBOutlet var viewMenu:UIView!
    @IBOutlet var viewSearch:CSAnimationView!
    @IBOutlet var textLocation: UITextField!
    @IBOutlet var categoryCollectionView: UICollectionView!
    @IBOutlet var subCategoryCollectionView: UICollectionView!
    @IBOutlet var btnMarker: UIButton!
    @IBOutlet var btnLogin: TKTransitionSubmitButton!
    @IBOutlet var btnBookNow: UIButton!
    @IBOutlet var btnCurrentLocation: UIButton!
    @IBOutlet var btnBookLater: UIButton!
    @IBOutlet var map_animation_view : CSAnimationView!
    @IBOutlet var lblNoService: UILabel!
    @IBOutlet var categoryview: UIView!
    
    @IBOutlet weak var markerView: CSAnimationView!
    @IBOutlet var backgroundimg: UIImageView!
    
       @IBOutlet var app_name: UILabel!
    
       @IBOutlet var job_loc: UILabel!
    
    var bookviewend = CGRect.zero
    var viewmapend = CGRect.zero
    var categoryviewend = CGRect.zero
    var viewSearchend = CGRect.zero
    
    var isAreaSelected = false
    
    var nibView1:MarkerView!
    var locationManager = CLLocationManager()
    var currentLatitide:String = ""
    var currentLongitude:String = ""
    var selectedMarker:GMSMarker!
    var urlHandler = URLhandler()
    var refreshControl:UIRefreshControl=UIRefreshControl()
    var themes:Themes=Themes()
    var CategoryidArray:NSMutableArray=NSMutableArray()
    var ISSelectedArray : NSMutableArray = NSMutableArray()
    var CategoryimageArray:NSMutableArray=NSMutableArray()
    var CategoryInactiveImagArray : NSMutableArray = NSMutableArray()
    var Child_StatusArray:NSMutableArray=NSMutableArray()
    var CategorynameArray:NSMutableArray=NSMutableArray()
    var subCategoryImageArray:NSMutableArray=NSMutableArray()
    var subCategoryListArray:NSMutableArray=NSMutableArray()
    var subCategoryListidArray:NSMutableArray=NSMutableArray()
    var SubCategoryListStatusArray:NSMutableArray=NSMutableArray()
    var subCategoryListImageArray:NSMutableArray=NSMutableArray()
    var subCategoryListActiveImageArray:NSMutableArray=NSMutableArray()
    var subCategoryListInactiveImageArray:NSMutableArray=NSMutableArray()
    
    
    var arrayListlatlog = NSMutableArray()
    
    var valAdded_Arrlat = [String]()
    var valAddDic = [NSDictionary]()
    var checkArraylat = NSMutableArray()
    var arrayListlog = NSMutableArray()
    var valAdded_Arrlog = [String]()
    var checkArraylog = NSMutableArray()
    var checklat = [String]()
    var overlapArray = NSMutableArray()
    
    var providerList = NSArray()
    var fullAddress = String()
    var providerChosen = false
    var status : Int!
    var SelectMulti_tasker_status :Int!
    var tempUserData = ProviderMapDetails()
    
    var min_Amount:String = String()
    var lat = [String]()
    var log = [String]()
    var collectionViewWidth : CGFloat!
    var finishedAnimation = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.markerView.frame = CGRect(x:(self.map_animation_view.frame.width - self.markerView.frame.width)/2, y : ((self.map_animation_view.frame.height - self.markerView.frame.height)/2) - 30, width: self.markerView.frame.width, height: self.markerView.frame.height)
        markerView.isHidden = true
        
        btnLogin.backgroundColor = PlumberThemeColor
        btnLogin.setTitleColor(UIColor.white, for: UIControlState())
        btnLogin.titleLabel?.font = PlumberLargeFont
        btnLogin.titleLabel?.adjustsFontSizeToFitWidth = true
     didselectCalled = false
        
        if(Device_Token == "")
        {
            Device_Token="Simulator Signup"
        }
        
        markerView.isUserInteractionEnabled = false
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.startUpdatingLocation()
        
        
        nibView1 = Bundle.main.loadNibNamed("MarkerView", owner: self, options: nil)?[0] as! MarkerView
        
     //   viewService.hidden = true
        
        
        btnLogin.setTitle(themes.setLang("userlogin"), for: UIControlState())
        btnBookNow.setTitle(themes.setLang("book_now"), for: UIControlState())
        btnBookLater.setTitle(themes.setLang("book_later"), for: UIControlState())
        
        app_name.text = themes.setLang("app_name")
        job_loc.text = themes.setLang("job_loc")
        
        self.categoryCollectionView.isHidden = true
        subCategoryCollectionView.isHidden = true
        self.btnLogin.isHidden = true
        categoryview.isHidden = true
        self.SelectMulti_tasker_status = 0
        
        collectionViewWidth = self.categoryCollectionView.frame.size.width
        
        setPage()
        if themes.getEmailID() == ""{
            btnLogin.isHidden = false
            bookview.isHidden = true
            menubtn.isHidden = true
            categoryview.isHidden = true
            lblNoService.text = themes.setLang("pls_login_to")
            // Blink()
        }
        else{
            btnLogin.isHidden = true
            bookview.isHidden = false
            menubtn.isHidden = false
            categoryview.isHidden = false
            lblNoService.text = themes.setLang("no_service")
        }
        
         updateViews()
    
    
    }
    override func viewWillAppear(_ animated: Bool) {
        
  
       
//        backgroundimg.hidden = true

    }

    func updateViews(){
        finishedAnimation = false
        viewmapend = viewMap.frame
        bookviewend = bookview.frame
        categoryviewend = categoryview.frame
        
        let bookviewstart = CGRect(x: bookviewend.x, y: self.view.frame.height, width: bookviewend.width, height: bookviewend.width)
        let categoryviewstart = CGRect(x: categoryviewend.x, y: self.view.frame.height, width: categoryviewend.width, height: categoryviewend.height)
        let viewMapstart = CGRect(x: viewmapend.x, y: viewmapend.y, width: viewmapend.width, height: self.view.frame.height - viewmapend.y)

        viewMap.frame = viewMapstart
        bookview.frame = bookviewstart
        categoryview.frame = categoryviewstart
    }
    
    func updateViewAnimations(){
        
        
        self.viewSearch.transform = CGAffineTransform(scaleX: 0, y: 0);
        
        UIView.animate(withDuration: 1.5, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.viewMap.frame = self.viewmapend
            self.themes.MakeAnimation(view: self.map_animation_view, animation_type: CSAnimationTypePop)

            self.bookview.frame = self.bookviewend
            self.categoryview.frame = self.categoryviewend
            self.viewSearch.transform = CGAffineTransform(scaleX: 1, y: 1);
        }) { (finished) in
            self.finishedAnimation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8, execute: {
            self.markerView.isHidden = false
            self.themes.MakeAnimation(view: self.markerView, animation_type: CSAnimationTypeBounceDown)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
          }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK: -Function
    
    func setPage(){
        //viewMenu.roundOffBorder()
       // viewSearch.roundOffBorder()
        viewSearch.layer.borderWidth = 1.0
        viewSearch.layer.borderColor = PlumberThemeColor.cgColor
     
        viewService.layer.cornerRadius = 12
        textLocation.delegate = self
        viewMap.delegate = self
        
//        self.showProgress()
        
        NotificationCenter.default.addObserver(self, selector: #selector(InitialViewController.getLocationId(_:)), name: NSNotification.Name(rawValue: "Location"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(InitialViewController.dismissimg), name: NSNotification.Name(rawValue: "dismisspopup"), object: nil)
        
        self.Home_Datafeed()
    }
    
    func dismissimg()
    {
        self.backgroundimg.isHidden = true;
    }
    func Blink(){
        btnLogin.alpha = 0.0
        UIButton.animate(withDuration: 1, animations: {
            self.btnLogin.alpha = 1.0
            }, completion: {
                (value: Bool) in
                self.Blink()
        })
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
    
    func set_mapView(_ lat:NSString,long:NSString){
        
        let UpdateLoc = CLLocationCoordinate2DMake(CLLocationDegrees(lat as String)!,CLLocationDegrees(long as String)!)
        let camera = GMSCameraPosition.camera(withTarget: UpdateLoc, zoom: constant.mapZoomIn)
        viewMap.animate(to: camera)
        viewMap.isMyLocationEnabled = true
        
        
        
  
        
        
        viewMap.settings.setAllGesturesEnabled(true)
        viewMap.settings.scrollGestures=true
        
        
    }
    func image(from view: UIView) -> UIImage {
        if UIScreen.main.responds(to: #selector(NSDecimalNumberBehaviors.scale))
        {
            UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.main.scale)
        }
        else {
            UIGraphicsBeginImageContext(view.frame.size)
        }
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    
    func plotProviders(_ providers:NSMutableArray,taskid:String){
        
        for item in providers{
            
            let dic = item as! NSArray
            for items in dic{
                  print ("get repeated count \((item as AnyObject).count)")
                
                
                let dictionary = items as! NSDictionary
                let latitude:NSString = "\(dictionary.value(forKey: "lat")!)" as NSString
                let longitude:NSString = "\(dictionary.value(forKey: "lng")!)" as NSString
                
                
                let camera = GMSCameraPosition.camera(withLatitude: latitude.doubleValue,
                                                                  longitude: longitude.doubleValue, zoom:15)
                let userData = createProvidersData(dictionary,taskid:taskid )
                let marker = GMSMarker()
                
                
                marker.position = camera.target
                marker.appearAnimation = .pop
                marker.opacity = 1.0
               
                marker.icon = UIImage(named: "marker-1")
                
                
                
                SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string: userData.service_icon)!, options: .highPriority, progress: nil, completed: { (image, error, cache, url) in
                    if image != nil{
                                if (item as AnyObject).count > 1
                                {
                                    let getimage: UIImage = self.imageByCombiningImage(UIImage(named: "marker-1")!, withImage:image!,drawText: "")
                                        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 70))
                                        let pinImageView = UIImageView.init()
                                        pinImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 47)
                                        pinImageView.image = getimage
                                        
                                        let label = UILabel()
                                        label.frame = CGRect(x: 35, y: 5, width: 15, height: 15)
                                           label.text = "1+"
                                         label.font = PlumberSmallFont
                                        label.textColor = UIColor.white
                                        label.backgroundColor = PlumberBlueColor
                                        label.layer.cornerRadius = label.frame.size.height / 2
                                    label.adjustsFontSizeToFitWidth = true
                                         label.layer.masksToBounds = true
                                    label.minimumScaleFactor = 0.5
                                        // label.sizeToFit()
                                        label.numberOfLines = 3
                                        // label.adjustsFontSizeToFitWidth = true;
                                        view.addSubview(pinImageView)
                                        view.addSubview(label)
                                        //i.e. customize view to get what you need
                                    let markerIcon: UIImage? = self.image(from: view)
                                        marker.icon = markerIcon
                                    
                                }
                                else
                                {
                                    marker.icon = self.imageByCombiningImage(UIImage(named: "marker-1")!, withImage:image!,drawText: "")

                                }
                    }
                })
                
                
                marker.userData = userData
                marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.2)
                marker.map = viewMap
                
                
                
                //  bounds = bounds.includingCoordinate(marker.position)
            }
        }
        
        
        
        
        
        if isAreaSelected == true{
            isAreaSelected = false
        }
    }
    
    func translateCoordinate(_ coordinate: CLLocationCoordinate2D, metersLat: Double,metersLong: Double) -> (CLLocationCoordinate2D) {
        var tempCoord = coordinate
        
        let tempRegion = MKCoordinateRegionMakeWithDistance(coordinate, metersLat, metersLong)
        let tempSpan = tempRegion.span
        
        tempCoord.latitude = coordinate.latitude + tempSpan.latitudeDelta
        tempCoord.longitude = coordinate.longitude + tempSpan.longitudeDelta
        
        return tempCoord
    }
    
    func setRadius(_ radius: Double,withCity city: CLLocationCoordinate2D,InMapView mapView: GMSMapView) {
        
        let range = self.translateCoordinate(city, metersLat: radius * 2, metersLong: radius * 2)
        
        let bounds = GMSCoordinateBounds(coordinate: city, coordinate: range)
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50)    // padding set to 5.0
        //        let marker = GMSMarker(position: city)
        //        marker.title = "title"
        //        marker.snippet = "snippet"
        //        marker.flat = true
        //        marker.map = mapView
        //
        //        // draw circle
        //        let circle = GMSCircle(position: city, radius: radius)
        //        circle.map = mapView
        //        circle.fillColor = UIColor(red:0.09, green:0.6, blue:0.41, alpha:0.5)
        mapView.moveCamera(update)
        mapView.animate(toLocation: city)
        mapView.animate(toZoom: 11 )
        // animate to center
        
        
        // animate to center
    }
    
    func createProvidersData(_ providers:NSDictionary,taskid:String)->ProviderMapDetails{
        
        let providerObj = ProviderMapDetails()
        providerObj.tasker_id = self.themes.CheckNullValue(providers.object(forKey: "taskerid"))!
        providerObj.Name = self.themes.CheckNullValue(providers.object(forKey: "name"))!
        providerObj.service_icon = self.themes.CheckNullValue(providers.object(forKey: "image_url"))!
        providerObj.available = self.themes.CheckNullValue(providers.object(forKey: "availability"))!
        providerObj.company = self.themes.CheckNullValue(providers.object(forKey: "company"))!
        providerObj.rating = self.themes.CheckNullValue(providers.object(forKey: "rating"))!
        providerObj.min_amount = self.themes.CheckNullValue(providers.object(forKey: "min_amount"))!
        providerObj.hour_amount = self.themes.CheckNullValue(providers.object(forKey: "hourly_amount"))!
        providerObj.lat = self.themes.CheckNullValue(providers.object(forKey: "lat"))!
        providerObj.lng = self.themes.CheckNullValue(providers.object(forKey: "lng"))!
        providerObj.workLoc = self.themes.CheckNullValue(providers.object(forKey: "worklocation"))!
        
        providerObj.taskid = taskid
        let obj = providerObj
        
        return obj
    }
    
    
    
    func delay(_ seconds: Double, completion:@escaping ()->()) {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            completion()
        }
    }
    
    func getLocationId(_ notify:Notification){
        isAreaSelected = true
        didselectCalled = true
        let sampleArray = notify.object as! NSArray
        self.textLocation.text = sampleArray.object(at: 2) as? String
        self.textLocation.endEditing(true)
        currentLatitide = "\(sampleArray.object(at: 0))"
        currentLongitude = "\(sampleArray.object(at: 1))"
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        self.set_mapView("\(sampleArray.object(at: 0))" as NSString, long: "\(sampleArray.object(at: 1))" as NSString)
        //        }
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        
        if self.status != nil
        {
        self.mapProviders(self.status)
        }
        //        }
    }
    
    func displayanimateViewController(_ animationType: SLpopupViewAnimationType) {
        
        let book:TaskerListViewController = TaskerListViewController(nibName:"TaskerListViewController", bundle: nil)
        book.delegate = self
        
        book.transitioningDelegate = self
        
        book.modalPresentationStyle = .custom
        
        self.navigationController?.present(book, animated: true, completion: nil)
        //self.navigationController?.pushViewController(withFlip: book, animated: true)
    }
    
    func pressCancel(_ sender: TaskerListViewController) {
        self.backgroundimg.isHidden = true
        
        self.dismiss(animated: true, completion: nil)
        
    }
    func displayViewController(_ animationType: SLpopupViewAnimationType) {
        let book:BookingView = BookingView(nibName:"BookingView", bundle: nil)
        book.delegate = self
        if SelectMulti_tasker_status == 1
        {
            book.taskernamestr = self.themes.CheckNullValue(Tasker_Data.SelectedTaskerDict.object(forKey: "name"))!
        }
        else{
            book.taskernamestr = self.nibView1.lblName.text!
        }
        book.transitioningDelegate = self
        
        book.modalPresentationStyle = .custom
        
        self.navigationController?.present(book, animated: true, completion: nil)
    }
    
    
    func pressedCancel(_ sender: BookingView) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func pressBooking(_ confimDate: NSString, Confirmtime: NSString, Instructionstr: NSString) {
        
        
        var getinst = String()
        
        getinst = Instructionstr as String
       
        self.dismiss(animated: true, completion: nil)

                self.showServiceProgress(rect: map_animation_view.frame)

//            self.showProgress()
            let addr = getAddressForLatLng(currentLatitide, longitude: currentLongitude)
            let getaddress = addr.replacingOccurrences(of: "$", with:" ")
            let tempAddArray = fullAddress.components(separatedBy: "$")
            for item in tempAddArray{
                print(item)
            }
            
            var  param = NSDictionary()
            if SelectMulti_tasker_status == 1
            {
                param = ["user_id":"\(themes.getUserID())",
                         "street":"\(tempAddArray[0])",
                         "city":"\(tempAddArray[2])",
                         "state":"\(tempAddArray[3])",
                         "country":"\(tempAddArray[4])",
                         "zipcode":"\(tempAddArray[5])",
                         "lng":"\(currentLongitude)",
                         "lat":"\(currentLatitide)",
                         "locality":"\(getaddress)",
                         "taskerid":"\(Tasker_Data.SelectedTaskerDict.object(forKey: "taskerid")!)",
                         "taskid":"\(Tasker_Data.SelectedTaskerDict.object(forKey: "Taskid")!)",
                         "instruction" :"\(getinst)",
                         "pickup_date":"\(confimDate)",
                         "pickup_time":"\(Confirmtime)"]
            }
            else{
                
                let markerData = selectedMarker.userData as! ProviderMapDetails
                
                let addr = getAddressForLatLng(currentLatitide, longitude: currentLongitude)
                let getaddress = addr.replacingOccurrences(of: "$", with:" ")

                let tempAddArray = fullAddress.components(separatedBy: "$")
                
                
                param = ["user_id":"\(themes.getUserID())",
                         "street":"\(tempAddArray[0])",
                         "city":"\(tempAddArray[2])",
                         "state":"\(tempAddArray[3])",
                         "country":"\(tempAddArray[4])",
                         "zipcode":"\(tempAddArray[5])",
                         "lng":"\(currentLongitude)",
                         "lat":"\(currentLatitide)",
                         "locality":"\(getaddress)",
                         "taskerid":"\(markerData.tasker_id)",
                         "taskid":"\(markerData.taskid)",
                         "instruction" :"\(getinst)",
                         "pickup_date":"\(confimDate)",
                         "pickup_time":"\(Confirmtime)"]
            }
            
            urlHandler.makeCall(constant.MapOrder_confirm, param: param) { (responseObject, error) -> () in
                self.DismissServiceProgress()
//                self.DismissProgress()
                if(error != nil){
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                } else{
                    
                    
                    if(responseObject != nil){
                        let Dict:NSDictionary=responseObject!
                        let Status=self.themes.CheckNullValue(Dict.object(forKey: "status"))!
                        if(Status == "1"){
                            let response:NSDictionary=Dict.object(forKey: "response") as! NSDictionary
                            let jobID:NSString=response.object(forKey: "job_id") as! NSString
                            Schedule_Data.JobID="\(jobID)"
                            Schedule_Data.orderDate = response.object(forKey: "booking_date") as! String
                            Schedule_Data.service = response.object(forKey: "service_type") as! String
                            Schedule_Data.jobDescription = response.object(forKey: "description") as! String
                            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmPageVCID") as! OrderConfirmationViewController
                            self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)
                            
                        }
                        else {
                            
                            let Response = self.themes.CheckNullValue(Dict.object(forKey: "response"))!
                            self.themes.AlertView("\(Appname)", Message: Response, ButtonTitle: self.themes.setLang("ok"))
                        }
                    }
                    else {
                        self.themes.AlertView("\(Appname)", Message: self.themes.setLang("No Reasons available"), ButtonTitle: self.themes.setLang("ok"))
                    }
                }
            }
        
    }
    
    
    func Home_Datafeed() {
        let param:Dictionary=["location_id":"\(themes.getLocationID())"]
        urlHandler.makeCall(constant.Get_Categories, param: param as NSDictionary) { (responseObject, error) -> () in
//            self.DismissProgress()
            self.refreshControl.endRefreshing()
                self.updateViewAnimations()
                if(error != nil){
                    //self.settablebackground()
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                }  else {
                    if(responseObject != nil) {
                        let dict:NSDictionary=responseObject!
                        let Status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                        if(Status != ""){
                            if(Status == "1")  {
                                self.status = 0
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                                    self.mapProviders(self.status)
                                })
                                if(self.CategoryidArray.count != 0) {
                                    self.CategoryidArray.removeAllObjects()
                                    self.CategoryimageArray.removeAllObjects()
                                    self.CategoryInactiveImagArray.removeAllObjects()
                                    self.CategorynameArray.removeAllObjects()
                                    self.Child_StatusArray.removeAllObjects()
                                    self.ISSelectedArray.removeAllObjects()
                                }
                                let CategoryArray:NSArray=(responseObject?.object(forKey: "response")! as AnyObject).object(forKey: "category") as! NSArray
                                for Dictionary in CategoryArray{
                                    let categoryid=(Dictionary as AnyObject).object(forKey: "cat_id") as! String
                                    self.CategoryidArray.add(categoryid)
                                    let categoryimage1=(Dictionary as AnyObject).object(forKey: "active_icon") as! String
                                    self.CategoryimageArray.add(categoryimage1)
                                    let categoryinactiveimage=self.themes.CheckNullValue((Dictionary as AnyObject).object(forKey: "inactive_icon"))!
                                    self.CategoryInactiveImagArray.add(categoryinactiveimage)
                                    let categoryname1=(Dictionary as AnyObject).object(forKey: "cat_name") as! String
                                    self.CategorynameArray.add(categoryname1)
                                    let childstatus1=(Dictionary as AnyObject).object(forKey: "hasChild") as! String
                                    self.Child_StatusArray.add(childstatus1)
                                    
                                    let isselected : String = "0"
                                    
                                    self.ISSelectedArray.add(isselected)
                                }
                                if self.themes.getEmailID() != ""{
                                    self.categoryCollectionView.isHidden=false
                                    self.categoryview.isHidden = false
                                    self.categoryCollectionView.delegate = self
                                    self.categoryCollectionView.dataSource = self
                                    self.categoryCollectionView.reloadData()
                                }
                                //                            self.Home_tableView.backgroundView=nil
                            } else {
                                //                            self.settablebackground()
                                if (responseObject?.object(forKey: "response") != nil) {
                                    let Response:NSString=responseObject?.object(forKey: "response") as! NSString
                                    self.themes.AlertView("\(Appname)", Message: "\(Response)", ButtonTitle: kOk)
                                }
                            }
                        }else {
                            // self.settablebackground()
                            self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                        }
                    }else {
                        //self.settablebackground()
                        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    }
                }
        }
    }
    
    func Category_feed() {
        let param=["category":"\(Home_Data.Category_id)", "location_id":"\(themes.getLocationID())"]
        urlHandler.makeCall("\(constant.Get_SubCategories)", param: param as NSDictionary) { (responseObject, error) -> () in
            self.refreshControl.endRefreshing()
            self.DismissServiceProgress()
//            self.DismissProgress()
            
            if(error != nil) {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
            }
            else {
                if(responseObject != nil) {
                    let dict:NSDictionary=responseObject!
                    
                    let Status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                    if(Status == "1") {
                        
                        self.subCategoryCollectionView.isHidden = false
                        
                        if(self.subCategoryListidArray.count != 0){
                            self.SubCategoryListStatusArray.removeAllObjects()
                            self.subCategoryListidArray.removeAllObjects()
                            self.subCategoryListImageArray.removeAllObjects()
                            self.subCategoryListActiveImageArray.removeAllObjects()
                            self.subCategoryListInactiveImageArray.removeAllObjects()
                            
                            self.subCategoryImageArray.removeAllObjects()
                            self.subCategoryListArray.removeAllObjects()
                        }
                        let CategoryArray:NSArray=(responseObject?.object(forKey: "response")! as AnyObject).object(forKey: "category") as! NSArray
                        for Dictionary in CategoryArray{
                            let categoryid=(Dictionary as AnyObject).object(forKey: "cat_id") as! String
                            self.subCategoryListidArray.add(categoryid)
                            let categoryimage = self.themes.CheckNullValue((Dictionary as AnyObject).object(forKey: "icon"))!
                            self.subCategoryListImageArray.add(categoryimage)
                            let categoryname=(Dictionary as AnyObject).object(forKey: "cat_name") as! String
                            self.subCategoryListArray.add(categoryname)
                            _=(Dictionary as AnyObject).object(forKey: "hasChild") as! NSString
                            let categoryActiveImage=(Dictionary as AnyObject).object(forKey: "active_icon") as! String
                            self.subCategoryListActiveImageArray.add(categoryActiveImage)
                            let categoryInactivename=(Dictionary as AnyObject).object(forKey: "inactive_icon") as! String
                            self.subCategoryListInactiveImageArray.add(categoryInactivename)
                            
                            self.SubCategoryListStatusArray.add("0")
                            
                        }
                        self.subCategoryCollectionView.delegate = self
                        self.subCategoryCollectionView.dataSource = self
                        self.subCategoryCollectionView.reloadData()
                    }   else {
                        self.subCategoryCollectionView.isHidden = true
                        // self.themes.AlertView("\(Appname)", Message: self.themes.setLang("no_category"), ButtonTitle: kOk)
                    }
                }else{
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    //self.settablebackground()
                }
            }
        }
    }
    
    
    
    func mapProviders(_ status:Int){
        
        if themes.getEmailID() != ""
        {
            viewService.isHidden = true
            self.showServiceProgress(rect: map_animation_view.frame)

//            self.showProgress()
        
        var param = NSDictionary()
        if (status == 0){
            param=["user_id":"\(themes.getUserID())","lat":"\(currentLatitide)","long":"\(currentLongitude)"]
        }else if (status == 1){
            param=["user_id":"\(themes.getUserID())","lat":"\(currentLatitide)","long":"\(currentLongitude)","maincategory":"\(Home_Data.Category_id)"]
        }else if (status == 2){
            param=["user_id":"\(themes.getUserID())","lat":"\(currentLatitide)","long":"\(currentLongitude)","category":"\(Home_Data.Category_id)"]
        }
        urlHandler.makeCall(constant.Map_Providers, param: param) { (responseObject, error) -> () in
            self.DismissServiceProgress()
//            self.DismissProgress()
            self.checkArraylat.removeAllObjects()
            self.checkArraylog.removeAllObjects()
            self.arrayListlatlog.removeAllObjects()
            self.lat.removeAll()
            self.log.removeAll()
            //            self.checklat.removeAll()
            
            self.refreshControl.endRefreshing()
            if(error != nil){
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
            }  else {
                if(responseObject != nil) {
                    let dict:NSDictionary=responseObject!
                    let Status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                    if(Status != ""){
                        self.btnMarker.isHidden = false
                        if(Status == "1")  {
                            var taskId = String()
                            if(status == 2){
                                taskId=dict.object(forKey: "task_id") as! NSString as String
                                
                            }else{
                                taskId = ""
                            }
                            
                            self.providerList = dict.object(forKey: "response") as! NSArray
                            self.min_Amount = self.themes.CheckNullValue(dict.object(forKey: "minimum_amount"))!
                            
                            for item in self.providerList{
                                let dic = item as! NSDictionary
                                let latitude:String = "\(dic.value(forKey: "lat")!)"
                                let longitude:String = "\(dic.value(forKey: "lng")!)"
                                
                                let latt = String(latitude.dropLast())
                                let logg = String(longitude.dropLast())
                                
                                self.lat.append(latt)
                                self.log.append(logg)
                                
                            }
                            self.check(self.providerList,taskid:taskId)
                            
                        } else {
                            self.viewService.isHidden = false
                            if (responseObject?.object(forKey: "response") != nil) {
                                if (responseObject?.object(forKey: "response"))! as! String == "User ID is Required" && status == 1{
                                }
                                
                                //let Response:NSString=responseObject?.objectForKey("response") as! NSString
                                //self.themes.AlertView("\(Appname)", Message: "\(Response)", ButtonTitle: kOk)
                            }
                        }
                    }else {
                        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    }
                }else {
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                }
            }
        }
        
    }
        else
        {
             lblNoService.text = themes.setLang("pls_login_to")
        }
    }
    
    func check(_ providers:NSArray,taskid:String)
    {
        
        for i in 0 ..< lat.count{
            valAddDic.removeAll()
            var valueChecking:Int = 0
            
            
            if checkArraylat.contains(lat[i]) && checkArraylog.contains(log[i]){
                continue
                
            }
                
            else{
                
                
                
                checkArraylat.add(lat[i])
                checkArraylog.add(log[i])
                for j in 0 ..< lat.count{
                    
                    if lat[i] == lat[j] && log[i] == log[j] {
                        valueChecking += 1
                        if providers.count > 0{
                            let dic = providers[j] as! NSDictionary
                            if valueChecking > 1
                            {
                                checklat.append(lat[i])
                            }
                            valAddDic.append(["lat":"\(lat[i])","lng":"\(log[i])","availability":self.themes.CheckNullValue(dic.object(forKey: "availability"))!,"cat_img":self.themes.CheckNullValue(dic.object(forKey: "cat_img"))!,"company":self.themes.CheckNullValue(dic.object(forKey: "company"))!,"distance_km":self.themes.CheckNullValue(dic.object(forKey: "distance_km"))!,"distance_mile":self.themes.CheckNullValue(dic.object(forKey: "distance_mile"))!,"hourly_amount":self.themes.CheckNullValue(dic.object(forKey: "hourly_amount"))!,"image_url":self.themes.CheckNullValue(dic.object(forKey: "image_url"))!,"marker_img":self.themes.CheckNullValue(dic.object(forKey: "marker_img"))!,"min_amount":self.themes.CheckNullValue(dic.object(forKey: "min_amount"))!,"name":self.themes.CheckNullValue(dic.object(forKey: "name"))!,"radius":self.themes.CheckNullValue(dic.object(forKey: "radius"))!,"rating":self.themes.CheckNullValue(dic.object(forKey: "rating"))!,"reviews":self.themes.CheckNullValue(dic.object(forKey: "reviews"))!,"taskerid":self.themes.CheckNullValue(dic.object(forKey: "taskerid"))!,"worklocation":self.themes.CheckNullValue(dic.object(forKey: "worklocation"))!,"Taskid":taskid])
                        }
                    }
                }
                
                
                
            }
            arrayListlatlog.add(valAddDic)
        }
        
        
        self.plotProviders(self.arrayListlatlog,taskid: taskid)
        
    }
    
    func imageByCombiningImage(_ firstImage: UIImage, withImage secondImage: UIImage,drawText:String) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(firstImage.size, false, 0.0)
        var resultImage: UIImage? = nil
        // Get the graphics context
        let context = UIGraphicsGetCurrentContext()
        // Draw the first image
        firstImage.draw(in: CGRect(x: 0, y: 0, width: firstImage.size.width, height: firstImage.size.height))
        // Get the frame of the second image
        let rect = CGRect(x: 7.5, y: 6.5, width: 25, height: 26)
        // Add the path of an ellipse to the context
        // If the rect is a square the shape will be a circle
        context?.addEllipse(in: rect)
        // Clip the context to that path
        context?.clip()
        // Do the second image which will be clipped to that circle
        secondImage.draw(in: rect)
        // Get the result
        resultImage = UIGraphicsGetImageFromCurrentImageContext()
        // End the image context
        UIGraphicsEndImageContext()
        return resultImage!
    }
    
    
    
    //MARK: - Button Action
    
    @IBAction func didClickMenu(_ sender: AnyObject) {
        self.findHamburguerViewController()?.showMenuViewController()
        
    }
    
    @IBAction func didClickLocation(_ sender: AnyObject) {
        self.locationManager.startUpdatingLocation()
        
    }
    
    @IBAction func didClickLogin(_ sender: AnyObject) {
        btnLogin.startLoadingAnimation(withloader: false)
        btnLogin.startFinishAnimation(0.1, completion: {
            Appdel.Make_RootVc("DLDemoRootViewController", RootStr: "signinVCID")
        })
    }
    
    
    @IBAction func didClickbookNow(_ sender: AnyObject) {
       
        
        

        
        if(self.status == 2) && providerChosen == true{
            
            
            self.displayViewController(.bottomBottom)
            
            //            let AlertView:UIAlertView=UIAlertView()
            //            AlertView.delegate=self
            //            AlertView.title="Are you sure you want to book?"
            //            AlertView.addButtonWithTitle("Confirm")
            //            AlertView.addButtonWithTitle("Cancel")
            //            AlertView.show()
            //            AlertView.tag = 0
            
        }else{
            if status != nil{
            
            if status == 0 {
                themes.AlertView("", Message: themes.setLang("choose_cat"), ButtonTitle: kOk)
                
            }else if status == 1{
                themes.AlertView("", Message:themes.setLang("choose_subcat"), ButtonTitle: kOk)
                
            }else if status == 2{
                themes.AlertView("", Message: themes.setLang("choose_tasker"), ButtonTitle: kOk)
            }
            }
            else{
               themes.AlertView("", Message:themes.setLang("Error in Network Connection"), ButtonTitle: kOk)
            }
        }
        
    }
    
    
    
    @IBAction func didClickBookLater(_ sender: AnyObject) {
        if status != nil{
        if status == 0{
            themes.AlertView("", Message: themes.setLang("choose_cat"), ButtonTitle: kOk)
            
        }else if status == 1{
            themes.AlertView("", Message: themes.setLang("choose_subcat"), ButtonTitle: kOk)
            
        }else{
            if currentLatitide != ""{
                let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleViewControllerID") as! ScheduleViewController
                secondViewController.Latitude = currentLatitide
                secondViewController.Longitude = currentLongitude
                
                self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)
            }
        }
    }
    }
    
    func didClickMarkerView(_ sender: AnyObject) {
     //   backgroundimg.hidden = true

        
        
        let taskerpro:TaskerProfileViewController = TaskerProfileViewController(nibName:"TaskerProfileViewController", bundle: nil)
             taskerpro.providerid = tempUserData.tasker_id
                taskerpro.minCost =  self.min_Amount
                taskerpro.hourlyCost = tempUserData.hour_amount
           taskerpro.taskid = tempUserData.taskid
        taskerpro.getlat = currentLatitide
        taskerpro.getlng = currentLongitude
        taskerpro.hideView = "1"
        self.navigationController?.pushViewController(withFlip: taskerpro, animated: true)
       
        
        //self.navigationController?.pushViewController(withFlip: book, animated: true)
      
        
    }
    
    func didClickChat(_ sender: AnyObject) {
       // backgroundimg.hidden = true

        Message_details.taskid = tempUserData.taskid
        Message_details.providerid = tempUserData.tasker_id
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageVC") as! MessageViewController
        self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)
        
    }
    func didClickClose(_ sender: AnyObject) {
        
        backgroundimg.isHidden = true

//        self.selectedMarker.icon = UIImage(named: "marker-1")
//

        
        SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string:self.tempUserData.service_icon )!, options: .highPriority,progress: nil, completed: {(image, error, cache, url) in
            
                DispatchQueue.main.async {
//                    if image != nil{
//                        self.selectedMarker.icon = self.imageByCombiningImage(UIImage(named: "marker-1")!, withImage:image!,drawText: "")
//
//                    }
                }
            })

        btnMarker.isHidden = false
        themes.MakeAnimation(view: nibView1, animation_type: CSAnimationTypePopAlphaOut)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.nibView1.removeFromSuperview()
        })
        providerChosen = false
    }
    
    func didClickAccept(_ sender: AnyObject) {
         backgroundimg.isHidden = true
        providerChosen = true
        themes.AlertView("", Message: "\(themes.setLang("selected1")) \(self.nibView1.lblName.text!) \(themes.setLang("selected2"))", ButtonTitle: kOk)
        
        btnMarker.isHidden = false
//        self.selectedMarker.icon = UIImage.init(named: "SelectedMarker")

        
        SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL.init(string:self.tempUserData.service_icon )!, options: .highPriority,progress: nil, completed: { (image, error, cache, url) in
            
                DispatchQueue.main.async {
//                    if image != nil{
//                        self.selectedMarker.icon = self.imageByCombiningImage(UIImage(named: "SelectedMarker")!, withImage:image!,drawText: "")
//
//                    }
                }
            })
        
        themes.MakeAnimation(view: nibView1, animation_type: CSAnimationTypePopAlphaOut)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.nibView1.removeFromSuperview()
        })

        
        
    }
    
    func pressSelected(_ Sel_Tasker_Detail: NSDictionary, providername: String) {
        self.backgroundimg.isHidden = true
       
        self.dismiss(animated: true, completion: nil)
        providerChosen = true
        self.nibView1.removeFromSuperview()
        themes.AlertView("", Message: "\(themes.setLang("selected1")) \(providername) \(themes.setLang("selected2"))", ButtonTitle: kOk)

        
        self.SelectMulti_tasker_status = 1
        
        Tasker_Data.SelectedTaskerDict = Sel_Tasker_Detail
        
        fullAddress = ""
        
        self.btnMarker.isHidden = false
        self.providerChosen = true
//        self.selectedMarker.icon = UIImage.init(named: "SelectedMarker")
        self.nibView1.removeFromSuperview()
        
   
        
    }
    
    func pressMessageVC(_ taskid: String, taskerid: String)
    {
        self.backgroundimg.isHidden = true
        self.dismiss(animated: true, completion: nil)
        Message_details.taskid = taskid
        Message_details.providerid = taskerid
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageVC") as! MessageViewController
        self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)
        
        
        
    }
    func pressDetailVC(_ min: String, taskerid: String, hour: String , task_id : String) {
        self.backgroundimg.isHidden = true
        self.dismiss(animated: true, completion: nil)
        let taskerpro:TaskerProfileViewController = TaskerProfileViewController(nibName:"TaskerProfileViewController", bundle: nil)
        taskerpro.providerid = taskerid
        taskerpro.minCost =  self.min_Amount
        taskerpro.hourlyCost = tempUserData.hour_amount
        taskerpro.taskid = task_id
        taskerpro.getlat = currentLatitide
        taskerpro.getlng = currentLongitude
        taskerpro.hideView = "1"
        self.navigationController?.pushViewController(withFlip: taskerpro, animated: true)
        
        
    }
    
    
    
    //MARK: - LocationManager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _ = CLGeocoder()
        let current = locations[0]
        if current.coordinate.latitude != 0 {
            currentLatitide = "\(current.coordinate.latitude)"
            currentLongitude = "\(current.coordinate.longitude)"
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
                    
            })
            

            self.locationManager.stopUpdatingLocation()
            let getaddress = getAddressForLatLng("\(currentLatitide)", longitude: "\(current.coordinate.longitude)")
            textLocation.text = getaddress.replacingOccurrences(of: "$", with: " ")
            set_mapView(currentLatitide as NSString, long: currentLongitude as NSString)
            
        }
    }
    
//    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//
//        if didselectCalled == false{
//        let getaddress = getAddressForLatLng("\(mapView.camera.target.latitude)", longitude: "\(mapView.camera.target.longitude)")
//        textLocation.text = getaddress.replacingOccurrences(of: "$", with: " ")
//        self.currentLatitide = "\(mapView.camera.target.latitude)"
//        self.currentLongitude = "\(mapView.camera.target.longitude)"
//        print("crash  occured")
//
//        if self.status != nil && finishedAnimation
//        {
//            self.mapProviders(self.status)
//        }
//        }else
//        {
//        didselectCalled = false
//     }
//    }
    
    func mapView(_ mapView: GMSMapView, didChange didChangeCameraPosition: GMSCameraPosition) {
        
        // currentLatitide = "\(mapView.camera.target.latitude)"
        // currentLongitude = "\(mapView.camera.target.longitude)"
        // set_mapView("\(mapView.camera.target.latitude)", long: "\(mapView.camera.target.longitude)")
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
       
        overlapArray.removeAllObjects()
        
        
        if status == 2{
             backgroundimg.isHidden = false
            btnMarker.isHidden = true
//            if selectedMarker != nil{
//                selectedMarker.icon = UIImage.init(named: "marker-1")
//            }
            selectedMarker = marker
            
            let temp = marker.userData as! ProviderMapDetails
            let userData = marker.userData as! ProviderMapDetails
            let doubleLat = Double.init(userData.lat)
            let doubleLng = Double.init(userData.lng)
            for item in arrayListlatlog
            {
                let dic = item as! NSArray
                for items in dic{
                    
                    let dictionary = items as! NSDictionary
                    let latitude:NSString = "\(dictionary.value(forKey: "lat")!)" as NSString
                    let longitude:NSString = "\(dictionary.value(forKey: "lng")!)" as NSString
                    if userData.lat == latitude as String && userData.lng == longitude as String
                    {
                        overlapArray.add(dictionary)
                        
                    }
                    
                    
                }
            }
            
            
            
            
            if checklat.contains(userData.lat)
            {
                
                if   overlapArray.count == 1
                {
                    _ = CLLocationCoordinate2D(latitude:doubleLat! , longitude:doubleLng!)
                    self.nibView1.userImage.sd_setImage(with: URL.init(string: userData.service_icon), placeholderImage: UIImage(named: "PlaceHolderSmall"))
                    let strRating = "\(userData.rating)"
                    let n = NumberFormatter().number(from: strRating)
                    
                    self.nibView1.btnChat.setTitle("\(themes.setLang("chat_space"))", for: UIControlState())
                    self.nibView1.btnViewDetails.setTitle("\(themes.setLang("detail"))", for:UIControlState())


                    self.nibView1.select.text = "\(themes.setLang("select_tasker"))"
                    self.nibView1.close.text = "\(themes.setLang("close"))"
                    self.nibView1.minCOst.text = "\(self.themes.setLang("hour_cost")) : \(self.themes.getCurrencyCode())\(userData.hour_amount)"
                    self.nibView1.providerRating.emptySelectedImage = UIImage(named: "whitStar")
                    self.nibView1.providerRating.fullSelectedImage = UIImage(named: "whitstartselect")
                    self.nibView1.providerRating.contentMode = UIViewContentMode.scaleAspectFill
                    self.nibView1.providerRating.maxRating = 5
                    self.nibView1.providerRating.minRating = 1
                    self.nibView1.providerRating.rating = CGFloat(n!)
                    self.nibView1.providerRating.editable = false;
                    self.nibView1.providerRating.halfRatings = true;
                    self.nibView1.providerRating.floatRatings = false;
                    self.tempUserData = userData
                    self.nibView1.lblName.text = temp.Name
                    
                    self.nibView1.lblAdd.text = temp.workLoc.replacingOccurrences(of: "$", with: " ")
                    self.nibView1.btnChat.addTarget(self, action: #selector(InitialViewController.didClickChat(_:)), for: UIControlEvents.touchUpInside)
                    self.nibView1.center = CGPoint(x: self.viewMap.frame.size.width  / 2,
                                                       y: self.viewMap.frame.size.height / 2-35);
                    self.nibView1.btnViewDetails.addTarget(self, action: #selector(InitialViewController.didClickMarkerView(_:)), for: UIControlEvents.touchUpInside)
                    self.nibView1.btnClose.addTarget(self, action: #selector(InitialViewController.didClickClose(_:)), for: UIControlEvents.touchUpInside)
                    self.nibView1.btnAccept.isHidden = false
                    self.nibView1.btnAccept.addTarget(self, action: #selector(InitialViewController.didClickAccept(_:)), for: UIControlEvents.touchUpInside)
                    self.view.addSubview(self.nibView1)
                    themes.MakeAnimation(view: self.nibView1, animation_type: CSAnimationTypePopAlpha)
                }
                else{
                    Tasker_Data.overlapTaskersArray = overlapArray
                    self.displayanimateViewController(.bottomBottom)
                }
                //return true
            }
            else{
                
                _ = CLLocationCoordinate2D(latitude:doubleLat! , longitude:doubleLng!)
                self.nibView1.userImage.sd_setImage(with: URL.init(string: userData.service_icon), placeholderImage: UIImage(named: "PlaceHolderSmall"))
                let strRating = "\(userData.rating)"
                let n = NumberFormatter().number(from: strRating)
                self.nibView1.btnChat.setTitle("\(themes.setLang("chat_space"))", for: UIControlState())
                self.nibView1.btnViewDetails.setTitle("\(themes.setLang("detail"))", for:UIControlState())
                self.nibView1.select.text = "\(themes.setLang("select_tasker"))"
                self.nibView1.close.text = "\(themes.setLang("close"))"
                
                self.nibView1.minCOst.text = "\(self.themes.setLang("hour_cost")) : \(self.themes.getCurrencyCode())\(userData.hour_amount)"
                self.nibView1.providerRating.emptySelectedImage = UIImage(named: "whitStar")
                self.nibView1.providerRating.fullSelectedImage = UIImage(named: "whitstartselect")
                self.nibView1.providerRating.contentMode = UIViewContentMode.scaleAspectFill
                self.nibView1.providerRating.maxRating = 5
                self.nibView1.providerRating.minRating = 1
                self.nibView1.providerRating.rating = CGFloat(n!)
                self.nibView1.providerRating.editable = false;
                self.nibView1.providerRating.halfRatings = true;
                self.nibView1.providerRating.floatRatings = false;
                self.tempUserData = userData
                self.nibView1.lblName.text = temp.Name
                
                self.nibView1.lblAdd.text = temp.workLoc.replacingOccurrences(of: "$", with: " ")
                self.nibView1.btnChat.addTarget(self, action: #selector(InitialViewController.didClickChat(_:)), for: UIControlEvents.touchUpInside)
                self.nibView1.center = CGPoint(x: self.viewMap.frame.size.width  / 2,
                                                   y: self.viewMap.frame.size.height / 2-35);
                self.nibView1.btnViewDetails.addTarget(self, action: #selector(InitialViewController.didClickMarkerView(_:)), for: UIControlEvents.touchUpInside)
                self.nibView1.btnClose.addTarget(self, action: #selector(InitialViewController.didClickClose(_:)), for: UIControlEvents.touchUpInside)
                self.nibView1.btnAccept.isHidden = false
                self.nibView1.btnAccept.addTarget(self, action: #selector(InitialViewController.didClickAccept(_:)), for: UIControlEvents.touchUpInside)
                
                self.view.addSubview(self.nibView1)
                themes.MakeAnimation(view: self.nibView1, animation_type: CSAnimationTypePopAlpha)
            }
        }
        else if status == 1
            
        {
            themes.AlertView("", Message:themes.setLang("choose_subcat"), ButtonTitle: kOk)
            
        }
        else{
            
            
            themes.AlertView("", Message: themes.setLang("choose_cat"), ButtonTitle: kOk)
            
        }
        
        return true
    }
    
    
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        //        let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MYProfileVCSID") as! MyProfileViewController
        //        secondViewController.providerid = tempUserData.job_id
        //        self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)
        
    }
    
    
    
    
    //MARK: - textField Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.nibView1.removeFromSuperview()
        
        if currentLatitide != ""{
            let navig = self.storyboard?.instantiateViewController(withIdentifier: "NormalViewController") as! ChooseLocationViewController
            navig.lat = currentLatitide
            navig.long = currentLongitude
            textField.endEditing(true)
            self.navigationController?.pushViewController(withFlip: navig, animated: true)
        }
    }
    
    //MARK: - Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView{
            return CategoryimageArray.count
        }else if collectionView == subCategoryCollectionView{
            return subCategoryListidArray.count
        }
        return 0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == categoryCollectionView{
            if themes.getUserID() == ""
            {
                themes.AlertView(themes.setLang("Sorry"), Message: "\(self.themes.setLang("pls_login_to"))", ButtonTitle: kOk)
                
            }
            else
                
            {
                
                if(Child_StatusArray.object(at: indexPath.row) as! String == "No"){
                    Home_Data.Category_id = CategoryidArray.object(at: indexPath.row) as! NSString
                    Home_Data.Category_name = CategorynameArray.object(at: indexPath.row)as! NSString
                    Home_Data.Category_image = CategoryimageArray.object(at: indexPath.row)as! NSString
                    Category_Data.CategoryID = CategoryidArray.object(at: indexPath.row) as! NSString
                    viewMap.clear()
                    self.status = 1
                    self.ISSelectedArray.removeAllObjects()
                    for _ in 0 ..< CategorynameArray.count
                    {
                        self.ISSelectedArray.add("0")
                    }
                    self.ISSelectedArray.replaceObject(at: indexPath.row, with: "1")
                    self.categoryCollectionView.reloadData()
                    
                    self.showServiceProgress(rect: map_animation_view.frame)

//                    self.showProgress()
                    self.mapProviders(self.status)
                    Category_feed()
                }else{
                    subCategoryCollectionView.isHidden = true
                }
            }
        }else{
            Home_Data.Category_id = subCategoryListidArray.object(at: indexPath.row) as! NSString
            Home_Data.subCategory_name = subCategoryListArray.object(at: indexPath.row) as! NSString
            //cell.lblSubCategoryTitle.textColor = PlumberThemeColor
            
            self.SubCategoryListStatusArray.removeAllObjects()
            for _ in 0 ..< subCategoryListidArray.count
            {
                self.SubCategoryListStatusArray.add("0")
            }
            self.SubCategoryListStatusArray.replaceObject(at: indexPath.row, with: "1")
            
            self.subCategoryCollectionView.reloadData()
            
            viewMap.clear()
            self.status = 2
            self.mapProviders(self.status)
            
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell1:UICollectionViewCell = UICollectionViewCell()
        if(collectionView == categoryCollectionView){
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CategoryCollectionViewCell
            cell.imgCategoryImage.layer.borderWidth = 0
            cell.imgCategoryImage.layer.cornerRadius = cell.imgCategoryImage.frame.width/2
            cell.imgCategoryImage.clipsToBounds = true
            if ISSelectedArray.object(at: indexPath.row) as! String == "0"
            {
                cell.lblCategoryTitle.textColor = UIColor.black
                
                cell.imgCategoryImage.sd_setImage(with: URL.init(string:self.CategoryInactiveImagArray.object(at: indexPath.row) as! String), completed: themes.block)
                
            }
            else{
                cell.lblCategoryTitle.textColor =  UIColor.black
                
                
                cell.imgCategoryImage.sd_setImage(with: URL.init(string:self.CategoryimageArray.object(at: indexPath.row) as! String), completed: themes.block)
                
            }
            cell.lblCategoryTitle.text = CategorynameArray.object(at: indexPath.row) as? String
            // cell.lblDuration.text = "1 min"
            cell1 = cell
            return cell
        }else if collectionView == subCategoryCollectionView{
            let subCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCategoryCell", for: indexPath) as! SubCategoryCollectionViewCell
          
            // subCell.imgSubCategoryImage.sd_setImageWithURL(NSURL.init(string: subCategoryListImageArray.objectAtIndex(indexPath.row) as! String), placeholderImage: UIImage.init(named:"PlaceHolderSmall"))
            subCell.lblSubCategoryTitle.text = subCategoryListArray.object(at: indexPath.row) as? String
            if SubCategoryListStatusArray.object(at: indexPath.row) as! String == "0"
            {
                
                subCell.imgSubCategoryImage.sd_setImage(with: URL.init(string: self.subCategoryListInactiveImageArray.object(at: indexPath.row) as! String), completed: themes.block)
                subCell.lblSubCategoryTitle.textColor = UIColor.black
                
            }
            else{
                
                subCell.imgSubCategoryImage.sd_setImage(with: URL.init(string: self.subCategoryListActiveImageArray.object(at: indexPath.row) as! String), completed: themes.block)
                subCell.lblSubCategoryTitle.textColor =  UIColor.black
                
            }
            
            
            
            
            
            subCell.imgSubCategoryImage.layer.cornerRadius = subCell.imgSubCategoryImage.frame.width/2
            subCell.imgSubCategoryImage.clipsToBounds = true
           
            cell1 = subCell
            return subCell
        }
        return cell1
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        
            collectionViewWidth = collectionView.contentOffset.x
            cell.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 10, self.categoryCollectionView.frame.size.height, 0)
            
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            cell.alpha = 1
            cell.layer.transform = CATransform3DIdentity
            
        })
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


extension UIView{
    func roundOffBorder(){
        self.layer.cornerRadius = 5
    }
}
