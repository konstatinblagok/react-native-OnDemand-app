//
//  ChooseLocationViewController.swift
//  Plumbal
//
//  Created by Casperon iOS on 24/11/2016.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit
import GoogleMaps

class ChooseLocationViewController: RootViewController,CLLocationManagerDelegate,GMSMapViewDelegate,UITextFieldDelegate {
    
    var lat : String = ""
    var long:String = ""
    var didselectCalled : Bool = Bool()
    struct Place {
        let id: String
        let description: String
    }
    @IBOutlet var viewMap1:GMSMapView!
    @IBOutlet var btnPin:UIButton!
    @IBOutlet var viewService:UIView!
    @IBOutlet var btnLocation:UIButton!
    @IBOutlet var txtLocation:UITextField!
    
    var themes : Themes = Themes()


    var locationManager = CLLocationManager()
    var sampleArray = NSMutableArray()
    @IBOutlet weak var lblPickLoc: UILabel!
    @IBOutlet weak var donebtn: UIButton!
    @IBOutlet weak var lblPickdrag: UILabel!

    
    var places = [Place]()
    var selectedAddress = String()
    
    @IBOutlet weak var countryTable: UITableView!
    var searchArray = [String]()
    
    @IBOutlet var map_animation_view : CSAnimationView!
    var viewmapend = CGRect.zero
    @IBOutlet weak var markerView: CSAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideView()
        didselectCalled = false
        markerView.isUserInteractionEnabled = false
        viewService.layer.cornerRadius = 12
        lblPickLoc.text = themes.setLang("pick_location")
        donebtn.titleLabel?.adjustsFontSizeToFitWidth = true
        lblPickdrag.text = themes.setLang("drag_pick")

        donebtn.setTitle(themes.setLang("done"), for: UIControlState())
        txtLocation.delegate = self
        txtLocation.addTarget(self, action: #selector(AddaddressViewController.TextfieldDidChange(_:)), for: UIControlEvents.editingChanged)

        viewMap1.delegate = self
        self.definesPresentationContext = true
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.markerView.frame = CGRect(x:(self.map_animation_view.frame.width - self.markerView.frame.width)/2, y : ((self.map_animation_view.frame.height - self.markerView.frame.height)/2) - 30, width: self.markerView.frame.width, height: self.markerView.frame.height)
        markerView.isHidden = true
        updateViews()
    }
    
    func updateViews(){
        viewmapend = viewMap1.frame
        
        let viewMapstart = CGRect(x: viewmapend.x, y: viewmapend.y, width: viewmapend.width, height: self.view.frame.height - viewmapend.y)
        
        viewMap1.frame = viewMapstart
        
        UIView.animate(withDuration: 1.0, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
            self.viewMap1.frame = self.viewmapend
        }) { (finished) in
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            self.themes.MakeAnimation(view: self.map_animation_view, animation_type: CSAnimationTypePop)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.markerView.isHidden = false
                self.themes.MakeAnimation(view: self.markerView, animation_type: CSAnimationTypeBounceDown)
            })
        })
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideView(){
        countryTable.isHidden = true
        
    }
    
    func showView(){
        countryTable.isHidden = false

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
//        switch countrySearchController.active {
//        case true:
            return places.count
//        case false:
//            return 0
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let cell = countryTable.dequeueReusableCell(withIdentifier: "Cell") as! SearchTableViewCell
        cell.textLabel?.text = ""
        cell.textLabel?.attributedText = NSAttributedString(string: "")
        
//        switch countrySearchController.active {
//        case true:
            let place = self.places[indexPath.row]
            cell.textLabel?.text=place.description
            return cell
//        case false:
//            return cell
//        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
       // check_Selection = "Select From List"
        hideView()
        tableView.deselectRow(at: indexPath, animated: true)
        let place = self.places[indexPath.row]
        txtLocation.text = place.description
        self.view.endEditing(true)
        txtLocation.resignFirstResponder()
        didselectCalled = true
        getLocation(place.id)
    }
    
      func textFieldDidBeginEditing(_ textField: UITextField) {
        showView()
        textField.text = ""
        
    }
    
    
    func TextfieldDidChange(_ textField:UITextField)
    {
        if(textField == txtLocation)
        {
            if(txtLocation.text != "")
            {
                searchArray.removeAll(keepingCapacity: false)
                self.getPlaces(textField.text!)
                countryTable.reload()
                
            }
            else
            {
                
                countryTable.isHidden = true
                
                
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    func set_mapView(_ lat:NSString,long:NSString){
        delay(0.5) { () -> () in
            let zoomOut = GMSCameraUpdate.zoom(to: 10)
            self.viewMap1.animate(with: zoomOut)
            let UpdateLoc = CLLocationCoordinate2DMake(CLLocationDegrees(lat as String)!,CLLocationDegrees(long as String)!)
            let Camera = GMSCameraUpdate.setTarget(UpdateLoc)
            self.viewMap1.animate(with: Camera)
            self.viewMap1.isMyLocationEnabled = true
            self.delay(0.5, completion: { () -> () in
                let zoomIn = GMSCameraUpdate.zoom(to: constant.mapZoomIn)
                
                self.viewMap1.animate(with: zoomIn)
            })
        }
        viewMap1.settings.setAllGesturesEnabled(true)
        viewMap1.settings.scrollGestures=true
    }
    
    func getAddressForLatLng(_ latitude: String, longitude: String) {
        if !didselectCalled
        {
        let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=\(constant.GooglemapAPI)&language=\(themes.getAppLanguage())")
        let data = try? Data(contentsOf: url!)
        if data != nil{
            let json = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            if let result = json["results"] as? NSArray {
                print(result)
                if(result.count != 0){
                    
                    if let address = (result[0] as AnyObject)["formatted_address"] as? String{
                        txtLocation.text = address
                        self.sampleArray = NSMutableArray()
                        self.sampleArray.add(latitude)
                        self.sampleArray.add(longitude)
                        self.sampleArray.add(address)

                    }
                }
            }
        }
        }
        didselectCalled = false
    }
    func delay(_ seconds: Double, completion:@escaping ()->()) {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            completion()
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
            "location":"\(lat),\(long)",
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
                    self.countryTable.reload()
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
                    
                    print(predictions)
                    self.sampleArray = NSMutableArray()
                    self.sampleArray.add(predictions.value(forKeyPath: "geometry.location.lat")!)
                    self.sampleArray.add(predictions.value(forKeyPath: "geometry.location.lng")!)
                    self.sampleArray.add(self.txtLocation.text!)
                    self.set_mapView("\(self.sampleArray.object(at: 0))" as NSString, long: "\(self.sampleArray.object(at: 1))" as NSString)
                    
                    //                    self.places = predictions.map { (prediction: AnyObject) -> Place in
                    //                        return Place(
                    //                            id: prediction["place_id"] as! String,
                    //                            description: prediction["description"] as! String
                    //                        )
                    //                    }
                    //
                    
                    //               NSNotificationCenter.defaultCenter().postNotificationName("Location", object: nil, userInfo: ["key1":])
                    //                    self.places = predictions.map { (prediction: AnyObject) -> Place in
                    //                        return Place(
                    //                            id: prediction["id"] as! String,
                    //                            description: prediction["description"] as! String
                    //                        )
                    //                    }
                }
            })
        }
        catch let error as NSError {
            // Catch fires here, with an NSErrro being thrown from the JSONObjectWithData method
            print("A JSON parsing error occurred, here are the details:\n \(error)")
        }
    }
    
    @IBAction func didClickOptions(_ sender: UIButton) {
        if sampleArray.count != 0{
            NotificationCenter.default.post(name: Notification.Name(rawValue: "Location"), object:sampleArray)
        }
        self.navigationController?.popViewControllerWithFlip(animated: true)
    }
    
    @IBAction func didPickLocation(_ sender: AnyObject) {
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func didClickBack(_ sender: AnyObject) {
        self.navigationController?.popViewControllerWithFlip(animated: true)

    }
    
    @IBAction func didClickDone(_ sender: AnyObject) {
        if sampleArray.count != 0{
            NotificationCenter.default.post(name: Notification.Name(rawValue: "Location"), object:sampleArray)
            self.navigationController?.popViewControllerWithFlip(animated: true)
        }
//        if check_Selection != "Select From List"{
//            themes.AlertView("\(Appname)",Message: themes.setLang("Select your address from showing list"),ButtonTitle: kOk)
//        }
//        else{
//            
//            if sampleArray.count != 0{
//                NSNotificationCenter.defaultCenter().postNotificationName("Location", object:sampleArray)
//                self.navigationController?.popViewControllerAnimated(true)
//            }
//        }
    }
    
    //MARK: - LocationManager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _ = CLGeocoder()
        let current = locations[0]
        if current.coordinate.latitude != 0 {
            let currentLatitide = "\(current.coordinate.latitude)"
            let currentLongitude = "\(current.coordinate.longitude)"
            locationManager.stopUpdatingLocation()
            set_mapView(currentLatitide as NSString, long: currentLongitude as NSString)
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        getAddressForLatLng("\(mapView.camera.target.latitude)", longitude: "\(mapView.camera.target.longitude)")
    }
    
}
