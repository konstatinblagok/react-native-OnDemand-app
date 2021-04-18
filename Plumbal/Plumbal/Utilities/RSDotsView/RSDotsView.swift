//
//  MHDotsView.swift
//  RSDotsView
//
//  Created by Remi Santos on 10/10/2014.
//  Copyright (c) 2014 Remi Santos. All rights reserved.
//

import UIKit


private class RSDotView: UILabel {
    var fillColor:UIColor = UIColor.black
    var diameter:CGFloat = CGFloat(1)
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        self.fillColor.setFill()
        context?.addEllipse(in: (CGRect (x: 0, y: 0, width: diameter, height: diameter)))
        context?.drawPath(using: CGPathDrawingMode.fill)
        context?.strokePath()
    }
}


class RSDotsView: UILabel {
   
    var dotsColor:UIColor = UIColor.white {
        didSet {
            buildView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildView()
    }
    
    
    
    fileprivate func buildView() {
        self.layer.cornerRadius = self.bounds.size.width/2;
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        let numberDots = CGFloat(3)
        let width = (self.bounds.size.width)/(numberDots+1)
       
        var frame = CGRect(x: 43, y: 14, width: 5, height: 5);
        self.text="Typing"
        self.textColor=UIColor.white
        for i in 0...Int(numberDots-1) {
            let dot = RSDotView(frame: frame)
            dot.diameter = 5;
            dot.fillColor = self.dotsColor;
            dot.backgroundColor = UIColor.clear
            
            self.addSubview(dot)
            frame.origin.x += width
        }
    }
    
    func startAnimating() {
        var i:Int = 0
        for dot in self.subviews as! [RSDotView] {
            dot.transform = CGAffineTransform(scaleX: 0.01, y: 0.01);
            let delay = 0.1*Double(i)
            UIView.animate(withDuration: Double(0.5), delay:delay, options: UIViewAnimationOptions().union(UIViewAnimationOptions.repeat).union(UIViewAnimationOptions.autoreverse) , animations: { () -> Void in
                dot.transform = CGAffineTransform(scaleX: 1, y: 1);
                }, completion: nil)
            
            i += 1;
        }
    }
    
    
    func stopAnimating() {
        for dot in self.subviews as! [RSDotView] {
            dot.transform = CGAffineTransform(scaleX: 1, y: 1);
            dot.layer.removeAllAnimations()
        }
    }
    
}
