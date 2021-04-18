//
//  AddaddressViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 28/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

import CoreLocation


class AddaddressViewController: RootViewController,CLLocationManagerDelegate {
    
    
    @IBOutlet var Done_Btn: CustomButton!
    var themes:Themes=Themes()
    @IBOutlet weak var lblMbl: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    
    
    
    
    
    @IBOutlet var baseView: UIView!
    
    @IBOutlet weak var titlebtn: UIButton!
    
    
    @IBOutlet weak var fetchImageView: UIButton!
    @IBOutlet var EnterAdd_Lbl: UILabel!
    @IBOutlet var EditCon_Lbl: UILabel!
    @IBOutlet var Place_Autocomplete_tableview: UITableView!
    @IBOutlet var Addaddress_ScrollView: UIScrollView!
    @IBOutlet var MobileNum_Field: UITextField!
    @IBOutlet var Email_Field: UITextField!
    @IBOutlet var Name_Field: UITextField!
    @IBOutlet var Back_but: UIButton!
    @IBOutlet var HouseNo_Field: UITextField!
    @IBOutlet var Landmark_Field: UITextField!
    @IBOutlet var Locality_Field: UITextField!
    @IBOutlet var City_Field: UITextField!
    @IBOutlet var Pincode_Field: UITextField!
    @IBOutlet var stateField: UITextField!
    @IBOutlet var countryField: UITextField!
    
    @IBOutlet var CountryCode_Picker: UIPickerView!
    @IBOutlet var Picker_Wrapper: UIView!
    @IBOutlet var Country_Code_Field: UITextField!
    
    var currlatitude : String = String()
    var currlongitude :String  = String()
    
    
    let locationManager = CLLocationManager()
    
    
    var URL_handler:URLhandler=URLhandler()
    
    
    
    
    struct Place {
        let id: String
        let description: String
    }
    
    var places = [Place]()
    var setstatus:Bool=Bool()
    
    
    
    var State=NSString()
    var country=NSString()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPage()
        
        Addaddress_Data.Latitude=""
        Addaddress_Data.Longitude=""
        //self.locationManager.requestWhenInUseAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        Addaddress_ScrollView.contentSize = CGSize(width: self.baseView.frame.size.width,height: self.baseView.frame.origin.y+self.baseView.frame.size.height+25)
        Locality_Field.addTarget(self, action: #selector(AddaddressViewController.TextfieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        Place_Autocomplete_tableview.isHidden=true
        Place_Autocomplete_tableview.tableFooterView=UIView()
        Place_Autocomplete_tableview.layer.borderWidth=1.0
        Place_Autocomplete_tableview.layer.borderColor=themes.Lightgray().cgColor
        Place_Autocomplete_tableview.layer.cornerRadius=5.0
        Name_Field.text=themes.getUserName()
        Email_Field.text=themes.getEmailID()
        MobileNum_Field.text=themes.getMobileNum()
        Country_Code_Field.text=themes.getCountryCode()
        
        
        //Delegate Methods
        
        Name_Field.delegate=self
        Email_Field.delegate=self
        MobileNum_Field.delegate=self
        //        HouseNo_Field.delegate=self
        Landmark_Field.delegate=self
        Locality_Field.delegate=self
        City_Field.delegate=self
        Pincode_Field.delegate=self
        Country_Code_Field.delegate=self
        stateField.delegate = self
        countryField.delegate = self
        
        
        
        
        
        
        let tapgesture:UITapGestureRecognizer=UITapGestureRecognizer(target:self, action: #selector(AddaddressViewController.DismissKeyboard(_:)))
        
        tapgesture.delegate=self
        
        view.addGestureRecognizer(tapgesture)
        
        //Tool bar for Pickerview
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: themes.setLang("done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddaddressViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        doneButton.tintColor=themes.ThemeColour()
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        Picker_Wrapper.addSubview(toolBar)
        
        Picker_Wrapper.removeFromSuperview()
        
        
        //Set image for backarraow
        
        themes.Back_ImageView.image=UIImage(named: "")
        
        Back_but.addSubview(themes.Back_ImageView)
        
        
        Place_Autocomplete_tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        // Do any additional setup after loading the view.
        
        
        
        
        
        
    }
    
    func applicationLanguageChangeNotification(_ notification:Notification) {
        lblMbl.text = themes.setLang("mobile_no_caps")
        lblName.text = themes.setLang("name_caps")
        lblEmail.text = themes.setLang("email_id_caps")
        titlebtn.setTitle(themes.setLang("add_address_title"), for: UIControlState())
        EditCon_Lbl.text=themes.setLang("edit_contact")
        Name_Field.placeholder=themes.setLang("full_name")
        Email_Field.placeholder=themes.setLang("email_id_smal")
        MobileNum_Field.placeholder=themes.setLang("mobile_no_small")
        EnterAdd_Lbl.text=themes.setLang("enter_address")
        Locality_Field.placeholder=themes.setLang("ur_locality")
        //        HouseNo_Field.placeholder=themes.setLang("house_no")
        City_Field.placeholder=themes.setLang("city")
        Pincode_Field.placeholder=themes.setLang("pincode")
        stateField.placeholder=themes.setLang("state")
        countryField.placeholder=themes.setLang("country")
        
        Locality_Field.placeholder = themes.setLang("locality")
        Landmark_Field.placeholder = themes.setLang("landmark")
        Done_Btn.setTitle(themes.setLang("done"), for: UIControlState())
    }
    func setPage(){
        setPading(Name_Field, title: themes.setLang("name_caps"))
        setPading(Email_Field, title: themes.setLang("email_id_smal"))
        setPading(MobileNum_Field, title: themes.setLang("mobile_no_small"))
        
        lblMbl.text = themes.setLang("mobile_no_caps")
        lblName.text = themes.setLang("name_caps")
        lblEmail.text = themes.setLang("email_id_caps")
        titlebtn.setTitle(themes.setLang("add_address_title"), for: UIControlState())
        EditCon_Lbl.text=themes.setLang("edit_contact")
        //        Name_Field.placeholder=themes.setLang("full_name")
        //        Email_Field.placeholder=themes.setLang("email_id_smal")
        //        MobileNum_Field.placeholder=themes.setLang("mobile_no_small")
        EnterAdd_Lbl.text=themes.setLang("enter_address")
        Locality_Field.placeholder=themes.setLang("ur_locality")
        //        HouseNo_Field.placeholder=themes.setLang("house_no")
        City_Field.placeholder=themes.setLang("city")
        Pincode_Field.placeholder=themes.setLang("pincode")
        stateField.placeholder=themes.setLang("state")
        countryField.placeholder=themes.setLang("country")
        
        Locality_Field.placeholder = themes.setLang("locality")
        Landmark_Field.placeholder = themes.setLang("landmark")
        Done_Btn.setTitle(themes.setLang("done"), for: UIControlState())
        
    }
    
    func setPading(_ textField : UITextField,title:String){
        let label = UILabel()
        label.sizeToFit()
        label.text = title
        label.textColor = themes.ThemeColour()
        label.font = PlumberMediumBoldFont
        textField.leftView = label
        textField.leftViewMode = UITextFieldViewMode .always
    }
    
    @IBAction func fetching_location(_ sender: AnyObject) {
        if(sender.tag == 0){
            self.locationManager.stopUpdatingLocation()
            
            let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(currlatitude),\(currlongitude)&key=\(constant.GooglemapAPI)")
            let data = try? Data(contentsOf: url!)
            if(data != nil){
                let json = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                
                if let result = json["results"] as? NSArray {
                    print(result)
                    self.DismissProgress()
                    if(result.count != 0){
                        if let address = (result[0] as AnyObject)["address_components"] as? NSArray {
                            let street : String = self.themes.CheckNullValue((address[1] as AnyObject)["short_name"]!)!
                            let city : String =  self.themes.CheckNullValue((address[2] as AnyObject)["short_name"]!)!
                            let locality : String = self.themes.CheckNullValue((address[3] as AnyObject)["short_name"]!)!
                            let state : String = self.themes.CheckNullValue((address[5] as AnyObject)["long_name"]!)!
                            let country : String = self.themes.CheckNullValue((address[6] as AnyObject)["long_name"]!)!
                            let zipcode : String = self.themes.CheckNullValue((address.lastObject as AnyObject)["short_name"]!)!
                            
                            
                            let fulladdress = "\(street), \(city), \(locality), \(state), \(country)"
                            Addaddress_Data.Latitude = currlatitude
                            Addaddress_Data.Longitude = currlongitude
                            Locality_Field.text = fulladdress.replacingOccurrences(of: ", ,", with: ",")
                            //                HouseNo_Field.text = "\(city)"
                            City_Field.text = "\(locality)"
                            Pincode_Field.text = "\(zipcode)"
                            stateField.text = state
                            countryField.text = country
                            self.State = "\(state)" as NSString
                            
                            
                            
                        }
                    }
                    
                }
                
            }
        }else if(sender.tag == 1){
            Locality_Field.text = ""
            //            HouseNo_Field.text = ""
            City_Field.text = ""
            Pincode_Field.text = ""
            Landmark_Field.text = ""
            stateField.text = ""
            countryField.text = ""
            Addaddress_Data.Latitude=""
            Addaddress_Data.Longitude=""
            
            
        }
        
        
    }
    
    func TextfieldDidChange(_ textField:UITextField)
    {
        if(textField == Locality_Field)
        {
            if(Locality_Field.text != "")
            {
                //  searchArray.removeAll(keepingCapacity: false)
                self.getPlaces(textField.text!)
                Place_Autocomplete_tableview.reload()
                
            }
            else
            {
                
                Place_Autocomplete_tableview.isHidden = true
                
                
            }
        }
    }
    
    
    
    func getPlaces(_ searchString: String) {
        let request = requestForSearch(searchString)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            self.handleResponse(data, response: response as? HTTPURLResponse, error: error)
        })
        task.resume()
    }
    
    func getLocation(_ placeId:String){
        let params = [
            "placeid":"\(placeId)",
            "key": "\(constant.GooglemapAPI)"
        ]
        let request:URL = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?\(query(params as [String : AnyObject]))")!
        print(request)
        let session = URLSession.shared
        let task = session.dataTask(with: NSMutableURLRequest(
            url: URL(string: "https://maps.googleapis.com/maps/api/place/details/json?\(query(params as [String : AnyObject]))")!
            ) as URLRequest, completionHandler: { data, response, error in
                self.handleLocationResponse(data, response: response as? HTTPURLResponse, error: error)
        })
        
        task.resume()
    }
    
    func requestForSearch(_ searchString: String) -> URLRequest {
        let params = [
            "input": searchString,
            "key": "\(constant.GooglemapAPI)",
            "radius":"1000000",
            ]
        
        print("the url is https://maps.googleapis.com/maps/api/place/autocomplete/json?\(query(params as [String : AnyObject]))")
        return NSMutableURLRequest(
            url: URL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?\(query(params as [String : AnyObject]))")!
            ) as URLRequest
    }
    
    func query(_ parameters: [String: AnyObject]) -> String {
        var components: [(String, String)] = []
        for key in  (Array(parameters.keys).sorted(by: <)) {
            let value: AnyObject! = parameters[key]
            components += [(escape(key), escape("\(value!)"))]
        }
        return components.map{"\($0)=\($1)"}.joined(separator: "&")
    }
    
    func escape(_ string: String) -> String {
        let legalURLCharactersToBeEscaped: CFString = ":/?&=;+!@#$()',*" as CFString
        return CFURLCreateStringByAddingPercentEscapes(nil, string as CFString, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }
    
    func handleResponse(_ data: Data!, response: HTTPURLResponse!, error: Error!) {
        if let error = error {
            print("GooglePlacesAutocomplete Error: \(error.localizedDescription)")
            return
        }
        if response == nil {
            print("GooglePlacesAutocomplete Error: No response from API")
            return
        }
        if response.statusCode != 200 {
            print("GooglePlacesAutocomplete Error: Invalid status code \(response.statusCode) from API")
            return
        }
        do {
            let json: NSDictionary = try JSONSerialization.jsonObject(
                with: data,
                options: JSONSerialization.ReadingOptions.mutableContainers
                ) as! NSDictionary
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let predictions = json["predictions"] as? Array<AnyObject> {
                    print(predictions)
                    self.places = predictions.map { (prediction: AnyObject) -> Place in
                        return Place(
                            id: prediction["place_id"] as! String,
                            description: prediction["description"] as! String
                        )
                    }
                    self.Place_Autocomplete_tableview.reload()
                }
            })
        }
        catch let error as NSError {
            // Catch fires here, with an NSErrro being thrown from the JSONObjectWithData method
            print("A JSON parsing error occurred, here are the details:\n \(error)")
        }
    }
    
    func handleLocationResponse(_ data: Data!, response: HTTPURLResponse!, error: Error!) {
        if let error = error {
            print("GooglePlacesAutocomplete Error: \(error.localizedDescription)")
            return
        }
        if response == nil {
            print("GooglePlacesAutocomplete Error: No response from API")
            return
        }
        if response.statusCode != 200 {
            print("GooglePlacesAutocomplete Error: Invalid status code \(response.statusCode) from API")
            return
        }
        do {
            let json: NSDictionary = try JSONSerialization.jsonObject(
                with: data,
                options: JSONSerialization.ReadingOptions.mutableContainers
                ) as! NSDictionary
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                print(json)
                if let predictions = json["result"] as? NSDictionary {
                    
                    print("get predictions\(predictions)")
                    //                    self.sampleArray = NSMutableArray()
                    //                    self.sampleArray.add(predictions.value(forKeyPath: "geometry.location.lat")!)
                    //                    self.sampleArray.add(predictions.value(forKeyPath: "geometry.location.lng")!)
                    //                    self.sampleArray.add(self.txtLocation.text!)
                    //                    self.set_mapView("\(self.sampleArray.object(at: 0))" as NSString, long: "\(self.sampleArray.object(at: 1))" as NSString)
                    //
                    Addaddress_Data.Latitude = "\(predictions.value(forKeyPath: "geometry.location.lat")!)"
                    Addaddress_Data.Longitude = "\(predictions.value(forKeyPath: "geometry.location.lng")!)"
                    var result1 = NSArray()
                    
                    if let address = (predictions as AnyObject)["address_components"] as? NSArray{
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
                        
                        // fullAddress = "\(street)$\(sublocality)$\(city)$\(state)$\(country)$\(zipcode)"
                        //                        return fullAddress
                        Addaddress_Data.HouseNo = street
                        self.City_Field.text = city
                        self.stateField.text =  state
                        self.countryField.text = country
                        self.Pincode_Field.text = zipcode
                    }
                }
            })
        }
        catch let error as NSError {
            // Catch fires here, with an NSErrro being thrown from the JSONObjectWithData method
            print("A JSON parsing error occurred, here are the details:\n \(error)")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
        }else{
            themes.AlertView("", Message: "\(themes.setLang("location_service_disabled"))\n \(themes.setLang("to_reenable_location")) ", ButtonTitle: kOk)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D? = manager.location!.coordinate
        if(locValue != nil){
            print("locations = \(locValue!.latitude) \(locValue!.longitude)")
            currlatitude = "\(locValue!.latitude)"
            currlongitude = "\(locValue!.longitude)"
            
        }
    }
    
    func tableView(_ tableView: UITableView!, numberOfRowsInSection section: Int) -> Int{
        return places.count
    }
    
    
    func tableView(_ tableView: UITableView!, heightForRowAtIndexPath indexPath: IndexPath!) -> CGFloat
    {
        
        return 40.0
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView!, cellForRowAtIndexPath indexPath: IndexPath!) -> UITableViewCell{
        
        let cell:UITableViewCell = (tableView.dequeueReusableCell(withIdentifier: "cell") )!
        
        let place = self.places[indexPath.row]
        
        cell.textLabel?.text=place.description
        
        return cell
    }
    
    
    
    
    func tableView(_ tableView: UITableView!, didSelectRowAtIndexPath indexPath: IndexPath!)
    {
        
        
        // check_Selection = "Select From List"
        self.Place_Autocomplete_tableview.isHidden = true
        let place = self.places[indexPath.row]
        Locality_Field.text = place.description
        self.view.endEditing(true)
        Locality_Field.resignFirstResponder()
        
        getLocation(place.id)
        
        //        let place = self.places[indexPath.row]
        //
        //
        //
        //        self.showProgress()
        //        Addaddress_Data.YourLocality = place.description
        //
        //        let geocoder: CLGeocoder = CLGeocoder()
        //
        //        geocoder.geocodeAddressString(place.description, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
        //            self.DismissProgress()
        //            if (error != nil) {
        //                print("Error \(error!)")
        //            } else if let placemark = placemarks?[0] {
        //
        //
        //                print("the responsadsase is .......\(placemark)")
        //
        //                //                let CityName:String?=placemark.subAdministrativeArea
        //                let Locality:String?=placemark.subLocality
        //
        //                let ZipCode:String?=placemark.postalCode
        //
        //
        //                if (placemark.administrativeArea != nil)
        //                {
        //                    self.State=placemark.administrativeArea! as NSString
        //                    self.stateField.text = self.State as String
        //                }
        //
        //                if(placemark.country != nil){
        //                    self.country = placemark.country! as NSString
        //                    self.countryField.text = self.country as String
        //
        //                }
        //
        //                if (placemark.subAdministrativeArea != nil)
        //                {
        //                    self.City_Field.text = self.themes.CheckNullValue(placemark.subAdministrativeArea!)
        //                }
        //
        //                if(ZipCode != nil)
        //                {
        //                    self.Pincode_Field.text=""
        //
        //                    self.Pincode_Field.text=ZipCode!
        //
        //                }
        //                else
        //                {
        //                    self.Pincode_Field.text=""
        //
        //                }
        //
        //
        //                if(Locality != nil)
        //                {
        //
        ////                    self.HouseNo_Field.text=Locality!
        //
        //                }
        //                else
        //                {
        ////                    self.HouseNo_Field.text=""
        //
        //                }
        //
        //
        //
        //            }
        //        } as! CLGeocodeCompletionHandler)
        //
        //
        //
        //        URL_handler.makeGetCall("https://maps.google.com/maps/api/geocode/json?sensor=false&key=\(constant.GooglemapAPI)&address=\(place.description.stringByAddingPercentEncodingForFormUrlencoded()!)") { (responseObject) -> () in
        //
        //            if(responseObject != nil)
        //            {
        //
        //
        //                let results:NSArray=(responseObject?.object(forKey: "results"))! as! NSArray
        //                if results.count > 0
        //                {
        //                    let firstItem: NSDictionary = results.object(at: 0) as! NSDictionary
        //                    let geometry: NSDictionary = firstItem.object(forKey: "geometry") as! NSDictionary
        //                    let locationDict:NSDictionary = geometry.object(forKey: "location") as! NSDictionary
        //                    let lat:NSNumber = locationDict.object(forKey: "lat") as! NSNumber
        //                    let lng:NSNumber = locationDict.object(forKey: "lng") as! NSNumber
        //
        //
        //                    Addaddress_Data.Latitude="\(lat)"
        //
        //                    Addaddress_Data.Longitude="\(lng)"
        //                    Addaddress_Data.City = self.themes.getLocationname()
        //                }
        //
        //
        //            }
        //            else
        //            {
        //                Addaddress_Data.Latitude=""
        //                Addaddress_Data.Longitude=""
        //
        //            }
        //
        //
        //
        //        }
        //
        //        Locality_Field.text=Addaddress_Data.YourLocality as String
        //
        //
        //        Place_Autocomplete_tableview.isHidden=true
        //
        //
        //
    }
    
    
    
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if (NSStringFromClass((touch.view?.classForCoder)!)=="UITableViewCellContentView")
        {
            
            
            
            return false
        }
            
        else{
            return true
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    func DismissKeyboard(_ sender:UITapGestureRecognizer)
    {
        
        //        Addaddress_ScrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        
        donePicker()
        
        view.endEditing(true)
        Place_Autocomplete_tableview.isHidden=true
        
        
        
    }
    
    
    
    func donePicker()
    {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.Picker_Wrapper.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 260.0)
            
        }, completion: { _ in
            
            self.Picker_Wrapper.removeFromSuperview()
            
        })
        
        
        
    }
    
    
    
    
    func showPicker()
    {
        view.addSubview(self.Picker_Wrapper)
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.Picker_Wrapper.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 260.0, width: UIScreen.main.bounds.size.width, height: 260.0)
            
        } , completion: { _ in
            
            
            
        })
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        if(textField == Name_Field)
        {
            Name_Field.resignFirstResponder()
            Email_Field.becomeFirstResponder()
        }
        if(textField == Email_Field)
        {
            
            Email_Field.resignFirstResponder()
            Country_Code_Field.becomeFirstResponder()
            
            
        }
        
        if(textField == Country_Code_Field)
        {
            
            Country_Code_Field.resignFirstResponder()
        }
        
        if(textField == MobileNum_Field)
        {
            MobileNum_Field.resignFirstResponder()
            
            //            HouseNo_Field.becomeFirstResponder()
        }
        
        if(textField == Locality_Field)
        {
            
            Locality_Field.resignFirstResponder()
            //            HouseNo_Field.becomeFirstResponder()
            
            
        }
        
        
        //        if(textField == HouseNo_Field)
        //        {
        //
        //            HouseNo_Field.resignFirstResponder()
        //            Landmark_Field.becomeFirstResponder()
        //
        //
        //        }
        
        
        if(textField == Landmark_Field)
        {
            Landmark_Field.resignFirstResponder()
            City_Field.becomeFirstResponder()
        }
        
        
        if(textField == City_Field)
        {
            City_Field.resignFirstResponder()
            
            stateField.becomeFirstResponder()
        }
        if(textField == stateField)
        {
            stateField.resignFirstResponder()
            
            countryField.becomeFirstResponder()
        }
        if(textField == countryField)
        {
            countryField.resignFirstResponder()
            
            Pincode_Field.becomeFirstResponder()
        }
        if(textField == Pincode_Field)
        {
            Pincode_Field.resignFirstResponder()
            //  Addaddress_ScrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
            
            
        }
        
        
        return true
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if(textField == Locality_Field)
        {
            donePicker()
            Place_Autocomplete_tableview.isHidden = false
        }
        if(textField == Country_Code_Field)
        {
            self.showPicker()
            view.endEditing(true)
            return false
        }
        if(textField == Landmark_Field)
        {
            donePicker()
        }
        if(textField == City_Field)
        {
            donePicker()
        }
        if(textField == Pincode_Field)
        {
            donePicker()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == Name_Field)
        {
            
            let aSet = CharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            
            
            
            
            
            return string == numberFiltered
        }
            
            
            
        else
        {
            return true
            
        }
        
    }
    
    
    //PickerVView Delegate
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return themes.codename.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (themes.codename[row] as! String)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        Country_Code_Field.text="\(themes.code[row])"
        Addaddress_Data.Country_code="\(themes.code[row])"
    }
    
    
    
    
    
    
    @IBAction func didClickoptions(_ sender: UIButton) {
        
        if(sender.tag == 0)
        {
            
            self.navigationController?.popViewControllerWithFlip(animated: true)
            
        }
        if(sender.tag == 1)
        {
            
            Add_address()
            
            
        }
    }
    
    func Add_address()
    {
        if(Name_Field.text == "") {
            themes.AlertView("\(Appname)", Message:themes.setLang("enter_ur_name"), ButtonTitle: kOk)
        }  else if(Email_Field.text == "") {
            themes.AlertView("\(Appname)", Message: themes.setLang("enter_ur_id"), ButtonTitle: kOk)
        }else if(MobileNum_Field.text == "") {
            themes.AlertView("\(Appname)", Message: themes.setLang("enter_ur_num"), ButtonTitle: kOk)
        }
            
            
        else if(Locality_Field.text == "") {
            themes.AlertView("\(Appname)", Message: themes.setLang("enter_ur_locality"), ButtonTitle: kOk)
        } else if(City_Field.text == "") {
            themes.AlertView("\(Appname)", Message: themes.setLang("enter_ur_city"), ButtonTitle: kOk)
        }else if(stateField.text == "") {
            themes.AlertView("\(Appname)", Message: themes.setLang("enter_ur_state"), ButtonTitle: kOk)
        }else if(countryField.text == "") {
            themes.AlertView("\(Appname)", Message: themes.setLang("enter_ur_country"), ButtonTitle: kOk)
        }
        else
        {
            Addaddress_Data.Name=Name_Field.text!
            Addaddress_Data.EmailID=Email_Field.text!
            Addaddress_Data.MobileNumber=MobileNum_Field.text!
            Addaddress_Data.Landmark=Landmark_Field.text!
            Addaddress_Data.YourLocality=Locality_Field.text!
            Addaddress_Data.City=City_Field.text!
            Addaddress_Data.Pincode=Pincode_Field.text!
            Addaddress_Data.Country_code=Country_Code_Field.text!
            self.showProgress()
            
            
            
            
            let param:NSDictionary=["user_id":"\(self.themes.getUserID())","name":"\(Addaddress_Data.Name)","email":"\(Addaddress_Data.EmailID)",
                "country_code":"\(Addaddress_Data.Country_code)","mobile":"\(Addaddress_Data.MobileNumber)","street":"\( Addaddress_Data.HouseNo)",
                "landmark":"\(Addaddress_Data.Landmark)","locality":"\(Addaddress_Data.YourLocality)","city":"\(Addaddress_Data.City)",
                "zipcode":"\(Addaddress_Data.Pincode)","lng":"\(Addaddress_Data.Longitude)",
                "line1":"\(Addaddress_Data.City)","state":"\(String(describing: self.stateField.text))","lat":"\(Addaddress_Data.Latitude)","country":"\(self.countryField.text!)"]
            
            
            
            URL_handler.makeCall(constant.Add_address, param: param, completionHandler: { (responseObject, error) -> () in
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
                        
                        
                        
                        
                        let Status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                        
                        if(Status == "1")
                            
                        {
                            self.navigationController?.popViewControllerWithFlip(animated: true)
                            
                        }
                        else
                        {
                            let error : String = self.themes.CheckNullValue(dict.object(forKey: "errors"))!
                            if error == ""
                            {
                                self.themes.AlertView(Appname, Message: "\(self.themes.CheckNullValue(dict.object(forKey: "response"))!)", ButtonTitle: kOk)
                                
                            }
                            else
                            {
                                self.themes.AlertView(Appname, Message: "\(self.themes.CheckNullValue(dict.object(forKey: "errors"))!)", ButtonTitle: kOk)
                            }
                        }
                        
                        
                    }
                        
                    else
                    {
                        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    }
                }
            })
            
            
            
            
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
    
}


extension String {
    func stringByAddingPercentEncodingForFormUrlencoded() -> String? {
        let characterSet = NSMutableCharacterSet.alphanumeric()
        characterSet.addCharacters(in: "-._* ")
        
        return addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)?.replacingOccurrences(of: " ", with: "+")
    }
}



extension AddaddressViewController:UITextFieldDelegate
{
    
}
extension AddaddressViewController:UIGestureRecognizerDelegate
{
    
}

extension AddaddressViewController:UIPickerViewDelegate
{
    
    
    
    
}

