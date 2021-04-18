//
//  AppDelegate.swift
//  Plumbal
//
//  Created by Casperon Tech on 30/09/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit
import CoreData
import HockeySDK
import GoogleMaps
import UserNotifications
import CocoaLumberjack
import FacebookLogin
import FacebookCore
import DLHamburgerMenu
import Fabric
import Crashlytics


let dbfileobj:DBFile = DBFile()
let signup:Signup=Signup()
var constant:Constant=Constant()
let Invite:Invite_Freinds=Invite_Freinds()
let Changepass:ChangePassword=ChangePassword()
let MyWallet:Wallet=Wallet()
let Transaction_Stat:Transaction=Transaction()
let OTP_sta:OTP=OTP()
let Menu_dataMenu=Menu()
var Addaddress_Data=Addaddress()
var Schedule_Data:ScheduleView=ScheduleView()
var Tasker_Data :TaskerList = TaskerList()
var Category_Data:Category_=Category_()
var Order_data:Order=Order()
var OrderDetail_data:OrderDetail=OrderDetail()
var trackingDetail : TrackingDetail = TrackingDetail()
var provider_map_details = ProviderMapDetails()
var themes:Themes=Themes()
var Root_Base:RootBase=RootBase()
var Payment_Detail:Payment=Payment()
var Language_handler:Languagehandler=Languagehandler()
var Terms_Details:Terms=Terms()
var Provider_Detail:ProviderDetail=ProviderDetail()
var Message_details:MessageView=MessageView()
var Nodatastatus:String=String()
let Edit_Prof:EditProfile=EditProfile()
var FB_Regis:FacebookRegister=FacebookRegister()
var Home_Data:HomePage=HomePage()
var Device_Token:String=String()
var Common_Chatid:String=String()
var ConnectionTimer : Timer = Timer()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    //XMPP
    var isSocketConnected : Bool = Bool()
    
    
    var Root_base:RootViewController=RootViewController()
    var window: UIWindow?
    let reachability = Reachability()
    var IsInternetconnected:Bool=Bool()
    var byreachable : String = String()
    
    var job_id:String=String()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.isIdleTimerDisabled = true
        self.ReachabilityListener()
        Fabric.with([Crashlytics.self])
        
        var fontFamilies = UIFont.familyNames
        for i in 0..<fontFamilies.count {
            let fontFamily = fontFamilies[i]
            let fontNames = UIFont.fontNames(forFamilyName: fontFamilies[i])
            print("\(fontFamily): \(fontNames)")
        }
        //Paypal
        
        themes.saveLanguage(themes.getAppLanguage() as NSString)
        
        
        
        themes.SetLanguageToApp()
        
        if themes.getEmailID() == ""{
            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let rootView: UINavigationController = sb.instantiateViewController(withIdentifier: "IntorVC") as! UINavigationController
            // let rootView: UIViewController = sb.instantiateViewControllerWithIdentifier("IntorVCSID")
            
            UIView.transition(with: self.window!, duration: 0.2, options: UIViewAnimationOptions.curveEaseIn, animations: {
                appDel.window?.rootViewController=rootView
            }, completion: nil)
        }
        else
        {
            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let rootView: UINavigationController = sb.instantiateViewController(withIdentifier: "RootVCID") as! UINavigationController
            UIView.transition(with: self.window!, duration: 0.2, options: UIViewAnimationOptions.curveEaseIn, animations: {
                appDel.window?.rootViewController=rootView
            }, completion: nil)
        }
        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction:"YOUR_CLIENT_ID_FOR_PRODUCTION",PayPalEnvironmentSandbox:"Ae5Sbc0BdkIcFxJyfU18jFLSxywi7XZg3ZnVIN0iMxcb7tabr9YPEL1abLWcRW3oARVeZIqmlB4Kip2x"])
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "methodOfChatFromApp"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.methodOfReceivedNotificationNetwork(_:)), name:NSNotification.Name(rawValue: kNoNetwork), object: nil)
        
        //Xmpp
        DDLog.add(DDTTYLogger.sharedInstance)
        
        //  setupStream()
        window?.backgroundColor=UIColor.clear
        GMSServices.provideAPIKey("\(constant.GooglemapAPI)")
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        UIApplication.shared.registerForRemoteNotifications()
        
        // application.registerForRemoteNotificationTypes(types: UIRemoteNotificationType)
        
        BITHockeyManager.shared().configure(withIdentifier: "bd11d5de32f74810a710511f6580222f")
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
        
        if(launchOptions != nil)
        {
            
            let localNotif = launchOptions![UIApplicationLaunchOptionsKey.remoteNotification]
                as? Dictionary<NSObject,AnyObject>
            if  (localNotif != nil)
            {
                let checkuserid = themes.CheckNullValue((localNotif as AnyObject)["user"]!)!
                
                if (themes.getUserID() == checkuserid)
                {
                    
                    var Message_Notice:String=String()
                    var taskid:String=String()
                    
                    let status = themes.CheckNullValue((localNotif as AnyObject)["status"]!)!
                    if status == "1"
                    {
                        let ChatMessage:NSArray =  (localNotif as AnyObject)["messages"] as! NSArray
                        taskid = (localNotif as AnyObject)["task"] as! String
                        
                        
                        Message_Notice = (ChatMessage[0] as AnyObject).object(forKey: "message") as! String
                        
                        let userid = themes.CheckNullValue((ChatMessage[0] as AnyObject).object(forKey: "from"))!
                        let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "ReceivePushChatToRootView"), object: nil, userInfo: ["message":"\(Message_Notice)","from":"\(userid)","task":"\(taskid)"])
                        }
                    }
                }
                else{
                    let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        self.APNSNotification(localNotif! as NSDictionary)
                    }
                }
                
            }
            else{
                
                
            }
            //}
        }
        //CheckReachability()
        return SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func setInitialViewcontroller(){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let objLoginVc:DLDemoRootViewController = mainStoryboard.instantiateViewController(withIdentifier: "DLDemoRootViewController") as! DLDemoRootViewController
        let navigationController: UINavigationController = UINavigationController(rootViewController: objLoginVc)
        self.window!.rootViewController = navigationController
        self.window!.backgroundColor = UIColor.white
        navigationController.setNavigationBarHidden(true, animated: true)
        self.window!.makeKeyAndVisible()
    }
    func ReconnectMethod()
    {
        
        if(themes.Check_userID() != "")
        {
            Thread.detachNewThreadSelector(#selector(EstablishCohnnection), toTarget: self, with: nil)
        }
    }
    
    
    func EstablishCohnnection()
    {
        if(SocketIOManager.sharedInstance.ChatSocket.status == .notConnected || SocketIOManager.sharedInstance.ChatSocket.status ==  .disconnected)
            
        {
            if(themes.Check_userID() != "")
            {
                //Listen To server side Chat related notification
                
                SocketIOManager.sharedInstance.establishChatConnection()
                
                
                
                
            }
            
            
            
        }
        
        if(SocketIOManager.sharedInstance.socket.status == .notConnected || SocketIOManager.sharedInstance.socket.status ==  .disconnected)
        {
            
            
            //Listen To server side Job related notification
            
            if(themes.Check_userID() != "")
            {  SocketIOManager.sharedInstance.establishConnection()
                
                
            }
            
        }
        
    }
    
    func urlPathToDictionary(_ path:String) -> [String:String]? {
        //Get the string everything after the :// of the URL.
        let stringNoPrefix = path.components(separatedBy: "://").last
        
        //Get all the parts of the url
        if var parts = stringNoPrefix?.components(separatedBy: "/") {
            //Make sure the last object isn't empty
            if parts.last == "" {
                parts.removeLast()
            }
            
            if parts.count % 2 != 0 { //Make sure that the array has an even number
                return nil
            }
            
            var dict = [String:String]()
            var key:String = ""
            
            //Add all our parts to the dictionary
            for (index, part) in parts.enumerated() {
                if index % 2 != 0 {
                    key = part
                } else {
                    dict[key] = part
                }
            }
            
            return dict
        }
        
        return nil
    }
    
    
    func methodOfChatFromApp(_ notification: Notification){
        
        
    }
    
    func socketTypeNotification(_ dict:NSDictionary)
    {
        
        let chatDict : NSDictionary = dict.object(forKey:"chat") as! NSDictionary!
        let taskid : String = themes.CheckNullValue(chatDict.object(forKey:"task"))!
        let Userid:NSString = dict.object(forKey: "user") as! NSString
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ReceiveTypingMessage"), object: nil, userInfo: ["userid":"\(Userid)","taskid":"\(taskid)"])
        
    }
    
    func socketStopTypeNotification(_ dict:NSDictionary)
    {
        
        //        let chatDict : NSDictionary = dict.objectForKey("chat") as! NSDictionary!
        //        let taskid : String = themes.CheckNullValue(chatDict.objectForKey("task"))!
        
        let Userid:NSString = dict.object(forKey: "user") as! NSString
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ReceiveStopTypingMessage"), object: nil, userInfo: ["userid":"\(Userid)","taskid":""])
        
    }
    
    func methodOfReceivedNotificationNetwork(_ notification: Notification){
        
        let navigationController = window?.rootViewController as? UINavigationController
        if(navigationController == nil)
        {
            if let activeController = window?.rootViewController! {
                
                let image = UIImage(named: "NoNetworkConn")
                activeController.view.makeToast(message:kErrorMsg, duration: 5, position:HRToastActivityPositionDefault as AnyObject, title: "Oops !!!!", image: image!)
            }
        }
        else
        {
            if let activeController = navigationController!.visibleViewController {
                
                let image = UIImage(named: "NoNetworkConn")
                activeController.view.makeToast(message:kErrorMsg, duration: 5, position:HRToastActivityPositionDefault as AnyObject, title: "Oops !!!!", image: image!)
            }
        }
        
        
    }
    
    func alertView(_ View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        if(View.tag == 1)
        {
            
            switch buttonIndex{
                
            case 0:
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ShowPayment"), object: nil, userInfo: ["job_id":"\(job_id)"])
                break;
            default:
                break;
                //Some code here..
                
            }
            if(View.tag == 2)
            {
                switch buttonIndex{
                case 0:
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "ShowRating"), object: nil, userInfo: ["job_id":"\(job_id)"])
                    break;
                default:
                    break;
                    //Some code here..
                }
            }
        }
    }
    
    
    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {
        print("Launched with URL: \(url.absoluteString)")
        
        _ = self.urlPathToDictionary(url.absoluteString)
        
        return SDKApplicationDelegate.shared.application(application, open: url)
        //            application,
        //            open: url,
        //            sourceApplication: sourceApplication,
        //            annotation: annotation)
    }
    
    func MakeRootVc(_ ViewIdStr:NSString){
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootView: UINavigationController = sb.instantiateViewController(withIdentifier: ViewIdStr as String) as! UINavigationController
        self.window!.rootViewController=rootView
        self.window!.makeKeyAndVisible()
    }
    
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        
        
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0 ..< deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        if tokenString == ""
        {
            tokenString = "Simulator Signup"
            
        }
        
        Device_Token = tokenString
        print("tokenString: \(tokenString)")
        
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        let userInfoDict:NSDictionary?=userInfo as NSDictionary?
        let checkuserid = themes.CheckNullValue(userInfoDict!.object(forKey: "user"))!
        if userInfoDict != nil
        {
            if (themes.getUserID() == checkuserid)
            {
                var Message_Notice:String=String()
                var taskid:String=String()
                var messageid : String = String()
                var tasker_status : String = String()
                var dateStr : String = String()
                var gettaskerid : String = String()
                
                let status = themes.CheckNullValue(userInfoDict!.object(forKey: "status"))!
                if status == "1"
                {
                    let ChatMessage:NSArray = userInfoDict!.object(forKey: "messages") as! NSArray
                    taskid = userInfoDict!.object(forKey: "task") as! String
                    gettaskerid = themes.CheckNullValue(userInfoDict!.object(forKey: "tasker"))!
                    tasker_status = themes.CheckNullValue((ChatMessage[0] as AnyObject).object(forKey: "tasker_status"))!
                    
                    Message_Notice = (ChatMessage[0] as AnyObject).object(forKey: "message") as! String
                    messageid = (ChatMessage[0] as AnyObject).object(forKey: "_id") as! String
                    dateStr = (ChatMessage[0] as AnyObject).object(forKey: "date") as! String
                    let userid : String = themes.CheckNullValue((ChatMessage[0] as AnyObject).object(forKey: "from"))!
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "ReceivePushChat"), object: ChatMessage, userInfo: ["message":Message_Notice,"from":userid,"task":taskid,"msgid":messageid,"taskerstus":tasker_status,"date" : dateStr,"tasker_id":gettaskerid])
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "ReceivePushChatToRootView"), object: nil, userInfo: ["message":Message_Notice,"from":userid,"task":taskid])
                }
            }
            else{
                self.APNSNotification(userInfo as NSDictionary)
            }
        }
    }
    
    
    func APNSNotification(_ dict : NSDictionary)
    {
        
        let userInfo:NSDictionary = dict
        
        var Message_Notice:NSString=NSString()
        var Action:NSString = NSString()
        
        
        
        
        Message_Notice = userInfo.object(forKey: "message") as! NSString
        Action = userInfo.object(forKey: "action") as! NSString
        
        
        
        
        
        if(Action == "requesting_payment")
        {
            
            let Order_id:NSString=userInfo.object(forKey: "key0") as! NSString
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ShowPushPayment"), object: nil, userInfo: ["Message":"\(Message_Notice)","Order_id":"\(Order_id)"])
            
        }
            
        else if(Action == "admin_notification")
        {
            
        }
            
        else if(Action == "payment_paid")
        {
            let Order_id:NSString=userInfo.object(forKey: "key0") as! NSString
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ShowPushRating"), object: nil, userInfo: ["Message":"\(Message_Notice)","Order_id":"\(Order_id)"])
            
        }
        else if (Action == "job_request")
        {
            
        }
            
        else
        {
            let Order_id:NSString=userInfo.object(forKey: "key0") as! NSString
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ShowPushNotification"), object: nil, userInfo: ["Order_id":"\(Order_id)"])
        }
        
        
    }
    
    
    
    
    
    func socketNotification(_ dict:NSDictionary)
    {
        var messageArray:NSMutableDictionary=NSMutableDictionary()
        var Message_Notice:NSString=NSString()
        var Action:NSString = NSString()
        let Message:NSDictionary?=dict["message"] as? NSDictionary
        
        
        if(Message != nil)
        {
            messageArray=(Message?.object(forKey: "message") as? NSMutableDictionary)!
            Message_Notice=(messageArray.object(forKey: "message") as? NSString)!
            Action=(messageArray.object(forKey: "action") as? NSString)!
            
            
            
            
            
            if(Action == "requesting_payment")
            {
                if (Message?.object(forKey: "message")) is NSString {
                    let Order_id:NSString=messageArray.object(forKey: "key0") as! NSString
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "ShowPayment"), object: nil, userInfo: ["Message":"\(Message_Notice)","Order_id":"\(Order_id)"])
                    
                }
                else
                {
                    let Order_id:NSString=messageArray.object(forKey: "key0") as! NSString
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "ShowPayment"), object: nil, userInfo: ["Message":"\(Message_Notice)","Order_id":"\(Order_id)"])
                }
                
            }
                
            else if(Action == "payment_paid")
            {
                let Order_id:NSString=messageArray.object(forKey: "key0") as! NSString
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ShowRating"), object: nil, userInfo: ["Message":"\(Message_Notice)","Order_id":"\(Order_id)"])
            }
            else if (Action == "job_request")
            {
                
            }
            else if (Action == "rejecting_task")
            {
                let Order_id:NSString=messageArray.object(forKey: "key1") as! NSString
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ShowNotification"), object: nil, userInfo: ["Message":"\(Message_Notice)","Order_id":"\(Order_id)"])
            }
            else if (Action == "job_cancelled")
            {
                
            }
                
                
            else
            {
                
                let Order_id:NSString=messageArray.object(forKey: "key0") as! NSString
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ShowNotification"), object: nil, userInfo: ["Message":"\(Message_Notice)","Order_id":"\(Order_id)","Action":"\(Action)"])
                
            }
            
            
            
        }
        
    }
    
    
    
    
    
    
    
    
    func socketChatNotification(_ dict:NSDictionary)
    {
        
        
        
        let Message:NSDictionary=(dict["message"] as? NSDictionary)!
        
        
        var Message_Notice:String=String()
        var taskid:String=String()
        var messageid : String = String()
        var tasker_status : String = String()
        var dateStr : String = String()
        var gettaskerid : String = String()
        
        
        let status = themes.CheckNullValue(Message.object(forKey: "status"))!
        if status == "1"
        {
            let ChatMessage:NSArray = Message.object(forKey: "messages") as! NSArray
            taskid = Message.object(forKey: "task") as! String
            gettaskerid = themes.CheckNullValue(Message.object(forKey: "tasker"))!
            tasker_status = themes.CheckNullValue((ChatMessage[0] as AnyObject).object(forKey: "tasker_status"))!
            
            
            
            Message_Notice = (ChatMessage[0] as AnyObject).object(forKey: "message") as! String
            messageid = (ChatMessage[0] as AnyObject).object(forKey: "_id") as! String
            dateStr = (ChatMessage[0] as AnyObject).object(forKey: "date") as! String
            let userid = themes.CheckNullValue((ChatMessage[0] as AnyObject).object(forKey: "from"))!
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ReceiveChat"), object: ChatMessage, userInfo: ["message":"\(Message_Notice)","from":"\(userid)","task":"\(taskid)","msgid":"\(messageid)" ,"taskerstus":tasker_status,"date" : dateStr ,"tasker_id":gettaskerid])
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ReceiveChatToRootView"), object: nil, userInfo: ["message":"\(Message_Notice)","from":"\(userid)","task":"\(taskid)"])
        }
        
        
        
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        ConnectionTimer.invalidate()
        ConnectionTimer = Timer()
        
        if(themes.Check_userID() != "")
        {
            
            //SocketIOManager.sharedInstance.RemoveAllListener()
            
            
            
            SocketIOManager.sharedInstance.LeaveChatRoom(themes.getUserID())
            SocketIOManager.sharedInstance.LeaveRoom(themes.getUserID())
            SocketIOManager.sharedInstance.RemoveAllListener()
        }
        
        
        
        //  self.CheckDisconnect()
        
        
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
        ConnectionTimer.invalidate()
        ConnectionTimer = Timer()
        
        if(themes.Check_userID() != "")
        {
            
            //SocketIOManager.sharedInstance.RemoveAllListener()
            
            
            SocketIOManager.sharedInstance.LeaveChatRoom(themes.getUserID())
            SocketIOManager.sharedInstance.LeaveRoom(themes.getUserID())
            SocketIOManager.sharedInstance.RemoveAllListener()
        }
        
        
    }
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //   CheckConnect()
        
        
        ConnectionTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ReconnectMethod), userInfo: nil, repeats: true)
        
        
        
        if(themes.Check_userID() != "")
        {
            
            SocketIOManager.sharedInstance.establishConnection()
            
            SocketIOManager.sharedInstance.establishChatConnection()
            
            
            
            
            
        }
        
        
        
        AppEventsLogger.activate()
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if(themes.Check_userID() != "")
        {
            
            //SocketIOManager.sharedInstance.RemoveAllListener()
            
            ConnectionTimer.invalidate()
            ConnectionTimer = Timer()
            
            SocketIOManager.sharedInstance.LeaveChatRoom(themes.getUserID())
            SocketIOManager.sharedInstance.LeaveRoom(themes.getUserID())
            SocketIOManager.sharedInstance.RemoveAllListener()
        }
        
        
        
        // self.CheckDisconnect()
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        // self.saveContext()
    }
    
    func ReachabilityListener()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
    }
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        if reachability.isReachable {
            IsInternetconnected=true
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
                byreachable = "1"
            } else {
                print("Reachable via Cellular")
                byreachable = "2"
            }
        } else {
            IsInternetconnected=false
            print("Network not reachable")
            byreachable = ""
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.Casperon.Plumbal" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Plumbal", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitima/Users/casperontechnologies1/Desktop/Launch screen/lanuchimage 320x480.pngte error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    
    
    func Make_RootVc(_ ViewIdStr:NSString,RootStr:NSString){
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootView: UIViewController = sb.instantiateViewController(withIdentifier: ViewIdStr as String)
        self.window!.rootViewController=rootView
        NotificationCenter.default.post(name: Notification.Name(rawValue: "MakerootView"), object: RootStr)
        
        
    }
    
    
    
    
}

