//
//  FareSummaryViewController.swift
//  PlumberJJ
//
//  Created by Casperon Technologies on 11/30/15.
//  Copyright © 2015 Casperon Technologies. All rights reserved.
//

import UIKit

class FareSummaryViewController: RootViewController,UITableViewDataSource,UITableViewDelegate {
    var jobIDStr:String = ""
    var url_handler:URLhandler=URLhandler()
   // var theme:Theme=Theme()
    var fareSummaryArr:NSMutableArray = [];
    @IBOutlet weak var headerFare: UILabel!
     @IBOutlet var review_Btn: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet var backbtn: UIButton!
    @IBOutlet weak var fareTblView: UITableView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var jobIdLbl: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var fareScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerFare.text = themes.setLang("fare_summary")

        themes.Back_ImageView.image=UIImage(named: "")
        
        backbtn.addSubview(themes.Back_ImageView)
        fareTblView.register(UINib(nibName: "FareDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "fareDetailCellIdentifier")
        fareTblView.estimatedRowHeight = 56
        fareTblView.rowHeight = UITableViewAutomaticDimension
        fareTblView.tableFooterView = UIView()
         GetFareDetails()
        jobIdLbl.text="\(themes.setLang("job_id")) : \(jobIDStr)"
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        review_Btn.isHidden = true
       print("OK")
    }
   
    func GetFareDetails(){
        
        let Param: Dictionary = ["user_id":"\(themes.getUserID())",
            "job_id":"\(jobIDStr)"]
        // print(Param)
        self.showProgress()
        url_handler.makeCall(constant.Get_Summary_Details, param: Param as NSDictionary) {
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
                    let needPaymentStr = "0"
                    if(status == "1")
                    {
                        if(((responseObject?.object(forKey: "response") as AnyObject).object(forKey: "billing")! as AnyObject).count>0){
                            
                          //  self.descLbl.text=themes.CheckNullValue(((responseObject?.object(forKey: "response") as AnyObject).object(forKey: "job") as AnyObject).object(forKey: "job_summary"))
                            let currencyStr=themes.getCurrencyCode()
                            // (self.themes.CheckNullValue(responseObject?.objectForKey("response")?.objectForKey("job")?.objectForKey("currency") as! String))
                            
                            self.descLbl.sizeToFit()
                            
                            let  listArr:NSArray=(responseObject?.object(forKey: "response") as AnyObject).object(forKey: "billing") as! NSArray
                            let  info = (responseObject?.object(forKey: "response") as AnyObject).object(forKey: "info")
                            let review = themes.CheckNullValue((info as AnyObject).object(forKey: "review"))
                            
                            if review  == "1"{
                                //self.review_Btn.hidden = false
                            }
                            else{
                                //self.review_Btn.hidden = true
                            }

                            for (_, element) in listArr.enumerated() {
                                let getResponseDic : NSDictionary = (element as AnyObject).object(forKey: "response")! as! NSDictionary
                                NSLog("get list arrya =%@", getResponseDic)
                                let result1:JobDetailRecord=JobDetailRecord()
                                let tit = themes.CheckNullValue(getResponseDic.object(forKey: "title"))!
                                result1.jobTitle = tit
                                result1.jobStatus=themes.CheckNullValue(getResponseDic.object(forKey: "dt"))!
                                if result1.jobStatus == "0"
                                {
                                    
                                    result1.jobDesc=themes.CheckNullValue(getResponseDic.object(forKey: "amount"))!
                                }
                                    
                                else
                                {
                                    result1.jobDesc="\(currencyStr)\(themes.CheckNullValue(getResponseDic.object(forKey: "amount"))!)"
                                    
                                }
                                self.fareSummaryArr .add(result1)
                            }
                            
                            
                        }
                        else{
                            
                            self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                        
                        }
                        self.fareTblView.reload()
                        //This code will run in the main thread:
                        
                        var frame: CGRect = self.fareTblView.frame
                        frame.origin.y=self.descLbl.frame.origin.y+self.descLbl.frame.size.height+20
                        frame.size.height = self.fareTblView.contentSize.height;
                        self.fareTblView.frame = frame;
                        self.contentView.frame=CGRect(x: self.contentView.frame.origin.x, y: self.contentView.frame.origin.y, width: self.contentView.frame.size.width, height: self.fareTblView.frame.origin.y+self.fareTblView.frame.size.height+20)
                        if(needPaymentStr=="1"){
                            self.fareScrollView.contentSize=CGSize(width: self.fareScrollView.frame.size.width, height: self.contentView.frame.origin.y+self.contentView.frame.size.height+50)
                        }else{
                           self.fareScrollView.contentSize=CGSize(width: self.fareScrollView.frame.size.width, height: self.contentView.frame.origin.y+self.contentView.frame.size.height)
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
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fareSummaryArr.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell:FareDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "fareDetailCellIdentifier") as! FareDetailTableViewCell
      cell.loadFareTableCell(fareSummaryArr.object(at: indexPath.row) as! JobDetailRecord)
        cell.selectionStyle=UITableViewCellSelectionStyle.none
         return cell
    }
    
    @IBAction func reviewBtn_Action(_ sender: UIButton) {
        
        let ratings_Controller:RatingsViewController=self.storyboard?.instantiateViewController(withIdentifier: "ReviewPoup") as! RatingsViewController
        Root_Base.Job_ID = jobIDStr
        self.navigationController?.pushViewController(withFlip: ratings_Controller, animated: true)
    
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickBackBtn(_ sender: AnyObject) {
        self.navigationController?.popViewControllerWithFlip(animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        
        self.view.hideToast(toast: self.view)
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
