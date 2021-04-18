//
//  PopupSortingViewController.swift
//  PlumberJJ
//
//  Created by CASPERON on 10/08/16.
//  Copyright © 2016 Casperon Technologies. All rights reserved.
//

import UIKit
protocol PopupSortingViewControllerDelegate {
    
    func pressedCancel(_ sender: PopupSortingViewController)
    
    
    
    func  passRequiredParametres(_ fromdate:NSString,todate: NSString,isAscendorDescend: Int,isToday:Int,isSortby: NSString)
    
    
}


class PopupSortingViewController: UIViewController {
    
    @IBOutlet var applyview: SetColorView!
    var selecIndex:Int!
    @IBOutlet var datecheckmark: UIImageView!
    @IBOutlet var namecheckmark: UIImageView!
    @IBOutlet var datebtn: UIButton!
    @IBOutlet var Namebtn: UIButton!
    var delegate:PopupSortingViewControllerDelegate?
    var Globalindex:NSString=NSString()
    var dates: NSMutableArray!
    var convertDatesArr : NSMutableArray!
    var statusoforder : Int = 0
    var todayInt : Int = 3
    var statusofsorting : NSString = NSString()
    var fromBtnisClicked : Bool!
    var toBtnisClicked :Bool!
    var fromDateval : NSString = NSString()
    var todateval : NSString = NSString()
    var themes:Themes=Themes()
    @IBOutlet weak var lbSorting: UILabel!
    
    
    @IBOutlet var checkmark2: UIImageView!
    @IBOutlet var checkmark1: UIImageView!
    
    @IBOutlet var checkmark3: UIImageView!
    @IBOutlet var checkmark4: UIImageView!
    @IBOutlet var checkmark5: UIImageView!
    @IBOutlet var btnToday: UIButton!
    @IBOutlet var btnRecent: UIButton!
    @IBOutlet var btnUpcoming: UIButton!
    
    @IBOutlet var filterbylabl: UILabel!
    
    @IBOutlet var orderbylabl: UILabel!
    @IBOutlet var ascendingbtn: UIButton!
    @IBOutlet var cancel: UIButton!
    
    @IBOutlet var applybtn: UIButton!
    @IBOutlet var Desendingbtn: UIButton!
    
    @IBOutlet var todate: UIButton!
    @IBOutlet var fromdate: UIButton!
    
    var datePicker1: SUSDatePickerView!
    
    @IBAction func didclickoption(_ sender: AnyObject) {
        
        if sender.tag == 0
        {
            self.Callcanceldelegate()
        }
        else   if sender.tag == 1
        {
            
            if let view = datePicker1 {
                view.removeFromSuperview()
            }
            datePicker1 = SUSDatePickerView(frame:self.view.bounds, delegate:self, mode: UIDatePickerMode.date, button:sender as! UIButton)
            
            self.view.addSubview(datePicker1!)
            themes.MakeAnimation(view: datePicker1, animation_type: CSAnimationTypePopAlpha)

            
        }
        else    if sender.tag == 10
        {
            statusofsorting = "name"
            namecheckmark.isHidden = false
            datecheckmark.isHidden = true
            
        }
        else   if   sender.tag == 11
        {
            statusofsorting = "date"
            namecheckmark.isHidden = true
            datecheckmark.isHidden = false
            
            
        }
        else     if sender.tag == 2
        {
            if let view = datePicker1 {
                view.removeFromSuperview()
            }
            datePicker1 = SUSDatePickerView(frame:self.view.bounds, delegate:self, mode: UIDatePickerMode.date, button:sender as! UIButton)
            self.view.addSubview(datePicker1!)
            themes.MakeAnimation(view: datePicker1, animation_type: CSAnimationTypePopAlpha)
        }
            
        else    if sender.tag == 3
        {
            
            statusoforder = 1
            checkmark1.isHidden = false
            checkmark2.isHidden = true
        }
        else   if sender.tag == 4
        {
            
            statusoforder = -1
            checkmark1.isHidden = true
            checkmark2.isHidden = false
        }else if(sender.tag == 5){
            fromdate.isEnabled = false
            todate.isEnabled = false
            fromdate.alpha = 0.5
            todate.alpha = 0.5
            
            checkmark3.isHidden = false
            checkmark4.isHidden = true
            checkmark5.isHidden = true
            todayInt = 0
        }else if(sender.tag == 6){
            fromdate.isEnabled = false
            todate.isEnabled = false
            fromdate.alpha = 0.5
            todate.alpha = 0.5
            
            checkmark3.isHidden = true
            checkmark4.isHidden = false
            checkmark5.isHidden = true
            todayInt = 1
        }else if(sender.tag == 7){
            fromdate.isEnabled = false
            todate.isEnabled = false
            fromdate.alpha = 0.5
            todate.alpha = 0.5
            
            checkmark3.isHidden = true
            checkmark4.isHidden = true
            checkmark5.isHidden = false
            todayInt = 2
        }
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        lbSorting.text = themes.setLang("sorting")
        fromdate.setTitle(themes.setLang("from_date"), for: UIControlState())
        todate.setTitle(themes.setLang("to_date"), for: UIControlState())
        orderbylabl.text = themes.setLang("order_by")
        ascendingbtn.setTitle(themes.setLang("ascending"), for: UIControlState())
        Desendingbtn.setTitle(themes.setLang("descending"), for: UIControlState())
        applybtn.setTitle(themes.setLang("apply"), for: UIControlState())
    }
    
    @IBAction func didapplybtnclick(_ sender: AnyObject) {
        
        //        if fromDateval == ""
        //        {
        //
        //            self.themes.AlertView("", Message: "Please select  date", ButtonTitle: "Ok")
        //
        //
        //        }
        //        else if todateval == ""
        //        {
        //            self.themes.AlertView(" ", Message: "Please Select date ", ButtonTitle: "Ok")
        //
        //        }
        //
        //        else
        //        {
        self.delegate?.passRequiredParametres((fromdate.titleLabel?.text)! as NSString, todate: (todate.titleLabel?.text)! as NSString, isAscendorDescend: statusoforder ,isToday:todayInt,isSortby :"date")
        self.delegate?.pressedCancel(self)
        //  }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterbylabl.text = themes.setLang("sort_by")
        btnToday.setTitle(themes.setLang("today_book"), for: UIControlState())
        btnRecent.setTitle(themes.setLang("recent_Book"), for: UIControlState())
        btnUpcoming.setTitle(themes.setLang("upcome_book"), for: UIControlState())
        
        fromdate.isEnabled = true
        todate.isEnabled = true
        
        if (selecIndex == 1){
            btnToday.isEnabled = false
            btnToday.alpha = 0.5
            btnUpcoming.alpha = 0.5
            btnRecent.alpha = 0.5
            
            btnUpcoming.isEnabled = false
            btnRecent.isEnabled = false
            
        }else if selecIndex == 0{
            btnToday.alpha = 1
            btnUpcoming.alpha = 1
            btnRecent.alpha = 1
            
            btnToday.isEnabled = true
            btnUpcoming.isEnabled = true
            btnRecent.isEnabled = true
            
        }
        
        let startDate: Date = Date(timeIntervalSinceNow: -60 * 60 * 24 * 20)
        let endDate: Date = Date(timeIntervalSinceNow:60 * 60 * 24 * 19)
        dates = [startDate]
        let gregorianCalendar: Calendar = Calendar(identifier: .gregorian)
        let components: DateComponents = (gregorianCalendar as NSCalendar).components(.day, from: startDate, to: endDate, options:[])
        //  gregorianCalendar.components(NSDayCalendarUnit, fromDate: startDate, toDate: endDate, options: []
        for i in 1..<components.day! {
            var newComponents: DateComponents = DateComponents()
            newComponents.day = i
            let date: Date = (gregorianCalendar as NSCalendar).date(byAdding: newComponents, to: startDate, options: [])!
            
            dates.add(date)
        }
        dates.add(endDate)
        convertDatesArr = NSMutableArray()
        
        for i in 0..<dates.count
        {
            convertDatesArr .add(self.stringDatePartOf(dates.object(at: i) as! Date))
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    func distance()
    {
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func Callcanceldelegate()
    {
        self.delegate?.pressedCancel(self)
    }
    
    //    (NSString*) stringDatePartOf:(NSDate*)date
    //    {
    //    NSDateFormatter *formatter = [[NSDateFormatter new];
    //    [formatter setDateFormat:@"yyyy-MM-dd"];
    //
    //    return [formatter stringFromDate:date];
    //    }
    
    func stringDatePartOf (_ date :Date) -> NSString {
        let formatter: DateFormatter =
            DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date) as NSString
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return convertDatesArr.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView) -> UIView? {
        var tView: UILabel = (view as! UILabel)
        
        tView = UILabel()
        tView .text = convertDatesArr[row] as? String
        tView.font = UIFont(name:"Roboto",size:14 )
        tView.textAlignment = .center
        return tView
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        orderbylabl.isHidden = false;
        ascendingbtn.isHidden = false;
        Desendingbtn.isHidden = false;
        applyview.isHidden = false
        
        if fromBtnisClicked == true
        {
            fromDateval = (convertDatesArr[row] as? String)! as NSString
            fromdate.setTitle(convertDatesArr[row] as? String, for:UIControlState())
        }
        if toBtnisClicked == true
        {
            todateval = (convertDatesArr[row] as? String)! as NSString
            
            todate.setTitle(convertDatesArr[row] as? String, for:UIControlState())
            
        }
        
        
    }
    
    
}

extension PopupSortingViewController:DatePickerDelegate{
    func dateSelectedInDatePicker(_ datePicker:SUSDatePickerView,selectedDate:Date, button:UIButton) {
        themes.MakeAnimation(view: datePicker, animation_type: CSAnimationTypePopAlphaOut as String)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            datePicker.removeFromSuperview()
        })
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        _ = formatter.string(from: selectedDate)
        button.setTitle(formatter.string(from: selectedDate), for: UIControlState())
    }
    
}
