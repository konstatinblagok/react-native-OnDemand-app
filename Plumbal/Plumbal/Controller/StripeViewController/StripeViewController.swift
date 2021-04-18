//
//  StripeViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 07/01/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit

class StripeViewController: RootViewController,STPPaymentCardTextFieldDelegate,UITextFieldDelegate {
    @IBOutlet var Stripe_ScrollView: UIScrollView!

    @IBOutlet var Desc_lab: UILabel!
    @IBOutlet var Pay_btn: UIButton!
    var paymentTextField:STPPaymentCardTextField=STPPaymentCardTextField()

    @IBOutlet var Email_TextField: UITextField!
    @IBOutlet var Name_TextField: UITextField!
    // Replace these values with your application's keys
    
    // Find this at https://dashboard.stripe.com/account/apikeys
    let stripePublishableKey = "\(MyWallet.publishable_key)"
    
    // To set this up, see https://github.com/stripe/example-ios-backend
    let backendChargeURLString = ""
    
    // To set this up, see https://stripe.com/docs/mobile/apple-pay
    let appleMerchantId = ""
    
    let shirtPrice : UInt = 1000 // this is in cents
    let themes:Themes=Themes()
    
    var Keyboardstatus:NSString=NSString()
    
    var URL_handler:URLhandler=URLhandler()


    
    @IBAction func didClickOption(_ sender: AnyObject) {
        
        if(sender.tag == 0)
        {
//self.dismiss(animated : true, completion: nil)
            self.navigationController?.popToRootViewController(animated: true)
        
        }
        
        if(sender.tag == 1)
        {
            view.endEditing(true)
            self.Stripe_ScrollView.contentOffset = CGPoint(x: 0, y: 0);
 
            
            let validateemail:Bool=themes.isValidEmail(Email_TextField.text!)
            if(Name_TextField.text == "")
            {
                themes.AlertView(self.themes.setLang("enter_all_details"), Message: "", ButtonTitle: self.themes.setLang("ok"))
            }
            
          else  if(Email_TextField.text == "")
            {
                themes.AlertView(self.themes.setLang("enter_all_details"), Message: "", ButtonTitle: self.themes.setLang("ok"))
            }
            else  if(validateemail == false)
            {
                themes.AlertView("\(Appname)",Message: self.themes.setLang("valid_email_alert"),ButtonTitle: self.themes.setLang("ok"))
                
            }
         else if(paymentTextField.cardNumber == nil)
        {
            themes.AlertView(self.themes.setLang("enter_all_details"), Message: "", ButtonTitle: self.themes.setLang("ok"))
        }
            
       else if(paymentTextField.cvc == nil )
        {
            themes.AlertView(self.themes.setLang("enter_all_details"), Message: "", ButtonTitle: self.themes.setLang("ok"))
        }

      else  if( paymentTextField.expirationMonth == 0 )
        {
            themes.AlertView(self.themes.setLang("enter_all_details"), Message: "", ButtonTitle: self.themes.setLang("ok"))
        }

       else if( paymentTextField.expirationYear == 0)
        {
            themes.AlertView(self.themes.setLang("enter_all_details"), Message: "", ButtonTitle: self.themes.setLang("ok"))
        }
            


        else
        {
            Pay_btn.isEnabled=false

            paymentTextField.resignFirstResponder()
            let stripeCard:STPCard=STPCard()
            stripeCard.name="Check"
            stripeCard.number=paymentTextField.cardNumber!
            stripeCard.cvc=paymentTextField.cvc!
            stripeCard.expMonth=paymentTextField.expirationMonth
            stripeCard.expYear=paymentTextField.expirationYear
//            self.stripeCard = [[STPCard alloc] init];
//            self.stripeCard.name = self.nameTextField.text;
//            self.stripeCard.number = self.cardNumber.text;
//            self.stripeCard.cvc = self.CVCNumber.text;
//            self.stripeCard.expMonth = [self.selectedMonth integerValue];
//            self.stripeCard.expYear = [self.selectedYear integerValue];
//            STPAPIClient.sharedClient().createTokenWithBankAccount(<#T##bankAccount: STPBankAccountParams##STPBankAccountParams#>, completion: <#T##STPTokenCompletionBlock?##STPTokenCompletionBlock?##(STPToken?, NSError?) -> Void#>)
            self.showProgress()
             Stripe.createToken(with: stripeCard, publishableKey: stripePublishableKey, completion: { (Token:STPToken?, error:NSError?) -> Void in
                self.Pay_btn.isEnabled=true

            if(Token != nil)
            {
                
                print("the token is \(Token!.tokenId) \(self.themes.getUserID())....\(self.themes.getEmailID()))")
                if(StripeStatus == "Provider_Payment")
                {
                self.Pay_Stripe_Provider("\(Token!.tokenId)")
                }
                
                if(StripeStatus == "Wallet")
                {
                    self.pay_Stripe("\(Token!.tokenId)")

                }
                
                 }
                else
            {
                self.DismissProgress()
                self.themes.AlertView(self.themes.setLang("Enter Valid Card details"), Message: "", ButtonTitle: self.themes.setLang("ok"))

                }
                } as? STPCompletionBlock)
        }
 
//        if (stripePublishableKey == "") {
//            let alert = UIAlertController(
//                title: "You need to set your Stripe publishable key.",
//                message: "You can find your publishable key at https://dashboard.stripe.com/account/apikeys .",
//                preferredStyle: UIAlertControllerStyle.Alert
//            )
//            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
//            alert.addAction(action)
//            presentViewController(alert, animated: true, completion: nil)
//            return
//        }
//        if (appleMerchantId != "") {
//            if let paymentRequest = Stripe.paymentRequestWithMerchantIdentifier(appleMerchantId) {
//                if Stripe.canSubmitPaymentRequest(paymentRequest) {
//                    paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: "Cool shirt", amount: NSDecimalNumber(string: "10.00")), PKPaymentSummaryItem(label: "Stripe shirt shop", amount: NSDecimalNumber(string: "10.00"))]
//                    let paymentAuthVC = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
//                    paymentAuthVC.delegate = self
//                    presentViewController(paymentAuthVC, animated: true, completion: nil)
//                    return
//                }
//            }
//        } else {
//            print("You should set an appleMerchantId.")
//        }
        }
    }
    
    
    
    func pay_Stripe(_ token:String)
    {
        self.Pay_btn.isEnabled=false

        
                        let param:NSDictionary=["user_id":"\(themes.getUserID())","total_amount":"\(Transaction_Stat.total_Amt)","card_id":"","stripe_token":"\(token)","stripe_email":"\(Email_TextField.text!)"]
                         URL_handler.makeCall(constant.Pay_Stripe, param: param, completionHandler: { (responseObject, error) -> () in
                            self.DismissProgress()
                            self.Pay_btn.isEnabled=true

                             if(error != nil)
                            {
                                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)

                               // self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                            }
        
                            else
                            {
                            if(responseObject != nil)
                            {

                                let dict:NSDictionary=responseObject!
                                let Staus=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                                let response:NSString=dict.object(forKey: "response") as! NSString

                                
                                
                                if (Staus == "1")
                                {
                                    
                                    self.themes.AlertView("\(Appname)", Message: "\(response)", ButtonTitle: self.themes.setLang("ok"))
                                    self.navigationController?.popToRootViewController(animated: true)
                                }
                                else
                                {
                                    
                                    self.themes.AlertView("\(Appname)", Message: "\(response)", ButtonTitle: self.themes.setLang("ok"))


                                }
                                
                                
                               }
                            }
                        })

    }
    
    func Pay_Stripe_Provider(_ token:String)
    {
//        Pay_Stripe_Provider
        
        
//        user_id => 566ecbf8cae2aacc23000029
//        job_id => 1453533620
//        card_id => card_17Y8YKDxV42h1bSVXWsqC0nP ( Required if user uses their saved cards )
//        stripe_token =>  tok_17XoSPDxV42h1bSVHPqFUevM  ( Required - Only if user uses new card )
//        stripe_email => sureshkumar@casperon.in ( Optional - Required when user uses new card with different email address.)

        self.Pay_btn.isEnabled=false

        let param:NSDictionary=["user_id":"\(themes.getUserID())","job_id":"\(Root_Base.Job_ID)","card_id":"","stripe_token":"\(token)","stripe_email":"\(Email_TextField.text!)"]
        URL_handler.makeCall(constant.Pay_Stripe_Provider, param: param, completionHandler: { (responseObject, error) -> () in
            self.DismissProgress()
            self.Pay_btn.isEnabled=true

            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)

               // self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
            }
                
            else
            {
                if(responseObject != nil)
                {
                    
                    let dict:NSDictionary=responseObject!
                    let Staus=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                    let response:NSString=dict.object(forKey: "response") as! NSString
                    
                    
                    
                    if (Staus == "1")
                    {
                        self.performSegue(withIdentifier: "RatingVC", sender: nil)

                        
//                         self.dismiss(animated : true, completion: nil)

//                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                    else
                    {
                        
                        self.themes.AlertView("\(Appname)", Message: "\(response)", ButtonTitle: self.themes.setLang("ok"))
                        
                        
                    }
                    
                    
                }
            }
        })

    }
    
    override func viewDidLoad() {
        
        Desc_lab.text="You are about to charge \(Transaction_Stat.total_Amt) for your wallet"
        Desc_lab.sizeToFit()
        paymentTextField.frame=CGRect(x: 15, y: 289, width: self.view.frame.width - 30, height: 44)
        Stripe_ScrollView.addSubview(paymentTextField)
        paymentTextField.delegate=self
        
        //ADD Done button for Contact Field
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        doneToolbar.backgroundColor=UIColor.white
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(StripeViewController.doneButtonAction))
        
        
        doneToolbar.items = [flexSpace,done]
        
        doneToolbar.sizeToFit()
        
        paymentTextField.inputAccessoryView = doneToolbar


        if(themes.Check_userID() != "")
        {
            Name_TextField.text=themes.getUserName()
            Email_TextField.text=themes.getEmailID()

        }
        
        Name_TextField.delegate=self

        Email_TextField.delegate=self
        
        NotificationCenter.default.addObserver(self, selector: #selector(StripeViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StripeViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

SetFrameAccordingToSegmentIndex()
    }
    
    
    func doneButtonAction()
    {
        paymentTextField.resignFirstResponder()
        
        self.Stripe_ScrollView.contentOffset = CGPoint(x: 0, y: 0);

        
    }

    func SetFrameAccordingToSegmentIndex(){
        
        
        
        DispatchQueue.main.async {
            
            
            
            //This code will run in the main thread:
            self.Stripe_ScrollView.contentSize=CGSize(width: self.Stripe_ScrollView.frame.size.width, height: self.Pay_btn.frame.origin.y+self.Pay_btn.frame.size.height+20)
            
            
        }
    }

    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        
    }

    
    func keyboardWillShow(_ notification: Notification) {
        
        Stripe_ScrollView.isScrollEnabled=false
        if(Keyboardstatus == "Email_TextField")
        {
            self.Stripe_ScrollView.contentOffset = CGPoint(x: 0, y: Email_TextField.frame.origin.y-10);

            
         }
        else if(Keyboardstatus == "Name_TextField")
        {
            
        }
        else
        {
            self.Stripe_ScrollView.contentOffset = CGPoint(x: 0, y: 270);

        
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        Stripe_ScrollView.isScrollEnabled=true

        
        Keyboardstatus=""

     }

    

    

     func textFieldDidBeginEditing(_ textField: UITextField) {
        
         
        if(textField == Name_TextField)
        {
            Keyboardstatus="Name_TextField"
            
        }

        
        
        if(textField == Email_TextField)
        {
            Keyboardstatus="Email_TextField"

        }
        


        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField == Name_TextField)
        {
            Name_TextField.resignFirstResponder()
            self.Stripe_ScrollView.contentOffset = CGPoint(x: 0, y: 0);

        }
        
        
        
        if(textField == Email_TextField)
        {
            Email_TextField.resignFirstResponder()
            self.Stripe_ScrollView.contentOffset = CGPoint(x: 0, y: 0);

        }
        return true

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        Keyboardstatus=""
    }
    
    
    
    
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
 
}
