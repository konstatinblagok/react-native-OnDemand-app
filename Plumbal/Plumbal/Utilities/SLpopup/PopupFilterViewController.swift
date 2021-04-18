//
//  PopupFilterViewController.swift
//  Plumbal
//
//  Created by Casperon on 31/08/16.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit
import CoreGraphics
import NMRangeSlider

protocol PopupFilterViewControllerDelegate {
    
    func pressedCancel(_ sender: PopupFilterViewController)
    
    func  passParametres(_ RatingValue:CGFloat,Priceval: String,MaxPrice: String,distancefilter:String)
    
    
    
    
    
    
}


class PopupFilterViewController: UIViewController,TPFloatRatingViewDelegate,UITextFieldDelegate {
    
    var delegate:PopupFilterViewControllerDelegate?
    
    var minimumpriceval : NSString!
    var maximumpriceval : NSString!
    @IBOutlet var upperLabel: UILabel!
    @IBOutlet var lowerLabel: UILabel!
    @IBOutlet weak var price_slider: UISlider!
    @IBOutlet var lblDistance: CustomLabel!
    @IBOutlet weak var cancelbtn: UIButton!
    @IBOutlet weak var applybtn: UIButton!
    @IBOutlet var kiloMeter_txt: UITextField!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblHourly: UILabel!
    @IBOutlet weak var lblSorting: UILabel!
    
    @IBOutlet var lableSlider: NMRangeSlider!
    @IBOutlet weak var RatingView: TPFloatRatingView!
    var Ratcount: CGFloat = CGFloat()
    @IBAction func sliderValueChanged(_ sender: AnyObject) {
        // self.updateSliderLabels()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        kiloMeter_txt.delegate = self
        lblHourly.text = themes.setLang("hourly_pricing")
        lblRating.text = themes.setLang("rating")
        lblDistance.text = themes.setLang("distance")
        lblSorting.text = themes.setLang("sorting")
        applybtn.setTitle(themes.setLang("apply"), for: UIControlState())
        kiloMeter_txt.placeholder = themes.setLang("kilo")
        RatingView.emptySelectedImage = UIImage(named: "Star")
        RatingView.fullSelectedImage = UIImage(named: "StarSelected")
        RatingView.contentMode = UIViewContentMode.scaleAspectFill
        RatingView.maxRating = 5
        RatingView.minRating = 0
        RatingView.rating = 0
        RatingView.editable = true;
        RatingView.halfRatings = true;
        RatingView.floatRatings = false;
        RatingView.tintColor = UIColor(red:232.0/255.0, green:101.0/255.0, blue:7.0/255.0, alpha:1.0)
        
        RatingView.delegate=self
        
        Done_Toolbar()
        
        
        var lowerCenter: CGPoint = CGPoint()
        lowerCenter.x = (self.lableSlider.frame.origin.x + self.upperLabel.frame.width/2)
        lowerCenter.y = (self.lableSlider.center.y - 30.0)
        self.lowerLabel.center = lowerCenter
        
        var upperCenter: CGPoint = CGPoint()
        upperCenter.x = (self.lableSlider.frame.maxX-self.upperLabel.frame.width/2)
        upperCenter.y = (self.lableSlider.center.y - 30.0)
        self.upperLabel.center = upperCenter
        
        self.configureLabelSlider()
        //  self.updateSliderLabels()
        
        // Do any additional setup after loading the view.
    }
    func updateSliderLabels() {
        var lowerCenter: CGPoint = CGPoint()
        lowerCenter.x = (self.lableSlider.lowerCenter.x + self.lableSlider.frame.origin.x)
        lowerCenter.y = (self.lableSlider.center.y - 30.0)
        self.lowerLabel.center = lowerCenter
        self.lowerLabel.text! = "\(themes.getCurrencyCode())\(Int(self.lableSlider.lowerValue))"
        var upperCenter: CGPoint = CGPoint()
        upperCenter.x = (self.lableSlider.upperCenter.x + self.lableSlider.frame.origin.x)
        upperCenter.y = (self.lableSlider.center.y - 30.0)
        self.upperLabel.center = upperCenter
        self.upperLabel.text! = "\(themes.getCurrencyCode())\(Int(self.lableSlider.upperValue))"
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func configureLabelSlider() {
        
        NSLog ("minimum price=%f and maximum price =%f",minimumpriceval.floatValue,maximumpriceval.floatValue)
        self.lableSlider.minimumValue = 0;
        self.lableSlider.maximumValue = maximumpriceval.floatValue;
        
        
        self.lowerLabel.text! = "\(themes.getCurrencyCode())\(Int(minimumpriceval.floatValue))"
        
        
        self.lableSlider.lowerValue = 0;
        self.lableSlider.upperValue = maximumpriceval.floatValue;
        self.upperLabel.text! = "\(themes.getCurrencyCode())\(Int(maximumpriceval.floatValue))"
        
        
        
        self.lableSlider.minimumRange = 5;
    }
    @IBAction func slidervaluechange(_ sender: NMRangeSlider) {
        
        self.updateSliderLabels()
    }
    @IBAction func didclickoption(_ sender: AnyObject) {
        if sender.tag == 0
        {
            self.Callcanceldelegate()
        }
        else if sender.tag == 1
        {
            // NSLog("Get maximum value=%@", "\(Int(self.lableSlider.upperValue))")
            self.delegate?.passParametres(Ratcount, Priceval:"\(Int(self.lableSlider.lowerValue))",MaxPrice: "\(Int(self.lableSlider.upperValue))",distancefilter: kiloMeter_txt.text!)
            self.delegate?.pressedCancel(self)
        }
        
        //            if kiloMeter_txt.text <= "0" {
        ////                self.view.makeToast(message: "Kindly enter above 0 KM", duration: 3, position: HRToastActivityPositionDefault, title: Appname)
        //                themes.AlertView("\(Appname)",Message: "Kindly enter abov 0 KM",ButtonTitle: kOk)
        //
        //            }
        //            else{
        //
        //            }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        kiloMeter_txt.resignFirstResponder()
        return true;
    }
    func Done_Toolbar()
    {
        
        //ADD Done button for Contatct Field
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        doneToolbar.backgroundColor=UIColor.white
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: themes.setLang("done"), style: UIBarButtonItemStyle.done, target: self, action: #selector(PopupFilterViewController.doneButtonAction))
        doneToolbar.items = [flexSpace,done]
        
        doneToolbar.sizeToFit()
        
        kiloMeter_txt.inputAccessoryView = doneToolbar
        
    }
    func Callcanceldelegate()
    {
        self.delegate?.pressedCancel(self)
    }
    
    func floatRatingView(_ ratingView: TPFloatRatingView, ratingDidChange rating: CGFloat) {
        
        print("the item changed is \(rating)....\(ratingView.tag)")
        
        //        RatingArray.replaceObjectAtIndex(ratingView.tag, withObject: "\(rating)")
        
    }
    func doneButtonAction()
    {
        kiloMeter_txt.resignFirstResponder()
        
    }
    
    
    func floatRatingView(_ ratingView: TPFloatRatingView, continuousRating rating: CGFloat) {
        Ratcount = rating
        //   RatingArray.replaceObjectAtIndex(ratingView.tag, withObject: "\(rating)")
        
        
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
