//
//  WalletViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 13/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class Wallet: NSObject {
    
    var Status:String=String()
    var currency:String=String()
   var current_balance:String=String()
    var recharge_boundary:NSInteger=NSInteger()
    var max_amount:NSInteger=NSInteger()
    var middle_amount:NSInteger=NSInteger()
    var min_amount:NSInteger=NSInteger()
    var auto_charge_status:String=String()
    
    var stripe_keys:NSDictionary=NSDictionary()
    var mode:String=String()
    var secret_key:String=String()
    var publishable_key:String=String()
    
    var card_number:NSMutableArray=NSMutableArray()
     var exp_month:NSMutableArray=NSMutableArray()
     var exp_year:NSMutableArray=NSMutableArray()
    var card_type:NSMutableArray=NSMutableArray()
    var customer_id:NSMutableArray=NSMutableArray()
    var card_id:NSMutableArray=NSMutableArray()
     var card_status:String=String()
    var cards:NSDictionary=NSDictionary()
    var card_Type:NSMutableArray=NSMutableArray()
    
    var result:NSArray=NSArray()










}
