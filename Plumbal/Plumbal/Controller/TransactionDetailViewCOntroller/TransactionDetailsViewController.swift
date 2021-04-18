//
//  TransactionDetailsViewController.swift
//  Plumbal
//
//  Created by Casperon on 07/02/17.
//  Copyright © 2017 Casperon Tech. All rights reserved.
//

import UIKit

class TransactionDetailsViewController: RootViewController,UITableViewDataSource,UITableViewDelegate {
    var themes:Themes=Themes()
    let URL_Handler:URLhandler=URLhandler()
    var GetJob_id : String = ""
    
    @IBOutlet var transacTableView: UITableView!
    var titleArray = NSArray()
    var descArray = NSArray()

    @IBOutlet var backbtn: UIButton!
    
    @IBOutlet var lblViewTransac: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        lblViewTransac.text = themes.setLang("view_task_detail")
        let Nb=UINib(nibName: "TransactionDetailTableViewCell", bundle: nil)
        self.transacTableView.register(Nb, forCellReuseIdentifier: "TransactionDetailTableViewCell")
        self.transacTableView.estimatedRowHeight = 58
        self.transacTableView.rowHeight = UITableViewAutomaticDimension
    

        
        themes.Back_ImageView.image=UIImage(named: "")
        
        backbtn.addSubview(themes.Back_ImageView)
        
        self.GetTransaction()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backAct(_ sender: AnyObject) {
        self.navigationController?.popViewControllerWithFlip(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func GetTransaction()  {
        let param=["user_id":"\(themes.getUserID())","booking_id":"\(GetJob_id)"]
        URL_Handler.makeCall(constant.view_Transaction_details, param: param as NSDictionary) { (responseObject, error) -> () in
            self.DismissProgress()
            if(error != nil)
            {
                self.view.makeToast(message:self.themes.setLang("network_fail"), duration: 4, position: HRToastPositionDefault, title: "")
                
                //self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
            }
            else
            {
                if(responseObject != nil)
                {
                    let Dict:NSDictionary=responseObject!
                    
                    let Status = self.themes.CheckNullValue( Dict.object(forKey: "status"))!
                    
                    if(Status == "1")
                    {
                        let ResponseDic:NSDictionary=Dict.object(forKey: "response") as! NSDictionary
                        
                        let TotalJobsArray : NSArray = ResponseDic.object(forKey: "jobs") as! NSArray
                        
                        let lat = self.themes.CheckNullValue((TotalJobsArray.object(at: 0) as AnyObject).object(forKey: "location_lat"))!
                        let long = self.themes.CheckNullValue((TotalJobsArray.object(at: 0) as AnyObject).object(forKey: "location_lng"))!
                        
                        let categoryName = self.themes.CheckNullValue((TotalJobsArray.object(at: 0) as AnyObject).object(forKey: "category_name"))!
                        let taskerName = self.themes.CheckNullValue((TotalJobsArray.object(at: 0) as AnyObject).object(forKey: "user_name"))!
                        let exactaddress = self.themes.CheckNullValue((TotalJobsArray.object(at: 0) as AnyObject).object(forKey: "exactaddress") as AnyObject)!
                        var taskAddress : String = String()
                        if exactaddress != ""
                        {
                            taskAddress = exactaddress
                        }
                        else
                        {
                            taskAddress  = self.getAddressForLatLng(lat, longitude: long)
                        }
                        //                        
                        let totalHour = self.themes.CheckNullValue((TotalJobsArray.object(at: 0) as AnyObject).object(forKey: "total_hrs"))!
                        let perHour = "\(self.themes.getCurrencyCode())\(self.themes.CheckNullValue((TotalJobsArray.object(at: 0) as AnyObject).object(forKey: "per_hour"))!)"
                        let basePrice = "\(self.themes.getCurrencyCode())\(self.themes.CheckNullValue((TotalJobsArray.object(at: 0) as AnyObject).object(forKey: "min_hrly_rate"))!)"
                        let taskTime = self.themes.CheckNullValue((TotalJobsArray.object(at: 0) as AnyObject).object(forKey: "booking_time"))!
                        
                        let bookingId = "\(self.GetJob_id as String)"
                        let serviceAMt = "\(self.themes.getCurrencyCode())\(self.themes.CheckNullValue((TotalJobsArray.object(at: 0) as AnyObject).object(forKey: "task_amount"))!)"
                        let commision = "\(self.themes.getCurrencyCode())\(self.themes.CheckNullValue((TotalJobsArray.object(at: 0) as AnyObject).object(forKey: "service_tax"))!)"
                        
                        let total = "\(self.themes.getCurrencyCode())\(self.themes.CheckNullValue((TotalJobsArray.object(at: 0) as AnyObject).object(forKey: "total_amount"))!)"
                        var get_mis_amount = "\(self.themes.getCurrencyCode())\(self.themes.CheckNullValue((TotalJobsArray.object(at: 0) as AnyObject).object(forKey: "material_fee"))!)"
                        let mode = self.themes.CheckNullValue((TotalJobsArray.object(at: 0) as AnyObject).object(forKey: "payment_mode"))!
                        let coupon_Amount =  self.themes.CheckNullValue((TotalJobsArray.object(at: 0) as AnyObject).object(forKey: "coupon_amount"))!
                       
                        if get_mis_amount == self.themes.getCurrencyCode(){
                            get_mis_amount = "---"
                        }
                        
                        
                        if coupon_Amount == ""{
                            
                            self.titleArray = ["Booking_Id",
                                               "Task_Category",
                                               "Tasker_Name",
                                               "Task_Address",
                                               "Total_Hours",
                                               "Hourly_Rate",
                                               "Base_Price",
                                               "Task_Time",
                                               "Task_Amount",
                                               "Material_Fees",
                                               "Payment_Mode",
                                               "Service_Tax",
                                               "Total_Amount"
                                               
                            ]
                            
                            self.descArray = [bookingId,
                                              categoryName,
                                              taskerName,
                                              taskAddress,
                                              totalHour,
                                              perHour,
                                              basePrice,
                                              taskTime,
                                              serviceAMt,
                                              get_mis_amount,
                                              mode,
                                              commision,
                                              total
                            ]
                        }
                            
                        else{
                            
                            self.titleArray = ["Booking_Id",
                                               "Task_Category",
                                               "Tasker_Name",
                                               "Task_Address",
                                               "Total_Hours",
                                               "Hourly_Rate",
                                               "couponamount",
                                               "Base_Price",
                                               "Task_Time",
                                               "Task_Amount",
                                               "Material_Fees",
                                               "Payment_Mode",
                                               "Service_Tax",
                                               "Total_Amount"
                            ]
                            
                            self.descArray = [bookingId,
                                              categoryName,
                                              taskerName,
                                              taskAddress,
                                              totalHour,
                                              perHour,
                                             "\(self.themes.getCurrencyCode())\(coupon_Amount)",
                                              basePrice,
                                              taskTime,
                                              serviceAMt,
                                              get_mis_amount,
                                              mode,
                                              commision,
                                              total
                            ]

                        }
                        
                        
                        self.transacTableView.delegate = self
                        self.transacTableView.dataSource = self
                        self.transacTableView.reload()
                        
                    }
                    else
                    {
                        let message=self.themes.CheckNullValue(responseObject!.object(forKey: "response"))!
                        self.themes.AlertView(Appname, Message: message, ButtonTitle: kOk)
                    }
                    
                }
                else
                {
                    self.themes.AlertView("\(Appname)", Message: self.themes.setLang("No Reasons available"), ButtonTitle:  self.themes.setLang("ok"))
                }
            }
            
        }
        
    }
    func getAddressForLatLng(_ latitude: String, longitude: String)->String {
        let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=\(constant.GooglemapAPI)")
        let data = try? Data(contentsOf: url!)
        
        var fullAddress = ""
        if data != nil{
            let json = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            if let result = json["results"] as? NSArray {
                if(result.count != 0){
                    if let address = (result[0] as AnyObject)["address_components"] as? NSArray {
                        var street : String = ""
                        var city : String = ""
                        var locality : String = ""
                        var state : String = ""
                        var country : String = ""
                        var zipcode : String = ""
                        
                        let streetNameStr : NSMutableString = NSMutableString()
                        
                        for item in address{
                            let item1 = (item as AnyObject)["types"] as! NSArray
                            
                            if((item1.object(at: 0) as! String == "street_number") || (item1.object(at: 0) as! String == "premise") || (item1.object(at: 0) as! String == "route")) {
                                let number1 = (item as AnyObject)["long_name"] as! String
                                streetNameStr.append(number1)
                                street = streetNameStr  as String
                                
                            }else if(item1.object(at: 0) as! String == "locality"){
                                let city1 = (item as AnyObject)["long_name"]
                                city = city1 as! String
                                locality = ""
                            }else if(item1.object(at: 0) as! String == "administrative_area_level_2" || item1.object(at: 0) as! String == "political") {
                                let city1 = (item as AnyObject)["long_name"]
                                locality = city1 as! String
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
                            fullAddress = "\(street)$\(city)$\(locality)$\(state)$\(country)$\(zipcode)"
                            if let address = (result[0] as AnyObject)["formatted_address"] as? String{
                                return address
                            }else{
                                return fullAddress
                            }
                        }
                    }
                }
            }
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Cell = tableView.dequeueReusableCell(withIdentifier: "TransactionDetailTableViewCell") as! TransactionDetailTableViewCell
        Cell.lblTitle.text = themes.setLang((titleArray.object(at: indexPath.row) as? String)!)
        Cell.lblDescL.text = descArray.object(at: indexPath.row) as? String
        Cell.lblDescL.sizeToFit()
        if indexPath.row == 0 || indexPath.row == titleArray.count-1{
            
            
            Cell.lblTitle.textColor = UIColor.init(red: 32/250, green: 109/250, blue: 22/250, alpha: 1)
            Cell.lblDescL.textColor = UIColor.init(red: 32/250, green: 109/250, blue: 22/250, alpha: 1)
        }else{
            Cell.lblTitle.textColor = UIColor.darkGray
            Cell.lblDescL.textColor = UIColor.gray
            
        }
        return Cell
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
