

import UIKit
protocol DatePickerDelegate {
    func dateSelectedInDatePicker(_ datePicker:SUSDatePickerView,selectedDate:Date, button : UIButton)
}
class SUSDatePickerView: CSAnimationView {
    var button : UIButton?
    var delegate : DatePickerDelegate?
    var datePicker : UIDatePicker = UIDatePicker()
    var dateLbl = UILabel()
    var datePickerMode : UIDatePickerMode? {
        didSet {
            self.datePicker.datePickerMode = datePickerMode!
        }
    }
    
    convenience init(frame:CGRect, delegate:DatePickerDelegate, mode:UIDatePickerMode, button:UIButton) {
        self.init(frame:frame)
        self.delegate = delegate
        self.button = button
        self.datePickerMode = mode
        addDatePicker(mode)
    }
    override init(frame:CGRect) {
        super.init(frame:frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addDatePicker(_ mode:UIDatePickerMode) {
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        let subView = UIView(frame:
            CGRect(
                x: self.center.x,
                y: self.center.y,
                width: self.frame.size.width-10,
                height: self.frame.size.height/2+10)
        )
        
        subView.center = self.center
        subView.backgroundColor = PlumberThemeColor
        subView.layer.borderWidth = 1
        subView.layer.cornerRadius = 10.0
        
        let sep1 = UIView(frame: CGRect(x: 1, y: subView.frame.width/6, width: subView.frame.width, height: 2))
        sep1.backgroundColor = UIColor.white
        
        let sep2 = UIView(frame: CGRect(x: 1,y: (subView.frame.width)-(subView.frame.width/4.5), width: subView.frame.width, height: 2))
        sep2.backgroundColor = UIColor.white
        
        let sep3 = UIView(frame: CGRect(x: sep2.frame.width/2,y: sep2.center.y, width: 2,height: subView.frame.height-sep2.center.y))
        
        sep3.backgroundColor = UIColor.white
        
        subView.addSubview(sep1)
        subView.addSubview(sep2)
        subView.addSubview(sep3)
        
        dateLbl.frame = CGRect(x: 1,y: 1, width: subView.frame.width,height: sep1.center.y)
        dateLbl.text = themes.setLang("date")
        dateLbl.textAlignment = NSTextAlignment.center
        dateLbl.textColor = UIColor.white
        subView.addSubview(dateLbl)
        
        datePicker = UIDatePicker()
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = mode
        if mode == UIDatePickerMode.date {
            datePicker.maximumDate = Date()
        }
        
        datePicker.addTarget(self, action: #selector(SUSDatePickerView.didChange(_:)), for: UIControlEvents.valueChanged)
        datePicker.frame = CGRect(x: 0, y: sep1.center.y,width: subView.frame.width,height: sep2.center.y-sep1.center.y )
        subView.addSubview(datePicker)
        
        let backBTn = UIButton(frame: CGRect(x: 1, y: sep2.center.y, width: sep3.center.x,height: sep3.frame.height))
        backBTn.setTitle(themes.setLang("Back"), for: UIControlState())
        backBTn.addTarget(self, action:#selector(SUSDatePickerView.cancelButtonClicked(_:)), for: UIControlEvents.touchUpInside)
        subView.addSubview(backBTn)
        
        let setBTn = UIButton(frame: CGRect(x: sep3.center.x,y: sep2.center.y,width: sep3.center.x, height: sep3.frame.height))
        setBTn.setTitle(themes.setLang("Set"), for: UIControlState())
        setBTn.addTarget(self, action:#selector(SUSDatePickerView.doneButtonClicked(_:)), for: UIControlEvents.touchUpInside)
        subView.addSubview(setBTn)
        
        self.addSubview(subView)

        
        }

    func didChange(_ sender:UIDatePicker){
        _ = sender.date;
        let dateformater = DateFormatter()
        if self.datePickerMode == UIDatePickerMode.date {
            dateformater.dateFormat = "dd-MM-yyyy"
        } else if self.datePickerMode == UIDatePickerMode.time {
            dateformater.dateFormat = "hh:mm a"
        }
        let fdate = dateformater.string(from: datePicker.date)
        dateLbl.text = fdate;
    }
 
    func doneButtonClicked(_ sender:UIButton) {
        if let deleg = self.delegate, let button = self.button {
            deleg.dateSelectedInDatePicker(self, selectedDate: datePicker.date, button : button)
        }
    }
    func cancelButtonClicked(_ sender:UIButton) {
        themes.MakeAnimation(view: self, animation_type: CSAnimationTypePopAlphaOut)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.removeFromSuperview()
        })
    }
    //    func addDatePicker(mode:UIDatePickerMode) {
    //        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    //        datePicker.backgroundColor = UIColor.whiteColor()
    //        datePicker.layer.borderColor = UIColor.darkGrayColor().cgColor
    //        datePicker.layer.borderWidth = 2.0
    //        datePicker.center = self.center
    //        datePicker.frame.size = CGSizeMake(frame.width,300)
    //        datePicker.datePickerMode = mode
    //        if mode == UIDatePickerMode.Date {
    //            datePicker.minimumDate = NSDate()
    //        }
    //
    //        var done = UIButton(frame: CGRectMake(datePicker.frame.origin.x, datePicker.frame.origin.y + datePicker.bounds.height, bounds.width/2 - 1, 40))
    //        done.setTitle("Done", forState: UIControlState.Normal)
    //        done.addTarget(self, action: Selector("doneButtonClicked:"), forControlEvents: UIControlEvents.TouchUpInside)
    //        done.backgroundColor = UIColor.darkGrayColor()
    //        addSubview(done)
    //
    //        var cancel = UIButton(frame: CGRectMake(bounds.width/2 + 1, datePicker.frame.origin.y + datePicker.bounds.height, bounds.width/2, 40))
    //        cancel.setTitle("Cancel", forState: UIControlState.Normal)
    //        cancel.addTarget(self, action: Selector("cancelButtonClicked:"), forControlEvents: UIControlEvents.TouchUpInside)
    //        cancel.backgroundColor = UIColor.darkGrayColor()
    //        addSubview(cancel)
    //
    //        addSubview(datePicker)
    //
    //    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
}

