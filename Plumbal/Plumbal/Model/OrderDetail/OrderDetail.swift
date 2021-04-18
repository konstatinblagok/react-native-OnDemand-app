//
//  OrderDetail.swift
//  Plumbal
//
//  Created by Casperon Tech on 27/11/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class OrderDetail: NSObject {
    
    var avg_rating:String=String()
    var Provider_Email:String=String()
    
    var userJobLocation : String = String()

    var bio:String=String()
     var booking_address:NSDictionary=NSDictionary()
    var date:String=String()
    var job_id:String=String()
    var lat:String=String()
    var lon:String=String()
    var job_status:String=String()
     var provider_email:String=String()
    var provider_image:String=String()
     var provider_mobile:String=String()
    var provider_name:String=String()
    var time:String=String()
    var location:String=String()
    var provider_lat = String()
    var provider_long = String()

    var provider_id:String=String()
    var min_amount : String = String()
    var hourly_amount : String = String()
    var task_id: String = String()
    var Provider_service_type:String = String()
    var cancel_Reason:String = String()

 

}
class TrackingDetail:NSObject{
    var userLat = Double()
    var userLong = Double()
    var taskId = String()
    var lastDriving = String()
    var bearing = String()
    
    
}
