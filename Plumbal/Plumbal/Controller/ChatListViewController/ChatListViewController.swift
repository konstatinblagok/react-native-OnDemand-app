//
//  ChatListViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 19/01/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit

class ChatListViewController: RootViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var Chat_TableView: UITableView!
    var themes:Themes=Themes()
    var ChatTextArray:NSMutableArray=NSMutableArray()
    var Chat_NameArray:NSMutableArray=NSMutableArray()
    let URL_Handler:URLhandler=URLhandler()
    var nameArray:NSMutableArray=NSMutableArray()
    var p_idArray:NSMutableArray=NSMutableArray()
    var job_idArray:NSMutableArray=NSMutableArray()
    var msgArray:NSMutableArray=NSMutableArray()
    var msg_timeArray:NSMutableArray=NSMutableArray()
    var imageArray:NSMutableArray=NSMutableArray()
    var tasker_idarray : NSMutableArray = NSMutableArray()
    var Category_idArray : NSMutableArray = NSMutableArray()
    var created_dateArray:NSMutableArray = NSMutableArray()
    var tasker_statusArray:NSMutableArray = NSMutableArray()
    var GetlastmesgfromArray : NSMutableArray = NSMutableArray()




    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = themes.setLang("chat")
        ChatTextArray=["Hello How are you","Hope You have a nice experience","Doing Great huhhh","Hello derella","The plumbing is on"]
        Chat_NameArray=["Annand","Jim","Darry","Dickens","Henry"]
         let Nb=UINib(nibName: "ChatListTableViewCell", bundle: nil)
        Chat_TableView.register(Nb, forCellReuseIdentifier: "ChatCell")
         Chat_TableView.estimatedRowHeight=120
        
        Chat_TableView.rowHeight = UITableViewAutomaticDimension
        Chat_TableView.separatorColor=UIColor.lightGray
        Chat_TableView.tableFooterView=UIView()

        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleLabel.text = themes.setLang("chat")
        ChatTextArray=["Hello How are you","Hope You have a nice experience","Doing Great huhhh","Hello derella","The plumbing is on"]
        Chat_NameArray=["Annand","Jim","Darry","Dickens","Henry"]
        let Nb=UINib(nibName: "ChatListTableViewCell", bundle: nil)
        Chat_TableView.register(Nb, forCellReuseIdentifier: "ChatCell")
        Chat_TableView.estimatedRowHeight=120
        
        Chat_TableView.rowHeight = UITableViewAutomaticDimension
        Chat_TableView.separatorColor=UIColor.lightGray
        Chat_TableView.tableFooterView=UIView()
self.showProgress()
        GetDetails()
        

    }
    
    func GetDetails()
    {
        
        
        nameArray=NSMutableArray()
        p_idArray=NSMutableArray()
        job_idArray=NSMutableArray()
        msgArray=NSMutableArray()
        msg_timeArray=NSMutableArray()
        imageArray=NSMutableArray()
        tasker_idarray = NSMutableArray()
        
        created_dateArray = NSMutableArray()
        tasker_statusArray = NSMutableArray()
         GetlastmesgfromArray  = NSMutableArray()

        let param=["type":"1","userId":"\(themes.getUserID())"]

        
        URL_Handler.makeCall(constant.Show_ChatList, param: param as NSDictionary) { (responseObject, error) -> () in
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
                    let Dict:NSDictionary=responseObject!
                    
                    let Status=self.themes.CheckNullValue(Dict.object(forKey: "status"))!
                    
                    
                    
                    if(Status == "1")
                    {
                        
                        let ChatList: NSMutableArray = ((Dict.object(forKey: "response")! as AnyObject).object(forKey: "message") as? NSMutableArray)!
                        if(ChatList.count > 0 )
                        {
                            self.Chat_TableView.isHidden=false
                         for  Dict in ChatList
                        {
                            
                            let image=self.themes.CheckNullValue((Dict as AnyObject).object(forKey: "tasker_image"))!
                            let name=self.themes.CheckNullValue((Dict as AnyObject).object(forKey: "tasker_name"))!
                            let p_id=self.themes.CheckNullValue((Dict as AnyObject).object(forKey: "task_id"))!
                            let job_id=self.themes.CheckNullValue((Dict as AnyObject).object(forKey: "booking_id"))!
                            let providerid=self.themes.CheckNullValue((Dict as AnyObject).object(forKey: "tasker_id"))!
                            let category=self.themes.CheckNullValue((Dict as AnyObject).object(forKey: "category"))!
                            
                            let created_date = self.themes.CheckNullValue((Dict as AnyObject).object(forKey: "created"))!
                            let tasker_status = self.themes.CheckNullValue((Dict as AnyObject).object(forKey: "user_status"))!
                            let lastmsgfrom = self.themes.CheckNullValue((Dict as AnyObject).object(forKey: "last_message_from"))!

                            
                            
                            self.nameArray.add(name)
                            self.p_idArray.add(p_id)
                            self.job_idArray.add(job_id)
                            //self.msgArray.addObject(msg)
                            //                            self.msg_timeArray.addObject(msg_time)
                            self.imageArray.add(image)
                            self.tasker_idarray.add(providerid)
                            self.Category_idArray.add(category)
                            self.created_dateArray.add(created_date)
                            self.tasker_statusArray.add(tasker_status)
                            self.GetlastmesgfromArray.add(lastmsgfrom)

                         }
                        self.Chat_TableView.reload()
                        }
                        else
                        {
                            self.Chat_TableView.isHidden=true
                        }
                        
                     }
                    else
                    {
                        let Response = self.themes.CheckNullValue(Dict.object(forKey: "response"))!
                        
                        self.themes.AlertView("\(Appname)", Message: "\(Response)", ButtonTitle: kOk)

                        
                    }
                    
                }
                else
                {
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)

                }
            }
            
            
        }

        
        
        
     }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     @IBAction func didClickOptions(_ sender: UIButton) {
        if(sender.tag == 0)
        {
            self.findHamburguerViewController()?.showMenuViewController()
        }
    }
    
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.p_idArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
                  let Cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatListTableViewCell

        Cell.Provider_image.sd_setImage(with: URL(string: "\(imageArray[indexPath.row])"), placeholderImage: UIImage(named: "PlaceHolderSmall"))

        //Cell.Provider_image.sd_setImageWithURL(NSURL(string: "\(imageArray[indexPath.row])"), completed: themes.block)
        Cell.Chat_Lbl.text="\(nameArray[indexPath.row])"
        Cell.Provider_image.layer.cornerRadius = Cell.Provider_image.frame.size.height / 2;
        Cell.Provider_image.layer.masksToBounds = true;
        Cell.Provider_image.layer.borderWidth = 0;
        Cell.Provider_image.contentMode = UIViewContentMode.scaleAspectFill
        Cell.selectionStyle=UITableViewCellSelectionStyle.none
        Cell.Time_Lab.text = "\(job_idArray[indexPath.row])"
        Cell.catagory_labl.text="\(Category_idArray[indexPath.row])"
        Cell.created_date.text = "\(created_dateArray[indexPath.row])"
        
        if (tasker_statusArray.object(at: indexPath.row) as! String == "1"
            && GetlastmesgfromArray.object(at: indexPath.row) as! String  != "\(themes.getUserID())")
        {
            Cell.border_view.backgroundColor = PlumberThemeColor
        }
        else{
            Cell.border_view.backgroundColor = UIColor.clear
        }
        Cell.border_view.layer.cornerRadius = Cell.border_view.frame.size.width/2
        Cell.border_view.clipsToBounds=true
          return Cell
     }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        Message_details.taskid = self.p_idArray[indexPath.row] as! String
        Message_details.providerid = self.tasker_idarray[indexPath.row] as! String
        Message_details.name = self.nameArray[indexPath.row] as! String
        Message_details.image = self.imageArray[indexPath.row] as! String
        
        
        
        
        
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageVC") as! MessageViewController
        
        self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)
        //        }
        
        
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
