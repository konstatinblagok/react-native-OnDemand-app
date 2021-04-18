//
//  SocketIOManager.swift
//  SocketChat
//http://192.168.1.251:3002/notify

//
//  Created by Gabriel Theodoropoulos on 1/31/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import SocketIO

var iSSocketDisconnected:Bool=Bool()
var iSChatSocketDisconnected:Bool=Bool()

class SocketIOManager: NSObject {
    var themes:Themes=Themes()
    var url_handler:URLhandler=URLhandler()
    var notificationmode : NSString = NSString()
    static let sharedInstance = SocketIOManager()
    var nick_name:NSString=NSString()
    var Appdel=UIApplication.shared.delegate as! AppDelegate
    
    let socket:SocketIOClient! = SocketIOClient(socketURL: URL(string: constant.BaseUrl)!, config: [.log(true), .nsp("/notify"), .forcePolling(true),.reconnects(true)])
    
    let ChatSocket:SocketIOClient! = SocketIOClient(socketURL: URL(string: constant.BaseUrl)!, config: [.log(true), .nsp("/chat"), .forcePolling(true),.reconnects(true)])
    
    override init() {
        super.init()
    }
    
    
    func establishConnection() {
       socket.connect()
        notificationmode = "socket"
        self.UpdateNotificationMode()
        socket.on("connect") {data, ack in
           print("..Check Socket Connection.....\(data).........")
            
              iSSocketDisconnected=false;
            self.roomcreation(constant.Roomname as String, nickname: self.themes.getUserID())

            
       
            
        }
        
        
        socket.on("network disconnect") {data, ack in
            print("..Check Socket dis Connection.....\(data).........")
            
        
            
            
            iSSocketDisconnected=true;
            
        }


    }
    
    
    func  UpdateNotificationMode(){
        let Param: Dictionary = ["user":themes.getUserID(),"user_type":"user","mode":notificationmode,"type":"ios"] as [String : Any]
        // print(Param)
        url_handler.makeCall(constant.UpdateNotificationMode, param: Param as NSDictionary) {
            (responseObject, error) -> () in
            
            if(error != nil)
            {
               
            }
            else
            {
                if(responseObject != nil && (responseObject?.count)!>0)
                {
                    let status=self.themes.CheckNullValue(responseObject?.object(forKey: "status"))!
                    if(status == "1")
                    {
                    }
                    else
                    {
                    }
                    
                    
                }
            }
        }

    }
    
    
    
    
    func establishChatConnection() {
        
       ChatSocket.connect()
         ChatSocket.on("connect") {data, ack in
            print("..Check Socket Connection.....\(data).........")
            iSChatSocketDisconnected = false
            
            SocketIOManager.sharedInstance.ChatWithNickname(self.themes.getUserID())

           
        }
        
        ChatSocket.on("disconnect") {data, ack in
            print("..Check Socket dis Connection.....\(data).........")
              iSChatSocketDisconnected=true;
            
        }
        
        ChatSocket.on("error") {data, ack in
            
            print("the socket erroe .......\(data)")
            
        }

    }
    
    
    
    func RemoveAllListener()
    {
        notificationmode = "apns"
        self.UpdateNotificationMode()

        //Removing Chat Listeners
        ChatSocket.off("roomcreated")
        ChatSocket.off("updatechat")
        ChatSocket.off("single message status")
        ChatSocket.off("message status")
        ChatSocket.off("start typing")
        ChatSocket.off("stop typing")
        ChatSocket.off("connect")
        ChatSocket.off("disconnect")
        ChatSocket.off("error")
        
        
        //Removing Socket job related Listeners

        socket.off("connect")
        socket.off("network disconnect")
        socket.off("network created")
        socket.off("notification")
        socket.off("tasker tracking")
        socket.off("push notification")
        
        ChatSocket.disconnect()

        socket.disconnect()





        


        
    }
    
    func LeaveRoom(_ providerid : String)
    {
        
    if socket.status == .disconnected
        
    {
        
        let param = ["user":providerid];

        socket.emit("network disconnect", param)
        }
        print("iosjjjj \(self.nick_name)")
        print("***************SOCKET DISCONNECTED******************")
    }
    
    func LeaveChatRoom(_ userid : String)
    {
          if ChatSocket.status == .disconnected
        
          {
        
            let param = ["user":userid];
  
        ChatSocket.emit("disconnect", param)
        print("iosjjjj \(self.nick_name)")
        }
        print("***************SOCKET DISCONNECTED******************")
    }
    
    

    //Job Related socket call

    func roomcreation (_ RoomName : String,nickname: String)
    {
        if (socket.status == .connected)
        {
            let param = ["user":nickname];

            socket.emit(RoomName, param)
        }
        socket.on("network created") {data, ack in
            print("..new  Socket Connection.....\(data).........")
            self.connectToServerWithNickname(self.themes.getUserID(), completionHandler: { (userList) in
                
            })
            self.listenTracking()
            
            
        }

    }
    func connectToServerWithNickname(_ nickname: String ,completionHandler: (_ userList: [[String: AnyObject]]?) -> Void) {

           


        
        
        
        let dictData:NSMutableDictionary = NSMutableDictionary()
        
        socket.on("notification") {[weak self] data, ack in
            dictData["message"]=data[0]
            print("..TEST DATA.....\(dictData).........")
            self!.Appdel.socketNotification(dictData);
            
        }
    }
    
    
    
    func listenTracking(){
        let dictData:NSMutableDictionary = NSMutableDictionary()
        socket.on("tasker tracking") {[weak self] data, ack in
            dictData["message"]=data[0]
            print("..Start tracking message....\(dictData).........")
            let Message:NSDictionary=(dictData["message"] as? NSDictionary)!
            trackingDetail.taskId = Message.object(forKey: "task") as! NSString as String
            trackingDetail.userLat = Double(Message.object(forKey: "lat") as! String)!
            trackingDetail.userLong = Double(Message.object(forKey: "lng")  as! String)!
            let lastdrive : String = self!.themes.CheckNullValue(Message.object(forKey: "lastdriving"))!
            let bearing : String = self!.themes.CheckNullValue(Message.object(forKey: "bearing"))!
            trackingDetail.lastDriving =   lastdrive
            trackingDetail.bearing = bearing
            NotificationCenter.default.post(name: Notification.Name(rawValue: "Tracking"), object: nil, userInfo: nil)
            
        }
        
    }

    func connectToServerWithprovidername(_ providername: NSMutableArray, completionHandler: (_ userList: [[String: AnyObject]]?) -> Void) {
        

        for k in 0..<providername.count {
            self.nick_name = providername.object(at: k) as! NSString
            
            
            
            
            socket.emit("switch room", providername.object(at: k) as! NSString)
            
            let dictData:NSMutableDictionary = NSMutableDictionary()
            
            socket.on("push notification") {[weak self] data, ack in
                dictData["message"]=data[0]
                print("..TEST DATA.....\(dictData).........")
                self!.Appdel.socketNotification(dictData);
                
            }
            
        }
    }

    
    
    func ChatWithNickname(_ nickname: String) {
        
        
        if (ChatSocket.status == .connected)

        {
        let param = ["user":nickname];
        
        ChatSocket.emit("create room",param)
       // let dictData:NSMutableDictionary = NSMutableDictionary()
        }

        ChatSocket.on("roomcreated") {[weak self] data, ack in
          //  dictData["message"]=data[0]
            print("..TEST DATA.....\(data).........")
            
            
            
            self!.listenstartTyping()
            self!.listenstoptTyping()
            self!.listenSingleMessageStatus()
            self!.ListeningMessageStatus()
            self!.getChatMessage { (messageInfo) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    NSLog("The Chat message information=%@", messageInfo)
                })
            }
            

           // self?.Appdel.socketChatNotification(dictData);
        }
        
    }
    
    
    func sendMessage(_ message: String, withNickname nickname: String, Providerid: String, taskid: String) {
        
        if(ChatSocket.status == .connected)
        {

        let jsonString:NSDictionary = ["user":nickname,"tasker":Providerid,"message":message,"task":taskid,"from":nickname]
        ChatSocket.emit("new message", jsonString)
        }
        else
        {
            ChatSocket.connect()
        }
       

       
    }
    
    
    func getChatMessage(_ completionHandler: (_ messageInfo: [String: AnyObject]) -> Void) {
        let dictData:NSMutableDictionary = NSMutableDictionary()
        ChatSocket.on("updatechat") {[weak self] data, ack in
            dictData["message"]=data[0]
            print("..TEST DATA.....\(dictData).........")
            self?.Appdel.socketChatNotification(dictData);
        }
        
    }
    

    
    fileprivate func listenForOtherMessages() {
        
        
    }
    
    func sendingSinglemessagStatus (_ taskid : String ,taskerid : String , Userid : String,usertype: String,messagearray:NSArray)
        
    {
        if(ChatSocket.status == .connected)
        {
        let jsonString:NSDictionary = ["task":taskid,"tasker":taskerid,"user":Userid,"usertype" :usertype,"user_status":"2","message":messagearray];
        ChatSocket.emit("single message status", jsonString)
        }
        else
        {
            ChatSocket.connect()
        }
        
    }
    
    func listenSingleMessageStatus() {
        let dictData:NSMutableDictionary = NSMutableDictionary()
        ChatSocket.on("single message status") { data, ack in
            dictData["message"]=data[0]
            print("..Singlemessage message....\(dictData).........")
  NotificationCenter.default.post(name: Notification.Name(rawValue: "readSinglemessagestatus"), object: data[0])
        }
        
    }

    
    
    
    func SendingMessagestatus (_ typeofapp: String, Userid: String, taskerid : String,taskid : String)
    {
        if(ChatSocket.status == .connected)
        {
            let jsonString:NSDictionary = ["task":taskid,"tasker":taskerid,"user":Userid,"type":typeofapp];
            ChatSocket.emit("message status", jsonString)

        }
        else
        {
            ChatSocket.connect()
        }
    
      

    }
    
    
    func ListeningMessageStatus ()
    {
        let dictData:NSMutableDictionary = NSMutableDictionary()
        ChatSocket.on("message status") { data, ack in
            dictData["message"]=data[0]
            print(". message.Status...\(dictData).........")
            //self?.Appdel.socketTypeNotification(data[0] as! NSDictionary) 
            NotificationCenter.default.post(name: Notification.Name(rawValue: "readmessagestatus"), object: data[0])

        }
        

    }
    func sendStopTypingMessage(_ Userid: String,taskerid: String,taskid : String) {
        
        if(ChatSocket.status == .connected)
        {
            let jsonString:NSDictionary = ["to":taskerid,"from":Userid,"user":Userid,"tasker":taskerid,"task":taskid
                ,"type":"user"]
            ChatSocket.emit("stop typing", jsonString)
            
        }
        else
        {
            ChatSocket.connect()
        }
    }
    func sendStartTypingMessage(_ Userid: String,taskerid: String,taskid : String ) {
        if(ChatSocket.status == .connected)
        {
            let jsonString:NSDictionary = ["to":taskerid,"from":Userid,"user":Userid,"tasker":taskerid,"task":taskid
                ,"type":"user"]
            ChatSocket.emit("start typing", jsonString)
            
        }
        else
        {
            ChatSocket.connect()
        }
        
    }
    
    func listenstartTyping() {
        let dictData:NSMutableDictionary = NSMutableDictionary()
        ChatSocket.on("start typing") {[weak self] data, ack in
            dictData["message"]=data[0]
             print("..Start typing message....\(dictData).........")
            self?.Appdel.socketTypeNotification(data[0] as! NSDictionary)
        }
        
    }
   


    func listenstoptTyping() {
        let dictData:NSMutableDictionary = NSMutableDictionary()
        ChatSocket.on("stop typing") {[weak self] data, ack in
            dictData["message"]=data[0]
            print("..Stop typing message....\(dictData).........")
             self?.Appdel.socketStopTypeNotification(data[0] as! NSDictionary)
        }
        
    }

    
    
    
   }
