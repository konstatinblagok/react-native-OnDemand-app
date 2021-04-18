//
//  CardListViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 27/01/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit

class CardListViewController: RootViewController {
    
    @IBOutlet var CardList_tableview: UITableView!
    @IBOutlet var wapper_View: BorderView!
    @IBOutlet var Choose_CardLabl: UIButton!
    @IBOutlet var Proceed_Btn: UIButton!

    var Globalindex:NSString=NSString()
    var URL_handler:URLhandler=URLhandler()
    var themes:Themes=Themes()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wapper_View.layer.cornerRadius=themes.RoundView(wapper_View.frame.size.width)
        wapper_View.clipsToBounds=true
        
        let Nb=UINib(nibName: "CardListTableViewCell", bundle: nil)
        
        CardList_tableview.register(Nb, forCellReuseIdentifier: "ListCell")
        CardList_tableview.estimatedRowHeight = 140
        CardList_tableview.rowHeight = UITableViewAutomaticDimension
        CardList_tableview.separatorColor=UIColor.clear
        
        if(StripeStatus == "Provider_Payment")
        {
         self.view.layer.cornerRadius = 8.0;
        self.view.clipsToBounds=true
        self.view.layer.borderColor = UIColor.lightGray.cgColor;
        self.view.layer.borderWidth=2.0;
        }

        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return MyWallet.card_id.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let Cell:CardListTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! CardListTableViewCell
        Cell.selectionStyle=UITableViewCellSelectionStyle.none
        
        
        Cell.Carddetail_Lab.text="Card Number: \(MyWallet.card_number[indexPath.section])\nExpire month: \(MyWallet.exp_month[indexPath.section])\nExpire year: \(MyWallet.exp_year[indexPath.section])\nCard Type: \(MyWallet.card_type[indexPath.section])"
        Cell.Carddetail_Lab.sizeToFit()
        Cell.selectionStyle = .none
        
        Cell.layer.cornerRadius = 5
        Cell.layer.shadowColor = UIColor.black.cgColor
        Cell.layer.shadowOpacity = 0.5
        Cell.layer.shadowRadius = 2
        Cell.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        Cell.Delete_card.addTarget(self, action: #selector(CardListViewController.Deleteaction(_:)), for: UIControlEvents.touchUpInside)
        Cell.Delete_card.tag=indexPath.section
        if(Globalindex as String == "\(indexPath.section)")
        {
            
            Cell.Selected_Img.isHidden=false
            
        }
        else
        {
            Cell.Selected_Img.isHidden=true
            
        }
        
        return Cell
    }
    func Deleteaction(_ sender:UIButton)
    {
        
        self.showProgress()
        Proceed_Btn.isEnabled=false
        CardList_tableview.isUserInteractionEnabled=false

        let param:NSDictionary=["user_id":"\(themes.getUserID())","card_id":"\(MyWallet.card_id[sender.tag])","customer_id":"\(MyWallet.customer_id[sender.tag])"]
        URL_handler.makeCall(constant.Delete_card, param: param, completionHandler: { (responseObject, error) -> () in
            self.DismissProgress()
            self.Proceed_Btn.isEnabled=true
             self.CardList_tableview.isUserInteractionEnabled=true


            if(error != nil)
            {
                //self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)

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
                        
                         self.CardList_tableview.beginUpdates()
                        MyWallet.card_number.removeObject(at: sender.tag)
                        MyWallet.exp_month.removeObject(at: sender.tag)
                        MyWallet.exp_year.removeObject(at: sender.tag)
                        MyWallet.card_type.removeObject(at: sender.tag)
                        MyWallet.customer_id.removeObject(at: sender.tag)
                        MyWallet.card_id.removeObject(at: sender.tag)
                        self.CardList_tableview.deleteSections(IndexSet(integer: sender.tag), with: .fade)
                        self.CardList_tableview.endUpdates()
                        
                    }
                    else
                    {
                        
                        self.themes.AlertView("\(Appname)", Message: "\(response)", ButtonTitle: "Ok")
                        
                        
                    }
                    
                    
                }
            }
        })
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        Globalindex="\(indexPath.section)" as NSString
        self.CardList_tableview.reload()
        
        
        
        
        
    }
    
    
    func pay_Stripe(_ cardid:String)
    {
        self.showProgress()
        Proceed_Btn.isEnabled=false
        CardList_tableview.isUserInteractionEnabled=false

        
        let param:NSDictionary=["user_id":"\(themes.getUserID())","total_amount":"\(Transaction_Stat.total_Amt)","card_id":"\(cardid)","stripe_token":"","stripe_email":""]
        URL_handler.makeCall(constant.Pay_Stripe, param: param, completionHandler: { (responseObject, error) -> () in
            self.DismissProgress()
            self.Proceed_Btn.isEnabled=true
            self.CardList_tableview.isUserInteractionEnabled=true

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
                        
                        self.navigationController?.popViewControllerWithFlip(animated: true)
                        
                        
                    }
                    else
                    {
                        
                        self.themes.AlertView("\(Appname)", Message: "\(response)", ButtonTitle: self.themes.setLang("ok"))
                        
                        
                    }
                    
                    
                }
            }
        })
    }
    
     @IBAction func DidclickOptions(_ sender: UIButton) {
        
        if(sender.tag == 0)
        {
            self.navigationController?.popViewControllerWithFlip(animated: true)
        }
        
        if(sender.tag == 1)
        {
//            let Storyboard:UIStoryboard=UIStoryboard(name: "Main", bundle: nil)
//            let vc = Storyboard.instantiateViewControllerWithIdentifier("StripeVC")
//            self.presentViewController(vc, animated: true, completion: nil)
            
            let Controller:StripeViewController=self.storyboard?.instantiateViewController(withIdentifier: "StripeVC") as! StripeViewController
            self.navigationController?.pushViewController(withFlip: Controller, animated: true)

        }
        if(sender.tag == 2)
        {
            
            if(MyWallet.card_number.count == 0)
            {
                themes.AlertView("\(Appname)", Message: themes.setLang("add_a_card") , ButtonTitle: kOk)
            }
                else if(Globalindex == "")
            {
                themes.AlertView("\(Appname)", Message:  themes.setLang("select_a_card"), ButtonTitle: kOk)

            }
            else
            {
                
                if(StripeStatus == "Provider_Payment")
                {
                    self.pay_Stripe_Provider("\(MyWallet.card_id[Int(Globalindex as String)!])")
                }
                
                if(StripeStatus == "Wallet")
                {
                    self.pay_Stripe("\(MyWallet.card_id[Int(Globalindex as String)!])")
                    
                }

            }
            
        }
        
    }
    
    
    func pay_Stripe_Provider(_ cardid:String)
    {
        self.showProgress()
        Proceed_Btn.isEnabled=false
        CardList_tableview.isUserInteractionEnabled=false

        
        let param:NSDictionary=["user_id":"\(themes.getUserID())","job_id":"\(Root_Base.Job_ID)","card_id":"\(cardid)","stripe_token":"","stripe_email":""]
        URL_handler.makeCall(constant.Pay_Stripe_Provider, param: param, completionHandler: { (responseObject, error) -> () in
            self.DismissProgress()
            self.Proceed_Btn.isEnabled=true
            self.CardList_tableview.isUserInteractionEnabled=true

            if(error != nil)
            {
                //self.themes.AlertView("Network Failure", Message: "Please try again", ButtonTitle: "Ok")
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)

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

                        
                        
                    }
                    else
                    {
                        
                        self.themes.AlertView("\(Appname)", Message: "\(response)", ButtonTitle: self.themes.setLang("ok"))
                        
                        
                    }
                    
                    
                }
            }
        })
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
