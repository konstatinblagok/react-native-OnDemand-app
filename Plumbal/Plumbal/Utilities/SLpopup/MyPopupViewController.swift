//
//  MyPopupViewController.swift
//  SLPopupViewControllerDemo
//
//  Created by Nguyen Duc Hoang on 9/13/15.
//  Copyright © 2015 Nguyen Duc Hoang. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import JTAlertView

protocol MyPopupViewControllerDelegate {
    //    func pressOK(sender: MyPopupViewController)
    func pressCancel(_ sender: MyPopupViewController)
    func PassSelectedAddress(_ Address:String,AddressIndexvalue:Int,latitudestr:String,longtitudestr:String,localitystr: String,fulladdress : String)
    func pressAdd (_ sender :MyPopupViewController)
    
    
}

class MyPopupViewController: UIViewController {
    
    var getIndex : Int = 0
    var delegate:MyPopupViewControllerDelegate?
    var Globalindex:String=String()
    var isDetailViewcontroller : Bool = Bool()
    
    @IBOutlet var listbtn: UIButton!
    @IBAction func didclickoption(_ sender: AnyObject) {
        self.delegate?.pressAdd(self)
        
    }
    
    @IBOutlet var Header_lab: UILabel!
    @IBOutlet var Address_tableView: UITableView!
    var themes:Themes=Themes()
    @IBOutlet var Close_WrapperView: UIView!
    
    var URL_handler:URLhandler=URLhandler()
    let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 75, height: 100),
                                                        type: .ballSpinFadeLoader)
    var AlertView:JTAlertView=JTAlertView()
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        
        super.viewDidLoad()
        getIndex = 0
        if isDetailViewcontroller == false
        {
            listbtn.isHidden = false
        }
        else
        {
            listbtn.isHidden = true
            
        }
        NSLog(isDetailViewcontroller ? "Yes" : "No");
        
        self.view.layer.cornerRadius = 22
        view.layer.borderWidth=1.0
        view.layer.borderColor=themes.ThemeColour().cgColor
        self.view.layer.masksToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(MyPopupViewController.loadList(_:)),name:NSNotification.Name(rawValue: "load"), object: nil)
        
        Close_WrapperView.layer.cornerRadius=Close_WrapperView.frame.size.width/2
        
        Close_WrapperView.layer.borderWidth=1.0
        Close_WrapperView.layer.borderColor=themes.ThemeColour().cgColor
        
        
        let Registernib=UINib(nibName: "AddressTableViewCell", bundle: nil)
        Address_tableView.register(Registernib, forCellReuseIdentifier: "AddressCell")
        
        
        let Tap:UITapGestureRecognizer=UITapGestureRecognizer(target: self, action: #selector(MyPopupViewController.Callcanceldelegate))
        Close_WrapperView.addGestureRecognizer(Tap)
        Header_lab.text=Schedule_Data.Schedule_header as String
        
        Address_tableView.tableFooterView=UIView()
        
        
        
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewDidLoad() {
        
    }
    
    
    func Callcanceldelegate()
    {
        self.delegate?.pressCancel(self)
    }
    
    func loadList(_ notification: Notification){
        //load data here
        
        print("loading")
        if(Schedule_Data.ScheduleAddressArray.count != 0)
        {
            
            Address_tableView.reload()
            
        }
    }
    
    
    
    
    
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        if Schedule_Data.ScheduleAddressArray .count > 0 {
            if isDetailViewcontroller == false
            {
                
                
                let height_Cell:CGFloat = self.themes.calculateHeightForString("\(Schedule_Data.ScheduleAddressArray[indexPath.row])")
                
                return height_Cell + 30
            }
            else
            {
                let height_Cell:CGFloat = self.themes.calculateHeightForString("\(Schedule_Data.ScheduleAddressArray[indexPath.row])")
                
                return height_Cell+15
            }
        }
        else {
            return   40.0
        }
        
        
    }
    
    func calculateHeightForString(_ inString:String) -> CGFloat
    {
        let messageString = inString
        let attrString:NSAttributedString? = NSAttributedString(string: messageString, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16.0)])
        let rect:CGRect = attrString!.boundingRect(with: CGSize(width: 300.0,height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context:nil )//hear u will get nearer height not the exact value
        let requredSize:CGRect = rect
        return requredSize.height  //to include button's in your tableView
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Schedule_Data.ScheduleAddressArray.count > 0
        {
            
            return Schedule_Data.ScheduleAddressArray.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        print("2 step")
        
        
        
        let Cell:AddressTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AddressCell") as! AddressTableViewCell
        
        
        Cell.More_address_btn.isHidden=true
        Cell.More_address_btn.isUserInteractionEnabled=false
        
        
        
        Cell.selectionStyle = .none
        //  Cell.Separator.hidden=true
        Cell.Address_Label.isHidden=false
        Cell.backgroundColor=UIColor.white
        
        if   Schedule_Data.ScheduleAddressArray.count > 0
        {
            Cell.Address_Label.isHidden=false
            
            Cell.Address_Label.text="\(Schedule_Data.ScheduleAddressArray[indexPath.row])"
        }
        
        if isDetailViewcontroller == false
        {
            
            
            
            
            Cell.Address_Label.frame = CGRect(x: Cell.Address_Label.frame.origin.x,y: Cell.More_address_btn.frame.origin.y,width: Cell.Address_Label.frame.size.width,height: Cell.More_address_btn.frame.size.height)
            
            
            if   Schedule_Data.ScheduleAddressArray.count > 0 {
                let height:CGFloat = self.themes.calculateHeightForString("\(Schedule_Data.ScheduleAddressArray[indexPath.row])")
                Cell.Address_Label.frame.size.height=height+40
            }
            
            Cell.More_icon.isHidden=true
            
            
            
            if (Schedule_Data.ScheduleAddressNameArray.count>0) {
                Cell.DeleteIcon.addTarget(self, action: #selector(MyPopupViewController.DeleteAddress(_:)), for: UIControlEvents.touchUpInside)
                Cell.DeleteIcon.tag=indexPath.row
                
                
                if Schedule_Data.ScheduleAddressNameArray.object(at: indexPath.row) as! String == Schedule_Data.scheduleAddressid
                {
                    Cell.Checkmark_ImageView.isHidden=false
                }
                else
                {
                    Cell.Checkmark_ImageView.isHidden=true
                }
                
                
            }
            
        }
            
        else
        {
            
            Cell.Address_Label.frame = CGRect(x: Cell.Address_Label.frame.origin.x,y:Cell.frame.origin.y,width: Cell.Address_Label.frame.size.width,height: Cell.Address_Label.frame.size.height)
            
            
            
            if   Schedule_Data.ScheduleAddressArray.count > 0
            {
                let height:CGFloat = self.themes.calculateHeightForString("\(Schedule_Data.ScheduleAddressArray[indexPath.row])")
                
                Cell.Address_Label.frame.size.height=height+15
            }
            
            
            Cell.More_icon.isHidden=true
            Cell.DeleteIcon.isHidden=true
            Cell.Checkmark_ImageView.isHidden = true
        }
        return Cell
        
        
    }
    func DeleteAddress(_ sender:UIButton)
    {
        self.showProgress()
        
        
        if Schedule_Data.ScheduleAddressArray.count > 0
        {
            
            let AddressName : NSString = Schedule_Data.ScheduleAddressNameArray[sender.tag] as! NSString
            
            let param=["user_id":"\(themes.getUserID())","address_name":"\(AddressName)"]
            
            URL_handler.makeCall(constant.Delete_Address, param: param as NSDictionary) { (responseObject, error) -> () in
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
                            let response:NSString=Dict.object(forKey: "response") as! NSString
                            self.themes.AlertView("\(Appname)", Message: "\(response)", ButtonTitle: self.themes.setLang("ok"))
                            
                            
                            print("\(Schedule_Data.ScheduleAddressNameArray)  and \( Schedule_Data.ScheduleAddressArray.count)")
                            
                            Schedule_Data.ScheduleAddressArray.remove(Schedule_Data.ScheduleAddressArray[sender.tag] as! NSString)
                            Schedule_Data.ScheduleAddressNameArray.remove(Schedule_Data.ScheduleAddressNameArray[sender.tag] as! NSString)
                            Schedule_Data.ScheduleLongtitudeArray.remove(Schedule_Data.ScheduleLongtitudeArray[sender.tag] as! NSString)
                            Schedule_Data.ScheduleLatitudeArray.remove(Schedule_Data.ScheduleLatitudeArray[sender.tag] as! NSString)
                            
                            
                            
                            
                            
                            
                            self.Address_tableView.reload()
                            
                            
                            self.delegate?.pressCancel(self)
                            
                            
                        }
                        else
                        {
                            self.themes.AlertView("\(Appname)", Message: self.themes.setLang("no_reasons_available"), ButtonTitle: kOk)
                            
                        }
                        
                    }
                    else
                    {
                        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    }
                }
                
            }
        }
        
    }
    func showProgress()
    {
        self.activityIndicatorView.color = themes.DarkRed()
        self.activityIndicatorView.center=CGPoint(x: self.view.frame.size.width/2,y: self.view.frame.size.height/2);
        self.activityIndicatorView.startAnimating()
        self.view.addSubview(activityIndicatorView)
    }
    func DismissProgress()
    {
        self.activityIndicatorView.stopAnimating()
        
        self.activityIndicatorView.removeFromSuperview()
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        if isDetailViewcontroller == false
        {
            
            getIndex = Int (Schedule_Data.ScheduleAddressNameArray.object(at: indexPath.row) as! NSString as String)!
            print("get address index=\(getIndex)")
            
            
            //  self.delegate?.PassSelectedAddress(Schedule_Data.ScheduleAddressArray.objectAtIndex(indexPath.row) as! String,AddressIndexvalue: indexPath.row)
            if Schedule_Data.ScheduleLatitudeArray.count == 0
            {
                self.delegate?.PassSelectedAddress(Schedule_Data.ScheduleAddressArray.object(at: indexPath.row) as! String, AddressIndexvalue: getIndex, latitudestr:"", longtitudestr: "",localitystr:"",fulladdress:"" )
                
            }
            else
            {
                self.delegate?.PassSelectedAddress(Schedule_Data.ScheduleAddressArray.object(at: indexPath.row) as! String, AddressIndexvalue:getIndex , latitudestr:Schedule_Data.ScheduleLatitudeArray.object(at: indexPath.row)as! String, longtitudestr: Schedule_Data.ScheduleLongtitudeArray.object(at: indexPath.row)as! String,localitystr:Schedule_Data.ScheduledisplayAddArray.object(at: indexPath.row) as! String,fulladdress :Schedule_Data.ScheduledlistaddArray.object(at: indexPath.row) as! String )
                
                
            }
            // Globalindex="\(indexPath.row)"
            Schedule_Data.scheduleAddressid = "\(getIndex)"
            self.Address_tableView.reload()
        }
        else{
            
            
            let getIndex : Int
            let convertStr : NSString = Schedule_Data.ScheduleAddressNameArray.object(at: indexPath.row) as! NSString
            
            
            getIndex = convertStr.integerValue
            
            self.delegate?.PassSelectedAddress(Schedule_Data.ScheduleAddressArray.object(at: indexPath.row) as! String, AddressIndexvalue: getIndex, latitudestr:"", longtitudestr:"", localitystr: "",fulladdress: "")
        }
        
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

