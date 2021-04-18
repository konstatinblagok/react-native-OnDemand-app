//
//  ChooseCityViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 23/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit
import SwiftyJSON




class ChooseCityViewController: RootViewController {

    @IBOutlet var City_tableView: UITableView!
    let themes:Themes=Themes()
    var URL_handler:URLhandler=URLhandler()
    var Citylistarray:NSMutableArray=NSMutableArray()
    var Cityidarray:NSMutableArray=NSMutableArray()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        City_tableView.tableFooterView=UIView()
        
        City_tableView.isHidden=true
        
        City_tableView.backgroundColor=UIColor.clear
        
        
        let nibName = UINib(nibName: "LocationTableViewCell", bundle:nil)
        self.City_tableView.register(nibName, forCellReuseIdentifier: "Cell")
        reloadCityData()


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadCityData()
    {
        
        self.showProgress()
        
        //let Param: Dictionary<String, String> = [:]
        
        URL_handler.makeGetCall(constant.Get_Location){ (responseObject) -> () in
      //  URL_handler.makeCall(constant.Get_Location, param: Param) { (responseObject, error) -> () in
            self.DismissProgress()
           
//            if(error != nil)
//            {
//                self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
//            }
//                
//            else
//            {
            


            
            if(responseObject != nil)
            {
                let json = JSON(responseObject!)
                
                
                
                let status=json["status"].string!
                
                
                if(status == "0")
                {
                    
                    self.themes.AlertView("\(Appname)",Message: self.themes.setLang("no_location_found"),ButtonTitle: kOk)
                    
                }
                else
                {
                    self.City_tableView.isHidden=false

                    
                    
                    let Locationarray:NSArray=(responseObject?.object(forKey: "response")! as AnyObject).object(forKey: "locations") as! NSArray
                    
                    
                    
                    for  Dict in Locationarray
                    {
                        
                        let city_name=(Dict as AnyObject).object(forKey: "city") as! String
                        
                        let id=(Dict as AnyObject).object(forKey: "id") as! String
                        
                        self.Citylistarray.add(city_name)
                        self.Cityidarray.add(id)
                        
                        self.City_tableView.reload()
                        
                    }
                    
                }
                
                
                
                
            }
            else
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
            }
            
            
            
        //}
        }
        
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Citylistarray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let Cell:LocationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! LocationTableViewCell
        Cell.selectionStyle=UITableViewCellSelectionStyle.none
        
        Cell.City_Name_Lab.text=Citylistarray.object(at: indexPath.row)  as? String
        
        
        
        
        
        if(Menu_dataMenu.Location_Detail == Citylistarray.object(at: indexPath.row)  as! String)
        {
            
            Cell.markerView.isHidden=false
            
            Cell.Check_Mark.isHidden=false
            
            
        }
            
        else
            
        {
            Cell.markerView.isHidden=true
            
            Cell.Check_Mark.isHidden=true
            
            
            
        }
        
        Cell.backgroundColor=UIColor.clear
        
        
        
        return Cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        signup.currency_Sym=self.themes.Currency_Symbol(signup.currency as String)
         self.themes.saveCountryCode(signup.Country_Code as String!)
        self.themes.saveLocationname(signup.Locationname as String)
        self.themes.saveCurrency(signup.Walletamt as String)
        self.themes.saveCurrencyCode(signup.currency_Sym as String)
        self.themes.saveUserID(signup.Userid as String)
        self.themes.saveUserPasswd(signup.Password as String)
        self.themes.saveUserName(signup.username as String)
        self.themes.saveEmailID(signup.Email as String)
        self.themes.saveuserDP(signup.Userimage as String)
        self.themes.saveMobileNum(signup.Contact_num as String)
        self.themes.saveWalletAmt(signup.Walletamt as String)
        self.themes.saveJaberID(signup.user_id as String)
        self.themes.saveJaberPassword(signup.soc_key as String)


        
        
        Menu_dataMenu.Location_Detail="\(Citylistarray.object(at: indexPath.row))"
        
        
        
        City_tableView.reload()
        
        UpdateLocation("\(Cityidarray.object(at: indexPath.row))" as NSString)
        
        signup.Locationname="\(Citylistarray.object(at: indexPath.row))"

        self.themes.saveLocationname("\(Citylistarray.object(at: indexPath.row))")

         Menu_dataMenu.Location_Detail=""
        
     }
    func UpdateLocation(_ Cityid:NSString)
    
    {
        
        self.showProgress()
        let Param: Dictionary = ["user_id":"\(themes.getUserID())","location_id":"\(Cityid)"]
         URL_handler.makeCall(constant.Update_Location, param: Param as NSDictionary) { (responseObject, error) -> () in
            self.DismissProgress()
            
            if(error != nil)
            {
                //self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)

            }
                
            else
            {
                
             if(responseObject != nil)
            {
                let json = JSON(responseObject!)
                
                
                
                let status=json["status"].string!
                
                
                if(status == "0")
                {
                    self.themes.AlertView("\(Appname)",Message: self.themes.setLang("no_location_found"),ButtonTitle: kOk)
                    
                }
                else
                {
                    
                    signup.Locationid=json["location_id"].string!
                    self.themes.saveLocationID(signup.Locationid as String)
              
                    //Home
//                    self.performSegueWithIdentifier("HomeVC", sender: nil)
                   Appdel.MakeRootVc("RootVCID")

                    
                }
   
            }
            else
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
            }
            
            
            
        }
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


