


//  Constant.swift
//  Plumbal
//
//  Created by Casperon Tech on 08/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import Foundation
import UIKit
import GradientCircularProgress

var kPageCount = "10"
let Workname="Maid"
var kTypeStatus = "TypingStatus"
var kNetworkErrorMsg = "No network connection..."
var kNetworkConnectedMsg = "Network available"
var kNoNetwork = "NoNetworkNotif"
var StripeStatus:String=String()
var Appdel=UIApplication.shared.delegate as! AppDelegate


class Constant{
    var RootBase:RootViewController=RootViewController()
    let progress = GradientCircularProgress()
    var kErrorMsg = "Error in network connection... Please try again"
    let Roomname:String = "join network"
    let SwitchRoomname : String = "switch room"
    let kGeoCodingString = "http://maps.google.com/maps/geo?q=%f,%f&output=csv"
    let Hostname:String="http://192.168.0.78:3002/notify"
    //let Hostname:String="192.168.1.150"//192.168.1.150 //67.219.149.186
    let DomainName:String="@casp83"//@casp83 //@messaging.dectar.com
   //let GooglemapAPI:String="AIzaSyC7Jj13VgWqbf4PwIuElfXGZB18249GYPE"
 //   let googlePlacesAPI :String = "AIzaSyA5Iddlqm1Pvy3acYtnZvgxe8W7ZsCrcis"
    let GooglemapAPI:String="AIzaSyAk9nfXSWqCJCg3w3F-vbkKjziDtq1MQNA"
    let googlePlacesAPI :String = "AIzaSyBWcrYcpT-7oCAfdqG4Be9GwhpbiLiqsEM"
    let kOpenGoogleMapScheme = "comgooglemaps://"
    let mapZoomIn:Float = 15.0
   
//
//    let BaseUrl:String = "http://www.semakazi.com"
//    let MainbaseUrl:String = "http://www.semakazi.com/mobile"

    let BaseUrl:String = "http://handyforall.zoplay.com"
    let MainbaseUrl:String = "http://handyforall.zoplay.com/mobile"

    //MARK: Service Url
    
    var AppbaseUrl:String {
        get{
            return "\(MainbaseUrl)" //v1
        }
    }
    
    var AppbaseUrl1:String   {
        get{
            return "\(MainbaseUrl)" //v2
        }
    }
    
    var AppbaseUrl2:String{
        get{
            return "\(MainbaseUrl)" //v3
        }
    }
    
    var RegisterAccount: String {
        get{
            return "\(AppbaseUrl)/app/check-user"
        }
    }
    
    var Register: String {
        get{
            return AppbaseUrl.appending("/app/register")
        }
    }
    
    var Login: String {
        get{
            return AppbaseUrl.appending("/app/login")
        }
    }
    var viewProfile : String {
        get{
            return AppbaseUrl.appending("/provider/provider-info")
        }
    }
    
    var Map_Providers : String{
        get{
            return AppbaseUrl.appending("/app/mapbook-job")
        }
 
    }
    var about_usUrl : String{
        get
        {
            return AppbaseUrl.appending("/app/mobile/aboutus")
            
        }
    }
    //language
    var UpdateLanguage : String {
        get
        {
            return  AppbaseUrl.appending("/app/user/update-user-language")
        }
    }
    var reviewsUrl : String {
        get{
            return AppbaseUrl.appending("/provider/provider-rating")
        }
    }
    
    var Invite_Friends: String {
        get{
            return AppbaseUrl.appending("/app/get-invites")
        }
    }
    
    var Change_pass: String {
        get{
            return AppbaseUrl.appending("/app/user/change-password")
        }
    }
    
    var Change_Name: String {
        get{
            return AppbaseUrl.appending("/app/user/change-name")
        }
    }
    var view_Transaction_details :String{
        get{
            return AppbaseUrl.appending("/app/userjob-transaction")
        }
    }
    
    var Get_Transaction :String{
        get{
            return AppbaseUrl.appending("/app/user-transaction")
        }
    }
    
    var GetNotificationUrl :String{
        get {
            return AppbaseUrl.appending("/app/notification")
            
        }
        
    }
    var GetUserreviews:String{
        get{
            return AppbaseUrl.appending("/app/get-reviews")
        }
    }
    var Mymoney: String {
        get{
            return AppbaseUrl.appending("/app/get-money-page")
        }
    }
    
    var Stripe_Check_Url: String {
        get{
            return AppbaseUrl.appending("/mobile/wallet-recharge/stripe-process")
        }
    }
    var Reset_Password: String {
        get{
            return AppbaseUrl.appending("/app/user/reset-password")
        }
    }
    
    var Wallet_Recharge : String{
        get{
            return AppbaseUrl.appending("/mobile/wallet-recharge/payform?")
        }
    }
    
    var Wallet_Recharge_paypal: String
    {
        
        get{
            return AppbaseUrl.appending("/app/wallet-recharge/mobpaypal")
        }
        
    }
    
    var contact_emergency : String {
        get{
            return AppbaseUrl.appending("/app/user/alert-emergency-contact")
        }
    }
    
    var Social_Check: String {
        get{
            return AppbaseUrl.appending("/app/mobile/social-fbcheckUser")
        }
    }
    
    var Social_Register: String {
        get{
            return AppbaseUrl.appending("/app/mobile/social-register")
        }
    }
    
    var Social_login: String{
        get{
            return AppbaseUrl.appending("/app/mobile/social-login")
        }
    }
    
    var Update_Password: String {
        get{
            return AppbaseUrl.appending("/app/user/update-reset-password")
        }
    }
    
    var Get_Location: String {
        get{
            return AppbaseUrl.appending("/app/get-location")
        }
    }
    var Update_Location: String {
        get{
            return AppbaseUrl.appending("/app/set-user-location")
        }
    }
    var Get_Categories: String {
        get{
            return AppbaseUrl.appending("/app/categories")
        }
    }
    
    var inser_address_map:String{
        get{
            return AppbaseUrl.appending("/map/insert-address")
        }
    }
    var Get_SubCategories: String {
        get{
            return AppbaseUrl.appending("/app/categories")
        }
    }
    var Add_address: String {
        get{
            return AppbaseUrl.appending("/app/insert-address")
        }
    }
    
    var List_address: String {
        get{
            return AppbaseUrl.appending("/app/list_address")
        }
    }
    
    
    var Image_Edit: String {
        get{
            return AppbaseUrl.appending("/app/user-profile-pic")
        }
    }
    
    var Coupon_Call: String {
        get{
            return AppbaseUrl.appending("/app/apply-coupon")
        }
    }
    
    var changemobilenumber: String {
        get{
            return AppbaseUrl.appending("/app/user/change-mobile")
        }
    }
    
    var view_emergency: String {
        get{
            return AppbaseUrl.appending("/app/user/view-emergency-contact")
        }
    }
    
    var add_emergency: String {
        get{
            return AppbaseUrl.appending("/app/user/set-emergency-contact")
        }
    }
    var Delete_emergency: String {
        get{
            return AppbaseUrl.appending("/app/user/delete-emergency-contact")
        }
    }
    
    var Logout_url : String {
        get{
            return AppbaseUrl.appending("/app/user/logout")
        }
    }
    var Delete_Address: String {
        get{
            return AppbaseUrl.appending("/app/delete_address")
        }
    }
    var Book_It: String {
        get{
            return AppbaseUrl.appending("/app/book-job")
        }
    }
    
    var Get_Orders: String {
        get{
            return AppbaseUrl.appending("/app/my-jobs-new")
        }
    }
    
    var Get_TransactionDetail: String {
        get{
            return AppbaseUrl.appending("/app/get-trans-list")
        }
    }
    
    var Get_SortingOrders: String {
        get{
            return AppbaseUrl.appending("/app/my-jobs-new")
        }
    }
    
    var Get_Todays_Orders : String{
        get{
            return AppbaseUrl.appending("/user/recentuser-list")
        }
    }
    
    var MapOrder_confirm : String
    {
        get{
            return AppbaseUrl2.appending("/app/mapuser-booking")
        }
    }
    var Order_Confirm: String {
        get{
            return AppbaseUrl2.appending("/app/user-booking")
        }
    }
    
    var Get_Reasons: String {
        get{
            return AppbaseUrl.appending("/app/cancellation-reason")
        }
    }
    var Cancel_Reasons: String {
        get{
            return AppbaseUrl.appending("/app/cancel-job")
        }
    }
    var GetOrderdetail: String {
        get{
            return AppbaseUrl.appending("/user/view-job")
        }
    }
    var Get_Payment_Detail: String {
        get{
            return AppbaseUrl.appending("/app/payment-list")
        }
    }
    var Apply_Coupon_code :String{
        get{
            return AppbaseUrl.appending("/app/payment/couponmob")
        }
        
    }
    var Get_Summary_Details : String {
        get{
            return AppbaseUrl.appending("/app/paymentlist/history")
        }
    }
    var Pay_Cash: String {
        get{
            return AppbaseUrl.appending("/app/payment/by-cash")
        }
    }
    var Pay_Autodetect: String {
        get{
            return AppbaseUrl.appending("/payment/by-auto-detect")
        }
    }
    var Pay_Wallet: String {
        get{
            return AppbaseUrl.appending("/app/payment/by-wallet")
        }
    }
    var Pay_Transaction: String {
        get{
            return AppbaseUrl.appending("/app/payment/by-gateway")
        }
    }
    
    var Pay_Paypal :String{
        get{
            return AppbaseUrl.appending("/app/payment/paypalPayment")
        }
    }
    
    var Get_rating: String {
        get{
            return AppbaseUrl.appending("/get-rattings-options")
        }
    }
    
    var Pay_Creditcard : String {
        get{
            return AppbaseUrl.appending("/mobile/stripe-manual-payment-form?")
        }
    }
    var Post_rating: String {
        get{
            return AppbaseUrl.appending("/submit-rattings")
        }
    }
    
    var Get_CategoryInfo: String {
        get{
            return AppbaseUrl1.appending("/user/get-category-info")
        }
    }
    
    var Get_ProviderInfo: String {
        get{
            return AppbaseUrl1.appending("/user/get-provider-profile")
        }
    }
    var Get_Onlinestatus: String {
        get{
            return AppbaseUrl2.appending("/app/chat/availablity")
        }
    }
    
    var GetStripeStatus: String {
        get{
            return AppbaseUrl.appending("/app/stripe-api-keys")
        }
    }
    
    var Pay_Stripe: String {
        get{
            return AppbaseUrl2.appending("/app/stripe-wallet-recharge")
        }
    }
    var Pay_Stripe_Provider: String {
        get{
            return AppbaseUrl2.appending("/app/stripe-fees-payment")
        }
    }
    
    var Delete_card: String {
        get{
            return AppbaseUrl2.appending("/app/stripe-delete-card")
        }
    }
    
    var Chat_Details: String {
        get{
            return MainbaseUrl.appending("/chat/chathistory")
        }
    }
    
    var UpdateNotificationMode : String{
        get{
            return MainbaseUrl.appending("/user/notification_mode")
        }
    }
    
    var Show_ChatList: String {
        get{
            return AppbaseUrl2.appending("/app/getmessage")
        }
    }
    
    
    var Appinfo_url : String{
        get {
            return   AppbaseUrl.appending ("/app/mobile/appinfo")
        }
    }
    
    
    var Complete_Payment : String{
        get{
            return AppbaseUrl.appending ("/app/payment/zero")
        }
    }
    //MARK: - Function
    
//    func showProgress(){
//        progress.show(message: "", style: BlueIndicatorStyle())
//    }
//    
//    
//    func DismissProgress() {
//        progress.dismiss()
//    }
}


//MARK: - Language Reuse

var Appname:String {
get {
    return themes.setLang("app_name")
}
}

var kOk : String{
get {
    return themes.setLang("ok")
}
}

var kErrorMsg:String {
get{
    return themes.setLang("error_msg")
}
}



 
