//
//  LocationViewController.swift
//  PlumberJJ
//
//  Created by Casperon Technologies on 11/12/15.
//  Copyright © 2015 Casperon Technologies. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class LocationViewController: RootViewController,CLLocationManagerDelegate {
    var isShowArriveBtn:Bool!
    var addressStr:String = ""
    var phoneStr:String = ""
    var mapLaat:String = ""
    var isPolyLineDrawn:Bool!
    var getUsername : String = ""
    var mapLong:String = ""
    let partnerMarker = GMSMarker()
    let userMarker = GMSMarker()
    var jobId : String!
    var providerId : String!
    var model : MapRequestModel!
    @IBOutlet weak var lblStartLoc: UILabel!

    @IBOutlet var distancelabl: UILabel!
    
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    let locationManager = CLLocationManager()
    let URL_Handler:URLhandler=URLhandler()
    let marker1 = GMSMarker()
    
    
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showProgress()
        themes.Back_ImageView.image=UIImage(named: "")
        backBtn.addSubview(themes.Back_ImageView)
       // self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
              
        //        if CLLocationManager.locationServicesEnabled() {
        //            locationManager.delegate = self
        //            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        //            locationManager.startUpdatingLocation()
        //        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
        }
        setDataToLocationView()
        
    }
    
    func set_mapView(_ loc:CLLocationCoordinate2D){
        let camera = GMSCameraPosition.camera(withLatitude: trackingDetail.userLat,
                                                          longitude:trackingDetail.userLong, zoom:constant.mapZoomIn)
        
        mapView.camera=camera
        mapView.frame=mapView.frame
        let marker = GMSMarker()
        marker.position = camera.target
        marker.appearAnimation = .pop
        marker.icon = UIImage(named: "StartPin")
        
        partnerMarker.position = CLLocationCoordinate2DMake(trackingDetail.userLat, trackingDetail.userLong)
        partnerMarker.appearAnimation = .pop
        partnerMarker.icon = UIImage(named: "CarIcon")
        partnerMarker.title = getUsername as String
        partnerMarker.map = mapView
        marker.map = mapView

        
        marker1.position = CLLocationCoordinate2DMake((mapLaat as NSString).doubleValue, (mapLong as NSString).doubleValue)
        marker1.appearAnimation = .pop
        marker1.icon = UIImage(named: "FinishPin")
        marker1.title = themes.getUserName()
        marker1.map = mapView
        mapView.settings.setAllGesturesEnabled(true)
        
      
    }
    
    
    func setAnimatedMapView(_ loc:CLLocationCoordinate2D){
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        partnerMarker.position = CLLocationCoordinate2DMake(trackingDetail.userLat, trackingDetail.userLong)
        CATransaction.commit()
    }
    
    
    
    
    
    func setDataToLocationView(){
        addressLbl.text="\(addressStr)"
        if(isShowArriveBtn==true){
            cancelBtn.isHidden=false
            
            
            //stepProgress.currentIndex=1
        }else{
        }
    }
    func getBearingBetweenTwoPoints1(_ point1 : CLLocation, point2 : CLLocation) -> Double {
        
        let lat1 = degreesToRadians(point1.coordinate.latitude)
        let lon1 = degreesToRadians(point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(point2.coordinate.latitude)
        let lon2 = degreesToRadians(point2.coordinate.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansToDegrees(radiansBearing)
    }
    override func viewDidAppear(_ animated: Bool) {
        
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "Tracking"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LocationViewController.methodOfReceivedTrackNotification(_:)), name:NSNotification.Name(rawValue: "Tracking"), object: nil)
        
        
        
        
    }
    
     func methodOfReceivedTrackNotification(_ notification: Notification){
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        partnerMarker.position = CLLocationCoordinate2DMake(trackingDetail.userLat, trackingDetail.userLong)
        if trackingDetail.lastDriving == ""{
            trackingDetail.lastDriving = "0.0"
        }
        if trackingDetail.bearing  == ""{
            trackingDetail.bearing = "0.0"
        }
        partnerMarker.rotation = Double( trackingDetail.lastDriving)! - Double (trackingDetail.bearing)!
        CATransaction.commit()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "Tracking"), object: nil)
        NotificationCenter.default.removeObserver(self);
        
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "Tracking"), object: nil)
        NotificationCenter.default.removeObserver(self);
        
    }

    
    func degreesToRadians(_ degrees: Double) -> Double { return degrees * .pi / 180.0 }
    func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / .pi }
    
    @IBAction func didClickBackBtn(_ sender: AnyObject) {
          self.navigationController?.popViewControllerWithFlip(animated: true)
       // self.dismiss(animated : true, completion: nil)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // upDateLocation()
        
        if((isPolyLineDrawn) == nil){
            
            drawRoadRouteBetweenTwoPoints(manager.location!.coordinate)
            let kilometer : Double = self.kilometersfromPlace(manager.location!.coordinate)
            print ("get distance \(kilometer)")
            
            
            distancelabl.text = "\(round(kilometer))KM"
            self.set_mapView(manager.location!.coordinate)

        } else{
            setAnimatedMapView(manager.location!.coordinate)
            
            
        }
        
    }
    func kilometersfromPlace(_ from: CLLocationCoordinate2D) -> Double {
        let userloc : CLLocation = CLLocation(latitude:(mapLaat as NSString).doubleValue, longitude: (mapLong as NSString).doubleValue)
        let dest:CLLocation = CLLocation(latitude: (OrderDetail_data.provider_lat as NSString).doubleValue, longitude: (OrderDetail_data.provider_long as NSString).doubleValue)
        let dist: CLLocationDistance = userloc.distance(from: dest)
        
        let distanceKM = dist / 1000
        let roundedTwoDigit = round(100 * distanceKM) / 100
        //        return roundedTwoDigit
        //        let distance: NSString = "\(dist)"
        return roundedTwoDigit
    }
    
    @IBAction func didclickgoogleMapbutton(_ sender: AnyObject) {
        
        let  startSelLocation :CLLocation = CLLocation.init(latitude: trackingDetail.userLat, longitude: trackingDetail.userLong)
        let dropSelLocation : CLLocation = CLLocation.init(latitude:(mapLaat as NSString).doubleValue, longitude: (mapLong as NSString).doubleValue)
        if self.model == nil {
            self.model = MapRequestModel()
            // And let's set our callback URL right away!
            OpenInGoogleMapsController.sharedInstance().callbackURL = URL(string: constant.kOpenGoogleMapScheme)
            OpenInGoogleMapsController.sharedInstance().fallbackStrategy = GoogleMapsFallback.chromeThenAppleMaps
        }
        
        if OpenInGoogleMapsController.sharedInstance().isGoogleMapsInstalled == false {
            print("Google Maps not installed, but using our fallback strategy")
        }
        
        if mapLaat != "0" {
            // [self.model useCurrentLocationForGroup:kLocationGroupStart];
            self.model.setQueryString(nil, center:startSelLocation.coordinate, for: LocationGroup.start)
            self.model.setQueryString(nil, center: dropSelLocation.coordinate, for: LocationGroup.end)
            self.openDirectionsInGoogleMaps()
        }
        else {
            self.view.makeToast(message: themes.setLang("no_dest"))
        }
    }
    func  openDirectionsInGoogleMaps()  {
        
        let directionsDefinition = GoogleDirectionsDefinition()
        if self.model.isStartCurrentLocation {
            directionsDefinition.startingPoint = nil
        }
        else {
            let startingPoint = GoogleDirectionsWaypoint()
            startingPoint.queryString = self.model.startQueryString
            startingPoint.location = self.model.startLocation
            directionsDefinition.startingPoint = startingPoint
        }
        if self.model.isDestinationCurrentLocation {
            directionsDefinition.destinationPoint = nil
        }
        else {
            let destination = GoogleDirectionsWaypoint()
            destination.queryString = self.model.destinationQueryString
            destination.location = self.model.desstinationLocation
            directionsDefinition.destinationPoint = destination
        }
        directionsDefinition.travelMode = self.travelMode(asGoogleMapsEnum: self.model.travelMode)
        OpenInGoogleMapsController.sharedInstance().openDirections(directionsDefinition)
        
        
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
    func travelMode(asGoogleMapsEnum appTravelMode: TravelMode) -> GoogleMapsTravelMode {
        switch appTravelMode {
        case TravelMode.bicycling:
            return GoogleMapsTravelMode.biking
        case TravelMode.driving:
            return GoogleMapsTravelMode.driving
        case TravelMode.publicTransit:
            return GoogleMapsTravelMode.transit
        case TravelMode.walking:
            return GoogleMapsTravelMode.walking
        case TravelMode.notSpecified:
            return GoogleMapsTravelMode.init(rawValue: 0)!
        }
    }
    
    
    func drawRoadRouteBetweenTwoPoints(_ loc:CLLocationCoordinate2D) {
        print("Current location of lattitude\(mapLaat) and longtitude \(mapLong)")
        lblStartLoc.text = themes.getAddressForLatLng("\(trackingDetail.userLat)", longitude: "\(trackingDetail.userLong)")
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\((OrderDetail_data.provider_lat as NSString).doubleValue),\((OrderDetail_data.provider_long as NSString).doubleValue)&destination=\((mapLaat as NSString).doubleValue),\((mapLong as NSString).doubleValue)&sensor=true&key=\(constant.GooglemapAPI)"
        URL_Handler.makeGetCall(directionURL) { (responseObject) -> () in
            if(responseObject != nil)
            {
                let routes_array = responseObject?.object(forKey: "routes") as! NSArray
                
                if(routes_array.count > 0)
                {
                    self.DismissProgress()
                    self.isPolyLineDrawn=true
                    for Dict in routes_array
                    {
                        
                        let overviewPolyline = ((Dict as AnyObject).object(forKey: "overview_polyline") as AnyObject).object(forKey: "points") as! String
                        let path:GMSPath=GMSPath(fromEncodedPath: overviewPolyline)!
                        let SingleLine:GMSPolyline=GMSPolyline(path: path)
                        SingleLine.strokeWidth=10.0
                        SingleLine.strokeColor=PlumberBlueColor
                        SingleLine.map=self.mapView
                        
                        let bounds: GMSCoordinateBounds = GMSCoordinateBounds(path: path)
                        let update: GMSCameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 100.0)
                        //bounds = [bounds includingCoordinate:PickUpmarker.position   coordinate:Dropmarker.position];
                        self.mapView.animate(with: update)
                        
                    }
                    
                    self.set_mapView(loc)
                }else{
                    
                }
                
            }else{
                self.DismissProgress()
                self.isPolyLineDrawn=true
                themes.AlertView("\(Appname)", Message:themes.setLang("no_routes"), ButtonTitle: kOk)

            }
        }
    }

    
    //    func upDateLocation(){
    //
    //        let objUserRecs:UserInfoRecord=theme.GetUserDetails()
    //        let Param: Dictionary = ["provider_id":"\(objUserRecs.providerId)",
    //            "latitude":"\(lat)",
    //            "longitude":"\(lon)"]
    //        // print(Param)
    //
    //        url_handler.makeCall(updateProviderLocation, param: Param) {
    //            (responseObject, error) -> () in
    //
    //            if(error != nil)
    //            {
    //                self.view.makeToast(message:kErrorMsg, duration: 3, position: HRToastPositionDefault, title: "Network Failure !!!")
    //            }
    //            else
    //            {
    //                if(responseObject != nil && (responseObject?.count)!>0)
    //                {
    //                    let status:NSString=responseObject?.objectForKey("status") as! NSString
    //
    //                    if(status == "1")
    //                    {
    //
    //
    //                    }
    //                    else
    //                    {
    //                        self.view.makeToast(message:kErrorMsg, duration: 5, position: HRToastPositionDefault, title: "Network Failure !!!")
    //                    }
    //                }
    //                else
    //                {
    //                    self.view.makeToast(message:kErrorMsg, duration: 3, position: HRToastPositionDefault, title: "Network Failure !!!")
    //                }
    //            }
    //
    //        }
    //    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickPhoneBtn(_ sender: AnyObject) {
        callNumber(phoneStr as String)
    }
    fileprivate func callNumber(_ phoneNumber:String) {
        if let phoneCallURL:URL = URL(string:"tel://"+"\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
}
