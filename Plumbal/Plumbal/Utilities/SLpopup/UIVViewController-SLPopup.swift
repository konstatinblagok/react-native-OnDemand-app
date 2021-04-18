//
//  UIVViewController-SLpopup.swift
//  AnonyChat
//
//  Created by Nguyen Duc Hoang on 9/6/15.
//  Copyright © 2015 Home. All rights reserved.
//

import UIKit
import QuartzCore
import ObjectiveC

enum SLpopupViewAnimationType: Int {
    case bottomTop
    case topBottom
    case bottomBottom
    case topTop
    case leftLeft
    case leftRight
    case rightLeft
    case rightRight
    case fade
}
let kSourceViewTag = 11111
let kpopupViewTag = 22222
let kOverlayViewTag = 22222

var kpopupViewController:UInt8 = 0
var kpopupBackgroundView:UInt8 = 1

let kpopupAnimationDuration = 0.35
let kSLViewDismissKey = "kSLViewDismissKey"

extension UIViewController {
    var popupBackgroundView:UIView? {
        get {
            return objc_getAssociatedObject(self, &kpopupBackgroundView) as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kpopupBackgroundView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var popupViewController:UIViewController? {
        get {
            return objc_getAssociatedObject(self, &kpopupViewController) as? UIViewController
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kpopupViewController, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
//    var dismissedCallback:UIViewController? {
//        get {
//            return objc_getAssociatedObject(self, kSLViewDismissKey) as? UIViewController
//        }
//        set(newValue) {
//            objc_setAssociatedObject(self, kSLViewDismissKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
    
    func presentpopupViewController(_ popupViewController: UIViewController, animationType:SLpopupViewAnimationType, completion:() -> Void) {
        let sourceView:UIView = self.getTopView()
        self.popupViewController = popupViewController
        let popupView:UIView = popupViewController.view
        sourceView.tag = kSourceViewTag
        popupView.autoresizingMask = [.flexibleTopMargin,.flexibleLeftMargin,.flexibleRightMargin,.flexibleBottomMargin]
        popupView.tag = kpopupViewTag
        if(sourceView.subviews.contains(popupView)) {
            return
        }
        popupView.layer.shadowPath = UIBezierPath(rect: popupView.bounds).cgPath
//        popupView.layer.masksToBounds = false
//        popupView.layer.shadowOffset = CGSizeMake(5, 5)
//        popupView.layer.shadowRadius = 5
//        popupView.layer.shadowOpacity = 0.5
        popupView.layer.shouldRasterize = true
        popupView.layer.rasterizationScale = UIScreen.main.scale
        
        let overlayView:UIView = UIView(frame: sourceView.bounds)
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.tag = kOverlayViewTag
        overlayView.backgroundColor = UIColor.clear
        
        self.popupBackgroundView = UIView(frame: sourceView.bounds)
        self.popupBackgroundView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.popupBackgroundView!.backgroundColor = UIColor.black
        self.popupBackgroundView?.alpha = 0.0
        if let _ = self.popupBackgroundView {
            overlayView.addSubview(self.popupBackgroundView!)
        }
        //Background is button
        let dismissButton: UIButton = UIButton(type: .custom)
        dismissButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dismissButton.backgroundColor = UIColor.clear
        dismissButton.frame = sourceView.bounds
        overlayView.addSubview(dismissButton)
        
        popupView.alpha = 0.0
        overlayView.addSubview(popupView)
        sourceView.addSubview(overlayView)
        
        dismissButton.addTarget(self, action: #selector(UIViewController.btnDismissViewControllerWithAnimation(_:)), for: .touchUpInside)
        switch animationType {
        case .bottomTop, .bottomBottom,.topTop,.topBottom, .leftLeft, .leftRight,.rightLeft, .rightRight:
            dismissButton.tag = animationType.rawValue
            print("slider1")
            self.slideView(popupView, sourceView: sourceView, overlayView: overlayView, animationType: animationType)
            
        default:
            dismissButton.tag = SLpopupViewAnimationType.fade.rawValue
            self.fadeView(popupView, sourceView: sourceView, overlayView: overlayView)
        }
        
    }
    func slideView(_ popupView: UIView, sourceView:UIView, overlayView:UIView, animationType: SLpopupViewAnimationType) {
        let sourceSize: CGSize = sourceView.bounds.size
        let popupSize: CGSize = popupView.bounds.size
        var popupStartRect:CGRect
        switch animationType {
        case .bottomTop, .bottomBottom:
            popupStartRect = CGRect(x: (sourceSize.width - popupSize.width)/2, y: sourceSize.height, width: popupSize.width, height: popupSize.height)
        case .leftLeft, .leftRight:
            popupStartRect = CGRect(x: -sourceSize.width, y: (sourceSize.height - popupSize.height)/2, width: popupSize.width, height: popupSize.height)
        case .topTop, .topBottom:
            popupStartRect = CGRect(x: (sourceSize.width - popupSize.width)/2, y: -sourceSize.height, width: popupSize.width, height: popupSize.height)
        default:
            popupStartRect = CGRect(x: sourceSize.width, y: (sourceSize.height - popupSize.height)/2, width: popupSize.width, height: popupSize.height)
        }
        let popupEndRect:CGRect = CGRect(x: (sourceSize.width - popupSize.width)/2, y: (sourceSize.height - popupSize.height)/2, width: popupSize.width, height: popupSize.height)
        popupView.frame = popupStartRect
        popupView.alpha = 1.0
        UIView.animate(withDuration: kpopupAnimationDuration, animations: { () -> Void in
            self.popupViewController?.viewWillAppear(false)
            self.popupBackgroundView?.alpha = 0.5
            popupView.frame = popupEndRect
            }, completion: { (finished) -> Void in
                self.popupViewController?.viewDidAppear(false)
        }) 
        
    }
    func slideViewOut(_ popupView: UIView, sourceView:UIView, overlayView:UIView, animationType: SLpopupViewAnimationType) {
        let sourceSize: CGSize = sourceView.bounds.size
        let popupSize: CGSize = popupView.bounds.size
        var popupEndRect:CGRect
        switch animationType {
        case .bottomTop, .topTop:
            popupEndRect = CGRect(x: (sourceSize.width - popupSize.width)/2, y: -popupSize.height, width: popupSize.width, height: popupSize.height)
        case .bottomBottom, .topBottom:
            popupEndRect = CGRect(x: (sourceSize.width - popupSize.width)/2, y: popupSize.height, width: popupSize.width, height: popupSize.height)
        case .leftRight, .rightRight:
            popupEndRect = CGRect(x: sourceSize.width, y: popupView.frame.origin.y, width: popupSize.width, height: popupSize.height)
        default:
            popupEndRect = CGRect(x: -popupSize.width, y: popupView.frame.origin.y, width: popupSize.width, height: popupSize.height)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.popupBackgroundView?.backgroundColor = UIColor.clear
            }) { (finished) -> Void in
                UIView.animate(withDuration: kpopupAnimationDuration, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                    self.popupViewController?.viewWillDisappear(false)
                    popupView.frame = popupEndRect
                    }) { (finished) -> Void in
                        popupView.removeFromSuperview()
                        overlayView.removeFromSuperview()
                        self.popupViewController?.viewDidDisappear(false)
                        self.popupViewController = nil
                }
        }
        
        
        
    }
    
    func fadeView(_ popupView: UIView, sourceView:UIView, overlayView:UIView) {
        let sourceSize: CGSize = sourceView.bounds.size
        let popupSize: CGSize = popupView.bounds.size
        popupView.frame = CGRect(x: (sourceSize.width - popupSize.width)/2,
                                                y: (sourceSize.height - popupSize.height)/2,
                                                width: popupSize.width,
                                                height: popupSize.height)
        popupView.alpha = 0.0
        
        UIView.animate(withDuration: kpopupAnimationDuration, animations: { () -> Void in
            self.popupViewController!.viewWillAppear(false)
            self.popupBackgroundView!.alpha = 0.5
            popupView.alpha = 1.0
        }, completion: { (finished) -> Void in
           self.popupViewController?.viewDidAppear(false)
        }) 
        
    }
    
    func fadeViewOut(_ popupView: UIView, sourceView:UIView, overlayView:UIView) {
        UIView.animate(withDuration: kpopupAnimationDuration, animations: { () -> Void in
            self.popupViewController?.viewDidDisappear(false)
            self.popupBackgroundView?.alpha = 0.0
            popupView.alpha = 0.0
        }, completion: { (finished) -> Void in
            popupView.removeFromSuperview()
            overlayView.removeFromSuperview()
            self.popupViewController?.viewDidDisappear(false)
            self.popupViewController = nil
        }) 
        
    }
    func btnDismissViewControllerWithAnimation(_ btnDismiss : UIButton) {
        let animationType:SLpopupViewAnimationType = SLpopupViewAnimationType(rawValue: btnDismiss.tag)!
        switch animationType {
        case .bottomTop, .bottomBottom, .topTop, .topBottom, .leftLeft, .leftRight, .rightLeft, .rightRight:
            self.dismissPopupViewController(animationType)
        default:
            self.dismissPopupViewController(SLpopupViewAnimationType.fade)
        }
    }
    func getTopView() -> UIView {
        var recentViewController:UIViewController = self
        if let _ = recentViewController.parent {
           recentViewController = recentViewController.parent!
        }
        return recentViewController.view
    }
    func dismissPopupViewController(_ animationType: SLpopupViewAnimationType) {
        if let activeController = navigationController?.visibleViewController {
            if activeController.isKind(of: InitialViewController.self){
                  NotificationCenter.default.post(name: Notification.Name(rawValue: "dismisspopup"), object:nil)
            }
        }
        let sourceView:UIView = self.getTopView()
        let popupView:UIView = sourceView.viewWithTag(kpopupViewTag)!
        let overlayView:UIView = sourceView.viewWithTag(kOverlayViewTag)!
        switch animationType {
        case .bottomTop, .bottomBottom, .topTop, .topBottom, .leftLeft, .leftRight, .rightLeft, .rightRight:
            self.slideViewOut(popupView, sourceView: sourceView, overlayView: overlayView, animationType: animationType)
        default:
            fadeViewOut(popupView, sourceView: sourceView, overlayView: overlayView)
            
            
        }
    }
}
