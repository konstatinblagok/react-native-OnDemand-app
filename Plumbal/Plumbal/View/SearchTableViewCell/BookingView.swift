//
//  BookingView.swift
//  Plumbal
//
//  Created by Casperon iOS on 15/3/2017.
//  Copyright © 2017 Casperon Tech. All rights reserved.
//

import UIKit
protocol BookingViewDelegate {
    
    func pressedCancel(_ sender: BookingView)
    func pressBooking (_ confimDate: NSString, Confirmtime : NSString, Instructionstr: NSString)
    
}


class BookingView: UIViewController,UITextViewDelegate {

    @IBOutlet var lblbookingDate: UILabel!
    @IBOutlet var lblBookingTime: UILabel!
    @IBOutlet var lblTaskerName: UILabel!
    @IBOutlet var titleHeader: UILabel!
    var taskernamestr : String = ""
    @IBOutlet var cancel: UIButton!
    @IBOutlet var confirm: UIButton!
    @IBOutlet var bottomview: SetColorView!
    @IBOutlet var instruction: UITextView!
    @IBOutlet var bookingdate: UILabel!
    @IBOutlet var bookingtime: UILabel!
    @IBOutlet var taskername: UILabel!
   
    
    var TextViewPlaceHolder = ""
    var hourtime : String = String()
    var railywaytime :String = String()
    var delegate:BookingViewDelegate?

    @IBAction func confirmBooking(_ sender: AnyObject) {
        if instruction.text! == TextViewPlaceHolder
        {
            themes.AlertView("\(Appname)", Message:"\(themes.setLang("enter_instruc"))", ButtonTitle: kOk)

        }
        else{
        self.delegate?.pressBooking(bookingdate.text! as NSString,Confirmtime: railywaytime as NSString,Instructionstr: instruction.text! as NSString)
        }
    }
    
    @IBAction func cancelbooking(_ sender: AnyObject) {
        self.delegate?.pressedCancel(self)

    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.view.layer.cornerRadius = 5
        view.layer.borderWidth=1.0
        view.layer.borderColor=themes.ThemeColour().cgColor
        self.view.layer.masksToBounds = true
        titleHeader.text = themes.setLang("job_confirmation")
lblTaskerName.text = themes.setLang("user_name")
        lblBookingTime.text = themes.setLang("book_time")
        lblbookingDate.text = themes.setLang("book_date")
        confirm.setTitle(themes.setLang("confirm_book"), for: UIControlState())
        cancel.setTitle(themes.setLang("cancel_book"), for: UIControlState())
confirm.titleLabel?.adjustsFontSizeToFitWidth = true
        
        TextViewPlaceHolder=themes.setLang("enter_instruc")

        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MM/dd/yyyy"
        
        let result = formatter.string(from: date)
        
        formatter.dateFormat = "HH:mm"
        railywaytime  = formatter.string(from: date)
        
        formatter.dateFormat = "h:mm a"
        hourtime = formatter.string(from: date)
        
        bookingdate.text = result
        self.bookingtime.text = hourtime.lowercased()
        self.taskername.text = taskernamestr as String
        
        
        if( self.instruction.text == "") {
            self.instruction.text=TextViewPlaceHolder
        }
        instruction.delegate=self
        instruction.layer.borderWidth=1.0
        instruction.layer.cornerRadius = 5
        instruction.layer.borderColor=PlumberThemeColor.cgColor
        instruction.font=PlumberMediumFont
        
         bottomview.layer.cornerRadius = 5
        bottomview.layer.masksToBounds = true
        

        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewDidLoad() {
        
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
      
        if(instruction.text == TextViewPlaceHolder) {
            instruction.textColor=UIColor.black
            instruction.text=""
        }
        return true
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
     
        if(instruction.text == "") {
            instruction.textColor=PlumberThemeColor
            instruction.text=TextViewPlaceHolder
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
