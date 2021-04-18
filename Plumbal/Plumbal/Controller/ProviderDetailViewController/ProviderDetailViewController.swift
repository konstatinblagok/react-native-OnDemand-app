//
//  ProviderDetailViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 12/01/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit

class ProviderDetailViewController: RootViewController {
    @IBOutlet var WrapperView:UIView!
    @IBOutlet var Message_Btn:UIButton!
    @IBOutlet var call_Btn:UIButton!
    @IBOutlet var Provider_tableView:UITableView!

    @IBOutlet var backbtn: UIButton!
    @IBOutlet var Header_btn: UIButton!
    @IBOutlet var Detail_Lab:UILabel!
    
    
    let URL_handler:URLhandler=URLhandler()
    var themes:Themes=Themes()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        themes.Back_ImageView.image=UIImage(named: "")
        
        backbtn.addSubview(themes.Back_ImageView)

         let Parallax_HeaderView:ParallaxHeaderView=ParallaxHeaderView.parallaxHeaderView(with: UIImage(named: "Register-bg"), for: CGSize(width: self.Provider_tableView.frame.size.width, height: 175)) as! ParallaxHeaderView
        self.Provider_tableView.tableHeaderView=Parallax_HeaderView
         let header: ParallaxHeaderView = self.Provider_tableView.tableHeaderView as! ParallaxHeaderView
        header.refreshBlurViewForNewImage()
        self.Provider_tableView.tableHeaderView = header
         Get_Data()
         let Nb=UINib(nibName: "ProviderInfoTableViewCell", bundle: nil)
         Provider_tableView.register(Nb, forCellReuseIdentifier: "InfoCell")
         let Nb1=UINib(nibName: "ProviderDetailTableViewCell", bundle: nil)
         Provider_tableView.register(Nb1, forCellReuseIdentifier: "DetailCell")
         Provider_tableView.isHidden=true
        Provider_tableView.rowHeight = UITableViewAutomaticDimension
        // WrapperView.layer.borderWidth=1.0
         // WrapperView.layer.borderColor=themes.ThemeColour().cgColor
         // Do any additional setup after loading the view.
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //
        //         for cell in self.Category_tableView.visibleCells as! [CategoryTableViewCell] {
        //
        //
        //
        //            let rectInSuperview: CGRect = Category_tableView.convertRect(cell.frame, toView: view)
        //            let distanceFromCenter: CGFloat = CGRectGetHeight(view.frame) / 2 - CGRectGetMinY(rectInSuperview)
        //            let difference: CGFloat = 183 - CGRectGetHeight(cell.frame)
        //            let move: CGFloat = (distanceFromCenter / CGRectGetHeight(view.frame)) * difference
        //
        //            imageRect=cell.Category_ImageView.frame
        //
        //            imageRect.origin.y = -(difference / 2) + move
        //
        //
        //             cell.Category_ImageView.frame = imageRect
        //        }
        
        
                 let header: ParallaxHeaderView = self.Provider_tableView.tableHeaderView as! ParallaxHeaderView
                header.layoutHeaderView(forScrollOffset: scrollView.contentOffset)
    }
    
    func Get_Data()
    {
        self.showProgress()
        
        let param=["user_id":"\(themes.getUserID())","provider_id":"\(OrderDetail_data.provider_id)"]
        URL_handler.makeCall(constant.Get_ProviderInfo, param: param as NSDictionary) { (responseObject, error) -> () in
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
                        self.Provider_tableView.isHidden=false
                        Provider_Detail.provider_name=(dict.object(forKey: "response")! as AnyObject).object(forKey: "provider_name") as! String
                        Provider_Detail.email=(dict.object(forKey: "response")! as AnyObject).object(forKey: "email") as! String
                        //Provider_Detail.bio=dict.objectForKey("response")!.objectForKey("bio") as! NSString
                        Provider_Detail.category1=(dict.object(forKey: "response")! as AnyObject).object(forKey: "category") as! NSMutableArray
                        
                        let avgInt : Float = (dict.object(forKey: "response")! as AnyObject).object(forKey: "avg_review") as! Float
                        let strAverageReview = "\(avgInt)"
                        Provider_Detail.avg_review=strAverageReview
                         //Provider_Detail.avg_review=dict.objectForKey("response")!.objectForKey("avg_review") as! NSString
                        Provider_Detail.mobile_number=(dict.object(forKey: "response")! as AnyObject).object(forKey: "mobile_number") as! String
                        Provider_Detail.image=(dict.object(forKey: "response")! as AnyObject).object(forKey: "image") as! String
                   
                        var tempArray = [String]()
                        
                        for ReasonDict in Provider_Detail.category1
                        {
                            let Reason_Str=(ReasonDict as AnyObject).object(forKey: "name") as! String
                            tempArray.append(Reason_Str as String)
                        }
                        
                        Provider_Detail.category = String()
                        Provider_Detail.category = tempArray.joined(separator: ", ")
                        
                      
                            Provider_Detail.Complete_Detail="Category : \(Provider_Detail.category)\n"
                        print("..get information.....\(Provider_Detail.Complete_Detail).........")
                        

                                               self.Provider_tableView.reload()
                        
                    }
                    else
                    {
                        self.themes.AlertView("\(Appname)",Message: self.themes.setLang("no_provider_detail"),ButtonTitle: kOk)
                        self.dismiss(animated: true, completion: nil)
                         self.navigationController?.popViewControllerWithFlip(animated: true)

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
    
     func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        var height_Cell:CGFloat=CGFloat()
       
        
        height_Cell = self.themes.calculateHeightForString("\((Provider_Detail.Complete_Detail as String) + (Provider_Detail.bio as String))")
        
            if(indexPath.row == 0)
            {
                
                
                    height_Cell = 90
                
            }
        else
            {
                height_Cell = height_Cell + 120
        }
            
            
            
        
        
        

        
        
        //         self.height_Return(height_Cell)
        return height_Cell
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        var Cell:UITableViewCell=UITableViewCell()
        if(Provider_Detail.provider_name != "")
        {
    
        if(indexPath.row == 0)
        {
           let Cell1 = tableView.dequeueReusableCell(withIdentifier: "InfoCell") as! ProviderInfoTableViewCell
            Cell1.selectionStyle=UITableViewCellSelectionStyle.none

            
            let n = NumberFormatter().number(from: Provider_Detail.avg_review as String)
            
             Cell1.ratingView.emptySelectedImage = UIImage(named: "Star")
            Cell1.ratingView.fullSelectedImage = UIImage(named: "StarSelected")
            Cell1.ratingView.contentMode = UIViewContentMode.scaleAspectFill
            Cell1.ratingView.maxRating = 5
            Cell1.ratingView.minRating = 1
            Cell1.ratingView.rating = CGFloat(n!)
            Cell1.ratingView.editable = false;
            Cell1.ratingView.halfRatings = true;
            Cell1.ratingView.floatRatings = false;

            Cell1.Name_Lab.text=Provider_Detail.provider_name as String
            Cell1.Contact_Lab.text=Provider_Detail.mobile_number as String
            Cell1.Email_Lab.text=Provider_Detail.email as String
            
            Cell1.Provider_Image.sd_setImage(with: URL(string: "\(Provider_Detail.image)"), completed: themes.block)
            Cell1.Provider_Image.layer.borderWidth=5.0
            
            Cell1.Provider_Image.layer.cornerRadius=Cell1.Provider_Image.frame.size.width/2
            
            Cell1.Provider_Image.clipsToBounds=true
            Cell1.Provider_Image.layer.borderColor=themes.ThemeColour().cgColor

 
         Cell=Cell1
        }
        else
        {
            let Cell2 = tableView.dequeueReusableCell(withIdentifier: "DetailCell") as! ProviderDetailTableViewCell
            var myMutableString = NSMutableAttributedString()
            myMutableString = NSMutableAttributedString(string: Provider_Detail.Complete_Detail as String, attributes: nil)
            myMutableString.addAttribute(NSFontAttributeName, value:UIFont.boldSystemFont(ofSize: 16) , range: NSRange(location:1,length:9))
            
            var myMutableString1 = NSMutableAttributedString()
            myMutableString1 = NSMutableAttributedString(string:"Bio : \(Provider_Detail.bio)", attributes: nil)
            myMutableString1.addAttribute(NSFontAttributeName, value:UIFont.boldSystemFont(ofSize: 16) , range: NSRange(location:1,length:4))
           // Cell2.bio_Lab.attributedText = myMutableString1
           // Cell2.bio_Lab.sizeToFit()
            Cell2.About_Lab.attributedText = myMutableString
            Cell2.About_Lab.sizeToFit()
            Cell2.selectionStyle=UITableViewCellSelectionStyle.none

            Cell=Cell2


        }
        }
        
        
        return Cell
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didClickoption(_ sender: UIButton) {
        if(sender.tag == 0)
        {
         self.dismiss(animated: true, completion: nil)
         self.navigationController?.popViewControllerWithFlip(animated: true)
        }
        if(sender.tag == 1)
        {
            let Storyboard:UIStoryboard=UIStoryboard(name: "Main", bundle: nil)
            let vc = Storyboard.instantiateViewController(withIdentifier: "MessageVC")
            self.present(vc, animated: true, completion: nil)
            
            //let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MessageVC") as! MessageViewController
            
           // self.navigationController?.pushViewController(withFlip: secondViewController, animated: true)


//            if (themes.canSendText()) {
//                // Obtain a configured MFMessageComposeViewController
//                let messageComposeVC = themes.configuredMessageComposeViewController("",number:"\(OrderDetail_data.provider_mobile)")
//                presentViewController(messageComposeVC, animated: true, completion: nil)
//            } else {
//                // Let the user know if his/her device isn't able to send text messages
//                let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
//                errorAlert.show()
//            }

        }

        
        if(sender.tag == 2)
        {
            UIApplication.shared.open(URL(string:"telprompt:\(OrderDetail_data.provider_mobile)")!, options: [:], completionHandler: nil)

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
