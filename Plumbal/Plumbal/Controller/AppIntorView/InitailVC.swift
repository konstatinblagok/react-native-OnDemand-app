//
//  InitailVC.swift
//  PlumberJJ
//
//  Created by Natarajan on 19/06/17.
//  Copyright © 2017 Casperon Technologies. All rights reserved.
//

import UIKit

class InitailVC: RootViewController, UIScrollViewDelegate  {
    
    //@IBOutlet var Title_lbl: UILabel!
    @IBOutlet var desc1_lbl: UILabel!
    @IBOutlet var desc_lbl: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var slideScroll: UIScrollView!
    @IBOutlet weak var slideImage: UIImageView!
    @IBOutlet weak var slideLable: UILabel!
    @IBOutlet var skipbtn: TKTransitionSubmitButton!
    var lastContentOffset: CGFloat = 0
    var scrollDirectionDetermined:Bool = true
    var reloadPage = 0
    var Roottimer :Timer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        skipbtn.backgroundColor = PlumberThemeColor
        skipbtn.setTitleColor(UIColor.white, for: UIControlState())
        skipbtn.titleLabel?.font = PlumberLargeFont
        skipbtn.titleLabel?.adjustsFontSizeToFitWidth = true
        let upGs = UISwipeGestureRecognizer(target: self, action: Selector(("handleSwipes:")))
        let downGs = UISwipeGestureRecognizer(target: self, action: Selector(("handleSwipes:")))
        
        upGs.direction = .left
        downGs.direction = .right
        
        super.view.addGestureRecognizer(upGs)
        super.view.addGestureRecognizer(downGs)
        skipbtn.layer.cornerRadius = 24
        skipbtn.layer.masksToBounds = true
        skipbtn.setTitle("\(themes.setLang("skip"))", for: UIControlState())
        
        
        let _ : CGFloat = slideImage.frame.origin.x
        self.slideImage.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.slideScroll.delegate = self
        self.slideScroll.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:slideScroll.frame.size.height)
        let slideScrollWidth:CGFloat = self.slideScroll.frame.width
        let _:CGFloat = self.slideScroll.frame.height
        
        let imgOne = UIImageView(frame: CGRect(x:CGFloat(0.15*self.view.frame.size.width), y:self.view.frame.size.height*0.1056338,width:CGFloat(0.70*self.view.frame.size.width), height:CGFloat(0.70*self.view.frame.size.width)))
        imgOne.image = UIImage(named: "slide1")
        imgOne.contentMode = .scaleAspectFill
        
        let Title_lbl = UILabel(frame: CGRect(x:CGFloat(0.15*self.view.frame.size.width), y:imgOne.frame.maxY-15,width:0.70*self.view.frame.size.width, height:0.5*imgOne.frame.size.height))
        Title_lbl.text = themes.setLang("Book tasker by tapping a button")
        
        Title_lbl.font = PlumberMediumPoppinsFont
        Title_lbl.numberOfLines = 2
        Title_lbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        Title_lbl.textColor = plumberwalkThroughTextColor
        Title_lbl.textAlignment = .center
        
        
        let imgTwo = UIImageView(frame: CGRect(x:slideScrollWidth+CGFloat(0.15*self.view.frame.size.width), y:self.view.frame.size.height*0.1056338,width:CGFloat(0.70*self.view.frame.size.width), height:CGFloat(0.70*self.view.frame.size.width)))
        imgTwo.image = UIImage(named: "slide2")
        imgTwo.contentMode = .scaleAspectFill
        
        let Title_lbl1 = UILabel(frame: CGRect(x:slideScrollWidth+CGFloat(0.15*self.view.frame.size.width), y:imgOne.frame.maxY-15,width:0.70*self.view.frame.size.width, height:0.5*imgTwo.frame.size.height))
        Title_lbl1.text = themes.setLang("Multiple payment options")
        Title_lbl1.font = PlumberMediumPoppinsFont
        Title_lbl1.numberOfLines = 2
        Title_lbl1.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        Title_lbl1.textColor = plumberwalkThroughTextColor
        Title_lbl1.textAlignment = .center
        let imgThree = UIImageView(frame: CGRect(x:slideScrollWidth*2+CGFloat(0.15*self.view.frame.size.width), y:self.view.frame.size.height*0.1056338,width:CGFloat(0.70*self.view.frame.size.width), height:CGFloat(0.70*self.view.frame.size.width)))
        imgThree.image = UIImage(named: "slide3")
        imgThree.contentMode = .scaleAspectFill
        
        let Title_lbl2 = UILabel(frame: CGRect(x:slideScrollWidth*2+CGFloat(0.15*self.view.frame.size.width), y:imgOne.frame.maxY-15,width:0.70*self.view.frame.size.width, height:0.5*imgThree.frame.size.height))
        Title_lbl2.text = themes.setLang( "Instant task alerts")
        Title_lbl2.font = PlumberMediumPoppinsFont
        Title_lbl2.numberOfLines = 2
        Title_lbl2.lineBreakMode = NSLineBreakMode.byWordWrapping
        Title_lbl2.textColor = plumberwalkThroughTextColor
        Title_lbl2.textAlignment = .center
        let imgFour = UIImageView(frame: CGRect(x:slideScrollWidth*3+CGFloat(0.15*self.view.frame.size.width), y:self.view.frame.size.height*0.1056338,width:CGFloat(0.70*self.view.frame.size.width), height:CGFloat(0.70*self.view.frame.size.width)))
        imgFour.image = UIImage(named: "slide4")
        imgFour.contentMode = .scaleAspectFill
        
        let Title_lbl3 = UILabel(frame: CGRect(x:slideScrollWidth*3+CGFloat(0.15*self.view.frame.size.width), y:imgOne.frame.maxY-15,width:0.70*self.view.frame.size.width, height:0.5*imgFour.frame.size.height))
        Title_lbl3.text = themes.setLang("Tracking towards work location")
        Title_lbl3.font = PlumberMediumPoppinsFont
        Title_lbl3.numberOfLines = 2
        Title_lbl3.lineBreakMode = NSLineBreakMode.byWordWrapping
        Title_lbl3.textColor = plumberwalkThroughTextColor
        Title_lbl3.textAlignment = .center
        
        let imgFive = UIImageView(frame: CGRect(x:slideScrollWidth*4+CGFloat(0.15*self.view.frame.size.width), y:self.view.frame.size.height*0.1056338,width:CGFloat(0.70*self.view.frame.size.width), height:CGFloat(0.70*self.view.frame.size.width)))
        imgFive.image = UIImage(named: "slide5")
        imgFive.contentMode = .scaleAspectFill
        
        let Title_lbl4 = UILabel(frame: CGRect(x:slideScrollWidth*4+CGFloat(0.15*self.view.frame.size.width), y:imgOne.frame.maxY-15,width:0.70*self.view.frame.size.width, height:0.5*imgFive.frame.size.height))
        Title_lbl4.text = themes.setLang("Chat with the tasker and hire them")
        Title_lbl4.font = PlumberMediumPoppinsFont
        Title_lbl4.numberOfLines = 2
        Title_lbl4.lineBreakMode = NSLineBreakMode.byWordWrapping
        Title_lbl4.textColor = plumberwalkThroughTextColor
        Title_lbl4.textAlignment = .center
        
        self.slideScroll.addSubview(imgOne)
        self.slideScroll.addSubview(Title_lbl)
        
        self.slideScroll.addSubview(imgTwo)
        self.slideScroll.addSubview(Title_lbl1)
        
        self.slideScroll.addSubview(imgThree)
        self.slideScroll.addSubview(Title_lbl2)
        
        
        self.slideScroll.addSubview(imgFour)
        self.slideScroll.addSubview(Title_lbl3)
        
        self.slideScroll.addSubview(imgFive)
        self.slideScroll.addSubview(Title_lbl4)
        
        self.skipbtn.titleLabel?.font = PlumberMediumPoppinsFontButton
        
        if UIScreen.main.bounds.size.height == 480{
            
            let imgOne = UIImageView(frame: CGRect(x:CGFloat(0.15*self.view.frame.size.width), y:self.view.frame.size.height*0.0556338,width:CGFloat(0.70*self.view.frame.size.width), height:CGFloat(0.70*self.view.frame.size.width)))
            imgOne.image = UIImage(named: "slide1")
            imgOne.contentMode = .scaleAspectFill
            
            let Title_lbl = UILabel(frame: CGRect(x:CGFloat(0.15*self.view.frame.size.width), y:imgOne.frame.maxY-15,width:0.70*self.view.frame.size.width, height:0.5*imgOne.frame.size.height))
            Title_lbl.text = themes.setLang("Book tasker by tapping a button")
            Title_lbl.font = PlumberMediumPoppinsFont
            Title_lbl.numberOfLines = 2
            Title_lbl.lineBreakMode = NSLineBreakMode.byWordWrapping
            Title_lbl.textColor = plumberwalkThroughTextColor
            Title_lbl.textAlignment = .center
            
            let imgTwo = UIImageView(frame: CGRect(x:slideScrollWidth+CGFloat(0.15*self.view.frame.size.width), y:self.view.frame.size.height*0.0856338,width:CGFloat(0.70*self.view.frame.size.width), height:CGFloat(0.70*self.view.frame.size.width)))
            imgTwo.image = UIImage(named: "slide2")
            imgTwo.contentMode = .scaleAspectFill
            
            let Title_lbl1 = UILabel(frame: CGRect(x:slideScrollWidth+CGFloat(0.15*self.view.frame.size.width), y:imgOne.frame.maxY-15,width:0.70*self.view.frame.size.width, height:0.5*imgTwo.frame.size.height))
            Title_lbl1.text = themes.setLang( "Multiple payment options")
            Title_lbl1.font = PlumberMediumPoppinsFont
            Title_lbl1.numberOfLines = 2
            Title_lbl1.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            Title_lbl1.textColor = plumberwalkThroughTextColor
            Title_lbl1.textAlignment = .center
            
            let imgThree = UIImageView(frame: CGRect(x:slideScrollWidth+CGFloat(0.15*self.view.frame.size.width), y:self.view.frame.size.height*0.0856338,width:CGFloat(0.70*self.view.frame.size.width), height:CGFloat(0.70*self.view.frame.size.width)))
            imgThree.image = UIImage(named: "slide2")
            imgThree.contentMode = .scaleAspectFill
            
            let Title_lbl2 = UILabel(frame: CGRect(x:slideScrollWidth+CGFloat(0.15*self.view.frame.size.width), y:imgOne.frame.maxY-15,width:0.70*self.view.frame.size.width, height:0.5*imgTwo.frame.size.height))
            Title_lbl2.text = themes.setLang("Multiple payment options")
            Title_lbl2.font = PlumberMediumPoppinsFont
            Title_lbl2.numberOfLines = 2
            Title_lbl2.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            Title_lbl2.textColor = plumberwalkThroughTextColor
            Title_lbl2.textAlignment = .center
            
            let imgfour = UIImageView(frame: CGRect(x:slideScrollWidth+CGFloat(0.15*self.view.frame.size.width), y:self.view.frame.size.height*0.0856338,width:CGFloat(0.70*self.view.frame.size.width), height:CGFloat(0.70*self.view.frame.size.width)))
            imgfour.image = UIImage(named: "slide2")
            imgfour.contentMode = .scaleAspectFill
            
            let Title_lbl3 = UILabel(frame: CGRect(x:slideScrollWidth+CGFloat(0.15*self.view.frame.size.width), y:imgOne.frame.maxY-15,width:0.70*self.view.frame.size.width, height:0.5*imgTwo.frame.size.height))
            Title_lbl3.text = themes.setLang( "Multiple payment options")
            Title_lbl3.font = PlumberMediumPoppinsFont
            Title_lbl3.numberOfLines = 2
            Title_lbl3.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            Title_lbl3.textColor = plumberwalkThroughTextColor
            Title_lbl3.textAlignment = .center
            
            let imgfive = UIImageView(frame: CGRect(x:slideScrollWidth+CGFloat(0.15*self.view.frame.size.width), y:self.view.frame.size.height*0.0856338,width:CGFloat(0.70*self.view.frame.size.width), height:CGFloat(0.70*self.view.frame.size.width)))
            imgfive.image = UIImage(named: "slide2")
            imgfive.contentMode = .scaleAspectFill
            
            let Title_lbl4 = UILabel(frame: CGRect(x:slideScrollWidth+CGFloat(0.15*self.view.frame.size.width), y:imgOne.frame.maxY-15,width:0.70*self.view.frame.size.width, height:0.5*imgTwo.frame.size.height))
            Title_lbl4.text = themes.setLang("Multiple payment options")
            Title_lbl4.font = PlumberMediumPoppinsFont
            Title_lbl4.numberOfLines = 2
            Title_lbl4.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            Title_lbl4.textColor = plumberwalkThroughTextColor
            Title_lbl4.textAlignment = .center
            
            
            self.pageControl.frame = CGRect(x: self.view.frame.size.width*0.30, y: Title_lbl4.frame.maxY+10, width: self.view.frame.size.width*0.40, height: self.pageControl.frame.size.height)
            self.skipbtn.frame = CGRect(x: self.view.frame.size.width*0.25, y: self.pageControl.frame.maxY+10, width: self.view.frame.size.width*0.50, height: imgFour.frame.size.height*0.222222-5)
            skipbtn.layer.cornerRadius = self.skipbtn.frame.size.height/2
        }
        else
        {
            self.pageControl.frame = CGRect(x: self.view.frame.size.width*0.30, y: Title_lbl4.frame.maxY+25, width: self.view.frame.size.width*0.40, height: self.pageControl.frame.size.height)
            self.skipbtn.frame = CGRect(x: self.view.frame.size.width*0.20, y: self.pageControl.frame.maxY+25, width: self.view.frame.size.width*0.60, height: imgFour.frame.size.height*0.222222)
            skipbtn.layer.cornerRadius = self.skipbtn.frame.size.height/2
        }
        
        self.slideScroll.contentSize = CGSize(width:self.slideScroll.frame.width * 5, height:self.slideScroll.frame.height-20)
        self.slideScroll.delegate = self
        self.pageControl.currentPage = 0
       Roottimer = Timer.scheduledTimer( timeInterval: 1,  target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
        
    }
    func setView(){
        
        let taskerpro:InitailVCUIViewController = InitailVCUIViewController(nibName:"InitailVCUIViewController", bundle: nil)
        self.navigationController?.pushViewController(withFlip: taskerpro, animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView){
        
        
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((slideScroll.contentOffset.x-pageWidth/2)/pageWidth)+1
        
        self.pageControl.currentPage = Int(currentPage);
        reloadPage=0
        
    }
    
    
    func moveToNextPage (){
        if(reloadPage>=3){
            reloadPage=0
            let pageWidth:CGFloat = self.slideScroll.frame.width
            let maxWidth:CGFloat = pageWidth * 5
            let contentOffset:CGFloat = self.slideScroll.contentOffset.x
            
            var slideToX = contentOffset + pageWidth
            
            if  contentOffset + pageWidth == maxWidth
            {
                slideToX = 0
            }
            self.slideScroll.scrollRectToVisible(CGRect(x:slideToX, y:0, width:pageWidth, height:self.slideScroll.frame.height), animated: true)
        }else{
            reloadPage += 1
        }
        
    }
    
    @IBAction func DidClickSkip(_ sender: AnyObject) {
    
        
    

       Roottimer.invalidate()
        skipbtn.startLoadingAnimation(withloader: false)
        skipbtn.startFinishAnimation(0.1, completion: {
            Appdel.MakeRootVc("RootVCID")
        })

        
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if slideScroll.contentOffset.x < scrollView.contentOffset.x {
            
        }
        else{
            
        }
        
        
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let pageWidth:CGFloat = scrollView.frame.width
        
        reloadPage=0
        
        
        
        self.lastContentOffset = scrollView.contentOffset.x
        
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview!)
        if translation.x > 0 {
            let currentPage:CGFloat = floor((slideScroll.contentOffset.x-pageWidth)/pageWidth)+1
            
            self.pageControl.currentPage = Int(currentPage);
        } else {
            let currentPage:CGFloat = floor((slideScroll.contentOffset.x-pageWidth)/pageWidth)+2
            
            self.pageControl.currentPage = Int(currentPage);
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
