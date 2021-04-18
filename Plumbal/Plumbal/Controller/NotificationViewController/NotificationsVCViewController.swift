//
//  NotificationsVCViewController.swift
//  PlumberJJ
//
//  Created by Casperon on 08/02/17.
//  Copyright © 2017 Casperon Technologies. All rights reserved.
//

import UIKit
import DGElasticPullToRefresh

class NotificationsVCViewController:
RootViewController,UITableViewDelegate,UITableViewDataSource {
    let URL_Handler:URLhandler=URLhandler()

    @IBOutlet var notification_table: STCollapseTableView!
    var ResponseDict : NSMutableArray = NSMutableArray()
    var  CategoryArray : NSMutableArray = NSMutableArray()
    var bookingidArray : NSMutableArray = NSMutableArray()
    @IBOutlet var titleLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        notification_table.register(UINib(nibName: "notificationVCTableViewCell", bundle: nil), forCellReuseIdentifier: "notification")
        notification_table.estimatedRowHeight = 90
        notification_table.rowHeight = UITableViewAutomaticDimension
       
        titleLabel.text = themes.setLang("notification")

        notification_table.tableFooterView = UIView()
       // [self.tableView setExclusiveSections:!self.tableView.exclusiveSections];
        self.notification_table.exclusiveSections = self.notification_table.exclusiveSections

       self.notification_table.openSection(0, animated: false)

        showProgress()
        self.GetNotifications()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func GetNotifications(){
        
        
        let Param: Dictionary = ["user_id":"\(themes.getUserID())",
                                 "role":"user"]
        // print(Param)
        
        URL_Handler.makeCall( constant.GetNotificationUrl, param: Param as NSDictionary) {
            (responseObject, error) -> () in
            
            self.DismissProgress()
            
            self.notification_table.isHidden=false
            self.notification_table.dg_stopLoading()
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
            }
            else
            {
                if(responseObject != nil && (responseObject?.count)!>0)
                {
                    let Dict:NSDictionary=responseObject!
                    let status=themes.CheckNullValue(responseObject?.object(forKey: "status"))!
                    
                    if(status == "1")
                    {
                        
                        self.ResponseDict = (Dict.value(forKey: "response")! as? NSMutableArray)!
                        
                        
                        for  Dict in self.ResponseDict
                        {
                            
                            let category = themes.CheckNullValue((Dict as AnyObject).object(forKey: "booking_id"))!
                            let jobid = themes.CheckNullValue((Dict as AnyObject).object(forKey: "category"))!
                            self.CategoryArray.add(category)
                            self.bookingidArray.add(jobid)
                            
                        }
                                              self.notification_table.reload()
                        
                    }else{
                        let message=themes.CheckNullValue(responseObject!.object(forKey: "response"))!
                        themes.AlertView(Appname, Message: message, ButtonTitle: kOk)

                    }
                    
                    
                }
                else
                {
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                }
            }
        }
    }
    
    
    @IBAction func menubtnAct(_ sender: AnyObject) {
        self.findHamburguerViewController()?.showMenuViewController()

//        self.view.endEditing(true)
//        self.frostedViewController.view.endEditing(true)
//        // Present the view controller
//        //
//        self.frostedViewController.presentMenuViewController()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.CategoryArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->     UITableViewCell {
        
        let cell3:UITableViewCell
        
        let cell:notificationVCTableViewCell = tableView.dequeueReusableCell(withIdentifier: "notification") as! notificationVCTableViewCell
        cell.message.text = themes.CheckNullValue((((ResponseDict.object(at: indexPath.section) as AnyObject).object(forKey: "messages")! as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "message"))!
        cell.timelable.text = themes.CheckNullValue((((ResponseDict.object(at: indexPath.section) as AnyObject).object(forKey: "messages")! as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "createdAt"))!
        
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        cell3=cell
        
        
        return cell3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let MessagesArray : NSArray = (ResponseDict.object(at: section) as AnyObject).object(forKey: "messages")  as! NSArray
        return MessagesArray.count;
    }
    
    
    func tableView( _ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        let mainview = UIView.init(frame: CGRect(x: self.notification_table.frame.origin.x,y: 0,width: self.notification_table.frame.size.width, height: 50))
        let header = UIView(frame: CGRect(x: 20, y: 10, width: self.notification_table.frame.size.width-40, height: 40))
        header.backgroundColor = UIColor.white
        header.layer.borderColor=UIColor.gray.cgColor
        header.layer.borderWidth = 1.0;
        header.layer.cornerRadius = 10
        let btnimg :UIImageView = UIImageView(frame:CGRect(x: self.notification_table.frame.size.width-80,y: 10,width: 20,height: 20))

        let lable : UILabel = UILabel(frame: CGRect(x: 0, y: 5, width: header.frame.size.width, height: 30))
        btnimg.image = UIImage(named:"black_back")
        lable.text  = "\(themes.CheckNullValue(self.CategoryArray.object(at: section))!) - \(themes.CheckNullValue(self.bookingidArray.object(at: section))!)"
        lable.font = UIFont.init(name:"Roboto-Regular", size:14)
        lable.textAlignment = .center
        header.addSubview(lable)
        header.addSubview(btnimg)
        mainview.addSubview(header)
        return mainview
        
    }
    
    deinit {
        if (self.notification_table != nil)
        {
         self.notification_table.delegate = nil
        }
    }

    
    
    //     func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        return self.headers[section]
    //    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
