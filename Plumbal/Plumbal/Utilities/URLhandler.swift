
//
//  URLhandler.swift
//  Plumbal
//
//  Created by Casperon Tech on 07/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

//import SwiftyJSON



class URLhandler
{
    static let sharedInstance: URLhandler = URLhandler()
    func isConnectedToNetwork() -> Bool {
        
        return (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected
    }
    
    func makeCall(_ url: String,param:NSDictionary, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError? ) -> ())
    
    
    {
        
        
        var user_id:String=String()
        
        if(themes.Check_userID() != "")
        {
           user_id=themes.getUserID()
        }
        
        var lang = "en"
        if themes.getAppLanguage() == "en"{
            lang = "en"
        }
        else{
            lang = "nl"
        }
        
        if isConnectedToNetwork() == true {
            
            Alamofire.request("\(url)", method: .post, parameters: param as? Parameters, encoding: JSONEncoding.default, headers: ["apptype": "ios", "apptoken":"\(Device_Token)", "userid":"\(user_id)","accept-language":"\(lang)"])
                .responseJSON { response in
                    
                    var Dictionay:NSDictionary!=NSDictionary()

                    do {
                        
                        Dictionay = try JSONSerialization.jsonObject(
                            
                            with: response.data!,
                            
                            options: JSONSerialization.ReadingOptions.mutableContainers
                            
                            ) as! NSDictionary
                        
                        let status:NSString?=Dictionay.object(forKey: "is_dead") as? NSString
                        if(status == nil)
                        {
                            
                            print("the dictionary is \(param)....\(url)...\(Dictionay)")
                            
                            completionHandler(Dictionay as NSDictionary?, response.result.error as NSError? )

                        }
                        else
                        {
                            print("the dictionary is \(url)........>>>\(param)>>>>>.......\(Dictionay)")
                            
                            themes.AlertView(themes.setLang("log_out1"), Message: themes.setLang("log_out2"), ButtonTitle:  kOk)
                            let RootBase:MenuVC=MenuVC()
                            RootBase.LogoutMethod()
                        }
                        
                    }
                        
                    catch {
                        print("the dictionary is \(url)........>>>\(param)>>>>>.......\(Dictionay)")
                        
                        themes.AlertView(themes.setLang("log_out1"), Message: themes.setLang("log_out2"), ButtonTitle:  kOk)
                        let RootBase:MenuVC=MenuVC()
                        RootBase.LogoutMethod()
                    }
                    
                    
                    
                    Dictionay=nil
            }
        }
        else
        {
            completionHandler(nil, NSError(domain: "sample", code: -1005, userInfo: nil))
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNoNetwork), object: nil)
        }
        
    }
    
    func makeGetCall(_ url: String, completionHandler: @escaping (_ responseObject: NSDictionary? ) -> ())
    {
         if isConnectedToNetwork() == true {
        Alamofire.request("\(url)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            
            if(response.result.error == nil)
            {
                
                do {
                    
                    let Dictionary = try JSONSerialization.jsonObject(
                        with: response.data!,
                        
                        options: JSONSerialization.ReadingOptions.mutableContainers
                        
                        ) as? NSDictionary
                    
                    completionHandler(Dictionary as NSDictionary?)
                    
                    
                }
                catch let error as NSError {
                    
                    // Catch fires here, with an NSErrro being thrown from the JSONObjectWithData method
                    print("A JSON parsing error occurred, here are the details:\n \(error)")
                    completionHandler(nil)
                }
            }
        }
        }
        else
         {
            completionHandler(nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNoNetwork), object: nil)
        }
    
    }
    
 
    
  /*  func make_UploadImage(url: NSString, param:NSDictionary, completionHandler: (responseObject: NSDictionary?,error:NSError? ) -> ())
    {
        
        var user_id:NSString=NSString()
        
        if(themes.Check_userID() != nil)
        {
            user_id=themes.getUserID()!
        }
        
        
        Alamofire.upload(.POST, URLString: url,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(fileURL: param .objectForKey("image")as! NSData, name: "photo")
                                multipartFormData.appendBodyPart(data: Constants.AuthKey.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"authKey")
                multipartFormData.appendBodyPart(data: "\(16)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"idUserChallenge")
                multipartFormData.appendBodyPart(data: "comment".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"comment")
                multipartFormData.appendBodyPart(data:"\(0.00)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"latitude")
                multipartFormData.appendBodyPart(data:"\(0.00)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"longitude")
                multipartFormData.appendBodyPart(data:"India".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"location")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { request, response, JSON, error in
                        
                        
                    }
                case .Failure(let encodingError): break
                    
                }
            })
        
        
        
    }*/

    
    
//    
//    
//    func uploadImage(urlString:NSString, parameters:NSDictionary, imgData:NSData) -> (NSURLResponse, NSError) {
//        
//        // create url request to send
//        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString as String)!)
//        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
//        let boundaryConstant = "myRandomBoundary12345";
//        let contentType = "multipart/form-data;boundary="+boundaryConstant
//        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
//        
//        
//        
//        // create upload data to send
//        let uploadData = NSMutableData()
//        
//        // add image
//        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//        uploadData.appendData(imgData)
//        
//        // add parameters
//        for (key, value) in parameters {
//            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
//        }
//        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//        
//        
//        
//        // return URLRequestConvertible and NSData
//        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
//    }
    



}

 
