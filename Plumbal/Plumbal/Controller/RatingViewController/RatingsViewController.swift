//
//  RatingsViewController.swift
//  PlumberJJ
//
//  Created by Casperon Technologies on 12/11/15.
//  Copyright © 2015 Casperon Technologies. All rights reserved.
//


import UIKit
import AssetsLibrary
import Foundation
import Alamofire



class RatingsViewController: RootViewController, UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ratingsDelegate {
    
    @IBOutlet var name_Lbl: CustomLabel!
    @IBOutlet var Review_title: UILabel!
    
    @IBOutlet var Provider_image: UIImageView!
    @IBOutlet weak var btnSkip: UIButton!
    
    @IBOutlet weak var lblRating: UILabel!

    
    @IBOutlet var addservicebtn: UIButton!
    @IBOutlet var service_image: UIImageView!
     var jobIDStr:NSString!
    @IBOutlet weak var ratingBtn: UIButton!
    var url_handler:URLhandler=URLhandler()
    let imagePicker = UIImagePickerController()
    //var theme:Theme=Theme()
    var get_imagedata : Data = Data()
    var get_pickerimage: UIImage?
  var themes:Themes=Themes()
    var ratingsOptArr:NSMutableArray = [];
    @IBOutlet weak var reviewTxtView: UITextView!
    @IBOutlet weak var reviewTblView: UITableView!
    override func viewDidLoad() {
        self.ratingBtn.isHidden=true
        super.viewDidLoad()
        
        lblRating.text = themes.setLang("rating")
        btnSkip.setTitle(themes.setLang("skip"), for: UIControlState())
        Review_title.text = themes.setLang("review")
        ratingBtn.setTitle(themes.setLang("submit"), for: UIControlState())
        reviewTxtView.font = PlumberMediumBoldFont
        NSLog("frame x =%f, frame  y=%f , frame width=%f , frame height =%f",self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height)
        Provider_image.layer.cornerRadius=Provider_image.frame.size.width/2
        Provider_image.clipsToBounds=true
       // Provider_image.layer.borderWidth=1.0
       // Provider_image.layer.borderColor = theme.Lightgray().cgColor
        

        imagePicker.delegate=self
        reviewTxtView.layer.cornerRadius=5
        reviewTxtView.layer.borderWidth=1
        reviewTxtView.delegate = self
        //reviewTxtView.layer.borderColor=PlumberLightGrayColor.cgColor
        reviewTxtView.layer.masksToBounds=true
        reviewTblView.register(UINib(nibName: "RatingsTableViewCell", bundle: nil), forCellReuseIdentifier: "RatingCellIdentifier")
        reviewTblView.estimatedRowHeight = 95
        reviewTblView.rowHeight = UITableViewAutomaticDimension
        reviewTblView.tableFooterView = UIView()
        GetRatingsOption()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didclickimage(_ sender: AnyObject) {
        let ImagePicker_Sheet = UIAlertController(title: nil, message: themes.setLang("select_image")
            , preferredStyle: .actionSheet)
        
        let Camera_Picker = UIAlertAction(title:themes.setLang("camera"), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.Camera_Pick()
        })
        let Gallery_Picker = UIAlertAction(title: themes.setLang("gallery"), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            //
            self.Gallery_Pick()
            
        })
        
        let cancelAction = UIAlertAction(title: themes.setLang("cancel"), style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        ImagePicker_Sheet.addAction(Camera_Picker)
        ImagePicker_Sheet.addAction(Gallery_Picker)
        ImagePicker_Sheet.addAction(cancelAction)
        
        self.present(ImagePicker_Sheet, animated: true, completion: nil)
    }
    
    func Camera_Pick()
    {
        
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .camera
            self.imagePicker.modalPresentationStyle = .popover
            self.present(self.imagePicker, animated: true, completion: nil)
        }
            
        else
        {
            Gallery_Pick()
        }
    }
    
    func Gallery_Pick()
    {
        
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.modalPresentationStyle = .popover
        self.present(self.imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //handle media here i.e. do stuff with photo
        
        picker.dismiss(animated: true, completion: nil)
        let url = info[UIImagePickerControllerReferenceURL]
        
        
        
        
        if (url !=  nil)
        {
            
            let pickimage = self.themes.rotateImage (info[UIImagePickerControllerOriginalImage] as! UIImage)
            get_pickerimage = UIImage.init(cgImage: pickimage.cgImage!, scale: 0.25 , orientation:.up)
            
            get_imagedata = UIImageJPEGRepresentation(get_pickerimage! ,0.1)!
            
            service_image .image = info[UIImagePickerControllerOriginalImage] as? UIImage
            //data!.writeToFile(localPath, atomically: true)
            
        }
        else
        {
            
            let pickimage = self.themes.rotateImage (info[UIImagePickerControllerOriginalImage] as! UIImage)
           get_pickerimage = UIImage.init(cgImage: pickimage.cgImage!, scale: 0.25 , orientation:.up)

            get_imagedata = UIImageJPEGRepresentation(get_pickerimage! ,0.1)!
            
            service_image .image = info[UIImagePickerControllerOriginalImage] as? UIImage
            
        }
        
        
    }
    
       
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //what happens when you cancel
        //which, in our case, is just to get rid of the photo picker which pops up
        picker.dismiss(animated: true, completion: nil)
    }

    
    func GetRatingsOption(){
        
      
         let Param:NSDictionary=["holder_type":"user", "user":self.themes.getUserID(),"job_id":Root_Base.Job_ID]
       
        self.showProgress()
        url_handler.makeCall(constant.Get_rating, param: Param) {
            (responseObject, error) -> () in
            
            self.DismissProgress()
            if(error != nil)
            {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
            }
            else
            {
                if(responseObject != nil && (responseObject?.count)!>0)
                {
                    let status=self.themes.CheckNullValue(responseObject?.object(forKey: "status"))!
                    if(status == "1")
                    {
                        let  listArr:NSArray=(responseObject?.object(forKey: "review_options") as? NSArray)!
                        self.Review_title.text = self.themes.CheckNullValue((listArr[0] as AnyObject).object(forKey: "option_name"))!
                        self.name_Lbl.text = self.themes.CheckNullValue((listArr[0] as AnyObject).object(forKey: "name"))!
                        if(listArr.count>0){
                             self.ratingBtn.isHidden=false
                            
                            for (_, element) in listArr.enumerated() {
                                let result1:RatingsRecord=RatingsRecord()
                                result1.title=self.themes.CheckNullValue((element as AnyObject).object(forKey: "option_name"))!
                                let optionInt : Int = ((element as AnyObject).object(forKey: "option_id")) as! Int
                                let strOptionId = "\(optionInt)"
                                result1.optionId=self.themes.CheckNullValue(strOptionId)!
                                
                                self.Provider_image.sd_setImage(with: URL(string:self.themes.CheckNullValue((element as AnyObject).object(forKey: "image"))!), placeholderImage: UIImage(named: "PlaceHolderSmall"))

                                //result1.optionId=self.theme.CheckNullValue(element.objectForKey("option_id"))!
                                result1.rateCount = "0"
                                self.ratingsOptArr .add(result1)
                            }
                            
                            
                            
                        }else{
                            self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                        }
                        self.reviewTblView.reload()
                        //This code will run in the main thread:
                    }
                    else
                    {
                        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    }
                }
                else
                {
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                }
            }
            
        }
    }
    
    func SaveUserRatings(){
       
        if(reviewTxtView.text == "" )
            
        {
            
            themes.AlertView("\(Appname)", Message: themes.setLang("enter_comment"), ButtonTitle: kOk)
        }
        else
        {
            
          
           if get_pickerimage == nil
        
           {
            
            
            
            
            let Param:NSDictionary = self.dictForrating()

            
            self.showProgress()
            url_handler.makeCall(constant.Post_rating, param: Param) {
                (responseObject, error) -> () in
                
                self.DismissProgress()
                if(error != nil)
                {
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                }
                else
                {
                    if(responseObject != nil && (responseObject?.count)!>0)
                    {
                        let status=self.themes.CheckNullValue(responseObject?.object(forKey: "status"))!
                        if(status == "1")
                        {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                        else
                        {
                            self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                        }
                    }
                    else
                    {
                        self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    }
                }
                
            }

            
            }
            
            else
           {
        
                let param : NSDictionary =  self.dictForrating()
                
                 NSLog("getDevicetoken =%@", self.dictForrating())
                self.showProgress()
            
            let URL = try! URLRequest(url: constant.Post_rating, method: .post, headers: ["apptype": "ios", "apptoken":"\(Device_Token)", "userid":"\(themes.getUserID())"])
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                
                multipartFormData.append(self.get_imagedata, withName: "file", fileName: "file.png", mimeType: "")
                
                for (key, value) in param {
                    
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key as! String)
                }
                
            }, with: URL, encodingCompletion: { encodingResult in
                
                
                switch encodingResult {
                    
                case .success(let upload, _, _):
                    print("s")
                    
                    upload.responseJSON { response in
                        
                        
                        if let JSON = response.result.value {
                            
                            self.DismissProgress()
                            print("JSON: \(JSON)")
                            let Status = self.themes.CheckNullValue((JSON as AnyObject).object(forKey:"status"))!
                            let response:NSDictionary = (JSON as AnyObject).object(forKey:"response") as! NSDictionary
                            if(Status == "1")
                            {
                                
                                
                                //        self.view.makeToast(message:self.themes.CheckNullValue(response.objectForKey("msg"))!, duration: 4, position: HRToastPositionCenter, title: "")
                                
                                //   self.Dismiss_View()
                                self.navigationController?.popToRootViewController(animated: true)
                                //                                        let Controller:OrderDetailViewController=self.storyboard?.instantiateViewControllerWithIdentifier("OrderDetail") as! OrderDetailViewController
                                //                                        self.navigationController?.pushViewController(withFlip: Controller, animated: true)
                                
                            }
                            else
                            {
                                  self.DismissProgress()
                                //  self.themes.AlertView("Image Upload Failed", Message: "Please try again", ButtonTitle: "Ok")
                                
                                self.themes.AlertView("\(Appname)", Message:self.themes.CheckNullValue(response.object(forKey: "msg"))!, ButtonTitle: kOk)
                                
                                
                                
                            }
                            
                            
                            
                            
                            
                            
                        }
                    }
                case .failure(let encodingError):
                    self.DismissProgress()
                    print(" the encodeing error is \(encodingError)")
                    
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                }
 })
            }
            
            
            
            
            
            
        
        }
       
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ratingsOptArr.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->     UITableViewCell {
        let cell:RatingsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RatingCellIdentifier") as! RatingsTableViewCell
        cell.objIndexPath=indexPath
        cell.loadRateTableCell(ratingsOptArr.object(at: indexPath.row) as! RatingsRecord)
        cell.delegate=self
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        return cell
    }
    
    @IBAction func didClickBackbtn(_ sender: AnyObject) {
    
       // self.Dismiss_View()
        self.navigationController?.popToRootViewController(animated: true)

    }
    
    func Dismiss_View()
    {
        self.dismiss(animated: true, completion: nil)
        
    }

    @IBAction func didClickRateUserBtn(_ sender: AnyObject) {
        themes.AlertView("\(Appname)", Message:themes.setLang("rating_submit"), ButtonTitle: kOk)
        SaveUserRatings()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dictForrating()->NSDictionary{
        var cmtstr:NSString=""
        if(reviewTxtView.text=="Review"){
            cmtstr=""
        }else{
            cmtstr=reviewTxtView.text as NSString
        }
        
        let reviewDict:NSMutableDictionary=NSMutableDictionary()
        
        var ratingDict : NSDictionary = NSDictionary()
        var ratingarray : NSMutableArray = NSMutableArray()
       
        for i in 0 ..< ratingsOptArr.count {

            let objRatingsRecs: RatingsRecord = ratingsOptArr[i] as! RatingsRecord
        
             ratingDict =  [ "rating": objRatingsRecs.rateCount, "option_id": objRatingsRecs.optionId, "option_title":objRatingsRecs.title ]
            ratingarray.add(ratingDict)
        }
        
         reviewDict.setValue(ratingarray, forKey: "ratings")
        reviewDict.setValue("user", forKey: "ratingsFor")
        reviewDict.setValue(Root_Base.Job_ID, forKey: "job_id")
        reviewDict.setValue(cmtstr, forKey: "comments")
        reviewDict.setValue("ios", forKey: "type") 

        

        return reviewDict
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(range.location==0 && text==" "){
            return false
        }
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    func ratingsCount(_ withRateVal:Float , withIndex:IndexPath){
        
        let objRatingsRecs: RatingsRecord = ratingsOptArr[withIndex.row] as! RatingsRecord
        objRatingsRecs.rateCount = "\(withRateVal)"
        ratingsOptArr.replaceObject(at: withIndex.row, with: objRatingsRecs)
       
        self.reviewTblView.beginUpdates()
        self.reviewTblView.reloadRows(at: [withIndex], with: .none)
        self.reviewTblView.endUpdates()
    }
    
 
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
