//
//  SplashViewController.swift
//  Plumbal
//
//  Created by Casperon Tech on 17/11/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class SplashViewController: RootViewController,UIPageViewControllerDataSource, UIPageViewControllerDelegate,UIScrollViewDelegate {
    
    var Globalindex:NSInteger=NSInteger()
    var _pageViewController: UIPageViewController?
    var Timer:Foundation.Timer=Foundation.Timer()
    var themes:Themes=Themes()
    var URL_Handler:URLhandler=URLhandler()

    let _pageTitles = ["logo", "logo", "logo"]
    let _pageImages = ["BGPlain", "BGPlain", "BGPlain"]
    let _descImages = ["Splash1", "Splash2", "Splash3"]
    var _descMsgs = ["Our rich & responsive interface will give you the best user experience.", "Book your Professional at anywhere at anytime", "Book a Professional and monitor their progress from anywhere"]

    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var Signin_Btn: UIButton!
    @IBOutlet var Reg_Btn: UIButton!
    
    //MARK: - Override Function

    override func viewDidLoad() {
        super.viewDidLoad()
        print("the id is \(themes.Check_userID())")
        if(themes.Check_userID() != "") {
            Appdel.MakeRootVc("RootVCID")
         }

        loadSplashVideo()
        Globalindex=0
     }
    
    override func viewWillAppear(_ animated: Bool) {
        Timer=Foundation.Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(SplashViewController.ChangeDot), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Timer.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: -  Function

    func ChangeDot() {
         if(Globalindex == _pageTitles.count-1) {
            Globalindex=0
        } else {
            Globalindex += 1
        }
        let startingViewController = viewControllerAtIndex(Globalindex)
        let viewControllers = [startingViewController!]
        _pageViewController!.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        _pageViewController!.didMove(toParentViewController: self)
      }

    
    func loadSplashVideo(){
        _pageViewController = storyboard!.instantiateViewController(withIdentifier: "WalkthroughPageView") as? UIPageViewController
        _pageViewController!.dataSource = self
        _pageViewController!.delegate = self
        let startingViewController = viewControllerAtIndex(0)
        let viewControllers = [startingViewController!]
        _pageViewController!.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        if(themes.screenSize.height == 480){
            _pageViewController!.view.frame = CGRect(x: 0, y: 10, width: self.view.frame.size.width, height: self.view.frame.size.height-60)
        } else{
        _pageViewController!.view.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: self.view.frame.size.height - 120)
        }
        addChildViewController(_pageViewController!)
        view.addSubview(_pageViewController!.view)
        _pageViewController!.didMove(toParentViewController: self)
        self.view.bringSubview(toFront: Signin_Btn)
        self.view.bringSubview(toFront: Reg_Btn)
        for view in self._pageViewController!.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
            }
        }
    }
    
    
    func viewControllerAtIndex(_ index: NSInteger) -> UIViewController? {
        
        if ((_pageTitles.count == 0) || (index >= _pageTitles.count)) {
            return nil
        }
        let pageContentViewController = storyboard!.instantiateViewController(withIdentifier: "WalkthroughPageContent") as! WalkThroughViewController
        pageContentViewController.titleText = _pageTitles[index] as NSString
        pageContentViewController.descText = _descMsgs[index] as NSString
        pageContentViewController.imgText = _descImages[index] as NSString
        pageContentViewController.pageIndex = index
        return pageContentViewController
    }
    
       //MARK: - Page ViewController Delegate
    
           
    func presentationCount(for pageViewController: UIPageViewController) -> NSInteger {
        return _pageTitles.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> NSInteger {
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (completed) {
            let pageContentViewController = pageViewController.viewControllers![0] as! WalkThroughViewController
            let index = pageContentViewController.pageIndex
            let backgroundImageName = _pageImages[index] as NSString
            UIView.transition(with: self.backgroundImage, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve,
                animations: { () -> Void in
                    self.backgroundImage.image = UIImage(named: backgroundImageName as String)
                }, completion: { (Bool) -> Void in
               })
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageContentViewController = viewController as! WalkThroughViewController
        var index = pageContentViewController.pageIndex;
        if ((index == 0) || (index == NSNotFound)) {
            index = self._pageTitles.count;
        }
        index -= 1;
        return self.viewControllerAtIndex(index);
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let pageContentViewController = viewController as! WalkThroughViewController
        var index = pageContentViewController.pageIndex;
        if (index == NSNotFound) {
            return nil
        }
        index += 1;
        if (index == _pageTitles.count) {
            index=0
        }
        Globalindex=index
        return viewControllerAtIndex(index);
    }

  //MARK: -  Languge Delegate

    func applicationLanguageChangeNotification(){
        Signin_Btn.setTitle(themes.setLang("Sign In"), for: UIControlState())
        Reg_Btn.setTitle(themes.setLang("Register"), for: UIControlState())
        _descMsgs = [themes.setLang("Our rich & responsive interface will give you the best user experience."),
                     themes.setLang("Book your Professional at anywhere at anytime"),
                     themes.setLang("Book a Professional instantly and monitor their progress from anywhere")]
    }
}
