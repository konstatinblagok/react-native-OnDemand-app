//
//  reviewViewController.swift
//  Plumbal
//
//  Created by Casperon on 07/02/17.
//  Copyright © 2017 Casperon Tech. All rights reserved.
//

import UIKit

class reviewViewController: RootViewController,UITextViewDelegate {
    fileprivate var loading = false {
        didSet {
            
        }
    }

    var themes:Themes=Themes()
      var nextPageStr:NSInteger!
    let URL_Handler:URLhandler=URLhandler()
    var reviewsArray:NSMutableArray = [];
    @IBOutlet weak var lblreviews: UILabel!


    @IBOutlet var review_table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        nextPageStr = 0
        review_table.register(UINib(nibName: "ReviewsTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewsTblIdentifier")
        review_table.estimatedRowHeight = 130
        review_table.rowHeight = UITableViewAutomaticDimension
        review_table.tableFooterView = UIView()

        self.GetReviews()
        
        lblreviews.text = themes.setLang("reviews")


        // Do any additional setup after loading the view.
    }

    @IBAction func menubtnAction(_ sender: AnyObject) {
        self.findHamburguerViewController()?.showMenuViewController()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func GetReviews(){
        
        let Param: Dictionary = ["user_id":"\(themes.getUserID())",
                                 "role":"user",
                                 "page":"\(nextPageStr)" as String,
                                 "perPage":kPageCount]
        // print(Param)
        self.showProgress()
        
        URL_Handler.makeCall(constant.GetUserreviews, param: Param as NSDictionary) {
            (responseObject, error) -> () in
            
            self.DismissProgress()
            
            self.review_table.isHidden=false
            self.review_table.dg_stopLoading()
            self.loading = false
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
            }
            else
            {
                if(responseObject != nil && (responseObject?.count)!>0)
                {
                    let Dict1:NSDictionary=responseObject!.object(forKey: "data") as! NSDictionary

                    let status=self.themes.CheckNullValue(Dict1.object(forKey: "status"))!
                    
                    if(status == "1")
                    {
                        let Dict:NSDictionary=responseObject!.object(forKey: "data") as! NSDictionary

                        if(((Dict.object(forKey: "response") as AnyObject).object(forKey: "reviews") as AnyObject).count>0){
                            let  listArr:NSArray=(Dict.object(forKey: "response") as AnyObject).object(forKey: "reviews") as! NSArray
                            if(self.nextPageStr==1){
                                self.reviewsArray.removeAllObjects()
                            }
                            for (_, element) in listArr.enumerated() {
                                let element = element as! NSDictionary
                                let rec = ReviewRecords(name: self.themes.CheckNullValue(element.object(forKey: "tasker_name"))!, time: self.themes.CheckNullValue(element.object(forKey: "date"))!, desc: self.themes.CheckNullValue(element.object(forKey: "comments"))!, rate: self.themes.CheckNullValue(element.object(forKey: "rating"))!, img: self.themes.CheckNullValue(element.object(forKey: "tasker_image"))!,ratting:self.themes.CheckNullValue(element.object(forKey: "image"))!,jobid :self.themes.CheckNullValue(element.object(forKey: "booking_id"))!)
                                
                                self.reviewsArray.add(rec)
                            }
                            self.review_table.reload()
                            self.nextPageStr=self.nextPageStr+1
                        }else{
                            if(self.nextPageStr>1){
                                self.view.makeToast(message:self.themes.setLang("no_leads"), duration: 3, position: HRToastPositionDefault, title:"\(Appname)")
                            }
                        }
                    }
                    else
                    {
                        let message=self.themes.CheckNullValue(responseObject!.value(forKeyPath: "data.response"))!
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
    func tableView(_ tableView: UITableView!, heightForRowAtIndexPath indexPath: IndexPath!) -> CGFloat
    {
        
        return 115
        
        
    }
    

    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
            return reviewsArray.count
           }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) ->     UITableViewCell {
        
        let cell3:UITableViewCell
        
       
            let cell:ReviewsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ReviewsTblIdentifier") as! ReviewsTableViewCell
            
            if (reviewsArray.count > 0)
            {
                cell.loadReviewTableCell((reviewsArray .object(at: indexPath.row) as! ReviewRecords), currentView:MyProfileViewController() as UIViewController)
                
            }
            cell.selectionStyle=UITableViewCellSelectionStyle.none
            cell3=cell
        
        
        return cell3
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
