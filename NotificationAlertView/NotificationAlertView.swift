//
//  NotificationAlertView.swift
//  com.rian.swift1
//
//  Created by Andrey Pervushin on 16.10.15.
//  Copyright © 2015 Andrey Pervushin. All rights reserved.
//

import UIKit

enum NotificationAlertViewPosition: Int {
    
    case Top, Bottom, Custom
    
}

class NotificationAlertView: UIView {
    
    
    static var popup:NotificationAlertView?
    
    //May be used in custom popup extensions if you should send some response
    //based on some actions
    var customCompletionHandler:((Int) -> Void)?
    
    //Show/hide animation duration in seconds
    var animationDuration: CFTimeInterval = 0.5
    
    //If this value not equal to "0" popup will hide after specified time in 
    //seconds
    var hideAfterDelay: CGFloat = 0
    
    //View that is showing in popup, you may use it to get any properties from
    //your view. (Change it it on your own risk)
    var contentView: UIView?
    
    //Chage this to show popup from top or bottom
    var position: NotificationAlertViewPosition!{
        didSet{
            
            switch position! {
            case .Top:
                self.addTopConstraint()
                return
                
            case .Bottom:
                self.addBottomConstraint()
                return
                
            default:
                return
            }
        }
    }
    
    
    //Set the value that will be best for your project
    var height : CGFloat = 100 {

        didSet{
            
            if (self.heightConstraint != nil){
                
                self.heightConstraint!.constant = height
                
            }
        }
    }
    
    private var blurView: UIVisualEffectView?
    
    private var backgroundImageView = UIImageView.init()
    
    private var frontImageView = UIImageView.init()
    
    private var heightConstraint:NSLayoutConstraint?
    
    private var positionConstraint:NSLayoutConstraint?
    
    private var isOpen = false
    
    private var isShowing = false
    
    private var isHiding = false
    
    private var transformLayer: CATransformLayer?
    
    
    //Construct popup with any specified view. View will fit popup size however
    //be carefull with constraints specified in it
    static func popupWithView(view:UIView?) -> NotificationAlertView{
        
        //-- Elements
        
        let tempPopup = NotificationAlertView()
        
        tempPopup.contentView = view
        
        for c in tempPopup.contentView!.constraints {
            
            if ( c.firstAttribute == .Height || c.firstAttribute == .Width){
                
                tempPopup.contentView!.removeConstraint(c)
                
            }
            
        }
        
        tempPopup.hidden = true
        
        tempPopup.translatesAutoresizingMaskIntoConstraints = false
        
        tempPopup.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        tempPopup.frontImageView.translatesAutoresizingMaskIntoConstraints = false
        
        tempPopup.transformLayer = CATransformLayer();
        
        //-- Blur View
        
        tempPopup.backgroundColor = UIColor.clearColor()
        
        let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
        
        tempPopup.blurView = UIVisualEffectView(effect: blur)
        
        tempPopup.blurView!.translatesAutoresizingMaskIntoConstraints = false
        
        //-- UI relations
        
        let root = UIApplication.sharedApplication().keyWindow!
        
        root.addSubview(tempPopup)
        
        tempPopup.addConstraintsToPopup()
        
        tempPopup.layer.addSublayer(tempPopup.transformLayer!)
        
        tempPopup.transformLayer!.addSublayer(tempPopup.backgroundImageView.layer)
        
        tempPopup.transformLayer!.addSublayer(tempPopup.frontImageView.layer)
        
        //-- Blur View
        
        tempPopup.superview!.addSubview(tempPopup.blurView!)
        
        tempPopup.superview!.insertSubview(tempPopup.blurView!, belowSubview: tempPopup)
        
        tempPopup.addBlurConstraints()
        
        return tempPopup
        
    }
    
    
    
    //Use it to show popup once it was constructed and hide previous
    func show(){
        
        
        if (self.contentView != nil){
            
            self.contentView!.removeFromSuperview()
            
            self.contentView!.translatesAutoresizingMaskIntoConstraints = false
            
            self.addSubview(self.contentView!)
            
            NotificationAlertView.addMarginConstraints(self, childView: self.contentView!, margins: [0,0,0,0])
            
        }
        
        self.setupCube()
        
        self.isShowing = true
        
        self.blurView!.hidden = true
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(CGFloat(NSEC_PER_SEC) * 0.01)), dispatch_get_main_queue()) { () -> Void in
            
            self.captureBackground()
            
            self.blurView!.hidden = false
            
            self.hidden = false
            
            self.contentView!.hidden = false
            
            self.captureFront()
            
            self.contentView!.hidden = true
            
            NotificationAlertView.hideAnimated(false)
            
            NotificationAlertView.updatePopup(self)
            
            CATransaction.begin();
            
            CATransaction.setCompletionBlock({
                
                self.contentView!.hidden = false
                
                self.isOpen = true
                
                self.isShowing = false
                
                if (self.hideAfterDelay > 0){
                    
                    let t = Int64(CGFloat(NSEC_PER_SEC) * self.hideAfterDelay + CGFloat(self.animationDuration))
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, t), dispatch_get_main_queue(), {
                        
                        self.isHiding = true
                        self.hideWithCompletion(nil)
                        
                    })
                    
                }
            })
            
            CATransaction.setAnimationDuration(self.animationDuration);
            
            self.transformLayer!.transform = CATransform3DRotate(self.transformLayer!.transform, CGFloat(M_PI_2), 1, 0, 0)
            
            CATransaction.commit();
            
        }
  
    }
    
    //Currently showed popup will be hiden
    static func hideAnimated(animated:Bool){
        
        if (animated){
            
            if (popup != nil){
                
                if (popup!.isHiding || popup!.isShowing){
                    return
                }
                
                popup!.isHiding = true
                
                popup!.hideWithCompletion(nil)
                
            }
            
        }else{
            
            if (popup != nil){
                popup!.removeFromSuperview()
            }
            
        }
        
    }
    
    func hideWithCompletion(completion: (() -> Void)?){
        
        self.captureFront()
        
        self.contentView!.removeFromSuperview()
        
        self.hidden = true
        
        self.blurView!.hidden = true
        
        self.captureBackground()
        
        self.blurView!.hidden = false
        
        self.hidden = false
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock({ () -> Void in
            
            self.isOpen = false
            
            self.isHiding = false
            
            self.removeFromSuperview()
            
            if (completion != nil){
                completion!()
            }
            
        })
        
        CATransaction.setAnimationDuration(self.animationDuration)
        
        self.transformLayer!.transform = CATransform3DRotate(self.transformLayer!.transform, CGFloat(-M_PI_2), 1, 0, 0);
        
        CATransaction.commit()
        
    }
    
    static func addMarginConstraints(superView:UIView, childView:UIView, margins:[CGFloat]){
        
        superView.addConstraints([
            
            NSLayoutConstraint(
                item: childView,
                attribute: .Leading,
                relatedBy: .Equal,
                toItem: superView,
                attribute: .Leading,
                multiplier: 1,
                constant: margins[0]),
            
            NSLayoutConstraint(
                item: childView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: superView,
                attribute: .Top,
                multiplier: 1,
                constant: margins[1]),
            
            NSLayoutConstraint(
                item: childView,
                attribute: .Trailing,
                relatedBy: .Equal,
                toItem: superView,
                attribute: .Trailing,
                multiplier: 1,
                constant: margins[2]),
            
            NSLayoutConstraint(
                item: childView,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: superView,
                attribute: .Bottom,
                multiplier: 1,
                constant: margins[3])
            
            ])
        
    }
    
    
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        
        super.layoutSublayersOfLayer(layer)
        
        self.backgroundImageView.layer.frame = self.bounds
        
        self.frontImageView.layer.frame = self.bounds
        
    }
    
    private func setupCube(){
        
        var pt = CATransform3DIdentity;
        pt.m34 = -1.0 / 300.0;
        self.layer.sublayerTransform = pt;
        
        let front = self.frontImageView.layer
        
        let background = self.backgroundImageView.layer
        
        front.transform = CATransform3DTranslate(front.transform, 0, 0, 0);
        
        front.transform = CATransform3DRotate(front.transform, CGFloat(-M_PI_2), 1, 0, 0);
        
        background.transform = CATransform3DTranslate(background.transform, 0, -self.height/2.0, self.height/2.0);
        
        self.transformLayer!.transform = CATransform3DTranslate(self.layer.transform, 0, self.height/2.0, -self.height/2.0);
        
    }
    
    private static func updatePopup(popupView:NotificationAlertView){
        
        popup = popupView;
        
    }
    
    private func captureBackground(){
        
        let layer = UIApplication.sharedApplication().keyWindow!.layer
        
        let scale = UIScreen.mainScreen().scale
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(layer.frame.size.width, self.height), false, scale)
        
        let context = UIGraphicsGetCurrentContext()!
        
        CGContextConcatCTM(context, CGAffineTransformMakeTranslation(0, -self.frame.origin.y))
        
        layer.renderInContext(context)
        
        self.backgroundImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        
    }
    
    private func captureFront(){
        
        let layer = UIApplication.sharedApplication().keyWindow!.layer
        
        let scale = UIScreen.mainScreen().scale
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(layer.frame.size.width, self.height), false, scale)
        
        let context = UIGraphicsGetCurrentContext()!
        
        self.contentView!.layer.renderInContext(context);
        
        self.frontImageView.image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
    }
    
    
    private func addConstraintsToPopup(){
        
        self.heightConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: self.height)
        
        self.addConstraint(self.heightConstraint!)
        
        self.superview!.addConstraints([
            
            NSLayoutConstraint(
                item: self,
                attribute: .Leading,
                relatedBy: .Equal,
                toItem: self.superview,
                attribute: .Leading,
                multiplier: 1,
                constant: 0),
            
            NSLayoutConstraint(
                item: self,
                attribute: .Trailing,
                relatedBy: .Equal,
                toItem: self.superview,
                attribute: .Trailing,
                multiplier: 1,
                constant: 0),
            
            ])
        
        self.addTopConstraint()
        
    }
    
    private func addTopConstraint(){
        
        if (self.positionConstraint != nil){
            self.superview!.removeConstraint(self.positionConstraint!)
        }
        
        self.positionConstraint = NSLayoutConstraint(
            item: self,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: self.superview,
            attribute: .Top,
            multiplier: 1,
            constant: 0)
        
        self.superview!.addConstraint(self.positionConstraint!)
        
    }
    
    private func addBottomConstraint(){
        
        if (self.positionConstraint != nil){
            self.superview!.removeConstraint(self.positionConstraint!)
        }
        
        self.positionConstraint = NSLayoutConstraint(
            item: self,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.superview,
            attribute: .Bottom,
            multiplier: 1,
            constant: 0)
        
        self.superview!.addConstraint(self.positionConstraint!)
        
    }
    
    private func addBlurConstraints(){
        
        superview!.addConstraints([
            
            NSLayoutConstraint(
                item: self.blurView!,
                attribute: .Leading,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Leading,
                multiplier: 1,
                constant: 0),
            
            NSLayoutConstraint(
                item: self.blurView!,
                attribute: .Trailing,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Trailing,
                multiplier: 1,
                constant: 0),
            
            NSLayoutConstraint(
                item: self.blurView!,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Top,
                multiplier: 1,
                constant: 0),
            
            NSLayoutConstraint(
                item: self.blurView!,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Bottom,
                multiplier: 1,
                constant: 0)
            
            ])
    }
    
}
