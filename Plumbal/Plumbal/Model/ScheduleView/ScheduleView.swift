//
//  ScheduleView.swift
//  Plumbal
//
//  Created by Casperon Tech on 04/11/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class ScheduleView: NSObject {
    
    
    var ScheduleAddressArray:NSMutableArray=NSMutableArray()
    
    var service:String=String()
    var orderDate:String=String()
    var JobID:String=String()
    var jobDescription:String=String()
    var TaskID:String=String()
    var RquiredAddressid : String = String()
    var PickupDate : String = String()
    var pickupTime : String = String()
    var GetScheduleIstr: String = String()
    var GetCoupenText : String = String()
    var getLatitude : String = String()
    var getLongtitude: String = String()
    
    var tasker_lat : String = String()
    var tasker_lng : String = String ()
    
    
    var Schedule_header:String=String()
    
    var ProviderListIdArray:NSMutableArray=NSMutableArray()
    var ProviderListNameArray:NSMutableArray=NSMutableArray()
    var ProviderLisreviewsArray:NSMutableArray=NSMutableArray()
    var ProviderdistanceArray:NSMutableArray=NSMutableArray()

    
    var ProviderListAvailableArray:NSMutableArray=NSMutableArray()
    var ProviderListImageArray:NSMutableArray=NSMutableArray()
    var ProviderListCompanyArray:NSMutableArray=NSMutableArray()
    var ProviderListRatingArray:NSMutableArray=NSMutableArray()
    var ProviderListMinamountArray:NSMutableArray=NSMutableArray()
    var ProviderListHouramountArray:NSMutableArray=NSMutableArray()
    
     var ScheduleAddressNameArray:NSMutableArray=NSMutableArray()
    var ScheduleLatitudeArray:NSMutableArray = NSMutableArray()
    var ScheduleLongtitudeArray:NSMutableArray = NSMutableArray()
    var ScheduledisplayAddArray : NSMutableArray = NSMutableArray()
    var ScheduledlistaddArray : NSMutableArray = NSMutableArray()
    
  
    var scheduleAddressid:String = String()

}
