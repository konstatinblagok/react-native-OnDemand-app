//
//  OrderConfirmationViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 02/11/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit
import CoreData

class OrderConfirmationViewController: RootViewController {
    var dbfileobj: DBFile!
 var  managedObjectContext :NSManagedObjectContext!
    var dataArray : NSMutableArray!
    var appDelegate : AppDelegate!

    @IBOutlet var Order_ID_Label: UILabel!

    @IBOutlet var orderdate: UILabel!
    @IBOutlet var Order_Header_Lbl: UILabel!
    @IBOutlet var Done_Btn: CustomButton!
     @IBOutlet var WeAlloc_Lbl: UILabel!
    @IBOutlet var OrderConf_Lbl: UILabel!
     @IBOutlet var Plumbing_Lbl: UILabel!
    @IBOutlet var plumbing_desc: UITextView!
    @IBOutlet weak var lblBookingId: UILabel!
    @IBOutlet weak var lblServiceType: UILabel!
    @IBOutlet weak var lblOrderDate: UILabel!

    @IBOutlet weak var lblOder_confirmation: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblOrderDate.text = themes.setLang("order_date")
        lblServiceType.text = themes.setLang("service_type")
        lblBookingId.text = themes.setLang("booking_id")
        OrderConf_Lbl.text = themes.setLang("order_confirm")
        Order_Header_Lbl.text = themes.setLang("congratulation")
        lblOder_confirmation.text = themes.setLang("order_desc")

        Done_Btn.setTitle(themes.setLang("done")
            , for: UIControlState())
        Order_ID_Label.text = Schedule_Data.JobID as String
        plumbing_desc.font = PlumberMediumBoldFont
        plumbing_desc.text = Schedule_Data.jobDescription as String
        Plumbing_Lbl.text = Schedule_Data.service as String
        orderdate.text = Schedule_Data.orderDate as String
        dbfileobj = DBFile()
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        self.managedObjectContext = appDelegate.managedObjectContext
        

        dataArray = dbfileobj.arr("Provider_Table")
        
        
        NSLog("get details from database=%@",dataArray)

        
//        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.width, 50))
//        doneToolbar.barStyle = UIBarStyle.Default
//        doneToolbar.backgroundColor=UIColor.whiteColor()
//        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
//        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("doneButtonAction"))
//        
//        
//        doneToolbar.items = [flexSpace,done]
//        ƒ
//        doneToolbar.sizeToFit()
//        
//        Contact_TextField.inputAccessoryView = doneToolbar


        // Do any additional setup after loading the view.
    }
    
     func applicationLanguageChangeNotification(_ notification:Notification)
    {
        
        lblOrderDate.text = themes.setLang("order_date")
        lblServiceType.text = themes.setLang("service_type")
        lblBookingId.text = themes.setLang("booking_id")
        OrderConf_Lbl.text = themes.setLang("order_confirm")
        Order_Header_Lbl.text = themes.setLang("congratulation")
        Done_Btn.setTitle(themes.setLang("done")
            , for: UIControlState())
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didiClickOption(_ sender: AnyObject) {
        
        if(sender.tag == 0)
        {
            
          //  self.navigationController?.popToRootViewControllerAnimated(true)
           self.performSegue(withIdentifier: "OrderVC", sender: nil)
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
