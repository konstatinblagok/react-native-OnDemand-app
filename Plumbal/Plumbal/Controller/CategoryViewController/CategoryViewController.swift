//
//  CategoryViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 05/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class CategoryViewController: RootViewController,UITableViewDelegate,UIScrollViewDelegate {
    
    @IBOutlet var Category_tableView: UITableView!
    @IBOutlet var Continue_Btn: CustomButton!
    @IBOutlet var Category_name: UILabel!
    @IBOutlet var Back_But: UIButton!
    @IBOutlet var headerView: UIView!
    
    var Category_ImageArray:NSMutableArray=NSMutableArray()
    var imageRect: CGRect=CGRect()
    var Category_ListArray:NSMutableArray=NSMutableArray()
    var Category_List_idArray:NSMutableArray=NSMutableArray()
    var Category_List_imageArray:NSMutableArray=NSMutableArray()
    var Checkmarkindex:NSString=NSString()
    var Check_ChildArray:NSMutableArray=NSMutableArray()
    var block: SDExternalCompletionBlock!
    let themes:Themes=Themes()
    let URL_handler:URLhandler=URLhandler()
    let imageview:UIImageView=UIImageView()
    var refreshControl:UIRefreshControl=UIRefreshControl()
    var Parallax_HeaderView:ParallaxHeaderView=ParallaxHeaderView()
    
    //MARK: Override Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Continue_Btn.setTitle(themes.setLang("continue"), for: UIControlState())

        themes.Back_ImageView.image=UIImage(named: "")
        Back_But.addSubview(themes.Back_ImageView)
        Category_name.text="\(Home_Data.Category_name)"
        themes.Back_ImageView.image=UIImage(named: "")
        let nibName = UINib(nibName: "CategoryTableViewCell", bundle:nil)
        Category_tableView.register(nibName, forCellReuseIdentifier: "Category_Cell")
        Category_tableView.separatorColor=themes.Lightgray()
        block = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: URL!) -> Void in
            if(image != nil) {
                self.Parallax_HeaderView = ParallaxHeaderView.parallaxHeaderView(with: image, for: CGSize(width: self.Category_tableView.frame.size.width, height: 150)) as! ParallaxHeaderView
                self.Category_tableView.tableHeaderView=self.Parallax_HeaderView
                let header: ParallaxHeaderView = self.Category_tableView.tableHeaderView as! ParallaxHeaderView
                header.refreshBlurViewForNewImage()
                self.Category_tableView.tableHeaderView = header
            }
            } as! SDExternalCompletionBlock
        self.Category_tableView.tableFooterView=UIView()
        self.showProgress()
        Category_feed()
        configurePulltorefresh()
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    
    //MARK: Function
    
    func settablebackground() {
        let nibView = Bundle.main.loadNibNamed("RefreshView", owner: self, options: nil)?[0] as! UIView
        nibView.frame = self.Category_tableView.bounds;
        self.Category_tableView.backgroundView=nibView
        
    }
    
    func configurePulltorefresh(){
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(CategoryViewController.Category_feed), for: UIControlEvents.valueChanged)
        self.Category_tableView.addSubview(refreshControl)
    }
    
    func animateTable() {
        Category_tableView.reload()
        let cells = Category_tableView.visibleCells
        let tableHeight: CGFloat = Category_tableView.bounds.size.height
        for i in cells {
            let cell: CategoryTableViewCell = i as! CategoryTableViewCell
            cell.Category_ImageView.transform = CGAffineTransform(translationX: 0, y: tableHeight)
            cell.TitleLabel.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        var index = 0
        for a in cells {
            let cell: CategoryTableViewCell = a as! CategoryTableViewCell
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
                cell.Category_ImageView.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.TitleLabel.transform = CGAffineTransform(translationX: 0, y: 0)
                }, completion: nil)
            index += 1
        }
    }
    
    func applicationLanguageChangeNotification(_ notification:Notification){
        Continue_Btn.setTitle(themes.setLang("continue"), for: UIControlState())
    }
    
    func Category_feed() {
        let param=["category":"\(Home_Data.Category_id)", "location_id":"\(themes.getLocationID())"]
        Continue_Btn.isEnabled=false
        URL_handler.makeCall("\(constant.Get_SubCategories)", param: param as NSDictionary) { (responseObject, error) -> () in
            self.DismissProgress()
            self.Continue_Btn.isEnabled=true
            self.Category_tableView.isHidden=false
            self.refreshControl.endRefreshing()
            if(error != nil) {
                self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                self.settablebackground()
                if(self.Category_List_idArray.count == 0){
                    self.Continue_Btn.isHidden=true
                    self.Parallax_HeaderView.isHidden=true
                }
            }
            else {
                if(responseObject != nil) {
                    let dict:NSDictionary=responseObject!
                    let Status=self.themes.CheckNullValue(dict.object(forKey: "status"))!
                    if(Status == "1") {
                        if(self.Category_List_idArray.count != 0){
                            self.Category_List_idArray.removeAllObjects()
                            self.Category_List_imageArray.removeAllObjects()
                            self.Category_List_imageArray.removeAllObjects()
                            self.Category_ListArray.removeAllObjects()
                            self.Check_ChildArray.removeAllObjects()
                        }
                        self.Continue_Btn.isHidden=false
                        let CategoryArray:NSArray=(responseObject?.object(forKey: "response") as AnyObject).object(forKey: "category") as! NSArray
                        for Dictionary in CategoryArray{
                            let categoryid=(Dictionary as AnyObject).object(forKey: "cat_id") as! String
                            self.Category_List_idArray.add(categoryid)
                            let categoryimage = self.themes.CheckNullValue((Dictionary as AnyObject).object(forKey: "image"))!
                            self.Category_List_imageArray.add(categoryimage)
                            let categoryname=(Dictionary as AnyObject).object(forKey: "cat_name") as! String
                            self.Category_ListArray.add(categoryname)
                            let Check_Child=(Dictionary as AnyObject).object(forKey: "hasChild") as! String
                            self.Check_ChildArray.add(Check_Child)
                            
                        }
                        self.Category_tableView.reload()
                        self.animateTable()
                        self.imageview.sd_setImage(with: URL(string: "\(Home_Data.Category_image)"), completed: self.block)
                        self.Parallax_HeaderView.isHidden=false
                    }   else {
                        if(self.Category_List_idArray.count == 0){
                            self.Continue_Btn.isHidden=true
                            self.Parallax_HeaderView.isHidden=true
                        }
                        self.themes.AlertView("\(Appname)", Message: self.themes.setLang("no_category"), ButtonTitle: kOk)
                        self.settablebackground()
                    }
                }else{
                    if(self.Category_List_idArray.count == 0){
                        self.Continue_Btn.isHidden=true
                        self.Parallax_HeaderView.isHidden=true
                    }
                    self.view.makeToast(message: kErrorMsg, duration: 3, position: HRToastActivityPositionDefault, title: Appname)
                    self.settablebackground()
                }
            }
        }
    }
    
    //MARK: - TableViewDelegate
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height_Cell:CGFloat = self.themes.calculateHeightForString("\(Category_ListArray.object(at: indexPath.row))")
        return height_Cell+50.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Category_List_idArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let Cell:CategoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Category_Cell") as! CategoryTableViewCell
        Cell.selectionStyle=UITableViewCellSelectionStyle.none
        if(Checkmarkindex as String == "\(indexPath.row)"){
            Cell.Checkmark_Image_View.isHidden=false
        }else {
            Cell.Checkmark_Image_View.isHidden=true
        }
        
        Cell.TitleLabel.text="\(Category_ListArray.object(at: indexPath.row))"
        Cell.Category_ImageView.layer.cornerRadius=Cell.Category_ImageView.frame.size.width/2
        Cell.Category_ImageView.clipsToBounds=true
        Cell.Category_ImageView.sd_setImage(with: URL(string: "\(Category_List_imageArray.object(at: indexPath.row))"), completed: themes.block)
        
        return Cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Checkmarkindex="\(indexPath.row)" as NSString
        self.Category_tableView.reload()
        Category_Data.CategoryID="\(Category_List_idArray[indexPath.row])" as NSString
        let Prefcategory : UserDefaults = UserDefaults.standard
        Prefcategory.set((Category_List_idArray[indexPath.row]), forKey:"maincategory")
        if(Check_ChildArray.object(at: indexPath.row) as! NSString == "Yes") {
            Home_Data.Category_name="\(Category_ListArray.object(at: indexPath.row))" as NSString
            Home_Data.Category_id="\("\(Category_List_idArray[indexPath.row])")" as NSString
            let Controller:CategoryViewController=self.storyboard?.instantiateViewController(withIdentifier: "Category1") as! CategoryViewController
            self.navigationController?.pushViewController(withFlip: Controller, animated: true)
        }
    }
    
    
    //MARK: ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(imageview.image != nil) {
            if scrollView == self.Category_tableView {
                let header: ParallaxHeaderView = self.Category_tableView.tableHeaderView as! ParallaxHeaderView
                header.layoutHeaderView(forScrollOffset: scrollView.contentOffset)
                self.Category_tableView.tableHeaderView = header
            }
        }
    }
    
    //MARK: - Button Action
    
    @IBAction func didCiickOption(_ sender: AnyObject) {
        if(sender.tag == 0) {
            self.navigationController?.popViewControllerWithFlip(animated: true)
        }
        if(sender.tag == 1) {
            if(Checkmarkindex != ""){
                self.performSegue(withIdentifier: "ScheduleVC", sender: nil)
            } else {
                themes.AlertView("\(Appname)", Message: themes.setLang("choose_category"), ButtonTitle: kOk)
            }
        }
    }
    
}
