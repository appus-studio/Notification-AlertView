//
//  APNotificationAlertViewBaseExtension.swift
//  AppusNotificationPopupExample
//
//  Created by Andrey Pervushin on 27.10.15.
//  Copyright © 2015 Andrey Pervushin. All rights reserved.
//
import UIKit

extension APNotificationAlertView {
    
    //Simple popup with text. Use hideAfterDelay property or outer action to hide
    
    static func popupWithText(text:String) -> APNotificationAlertView{
        
        //-- Elements
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = UIColor.cyanColor()
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = text
        
        label.textAlignment = NSTextAlignment.Center
        
        label.numberOfLines = 0
        
        label.minimumScaleFactor = 0.3
        
        //-- UI relations
        
        view.addSubview(label)
        
        APNotificationAlertView.addMarginConstraints(view, childView: label, margins: [0,0,0,0])
        
        return APNotificationAlertView.popupWithView(view)
        
    }
    
    //Popup with text and Yes/No options. Use customCompletionHandler to get
    //presed option index (Yes:0 No:1)
    @available(iOS 9, *)
    static func popupWithQuestion(text:String) -> APNotificationAlertView{
        
        //-- Elements
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1)
        
        let icon = UILabel()
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        icon.text = "?"
        
        icon.textColor = UIColor.lightGrayColor()
        
        icon.textAlignment = .Center
        
        icon.numberOfLines = 0
        
        icon.layer.cornerRadius = 15
        
        icon.layer.borderWidth = 1
        
        icon.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = text
        
         icon.textColor = UIColor.grayColor()
        
        label.textAlignment = .Center
        
        label.numberOfLines = 0
        
        label.minimumScaleFactor = 0.3
        
        let panel = UIStackView()
        
        panel.translatesAutoresizingMaskIntoConstraints = false
        
        panel.axis = .Vertical
        
        panel.distribution = .FillEqually
        
        panel.alignment = .Fill
        
        var buttons = [UIButton]()
        
        var i = 0;
        for title in ["Yes", "No"] {
            
            let button = UIButton(type: .System)
            
            button.tag = i
            
            button.translatesAutoresizingMaskIntoConstraints = false
            
            button.setTitle(title, forState: .Normal)
            
            panel.addArrangedSubview(button)
            
            buttons.append(button)
            
            i++
        }
        
        //-- UI relations
        
        view.addSubview(icon)
        
        view.addSubview(label)
        
        view.addSubview(panel)
        
        APNotificationAlertView.addLeftIconConstraints(view, childView: icon, values: [5,30,30])
        
        APNotificationAlertView.addMarginConstraints(view, childView: label, margins: [40,20,-80,0])
        
        APNotificationAlertView.addHorizontalSnapConstraints(view, childView: panel, margins: [20,0], layoutAttribute: .Right, width: 80)
        
        let tempPopup = APNotificationAlertView.popupWithView(view)
        
        //-- Event Handlers
        
        for button in buttons{
            button.addTarget(tempPopup, action: "onDialogButtonAction:", forControlEvents: .TouchUpInside)
        }
        
        return tempPopup
    }
    
    
    //Popup with text and warious number of options. Use customCompletionHandler 
    //to get presed option index
    @available(iOS 9, *)
    static func popupDialogWithText(text:String, options:[String]) -> APNotificationAlertView{
        
        //-- Elements
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1)
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = text
        
        label.textAlignment = .Center
        
        label.numberOfLines = 0
        
        label.minimumScaleFactor = 0.3
        
        let panel = UIStackView()
        
        panel.translatesAutoresizingMaskIntoConstraints = false
        
        panel.axis = .Horizontal
        
        panel.distribution = .FillEqually
        
        panel.alignment = .Fill
        
        var buttons = [UIButton]()
        
        var i = 0;
        for title in options {
            
            let button = UIButton(type: .System)
            
            button.tag = i
            
            button.translatesAutoresizingMaskIntoConstraints = false
            
            button.setTitle(title, forState: .Normal)
            
            panel.addArrangedSubview(button)
            
            buttons.append(button)
            
            i++
        }
        
        //-- UI relations
        
        view.addSubview(panel)
        
        view.addSubview(label)
        
        APNotificationAlertView.addVerticalSnapConstraints(view, childView: panel, layoutAttribute: .Bottom, height: 35)
        
        APNotificationAlertView.addMarginConstraints(view, childView: label, margins: [50,20,0,-35])
        
        
        let tempPopup = APNotificationAlertView.popupWithView(view)
        
        //-- Event Handlers
        
        for button in buttons{
            button.addTarget(tempPopup, action: "onDialogButtonAction:", forControlEvents: .TouchUpInside)
        }
        
        return tempPopup
        
    }
    
    func onDialogButtonAction(button: UIButton){
        
        if let completion = self.customCompletionHandler{
            completion(button.tag)
        }
        
    }
    
    
    
    static func addLeftIconConstraints(superView:UIView, childView:UIView, values:[CGFloat]){
        
        childView.addConstraint(NSLayoutConstraint(
            item: childView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: values[1]))
        
        childView.addConstraint(NSLayoutConstraint(
            item: childView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: values[2]))
        
        superView.addConstraints([
            
            NSLayoutConstraint(
                item: childView,
                attribute: .Leading,
                relatedBy: .Equal,
                toItem: superView,
                attribute: .Leading,
                multiplier: 1,
                constant: values[0]),
            
            NSLayoutConstraint(
                item: childView,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: superView,
                attribute: .CenterY,
                multiplier: 1,
                constant: 0),
            
            ])
        
    }

    
    static func addVerticalSnapConstraints(superView:UIView, childView:UIView, layoutAttribute: NSLayoutAttribute, height:CGFloat){
        
        childView.addConstraint(NSLayoutConstraint(
            item: childView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: height))
        
        superView.addConstraints([
            
            NSLayoutConstraint(
                item: childView,
                attribute: .Leading,
                relatedBy: .Equal,
                toItem: superView,
                attribute: .Leading,
                multiplier: 1,
                constant: 0),
            
            NSLayoutConstraint(
                item: childView,
                attribute: .Trailing,
                relatedBy: .Equal,
                toItem: superView,
                attribute: .Trailing,
                multiplier: 1,
                constant: 0),
            
            NSLayoutConstraint(
                item: childView,
                attribute: layoutAttribute,
                relatedBy: .Equal,
                toItem: superView,
                attribute: layoutAttribute,
                multiplier: 1,
                constant: 0),
            
            ])
        
    }
    
    static func addMarginSizeConstraints(superView:UIView, childView:UIView, values:[CGFloat]){
        
        childView.addConstraint(NSLayoutConstraint(
            item: childView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: values[2]))
        
        childView.addConstraint(NSLayoutConstraint(
            item: childView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: values[3]))
        
        superView.addConstraints([
            
            NSLayoutConstraint(
                item: childView,
                attribute: .Left,
                relatedBy: .Equal,
                toItem: superView,
                attribute: .Left,
                multiplier: 1,
                constant: values[0]),
            NSLayoutConstraint(
                item: childView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: superView,
                attribute: .Top,
                multiplier: 1,
                constant: values[1]),
            
            ])
        
    }
    
    static func addHorizontalSnapConstraints(superView:UIView, childView:UIView, margins:[CGFloat], layoutAttribute: NSLayoutAttribute, width:CGFloat){
        
        childView.addConstraint(NSLayoutConstraint(
            item: childView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: width))
        
        superView.addConstraints([
            
            NSLayoutConstraint(
                item: childView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: superView,
                attribute: .Top,
                multiplier: 1,
                constant: margins[0]),
            
            NSLayoutConstraint(
                item: childView,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: superView,
                attribute: .Bottom,
                multiplier: 1,
                constant: margins[1]),
            
            NSLayoutConstraint(
                item: childView,
                attribute: layoutAttribute,
                relatedBy: .Equal,
                toItem: superView,
                attribute: layoutAttribute,
                multiplier: 1,
                constant: 0),
            
            ])
        
    }
    
    
    
}
