////
////  Wallet_SDKViewController.swift
////  Plumbal
////
////  Created by Casperon Tech on 13/10/15.
////  Copyright © 2015 Casperon Tech. All rights reserved.
////
//
//import UIKit
//
//import Stripe
//
//
//class Wallet_SDKViewController: UIViewController,PayPalPaymentDelegate, PayPalFuturePaymentDelegate, PayPalProfileSharingDelegate,PKPaymentAuthorizationViewControllerDelegate {
//
//   
//    
//    //Stripe Payment
//    
//    
//    // Find this at https://dashboard.stripe.com/account/apikeys
//    let stripePublishableKey = "pk_test_UXGJ2AfiBinARpeXmUJc2C86"
//    
//    // To set this up, see https://github.com/stripe/example-ios-backend
//    let backendChargeURLString = "https://plumbal192.herokuapp.com/"
//    
//    // To set this up, see https://stripe.com/docs/mobile/apple-pay
//    let appleMerchantId = ""
//    
//    
//    let shirtPrice : UInt = 1000 // this is in cents
//    
//    
//    
//    
//    
//    var environment:String = PayPalEnvironmentSandbox {
//        willSet(newEnvironment) {
//            if (newEnvironment != environment) {
//                PayPalMobile.preconnectWithEnvironment(newEnvironment)
//            }
//        }
//    }
//    
//    
//    #if HAS_CARDIO
//    var acceptCreditCards: Bool = true {
//    didSet {
//    payPalConfig.acceptCreditCards = acceptCreditCards
//    }
//    }
//    #else
//    var acceptCreditCards: Bool = false {
//        didSet {
//            payPalConfig.acceptCreditCards = acceptCreditCards
//        }
//    }
//    #endif
//    
//    var payPalConfig = PayPalConfiguration() // default
//    
//    
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        PayPalMobile.preconnectWithEnvironment(environment)
//        
//        title = "Plumbal Paypal Gateway"
//        // Set up payPalConfig
//        payPalConfig.acceptCreditCards = acceptCreditCards;
//        payPalConfig.merchantName = "Plumbal"
//        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
//        payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
//        
//        // Setting the languageOrLocale property is optional.
//        //
//        // If you do not set languageOrLocale, then the PayPalPaymentViewController will present
//        // its user interface according to the device's current language setting.
//        //
//        // Setting languageOrLocale to a particular language (e.g., @"es" for Spanish) or
//        // locale (e.g., @"es_MX" for Mexican Spanish) forces the PayPalPaymentViewController
//        // to use that language/locale.
//        //
//        // For full details, including a list of available languages and locales, see PayPalPaymentViewController.h.
//        
//        payPalConfig.languageOrLocale = NSLocale.preferredLanguages()[0]
//        
//        
//        payPalConfig.payPalShippingAddressOption = .PayPal;
//        
//        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
//        
//        
//        
//        // Do any additional setup after loading the view.
//    }
//    
//    
//    @IBAction func Payment_Paypal(sender: AnyObject) {
//        
//        if(sender.tag == 0)
//        {
//            
//            let item1 = PayPalItem(name: "Wallet Amount Payment", withQuantity: 1, withPrice: NSDecimalNumber(string: "800"), withCurrency: "USD", withSku: "Hip-0037")
//            
//            let items = [item1]
//            let subtotal = PayPalItem.totalPriceForItems(items)
//            
//            // Optional: include payment details
//            let shipping = NSDecimalNumber(string: "0.0")
//            let tax = NSDecimalNumber(string: "0.0")
//            let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
//            
//            let total = subtotal.decimalNumberByAdding(shipping).decimalNumberByAdding(tax)
//            
//            let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Wallet Amount", intent: .Sale)
//            
//            payment.items = items
//            payment.paymentDetails = paymentDetails
//            
//            if (payment.processable) {
//                let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
//                presentViewController(paymentViewController, animated: true, completion: nil)
//            }
//            else {
//                // This particular payment will always be processable. If, for
//                // example, the amount was negative or the shortDescription was
//                // empty, this payment wouldn't be processable, and you'd want
//                // to handle that here.
//                print("Payment not processalbe: \(payment)")
//            }
//        }
//        
//    }
//    
//    
//    
//    // PayPalPaymentDelegate
//    
//    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController!) {
//        print("PayPal Payment Cancelled")
//        paymentViewController?dismiss(true, completion: nil)
//    }
//    
//    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController!, didCompletePayment completedPayment: PayPalPayment!) {
//        print("PayPal Payment Success !")
//        paymentViewController?dismiss(true, completion: { () -> Void in
//            // send completed confirmaion to your server
//            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment\(completedPayment).")
//            
//        })
//    }
//    
//    
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        
//        
//        // Dispose of any resources that can be recreated.
//    }
//    
//    
//    
//    func payPalFuturePaymentDidCancel(futurePaymentViewController: PayPalFuturePaymentViewController!) {
//        print("PayPal Future Payment Authorization Canceled")
//        futurePaymentViewController?dismiss(true, completion: nil)
//    }
//    
//    func payPalFuturePaymentViewController(futurePaymentViewController: PayPalFuturePaymentViewController!, didAuthorizeFuturePayment futurePaymentAuthorization: [NSObject : AnyObject]!) {
//        print("PayPal Future Payment Authorization Success!")
//        // send authorization to your server to get refresh token.
//        futurePaymentViewController?dismiss(true, completion: { () -> Void in
//        })
//    }
//    
//    
//    // PayPalProfileSharingDelegate
//    
//    func userDidCancelPayPalProfileSharingViewController(profileSharingViewController: PayPalProfileSharingViewController!) {
//        print("PayPal Profile Sharing Authorization Canceled")
//        profileSharingViewController?dismiss(true, completion: nil)
//    }
//    
//    func payPalProfileSharingViewController(profileSharingViewController: PayPalProfileSharingViewController!, userDidLogInWithAuthorization profileSharingAuthorization: [NSObject : AnyObject]!) {
//        print("PayPal Profile Sharing Authorization Success!")
//        
//        // send authorization to your server
//        
//        profileSharingViewController?dismiss(true, completion: { () -> Void in
//        })
//        
//    }
//    
//    
//    
//    //Stripe Payment Delegate Propeties
//    
//    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: ((PKPaymentAuthorizationStatus) -> Void)) {
//        let apiClient = STPAPIClient(publishableKey: stripePublishableKey)
//        apiClient.createTokenWithPayment(payment, completion: { (token, error) -> Void in
//            if error == nil {
//                if let token = token {
//                    self.createBackendChargeWithToken(token, completion: { (result, error) -> Void in
//                        if result == STPBackendChargeResult.Success {
//                            completion(PKPaymentAuthorizationStatus.Success)
//                        }
//                        else {
//                            completion(PKPaymentAuthorizationStatus.Failure)
//                        }
//                    })
//                }
//            }
//            else {
//                completion(PKPaymentAuthorizationStatus.Failure)
//            }
//        })
//    }
//    
//    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func createBackendChargeWithToken(token: STPToken, completion: STPTokenSubmissionHandler) {
//        if backendChargeURLString != "" {
//            if let url = NSURL(string: backendChargeURLString  + "/charge") {
//                
//                let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
//                let request = NSMutableURLRequest(URL: url)
//                request.HTTPMethod = "POST"
//                let postBody = "stripeToken=\(token.tokenId)&amount=\(shirtPrice)"
//                let postData = postBody.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
//                session.uploadTaskWithRequest(request, fromData: postData, completionHandler: { data, response, error in
//                    let successfulResponse = (response as? NSHTTPURLResponse)?.statusCode == 200
//                    if successfulResponse && error == nil {
//                        completion(.Success, nil)
//                    } else {
//                        if error != nil {
//                            completion(.Failure, error)
//                        } else {
//                            completion(.Failure, NSError(domain: StripeDomain, code: 50, userInfo: [NSLocalizedDescriptionKey: "There was an error communicating with your payment backend."]))
//                        }
//                        
//                    }
//                }).resume()
//                
//                return
//            }
//        }
//        completion(STPBackendChargeResult.Failure, NSError(domain: StripeDomain, code: 50, userInfo: [NSLocalizedDescriptionKey: "You created a token! Its value is \(token.tokenId). Now configure your backend to accept this token and complete a charge."]))
//    }
//    
//    
//    
//    /*
//    // MARK: - Navigation
//    
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    // Get the new view controller using segue.destinationViewController.
//    // Pass the selected object to the new view controller.
//    }
//    */
//
//
//}
