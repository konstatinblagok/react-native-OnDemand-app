//
//  WalletDetailViewController.swift
//  Plumbal
//
//  Created by Casperon on 06/09/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit

class WalletDetailViewController: RootViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet var Walletsegment: CustomSegmentControl!
    @IBOutlet var backbtn: UIButton!
    @IBOutlet var Transactiontable: UITableView!
    
    @IBOutlet weak var titleBtn: UIButton!
    
    var themes:Themes=Themes()
    var refreshControl:UIRefreshControl=UIRefreshControl()

     var URL_handler:URLhandler=URLhandler()
    
    var TransacTypeArray:NSMutableArray=NSMutableArray()
    var TransacAmountArray:NSMutableArray=NSMutableArray()
    var TransacTitleArray:NSMutableArray=NSMutableArray()
    var TransacDateArray:NSMutableArray=NSMutableArray()
    var TransacBalanceArray:NSMutableArray=NSMutableArray()
    var Trans_status: NSString = NSString()
    override func viewDidLoad() {
        super.viewDidLoad()
        titleBtn.setTitle(themes.setLang("transaction"), for: UIControlState())

        
        themes.Back_ImageView.image=UIImage(named: "")
        backbtn.addSubview(themes.Back_ImageView)
        Walletsegment.frame=CGRect(x: 5, y: 92, width: view.frame.size.width-10, height: 43)
        Walletsegment.setTitle(themes.setLang("all"), forSegmentAt: 0)
        Walletsegment.setTitle(themes.setLang("credit"), forSegmentAt: 1)
        Walletsegment.setTitle(themes.setLang("debit"), forSegmentAt: 2)
        Walletsegment.selectedSegmentIndex=0
        Walletsegment.tintColor=themes.ThemeColour()
        
        Walletsegment.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Roboto", size: 14.0)!, NSForegroundColorAttributeName: themes.DarkRed()], for: UIControlState())
        Trans_status = "all"
          let nibName = UINib(nibName: "TransTableViewCell", bundle:nil)
        self.Transactiontable.register(nibName, forCellReuseIdentifier: "TransaCell")
        self.Transactiontable.frame = CGRect(x: Transactiontable.frame.origin.x, y: Walletsegment.frame.maxY+5, width: Transactiontable.frame.size.width, height:self.view.frame.size.height - CGFloat(self.Walletsegment.frame.maxY+5))
        Transactiontable.estimatedRowHeight = 250
        Transactiontable.rowHeight = UITableViewAutomaticDimension
        Transactiontable.separatorColor=UIColor.clear
        Transactiontable.dataSource = self
        Transactiontable.delegate = self
        
      
        GetTransactionDetails("\(Trans_status)" as NSString, ShowProgress: true)
        configurePulltorefresh()

        
        GetTransactionDetails("\(Trans_status)" as NSString, ShowProgress: true)

        // Do any additional setup after loading the view.
    }
    
    
    func configurePulltorefresh()
    {
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(WalletDetailViewController.Order_dataFeed), for: UIControlEvents.valueChanged)
        self.Transactiontable.addSubview(refreshControl)
        
       }
    func Order_dataFeed()
    {
        GetTransactionDetails("\(self.Trans_status)" as NSString, ShowProgress: false)
        
    }

    override func viewDidLayoutSubviews() {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
   


    @IBAction func didclickoption(_ sender: AnyObject) {
        self.navigationController?.popViewControllerWithFlip(animated: true)

        
    }
    @IBAction func ChangeTransaction(_ sender: CustomSegmentControl) {
        let segmentIndex:NSInteger = sender.selectedSegmentIndex;
        
        if(segmentIndex == 0)
        {
         
            Trans_status="all"
        GetTransactionDetails("\(Trans_status)" as NSString, ShowProgress: true)
            
        }
        if(segmentIndex == 1)
        {
            
            Trans_status="credit"
            GetTransactionDetails("\(Trans_status)" as NSString, ShowProgress: true)
            
            
        }
        if(segmentIndex == 2)
        {
            
            Trans_status="debit"
            GetTransactionDetails("\(Trans_status)" as NSString, ShowProgress: true)

            
            
        }

        
    }
  
    func ReloadData(_ sender: OrderDetailViewController) {
       // self.GetOrderDetails(PageStatus, Page_Count: PageCount,ShowProgress: true)
        
    }

    func GetTransactionDetails(_ Type:NSString,ShowProgress:Bool)
     {
        
        let param=["user_id":"\(themes.getUserID())","type":"\(Type)"]
        if(ShowProgress)
        {
            self.showProgress()
        }
        self.Transactiontable.backgroundView=nil

        
        URL_handler.makeCall(constant.Get_TransactionDetail, param: param as NSDictionary) { (responseObject, error) -> () in
            self.DismissProgress()
            
            self.Walletsegment.isEnabled=true
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)

               // self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                let nibView = Bundle.main.loadNibNamed("Nodata", owner: self, options: nil)![0] as! UIView
                nibView.frame = self.Transactiontable.bounds;
                self.Transactiontable.backgroundView=nibView
                
                
            }
            else
            {
            let dict:NSDictionary=responseObject!
            
            let Status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
            
            if(Status == "1")
            {
                
                
                
                let TransDict:NSDictionary=responseObject?.object(forKey: "response")  as! NSDictionary
                
                let TransArray:NSArray?=TransDict.object(forKey: "trans") as? NSArray
                self.emptyArray()
                
                if(TransArray != nil)
                {
                    
                    if(TransArray?.count != 0)
                    {
                        
                        for Dictionary in TransArray!
                        {
                            let Transtype=self.themes.CheckNullValue((Dictionary as AnyObject).object(forKey: "type"))!
                            self.TransacTypeArray.add(Transtype)
                            let Transamount=self.themes.CheckNullValue((Dictionary as AnyObject).object(forKey: "trans_amount"))!
                             self.TransacAmountArray.add(Transamount)
                            let Transtitle=self.themes.CheckNullValue((Dictionary as AnyObject).object(forKey: "title"))!
                            self.TransacTitleArray.add(Transtitle)
                            let TransDate=self.themes.CheckNullValue((Dictionary as AnyObject).object(forKey: "trans_date"))!
                            self.TransacDateArray.add(TransDate)
                            let Transbalance=self.themes.CheckNullValue((Dictionary as AnyObject).object(forKey: "balance_amount"))!
                            self.TransacBalanceArray.add(Transbalance)
                        

                    }
                         self.Transactiontable.backgroundView=nil
                    }
                    else
                    {
                        
                        let nibView = Bundle.main.loadNibNamed("Nodata", owner: self, options: nil)![0] as! UIView
                        nibView.frame = self.Transactiontable.bounds;
                        self.Transactiontable.backgroundView=nibView
                        
                        if(self.TransacTypeArray.count != 0)
                        {
                            self.Transactiontable.backgroundView=nil
                            
                        }
                        
                        self.present(self.themes.Showtoast("No more Orders"), animated: false, completion: nil)
                    }
                }
                
                self.Transactiontable.reload()
            }
                
            else
            {
                
                let Response:NSString=responseObject?.object(forKey: "response")  as! NSString
                self.themes.AlertView("\(Appname)", Message: "\(Response)", ButtonTitle: self.themes.setLang("ok"))
                self.emptyArray()
                self.Transactiontable.reload()
                }

                
                
            }
        }
    }
    
    
    func emptyArray()
    {
        
            if(self.TransacTypeArray.count != 0)
            {
                self.TransacTypeArray.removeAllObjects()
            }
            if(self.TransacAmountArray.count != 0)
            {
                self.TransacAmountArray.removeAllObjects()
            }
            if(self.TransacTitleArray.count != 0)
            {
                self.TransacTitleArray.removeAllObjects()
            }
            if(self.TransacDateArray.count != 0)
            {
                self.TransacDateArray.removeAllObjects()
            }
            if(self.TransacBalanceArray.count != 0)
            {
                self.TransacBalanceArray.removeAllObjects()
            }
        
        
        
    }
    
    
    override func showProgress()
    {
        self.activityIndicatorView.color = themes.DarkRed()
        self.activityIndicatorView.center=CGPoint(x: self.view.frame.size.width/2,y: self.view.frame.size.height/2);
        self.activityIndicatorView.startAnimating()
        self.view.addSubview(activityIndicatorView)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return TransacTypeArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 15
    }
    
    func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    //    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //
    //
    //        let height_Cell:CGFloat = self.themes.calculateHeightForString("\(OrderCompleteDetailArray.objectAtIndex(indexPath.section))")
    //
    //
    //        //         self.height_Return(height_Cell)
    //        return height_Cell+135
    //
    //     }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let Cell:TransTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TransaCell") as! TransTableViewCell
        
        
        
        Cell.frame.size.width=100.0
        
        
        Cell.selectionStyle = .none
        
        Cell.layer.cornerRadius = 5
        Cell.layer.shadowColor = UIColor.black.cgColor
        Cell.layer.shadowOpacity = 0.5
        Cell.layer.shadowRadius = 2
        Cell.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)

        
      
     NSLog("get cuurency symbol=%@", self.themes.getCurrencyCode())
        
        Cell.Transac_titlelabl.text="\(TransacTitleArray.object(at: indexPath.section))"
        Cell.Transac_Datelabl.text="\(themes.setLang("date")):\(TransacDateArray.object(at: indexPath.section))"
        Cell.Transac_amountlabl.text="\(themes.setLang("amount")):\(self.themes.getCurrencyCode())\(TransacAmountArray.object(at: indexPath.section))"
        Cell.Transac_Balancelabl.text="\(themes.setLang("balance")):\(self.themes.getCurrencyCode())\(TransacBalanceArray.object(at: indexPath.section))"
        
    
        
      
        
        
        
        return Cell
        
    }
    


}
