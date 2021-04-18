//
//  MessageViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 20/01/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import KissXML

class MessageViewController: RootViewController,InputbarDelegate,MessageGatewayDelegate,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIGestureRecognizerDelegate{
    
    
    @IBOutlet var Provider_Image: UIImageView!
    @IBOutlet var Block_Lbl: UILabel!
    @IBOutlet var User_lbl: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var inputbar: Inputbar!
    
    var ChatDetailsArr : NSMutableArray = NSMutableArray()
    var textArray : NSMutableArray = NSMutableArray()
    var FromDetailArray: NSMutableArray = NSMutableArray()
    var tasker_statusarray : NSMutableArray = NSMutableArray()
    var messgaeidarray : NSMutableArray = NSMutableArray()
    var getDateArray :NSMutableArray = NSMutableArray ()
    var tableArray:TableArray=TableArray()
    var gateway:MessageGateway=MessageGateway()
    @IBOutlet var typingLbl: RSDotsView!
    @IBOutlet var Status_Lbl: UIButton!
    @IBOutlet var Status_View: UILabel!
    var type_str:NSString=NSString()
    var chat:Chat=Chat()
    var themes:Themes=Themes()
    var URL_Handler:URLhandler=URLhandler()
    
    
    var people = [NSManagedObject]()
    
    
    
    
    let App_Delegate=UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        
        
        
        inputbar.delegate=self;
        super.viewDidLoad()
        setInputbar()
        self.setTableView()
        GetDetails()
        
        
        setStatusView()
        //inputbar.hidden=true
        //Block_Lbl.hidden=false
        SetImageView()
        
        let tapgesture:UITapGestureRecognizer=UITapGestureRecognizer(target:self, action:#selector(DismissKeyboard))
        tapgesture.delegate = self;
        
        view.addGestureRecognizer(tapgesture)
        setTest()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        Common_Chatid = Order_data.job_id
        
        
    }
    
    
    func DismissKeyboard()
    {
        
        inputbar.resignFirstResponder()
       // inputbar.hideKeyboard()
        
        
    }
    
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "readSinglemessagestatus"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "readmessagestatus"), object: nil)
        
        NotificationCenter.default.removeObserver(self);
        
        Common_Chatid = ""
    }
    
    func setStatusView()
    {
        Status_View.layer.cornerRadius = Status_View.frame.size.height / 2;
        Status_View.layer.masksToBounds = true;
        Status_View.layer.borderWidth = 0;
        Status_View.contentMode = UIViewContentMode.scaleAspectFill
        
    }
    
    func GetDetails()
    {
        self.showProgress()
        let param=["user":themes.getUserID(),"tasker":Message_details.providerid as String,"task":Message_details.taskid as String, "type":"user","read_status":"user"];
        
        
        URL_Handler.makeCall(constant.Chat_Details, param: param as NSDictionary) { (responseObject, error) -> () in
            self.DismissProgress()
            if(error != nil)
            {
                // self.themes.AlertView("", Message:"", ButtonTitle: "Ok")
                
            }
            else
            {
                if(responseObject != nil)
                {
                    let Dict:NSDictionary=responseObject!
                    
                    
                    let taskerDetails = Dict.object(forKey: "tasker") as! NSDictionary
                    
                    self.User_lbl.text = taskerDetails.object(forKey: "username") as? String
                    
                    Message_details.name=taskerDetails.object(forKey: "username") as! String
                    
                    Message_details.image=taskerDetails.object(forKey: "avatar") as! String
                    
                    self.Provider_Image.sd_setImage(with: URL(string:taskerDetails.object(forKey: "avatar") as! String), placeholderImage: UIImage(named: "PlaceHolderSmall"))
                    
                    let MessageDetails : NSMutableArray = Dict.object(forKey: "messages") as! NSMutableArray
                    
                    
                    if MessageDetails.count > 0
                    {
                        
                        for data  in MessageDetails
                        {
                            
                            
                            self.textArray.add(self.themes.CheckNullValue((data as AnyObject).value(forKey: "message"))!)
                            self.FromDetailArray.add(self.themes.CheckNullValue((data as AnyObject).value(forKey: "from"))!)
                            self.tasker_statusarray.add(self.themes.CheckNullValue((data as AnyObject).value(forKey: "tasker_status"))!)
                            self.messgaeidarray.add(self.themes.CheckNullValue((data as AnyObject).value(forKey: "_id"))!)
                            self.getDateArray.add(self.themes.CheckNullValue((data as AnyObject).value(forKey: "date"))!)
                        }
                        
                        
                        Message_details.job_id=Message_details.taskid as String
                        
                        
                        for k in 0..<self.textArray.count {
                            let mesg : Message = Message()
                            mesg.text = self.textArray.object(at: k) as! String;
                            
                            let text = self.getDateArray.object(at: k)  as! String
                            let types: NSTextCheckingResult.CheckingType = .date
                            var getdate = Date()
                            let detector = try? NSDataDetector(types: types.rawValue)
                            let matches = detector!.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.count))
                            for match in matches {
                                getdate = (match.date!)
                            }
                            mesg.date = getdate
                            
                            
                            if self.FromDetailArray.object(at: k) as! String == self.themes.getUserID()
                            {
                                mesg.sender = MessageSender.myself;
                                if (self.tasker_statusarray.object(at: k) as! String == "2")
                                {
                                    mesg.status = MessageStatus.read
                                }
                                else if (self.tasker_statusarray.object(at: k) as! String == "1")
                                {
                                    mesg.status = MessageStatus.received
                                }
                                
                            }
                            else{
                                mesg.sender = MessageSender.someone;
                            }
                            
                            self.tableArray.addObject(mesg)
                        }
                        self.tableView.reloadData()
                        self.tableViewScrollToBottomAnimated(true)
                        self.inputbar.isUserInteractionEnabled = true

          
                        let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            if SocketIOManager.sharedInstance.ChatSocket.status == .connected
                            {
                                
                                SocketIOManager.sharedInstance.SendingMessagestatus("user", Userid: self.themes.getUserID(), taskerid:Message_details.providerid as String, taskid: Message_details.taskid as String)
                            }
                        }
                        
                        
                    }
                    
                }
                else
                {
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                }
            }
            
            
        }
        
    }
    
    
    func SetImageView()
    {
        Provider_Image.layer.cornerRadius = Provider_Image.frame.size.height / 2;
        Provider_Image.clipsToBounds=true
        Provider_Image.layer.masksToBounds = true;
        // Provider_Image.layer.borderWidth = 0;
        Provider_Image.contentMode = UIViewContentMode.scaleAspectFill
        //Provider_Image.layer.borderWidth=2.0
        Provider_Image.layer.borderColor=UIColor.white.cgColor
        
        
    }
    
    func SetData()
    {
        
        if(Message_details.chat_status == "open" && Message_details.receiver_status == "online")
        {
            inputbar.isHidden=false
            Block_Lbl.isHidden=true
            Status_Lbl.setTitle("online", for: UIControlState())
            Status_View.backgroundColor=UIColor.green
        }
        else
        {
            inputbar.isHidden=true
            Block_Lbl.isHidden=false
            Status_Lbl.setTitle("offline", for: UIControlState())
            Status_View.backgroundColor=UIColor.gray
        }
        
        User_lbl.text=Message_details.name as String
        Provider_Image.sd_setImage(with: URL(string: Message_details.image as String), completed: themes.block)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceiveChat"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showMessage(_:)), name: NSNotification.Name(rawValue: "ReceiveChat"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceivePushChat"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showPushMessage(_:)), name: NSNotification.Name(rawValue: "ReceivePushChat"), object: nil)
        
        
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceiveTypingMessage"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showTypingStatus(_:)), name: NSNotification.Name(rawValue: "ReceiveTypingMessage"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceiveStopTypingMessage"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopTypingStatus(_:)), name: NSNotification.Name(rawValue: "ReceiveStopTypingMessage"), object: nil)
        
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "readmessagestatus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessageViewController.ReadmessageStatus(_:)), name:NSNotification.Name(rawValue: "readmessagestatus"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "readSinglemessagestatus"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MessageViewController.ReadSinglemessageStatus(_:)), name:NSNotification.Name(rawValue: "readSinglemessagestatus"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "Dismisskeyboard"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DismissKeyboard), name:NSNotification.Name(rawValue: "Dismisskeyboard"), object: nil)
        
        
        
        let controller:MessageViewController=self
        self.view.keyboardTriggerOffset = inputbar.frame.size.height
        self.view!.addKeyboardPanning(actionHandler: {(keyboardFrameInView: CGRect, opening: Bool, closing: Bool) -> Void in
            var toolBarFrame = self.inputbar.frame
            toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height
            self.inputbar.frame = toolBarFrame
            var tableViewFrame = self.tableView.frame
            tableViewFrame.size.height = toolBarFrame.origin.y - 80
            self.tableView.frame = tableViewFrame
            controller.tableViewScrollToBottomAnimated(false)
        })
    }
    
    func ReadSinglemessageStatus(_ notification: Notification){
        
        
        guard let url = notification.object else {
            return // or throw
        }
        
        let blob = url as! NSDictionary // or as! Sting or as! Int
        if(blob.count>0){
            
            let taskid : String = self.themes.CheckNullValue(blob.object(forKey: "task"))!
            
            if taskid == Message_details.taskid as String
            {
                let mesg : Message = tableArray.lastObject()
                mesg.status = MessageStatus.read
                
                tableView.reloadData()
                
            }
        }
    }
    
    func ReadmessageStatus(_ notification: Notification){
        
        guard let url = notification.object else {
            return // or throw
        }
        
        let blob = url as! NSDictionary // or as! Sting or as! Int
        if(blob.count>0){
            
            let taskid : String = themes.CheckNullValue(blob.object(forKey: "task"))!
            
            if taskid == Message_details.taskid as String
            {
                
                ChatDetailsArr  = NSMutableArray()
                textArray  = NSMutableArray()
                FromDetailArray = NSMutableArray()
                tasker_statusarray  = NSMutableArray()
                messgaeidarray  = NSMutableArray()
                self.tableArray = TableArray()
                gateway = MessageGateway()
                self.getDateArray = NSMutableArray()
                
                
                if blob.count > 0
                {
                    
                    let MessageDetails : NSMutableArray = blob.object(forKey: "messages") as! NSMutableArray
                    
                    for data  in MessageDetails
                    {
                        self.textArray.add(self.themes.CheckNullValue((data as AnyObject).value(forKey: "message"))!)
                        self.FromDetailArray.add(self.themes.CheckNullValue((data as AnyObject).value(forKey: "from"))!)
                        self.tasker_statusarray.add(self.themes.CheckNullValue((data as AnyObject).value(forKey: "tasker_status"))!)
                        self.messgaeidarray.add(self.themes.CheckNullValue((data as AnyObject).value(forKey: "_id"))!)
                        self.getDateArray.add(self.themes.CheckNullValue((data as AnyObject).value(forKey: "date"))!)
                    }
                    
                    Message_details.dateformat = self.getDateArray.object(at: 0) as! String
                    
                    Message_details.job_id=Message_details.taskid
                    
                    for k in 0..<textArray.count {
                        let mesg : Message = Message()
                        mesg.text = self.textArray.object(at: k) as! String;
                        
                        let text = self.getDateArray.object(at: k)  as! String
                        let types: NSTextCheckingResult.CheckingType = .date
                        var getdate = Date()
                        let detector = try? NSDataDetector(types: types.rawValue)
                        let matches = detector!.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.count))
                        
                        for match in matches {
                            getdate = (match.date!)
                        }
                        mesg.date = getdate
                        
                        
                        
                        if self.FromDetailArray.object(at: k) as! String == self.themes.getUserID()
                        {
                            mesg.sender = MessageSender.myself;
                            if (self.tasker_statusarray.object(at: k) as! String == "2")
                            {
                                mesg.status = MessageStatus.read
                            }
                            else if (self.tasker_statusarray.object(at: k) as! String == "1")
                            {
                                mesg.status = MessageStatus.received
                            }
                            
                        }
                        else{
                            mesg.sender = MessageSender.someone;
                            
                        }
                        
                        
                        self.tableArray.addObject(mesg)
                    }
                    
                    
                    self.tableView.reloadData()
                    self.tableViewScrollToBottomAnimated(true)
                    
                }
                
            }
            
        }
        
        
    }
    func showTypingStatus(_ notification: Notification)
    {
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        
        
        let taskid : NSString = userInfo["taskid"]! as NSString
        
        
//        if (taskid as String == Message_details.taskid as String)
//        {
//
        
            
            Status_View.text = "typing......"
//        }
        
        
    }
    
    func stopTypingStatus(_ notification: Notification) {
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        
        
        let taskid : NSString = userInfo["taskid"]! as NSString
        
        
//        if (taskid as String == Message_details.taskid as String)
//        {
        
            
            Status_View.text = ""
            
//        }
        
    }
    
    
    
    
    
    func showPushMessage(_ notification: Notification) {
        let message_array = notification.object as! NSArray
        
//        inputbar.resignFirstResponder()
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        
        
        let check_userid = userInfo["from"]
        let check_taskid = userInfo["task"]
        let messgeid = userInfo["msgid"]
        
        let taskerstatus  = userInfo["taskerstus"]
        
        let Chatmessage:NSString! = userInfo["message"] as NSString!
        let gettaskerid = userInfo["tasker_id"]
        
        let getdate = userInfo["date"]
        
        
        
        let text = getdate
        let types: NSTextCheckingResult.CheckingType = .date
        var getdatefromweb = Date()
        let detector = try? NSDataDetector(types: types.rawValue)
        let matches = detector!.matches(in: text!, options: .reportCompletion, range: NSMakeRange(0, (text?.count)!))
        
        for match in matches {
            getdatefromweb = (match.date!)
        }
        
        
        
        if messgaeidarray.contains(messgeid!)
        {
            
        }
        else
        {
            messgaeidarray.add(messgeid!)
            if check_taskid! == Message_details.taskid as String && gettaskerid! == Message_details.providerid as String
            {
                
                let mesg : Message = Message()
                
                
                if (check_userid == self.themes.getUserID())
                {
                    mesg.text = Chatmessage as String;
                    mesg.sender = MessageSender.myself;
                    mesg.date = getdatefromweb
                    
                    
                    if (taskerstatus  == "2")
                    {
                        mesg.status = MessageStatus.read
                    }
                    else if (taskerstatus  == "1")
                    {
                        mesg.status = MessageStatus.received
                    }
                    
                    
                }
                else
                {
                    
                    let delayTime = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        
                        SocketIOManager.sharedInstance.sendingSinglemessagStatus(Message_details.taskid as String, taskerid: Message_details.providerid as String, Userid:self.themes.getUserID(),usertype:"user",messagearray:message_array)
                    }
                    mesg.text = Chatmessage as String;
                    mesg.sender = MessageSender.someone;
                    mesg.date = getdatefromweb
                    
                    
                }
                self.tableArray.addObject(mesg)
                
                self.tableView.reloadData()
                
                self.tableViewScrollToBottomAnimated(true)
            }
            else{
                
                Message_details.taskid = check_taskid!
                Message_details.providerid = check_userid!
                self.ReloadMessageView()
                
                
            }
        }
        
        
        
        
    }
    
    func showMessage(_ notification: Notification)
    {
        
//        inputbar.resignFirstResponder()
        let message_array = notification.object as! NSArray
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        
        
        let check_userid = userInfo["from"]
        let check_taskid = userInfo["task"]
        let messgeid = userInfo["msgid"]
        let taskerstatus  = userInfo["taskerstus"]
        let getdate = userInfo["date"]
        let gettaskerid = userInfo["tasker_id"]
        
        
        
        let text = getdate
        let types: NSTextCheckingResult.CheckingType = .date
        var getdatefromweb = Date()
        let detector = try? NSDataDetector(types: types.rawValue)
        let matches = detector!.matches(in: text!, options: .reportCompletion, range: NSMakeRange(0, (text?.count)!))
        
        for match in matches {
            getdatefromweb = (match.date!)
        }
        
        
        let Chatmessage = userInfo["message"]
        
        if messgaeidarray.contains(messgeid!)
        {
            
        }
        else
        {
            messgaeidarray.add(messgeid!)
            if check_taskid! == Message_details.taskid as String && gettaskerid! == Message_details.providerid as String
            {
                
                let mesg : Message = Message()
                
                
                
                if (check_userid == self.themes.getUserID())
                {
                    mesg.text = Chatmessage as! String;
                    mesg.sender = MessageSender.myself;
                    //mesg.date = NSDate()
                    mesg.date = getdatefromweb
                    
                    if (taskerstatus  == "2")
                    {
                        mesg.status = MessageStatus.read
                    }
                    else if (taskerstatus  == "1")
                    {
                        mesg.status = MessageStatus.received
                    }
                    
                }
                else
                {
                    
                    mesg.text = Chatmessage as! String;
                    mesg.sender = MessageSender.someone;
                    //mesg.date = NSDate()
                    mesg.date = getdatefromweb
                    
                    
                    let systemSoundID: SystemSoundID = 1016
                    // to play sound
                    AudioServicesPlaySystemSound (systemSoundID)
                    SocketIOManager.sharedInstance.sendingSinglemessagStatus(Message_details.taskid as String, taskerid: Message_details.providerid as String, Userid: themes.getUserID(),usertype:"user",messagearray:message_array)

                }
               

                self.tableArray.addObject(mesg)
                
                self.tableView.reloadData()
                
                self.tableViewScrollToBottomAnimated(true)
            }
            else{
                self.DismissKeyboard()
                let alertView = UNAlertView(title: Appname, message:self.themes.setLang("You have a message from Tasker"))
                alertView.addButton(self.themes.setLang("ok"), action: {
                    Message_details.taskid = check_taskid!
                    Message_details.providerid = check_userid!
                    self.ReloadMessageView()
                    
                    
                })
               AudioServicesPlayAlertSound(1315);

                alertView.show()
                
                
                
                
            }
        }
        
        
        
    }
    
    func   ReloadMessageView() {
        
        setInputbar()
        self.setTableView()
        
        ChatDetailsArr  = NSMutableArray()
        textArray  = NSMutableArray()
        FromDetailArray = NSMutableArray()
        tasker_statusarray  = NSMutableArray()
        messgaeidarray  = NSMutableArray()
        self.tableArray = TableArray()
        gateway = MessageGateway()
        self.getDateArray = NSMutableArray()
        
        GetDetails()
        
        setStatusView()
        SetImageView()
        setTest()
        
        
        
    }
    
    
    func setTest()
    {
        chat = Chat()
        chat.sender_name = "Player 1"
        chat.receiver_id = "12345"
        chat.sender_id = "54321"
        let texts: NSArray = []
        var last_message: Message? = nil
        for text in texts {
            let message: Message = Message()
            message.text = text as! String
            message.sender = .someone
            message.status = .received
            message.chat_id = chat.identifier()
            (LocalStorage.sharedInstance() as AnyObject).store(message)
            last_message = message
        }
        chat.numberOfUnreadMessages = texts.count
        if(last_message != nil)
        {
            chat.last_message = last_message!
        }
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        
        NSLog("the textview=%@",textView.text)
        
    }
    @IBAction func didClickOptions(_ sender: AnyObject) {
        if(sender.tag == 0)
        {
            self.navigationController?.popViewControllerWithFlip(animated: true)
            self.dismiss(animated: true, completion: nil)
            
            
        }
    }
    
    func receiveTypestaus(_ notification:Notification)
    {
        
        
        type_str=notification.object as! NSString
        
        
        
        if(type_str == "Type")
        {
            typingLbl.isHidden=false
            typingLbl.startAnimating()
            Status_View.isHidden=true
            Status_Lbl.isHidden=true
        }
        else if(type_str == "StopType")
        {
            typingLbl.isHidden=true
            typingLbl.stopAnimating()
            Status_View.isHidden=false
            Status_Lbl.isHidden=false
            
            
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setInputbar()
    {
        self.inputbar.placeholder = nil;
        self.inputbar.delegate = self;
//        self.inputbar.leftButtonImage = UIImage(named: "share")
        self.inputbar.rightButtonText = themes.setLang("Send");
        self.inputbar.rightButtonTextColor = UIColor(red: 0, green: 124/255.0, blue: 1, alpha: 1)
    }
    
    func setTableView()
    {
        self.tableArray = TableArray()
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0,width: view.frame.size.width, height: 10.0))
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.register(MessageCell.classForCoder(), forCellReuseIdentifier: "MessageCell")
        
    }
    func setGateway()
    {
        gateway = MessageGateway()
        gateway.delegate = self;
        gateway.chat = self.chat;
        gateway.loadOldMessages()
        
        
    }
    
    //TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableArray.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableArray.numberOfMessages(inSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier: String = "MessageCell"
        var cell: MessageCell! = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! MessageCell
        if (cell == nil) {
            cell = MessageCell(style: .default, reuseIdentifier: CellIdentifier)
        }
        if(self.tableArray.object(at: indexPath) != nil){
            cell.message = self.tableArray.object(at: indexPath)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableArray.title(forSection: section)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message: Message = self.tableArray.object(at: indexPath)
        return message.heigh
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let frame: CGRect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40)
        let view: UIView = UIView(frame: frame)
        view.backgroundColor = UIColor.clear
        view.autoresizingMask = .flexibleWidth
        let label: UILabel = UILabel()
        label.text = self.tableArray.title(forSection: section)
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica", size: 20.0)
        label.sizeToFit()
        label.center = view.center
        label.font = UIFont(name: "Helvetica", size: 13.0)
        label.backgroundColor = UIColor(red: 207 / 255.0, green: 220 / 255.0, blue: 252.0 / 255.0, alpha: 1)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.autoresizingMask = UIViewAutoresizing()
        view.addSubview(label)
        return view
        
    }
    func tableViewScrollToBottomAnimated(_ animated: Bool) {
        let numberOfSections:NSInteger=tableArray.numberOfSections()
        let numberOfRows:NSInteger=tableArray.numberOfMessages(inSection: numberOfSections-1)
        if(numberOfRows != 0)
        {
            tableView.scrollToRow(at: tableArray.indexPathForLastMessage(), at: UITableViewScrollPosition.bottom, animated: animated)
        }
    }
    func inputbarDidPressRightButton(_ inputbar: Inputbar!) {
        
        if (inputbar.text() == "")
        {
            
        }
        else
            
        {
            
            
            SocketIOManager.sharedInstance.sendMessage(inputbar.text(), withNickname:themes.getUserID(), Providerid:Message_details.providerid as String , taskid:Message_details.taskid as String)
            
            //  self.GetDetails()
        }
        
        
    }
    
    func MessageFromIn(_ str: String) {
        
        let message: Message = Message()
        message.text = str
        message.date = Date()
        message.chat_id = "1"
        message.sender = .someone
        
        //Store Message in memory
        self.tableArray.addObject(message)
        //Insert Message in UI
        do
        {
            
            try moveTable(message)
        }
        catch
        {
            print("there is an error")
        }
        //Send message to server
        // HI
        //[self.gateway sendMessage:message];
    }
    
    func moveTable (_ message:Message)throws
    {
        let indexPath: IndexPath =  tableArray.indexPath(for: message)
        self.tableView.beginUpdates()
        if self.tableArray.numberOfMessages(inSection: indexPath.section) == 1 {
            self.tableView.insertSections(IndexSet(integer:indexPath.section), with: .none)
        }
        
        //        self.tableView.reloadData()
        self.tableView.insertRows(at: [indexPath], with: .bottom)
        self.tableView.endUpdates()
        self.tableView.scrollToRow(at: self.tableArray.indexPathForLastMessage(), at: .bottom, animated: true)
        
    }
    func inputbarDidPressLeftButton(_ inputbar: Inputbar!) {
        //        let alertView: UIAlertView = UIAlertView(title: "Left Button Pressed", message: "", delegate: nil, cancelButtonTitle: "Ok")
        //        alertView.show()
        
    }
    
    func gatewayDidReceiveMessages(_ array: [Any]!) {
        self.tableArray.addObjects(from: array)
        self.tableView.reloadData()
        
    }
    
    func gatewayDidUpdateStatus(for message: Message) {
        let indexPath: IndexPath = tableArray.indexPath(for: message)
        let cell: MessageCell = self.tableView.cellForRow(at: indexPath) as! MessageCell
        cell.updateMessageStatus()
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    func inputbarDidBecomeFirstResponder(_ inputbar: Inputbar!) {
        
        
        
        SocketIOManager.sharedInstance.sendStartTypingMessage(self.themes.getUserID(), taskerid: Message_details.providerid as String,taskid: Message_details.taskid as String)
        
        
        
    }
    func inputbarTextEndEditingChat(_ inputbar: Inputbar!) {
        
        
        SocketIOManager.sharedInstance.sendStopTypingMessage(self.themes.getUserID(), taskerid: Message_details.providerid as String,taskid: Message_details.taskid as String)
        
        
        
    }
    
    func checkTyping()
    {
        
        let body = DDXMLElement.element(withName: "body") as! DDXMLElement
        body.setXmlns("StopType")
        let message_sent = DDXMLElement.element(withName: "message") as! DDXMLElement
        message_sent.addAttribute(withName: "type", stringValue: "Typing")
        //        let Details=["job_id":"\(Message_details.job_id)"] as NSDictionary
        //        message_sent.addAttributeWithName("Detail_id", stringValue: "\(Details)")
        message_sent.addAttribute(withName: "to", stringValue: "\(Message_details.id)\(constant.DomainName)")
        message_sent.addAttribute(withName: "jobid", stringValue: Message_details.job_id as String)
        
        message_sent.addChild(body)
        
        
        
        
        
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








