//
//  InviteFriendsViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 08/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

import SwiftyJSON

import Social

import MessageUI
import FacebookShare
import FacebookLogin
import FacebookCore




class InviteFriendsViewController: RootViewController,MFMailComposeViewControllerDelegate {
    
    @IBOutlet var invite_scroll: UIScrollView!
    
    @IBOutlet var twitterBtn: UIButton!
    @IBOutlet var Invite_Lbl: UILabel!
    @IBOutlet var Let_World: UILabel!
    @IBOutlet var Let_World1: UILabel!
    
    @IBOutlet var Share_Ref: UILabel!
    @IBOutlet var SlideinMenu_But: UIButton!
    
    @IBOutlet var Amount: UILabel!
    @IBOutlet var Your_Amt: UILabel!
    
    
    @IBOutlet var Referral_Label: UILabel!
    var URL_handler:URLhandler=URLhandler()
    var themes:Themes=Themes()
    var inviteDisc1 = String()
    var inviteDisc2 = String()
    var inviteDisc3 = String()
    var inviteDisc4 = String()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPage()
        //            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    func setPage(){
        inviteDisc1 = themes.setLang("invite_disc1")
        inviteDisc2 = themes.setLang("invite_disc2")
        inviteDisc3 = themes.setLang("invite_disc3")
        inviteDisc4 = themes.setLang("invite_disc4")
        Invite_Lbl.text=themes.setLang("invite_friend")
        Share_Ref.text=themes.setLang("share_referal")
        Let_World.text=themes.setLang("world_know")
        Let_World1.text=themes.setLang("world_know")
        self.invite_scroll.isHidden = false

        getInviteData()

        
        invite_scroll.contentSize = CGSize(width: invite_scroll.frame.size.width,height: self.twitterBtn.frame.origin.y+self.twitterBtn.frame.size.height+20)
        
        
        

    }
    
    
    func getInviteData(){
        
        let param:NSDictionary=["user_id":"\(themes.getUserID())","username":"\(themes.getUserName())"]
        
        self.showProgress()
        
        URL_handler.makeCall(constant.Invite_Friends.trimmingCharacters(in: CharacterSet.whitespaces), param: param, completionHandler: { (responseObject, error) -> () in
            
            self.DismissProgress()
            
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                self.invite_scroll.isHidden = true
                //self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
            }
                
            else
            {
                
                
                if(responseObject != nil)
                {
                    
                    self.DismissProgress()
                    let json = JSON(responseObject!)
                    
                    
                    Invite.Status = json["status"].string!
                    
                    
                    if(Invite.Status == "1")
                    {
                        self.invite_scroll.isHidden = false

                        Invite.Currency = json["response"]["details"]["currency"].string!
                        
                        Invite.Referral = json["response"]["details"]["referral_code"].string!
                        
                        Invite.urlstring = json["response"]["details"]["link"].string!
                        Invite.ImageUrl = json["response"]["details"]["image_url"].string!
                        
                        
                        
                        Invite.Friends_earn = json["response"]["details"]["friends_earn_amount"].intValue
                        //
                        //
                        Invite.you_Earn = json["response"]["details"]["your_earn_amount"].intValue
                        
                        
                        
                        
                        
                        Invite.Currency_Sym=self.themes.Currency_Symbol(Invite.Currency as String)
                        
                        
                        self.Amount.text="\(self.themes.setLang("frnds_join")) \(Invite.Friends_earn)\(Invite.Currency_Sym)"
                        
                        self.Your_Amt.text="\(self.themes.setLang("frnds_share")) \(Invite.you_Earn)\(Invite.Currency_Sym)"
                        
                        self.Referral_Label.text="\(Invite.Referral)"
                        
                        
                        
                    }
                    
                    
                }
                else
                {
                    self.invite_scroll.isHidden = true

                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    
                    // self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                    
                }
            }
        })
        

    }
    
    
    func applicationLanguageChangeNotification(_ notification:Notification)
    {
        
        
        
        
        
    }
    
    
    @IBAction func DidClickoption(_ sender: UIButton) {
        
        
        if(sender.tag == 0)
        {
            
            let urlString = "\(inviteDisc1)  \(Appname) \(inviteDisc2) \(Invite.Currency_Sym)\(Invite.Friends_earn), \(inviteDisc3) \(Invite.Referral)./n  \(inviteDisc4) \n \(Invite.urlstring)"
            let urlStringEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            let whatsappURL  = URL(string: "whatsapp://send?text=\(urlStringEncoded!)")
            if (UIApplication.shared.canOpenURL(whatsappURL!)) {
                UIApplication.shared.open(whatsappURL!, options: [:], completionHandler: nil)
            } else {
                themes.AlertView(themes.setLang("app_not_found"), Message: themes.setLang("install_app"), ButtonTitle: kOk)
            }
        }
        
        
        
        
        if(sender.tag == 1)
        {
            if (themes.canSendText()) {
                // Obtain a configured MFMessageComposeViewController
                let messageComposeVC = themes.configuredMessageComposeViewController( "\(inviteDisc1)  \(Appname) \(inviteDisc2) \(Invite.Currency_Sym)\(Invite.Friends_earn), \(inviteDisc3) \(Invite.Referral)./n  \(inviteDisc4) \n \(Invite.urlstring)",number:"")
                // Present the configured MFMessageComposeViewController instance
                // Note that the dismissal of the VC will be handled by the messageComposer instance,
                // since it implements the appropriate delegate call-back
                present(messageComposeVC, animated: true, completion: nil)
            } else {
                // Let the user know if his/her device isn't able to send text messages
                
                themes.AlertView(themes.setLang("cannot_send_text"), Message: themes.setLang("not_able_to_send_text"), ButtonTitle: kOk)
                
            }
        }
        
        
        if(sender.tag == 2)
        {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
            
        }
        
        
        if(sender.tag == 3)
        {
            let shareContent = LinkShareContent(url: URL(string:"\(Invite.urlstring)")!, title: "\(inviteDisc1)  \(Appname) \(inviteDisc2) \(Invite.Currency_Sym)\(Invite.Friends_earn), \(inviteDisc3) \(Invite.Referral)./n  \(inviteDisc4) \n \(Invite.urlstring)", description: nil, quote: nil, imageURL: nil)
            do{
                try MessageDialog.show(shareContent, completion: { (result) in
                    print(result)
                })
                
            }
            catch{
                print(error)
            }
        }
        
        
        if(sender.tag == 4)
        {
            
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
                
                let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                twitterSheet.setInitialText( "\(inviteDisc1)  \(Appname) \(inviteDisc2) \(Invite.Currency_Sym)\(Invite.Friends_earn), \(inviteDisc3) \(Invite.Referral)./n  \(inviteDisc4) \n \(Invite.urlstring)")
                twitterSheet.add(URL(string: "\(Invite.urlstring))"))
                self.present(twitterSheet, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: themes.setLang("accounts"), message: themes.setLang("login_twitter"), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: kOk, style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        if(sender.tag == 5)
        {
            
            
            //            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            //                let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            //                twitterSheet.addURL(NSURL.init(string:"\(Invite.urlstring)"))
            //                twitterSheet.setInitialText( "I have  \(Appname) Coupon Code, worth \(Invite.Friends_earn)\(Invite.Currency_Sym), When a new friend sign's up, they can avail my Coupon Code \(Invite.Referral)Click on the below link \n \(Invite.urlstring)")
            //                self.presentViewController(twitterSheet, animated: true, completion: nil)
            //            } else {
            //                let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            //                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            //                self.presentViewController(alert, animated: true, completion: nil)
            //            }
            
           let content = LinkShareContent.init(url: URL(string: "\(Invite.urlstring))")!, title: themes.setLang("share_ur_frnd"), description: nil, quote: nil, imageURL: nil)
//            //            content.contentDescription = "\(themes.setLang("coupen_disc1")) \(Appname) \(themes.setLang("coupen_disc2")) \(Invite.Friends_earn)\(Invite.Currency_Sym) \(themes.setLang("coupen_disc3"))"
//            do{
//               try MessageDialog.show(content, completion: { (result) in
//                    print(result)
//                })
//
//            }
//            catch{
//                print(error)
//            }
            //            content.contentTitle = "Share Your friends about us"
            //            content.contentDescription = "Refer and Earn, when your friend signup with your referral code, you earn \(Invite.Currency_Sym)\(Invite.you_Earn), in your wallet and your friend earns \(Invite.Currency_Sym)\(Invite.Friends_earn).\n Signup using the code \(Invite.Referral) and earn money in your wallet"
            //
            //            content.imageURL =  NSURL(string:"http://www.fnordware.com/superpng/pnggradHDrgba.png")
            //            FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
            
            let shareDialog = ShareDialog(content: content)
            shareDialog.mode = .feedWeb
            shareDialog.failsOnInvalidData = true
            shareDialog.completion = { result in
                // Handle share results
            }
           try! shareDialog.show()
            
            
        }
    }
    
    
    @IBAction func menuButtonTouched(_ sender: AnyObject) {
        self.findHamburguerViewController()?.showMenuViewController()
    }
    
    
    
    
    
    
    
    
    
    //Delegate Function For mail composing
    
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        //        mailComposerVC.setToRecipients(["info@zoplay.com"])
        mailComposerVC.setSubject(themes.setLang("share_ur_frnd"))
        mailComposerVC.setMessageBody("\(inviteDisc1)  \(Appname) \(inviteDisc2) \(Invite.Currency_Sym)\(Invite.Friends_earn), \(inviteDisc3) \(Invite.Referral)./n  \(inviteDisc4) \n \(Invite.urlstring)", isHTML: false)
        
        return mailComposerVC
    }
    
    
    
    
    func showSendMailErrorAlert() {
        
        
        themes.AlertView(themes.setLang("not_send_email"), Message: themes.setLang("device_not_send_email"), ButtonTitle: kOk)
        
        
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
