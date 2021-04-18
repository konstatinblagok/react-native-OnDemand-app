//
//  TermsViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 30/12/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class TermsViewController: RootViewController {
    @IBOutlet var minfare_labl: UILabel!
    let themes:Themes=Themes()
    
    @IBOutlet var Terms_Cond_lab: UILabel!
    @IBOutlet var back_btn: UIButton!
    @IBOutlet var Minfare_lab: UILabel!
    @IBOutlet var minfare_seperator: BorderLabel!
    @IBOutlet var wrapper_View: UIView!
     @IBOutlet var Show_Password: UIButton!
    @IBOutlet var Terms_ScrollView: UIScrollView!
    var minfare:String=String()
    var URL_Handler:URLhandler=URLhandler()
    override func viewDidLoad() {
        super.viewDidLoad()
        Get_Minfare()
        minfare=themes.setLang("Your min fare for this category is")
        themes.Back_ImageView.image=UIImage(named: "")
        
        back_btn.addSubview(themes.Back_ImageView)


        // Do any additional setup after loading the view.
    }
    
    func SetFrameAccordingToSegmentIndex(){
        
        
        
        DispatchQueue.main.async {
            
            
            
            //This code will run in the main thread:
            self.Terms_ScrollView.contentSize=CGSize(width: self.Terms_ScrollView.frame.size.width, height: self.wrapper_View.frame.origin.y+self.wrapper_View.frame.size.height+60)
            
            
        }
    }
    
    func Get_Minfare()
    {
        Terms_ScrollView.isHidden=true
        self.showProgress()

        let param=["category_id":"\(Home_Data.Category_id)","location_id":"\(themes.getLocationID())"] //56eff0dccae2aa300d00002a
        URL_Handler.makeCall(constant.Get_CategoryInfo, param: param as NSDictionary) { (responseObject, error) -> () in
            self.Terms_ScrollView.isHidden=false
            self.DismissProgress()
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
                    
                    
                    if (Staus == "1")
                    {
                        Terms_Details.currency_code=(dict.object(forKey: "response") as AnyObject).object(forKey: "currency_code") as! String
                        Terms_Details.Terms_desc=(dict.object(forKey: "response") as AnyObject).object(forKey: "description") as! String
                        Terms_Details.min_fare=(dict.object(forKey: "response") as AnyObject).object(forKey: "min_fare") as! String
                        Terms_Details.is_set=(dict.object(forKey: "response") as AnyObject).object(forKey: "is_service_available") as! String

                        
                             self.setData()

                        
                    }
                    else
                    {
                        self.themes.AlertView("\(Appname)",Message: self.themes.setLang("no_min_fare"),ButtonTitle: kOk)
                        //self.performSegueWithIdentifier("ScheduleVC", sender: nil)


                    }
                    
                }
                else
                {
                    self.DismissProgress()
                    
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    
                    
                    
                }

            }
        }
    }
    func setData()
    {
        let index = 0

        
        Minfare_lab.transform = CGAffineTransform(translationX: self.view.frame.size.width, y: 0)
        Terms_Cond_lab.transform = CGAffineTransform(translationX: self.view.frame.size.width, y: 0)

 
        UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
            self.Minfare_lab.transform = CGAffineTransform(translationX: 0, y: 0);
            self.Terms_Cond_lab.transform = CGAffineTransform(translationX: 0, y: 0)

            }, completion: nil)


        self.Terms_Cond_lab.text=Terms_Details.Terms_desc as String
        Terms_Cond_lab.sizeToFit()
        if(Terms_Cond_lab.frame.size.height > 30)
        {
        wrapper_View.frame.origin.y=Terms_Cond_lab.frame.origin.y+Terms_Cond_lab.frame.size.height+30
        }
        self.Minfare_lab.text="\(self.minfare)  \(self.themes.Currency_Symbol(Terms_Details.currency_code as String))\(Terms_Details.min_fare)"
        SetFrameAccordingToSegmentIndex()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickoption(_ sender: AnyObject) {
        if(sender.tag == 0)
        {
            
                 if(Show_Password.isSelected == true)
                {
                    Show_Password.isSelected = false
                    Show_Password.setImage(UIImage(named: "check"), for: UIControlState())
                 }
                else
                {
                    Show_Password.isSelected = true
                    Show_Password.setImage(UIImage(named: "tick"), for: UIControlState())
                 }
             }
        
        if(sender.tag == 2)
        {
            
            if(Show_Password.isSelected == false)
            {
                themes.AlertView("\(Appname)", Message: themes.setLang("accept_terms"), ButtonTitle: kOk)
            }
            else
            {
                self.performSegue(withIdentifier: "ScheduleVC", sender: nil)
            }
         }
        if(sender.tag == 3)
        {
            self.navigationController?.popViewControllerWithFlip(animated: true)
        }
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
