//
//  TaskerListViewController.swift
//  Plumbal
//
//  Created by Casperon on 04/07/17.
//  Copyright © 2017 Casperon Tech. All rights reserved.
//

import UIKit
protocol TaskerListViewControllerDelegate {
    func pressCancel(_ sender: TaskerListViewController)
    func pressSelected (_ Sel_Tasker_Detail: NSDictionary,providername : String)
    func pressMessageVC(_ taskid: String , taskerid : String)
    func pressDetailVC(_ min: String , taskerid : String,hour : String,task_id : String)
    
}

class TaskerListViewController: RootViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet var close_Btn: UIButton!
    @IBOutlet var taskerlist_collectionview: UICollectionView!
    var delegate:TaskerListViewControllerDelegate?
    
    @IBOutlet var swipe_title: UILabel!
    @IBOutlet var taskerlist_title: UILabel!
    @IBAction func cancelbooking(_ sender: AnyObject) {
     self.delegate?.pressCancel(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let nibName = UINib(nibName:"taskerlistCollectionViewCell" , bundle: nil)
        taskerlist_collectionview.register(nibName, forCellWithReuseIdentifier: "taskerlistCollectionViewCell")
        // Do any additional setup after loading the view.
        
        
    }
    
    @IBAction func didclickcancel(_ sender: AnyObject) {
        self.delegate?.pressCancel(self)
    }
    
    override func viewDidLoad() {
        taskerlist_title.text = "\(themes.setLang("tasker_list"))"
        swipe_title.text = "\(themes.setLang("swipetogettasker"))"
       taskerlist_collectionview.delegate = self
        taskerlist_collectionview.dataSource = self
        taskerlist_collectionview.reloadData()
        
    }
    //MARK: - Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      
        return Tasker_Data.overlapTaskersArray.count

      
    }
//   func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//    
//    return CGSizeMake(taskerlist_collectionview.frame.size.width,taskerlist_collectionview.frame.size.height)
//    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  
        let Cell = taskerlist_collectionview.dequeueReusableCell(withReuseIdentifier: "taskerlistCollectionViewCell", for: indexPath) as! taskerlistCollectionViewCell
       // let Cell = taskerlist_collectionview.dequeueReusableCellWithReuseIdentifier("taskercell", forIndexPath: indexPath) as! taskerlistCollectionViewCell
        Cell.frame.size.width = taskerlist_collectionview.frame.size.width
        Cell.frame.size.height = taskerlist_collectionview.frame.size.height
        let strRating = "\((Tasker_Data.overlapTaskersArray.object(at: indexPath.row) as AnyObject).object(forKey: "rating")!)"
        let n = NumberFormatter().number(from: strRating)
        
        if n != nil
        {
            
      
            Cell.taskerRating.emptySelectedImage = UIImage(named: "whitStar")
            Cell.taskerRating.fullSelectedImage = UIImage(named: "whitstartselect")

            Cell.taskerRating.contentMode = UIViewContentMode.scaleAspectFill
            Cell.taskerRating.maxRating = 5
            Cell.taskerRating.minRating = 1
            Cell.taskerRating.rating = CGFloat(n!)
            Cell.taskerRating.editable = false;
            Cell.taskerRating.halfRatings = true;
            Cell.taskerRating.floatRatings = false;
        }
        
        
        
        Cell.content.layer.shadowOffset = CGSize(width: 2, height: 2)
        // Cell.totalview.layer.cornerRadius=14;
        Cell.content.layer.shadowOpacity = 0.2
        Cell.content.layer.shadowOffset = CGSize(width: 2, height: 2)
        Cell.chatBtn.layer.cornerRadius = 5
        Cell.chatBtn.layer.masksToBounds = true
        
        
        Cell.viewBtn.layer.cornerRadius = 5
        Cell.viewBtn.layer.masksToBounds = true
        Cell.select_tasker.text = "\(themes.setLang("select_tasker"))"
        Cell.close.text = "\(themes.setLang("close"))"
        Cell.chatBtn.setTitle("\(themes.setLang("chat_space"))", for: UIControlState())
         Cell.viewBtn.setTitle("\(themes.setLang("detail"))", for:UIControlState())
        
        Cell.selectBtn.tag = indexPath.row
        Cell.selectBtn.addTarget(self, action: #selector(TaskerListViewController.selectTasker(_:)), for: UIControlEvents.touchUpInside)
        Cell.cancelBtn.tag = indexPath.row
        Cell.cancelBtn.addTarget(self, action: #selector(TaskerListViewController.cancelmethod(_:)), for: UIControlEvents.touchUpInside)
        
        Cell.chatBtn.tag=indexPath.row
        Cell.chatBtn.addTarget(self, action: #selector(TaskerListViewController.PushtoMessageView(_:)), for: UIControlEvents.touchUpInside)
        Cell.viewBtn.tag=indexPath.row
        Cell.viewBtn.addTarget(self, action: #selector(TaskerListViewController.PushtodetailView(_:)), for: UIControlEvents.touchUpInside)
        
        
        Cell.taskername.text="\((Tasker_Data.overlapTaskersArray.object(at: indexPath.row) as AnyObject).object(forKey: "name")!)"
        Cell.min_cost.text =  "\(themes.setLang("hour_cost")) : \(themes.getCurrencyCode())\((Tasker_Data.overlapTaskersArray.object(at: indexPath.row) as AnyObject).object(forKey: "hourly_amount")!)"
        
        Cell.taskerAdd.text = "\((Tasker_Data.overlapTaskersArray.object(at: indexPath.row) as AnyObject).object(forKey: "worklocation")!)"
        Cell.taskerimg.layer.cornerRadius = Cell.taskerimg.frame.width/2;
        Cell.taskerimg.layer.masksToBounds = true;
        Cell.taskerimg.sd_setImage(with: URL(string: "\((Tasker_Data.overlapTaskersArray.object(at: indexPath.row) as AnyObject).object(forKey: "image_url")!)"), completed: themes.block)
        return Cell
    
            



    }
    
    
  

    func PushtoMessageView(_ sender:UIButton)
    {
       
        self.delegate?.pressMessageVC("\((Tasker_Data.overlapTaskersArray.object(at: sender.tag) as AnyObject).object(forKey: "Taskid")!)",
            taskerid: "\((Tasker_Data.overlapTaskersArray.object(at: sender.tag) as AnyObject).object(forKey: "taskerid")!)")
    }
    
    func PushtodetailView(_ sender:UIButton)
    {
        self.delegate?.pressDetailVC("\((Tasker_Data.overlapTaskersArray.object(at: sender.tag) as AnyObject).object(forKey: "min_amount")!)", taskerid: "\((Tasker_Data.overlapTaskersArray.object(at: sender.tag) as AnyObject).object(forKey: "taskerid")!)", hour: "\((Tasker_Data.overlapTaskersArray.object(at: sender.tag) as AnyObject).object(forKey: "hourly_amount")!)",task_id : "\((Tasker_Data.overlapTaskersArray.object(at: sender.tag) as AnyObject).object(forKey: "Taskid")!)")
    }
    
    func selectTasker(_ sender:UIButton)  {
        self.delegate?.pressSelected(Tasker_Data.overlapTaskersArray.object(at: sender.tag) as! NSDictionary, providername: "\((Tasker_Data.overlapTaskersArray.object(at: sender.tag) as! NSDictionary).value(forKey: "name")!)")

    }
    
    @IBAction func close_Action(_ sender: UIButton) {
        self.delegate?.pressCancel(self)
        
        
        
    }
    
    func cancelmethod(_ sender: UIButton)
    {
        self.delegate?.pressCancel(self)
        
    }
 
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
}
