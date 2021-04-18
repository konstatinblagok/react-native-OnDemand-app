//
//  TransactionVC.swift
//  Plumbal
//
//  Created by Casperon on 06/02/17.
//  Copyright © 2017 Casperon Tech. All rights reserved.
//

import UIKit

class TransactionVC: RootViewController {
    var themes:Themes=Themes()
    let URL_Handler:URLhandler=URLhandler()
    var PageCount:NSInteger=0
    var refreshControl:UIRefreshControl=UIRefreshControl()
    var jobidArray : NSMutableArray = NSMutableArray()
    var categoryArray : NSMutableArray = NSMutableArray()
    var amountArray : NSMutableArray = NSMutableArray()
    @IBOutlet var titleLbl: UILabel!

    @IBOutlet var transaction_table: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibName = UINib(nibName: "transacationTableViewCell", bundle:nil)
        self.transaction_table.register(nibName, forCellReuseIdentifier: "transactionCell")
        transaction_table.estimatedRowHeight = 80
        transaction_table.rowHeight = UITableViewAutomaticDimension
        titleLbl.text = themes.setLang("transaction")
        self.showProgress()
    self.GetTransaction()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func menubtnAction(_ sender: AnyObject) {
        self.findHamburguerViewController()?.showMenuViewController()

    }
    
    func GetTransaction()  {
        let param=["user_id":"\(themes.getUserID())"]
        URL_Handler.makeCall(constant.Get_Transaction, param: param as NSDictionary) { (responseObject, error) -> () in
            self.DismissProgress()
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                
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
                        
                        if TotalJobsArray.count == 0{
                            self.themes.AlertView(Appname, Message: self.themes.setLang("transac_unavail"), ButtonTitle: kOk)

                        }
                        
                        for transacDict in TotalJobsArray
                        {
                            let jobid=self.themes.CheckNullValue((transacDict as AnyObject).object(forKey: "job_id"))!
                            self.jobidArray.add(jobid)
                            let category=self.themes.CheckNullValue((transacDict as AnyObject).object(forKey: "category_name"))!
                            self.categoryArray.add(category)
                            let amount=self.themes.CheckNullValue((transacDict as AnyObject).object(forKey: "total_amount"))!
                            
                            self.amountArray.add("\(self.themes.getCurrencyCode())\(amount)")

                            
                        }
                        if (TotalJobsArray.count == 0)
                        {
                            self.themes.AlertView(Appname, Message: self.themes.setLang("transac_unavail"), ButtonTitle: kOk)

                        }

                        self.transaction_table.reload()

                    }
                    else
                    {
                        let message=self.themes.CheckNullValue(responseObject!.object(forKey: "response"))!
                        self.themes.AlertView(Appname, Message: message, ButtonTitle: kOk)
                    }
                    
                }
                else
                {
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                }
            }
            
        }
    }
  
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if jobidArray.count > 0{
            return self.jobidArray.count

        }
        else{
            return 0

        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let Cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as! transacationTableViewCell
        
      Cell.totalview.layer.shadowOffset = CGSize(width: 2, height: 2)
       // Cell.totalview.layer.cornerRadius=14;
        Cell.totalview.layer.shadowOpacity = 0.2
        Cell.totalview.layer.shadowRadius = 2
          if jobidArray.count > 0
          {
      Cell.jobid.text = self.jobidArray.object(at: indexPath.row) as? String
         Cell.category.text = self.categoryArray.object(at: indexPath.row) as? String
         Cell.totalamount.text = self.amountArray.object(at: indexPath.row) as? String
        }
        
        
        
        return Cell
    }

     func tableView(_ tableView: UITableView!, heightForRowAtIndexPath indexPath: IndexPath!) -> CGFloat {
   return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let Controller:TransactionDetailsViewController=self.storyboard?.instantiateViewController(withIdentifier: "transDetail") as! TransactionDetailsViewController
        Controller.GetJob_id = self.jobidArray.object(at: indexPath.row) as! String
        self.navigationController?.pushViewController(withFlip: Controller, animated: true)

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
