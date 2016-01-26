//
//  ViewController.swift
//  AppusNotificationPopupExample
//
//  Created by Andrey Pervushin on 27.10.15.
//  Copyright © 2015 Andrey Pervushin. All rights reserved.
//

import UIKit



class ViewController: UIViewController {
    
    @IBOutlet var samplePopupView: UIView!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    let dataSource = [
        ["title":"Top", "action":"showViewFromTopAction"],
        ["title":"Text", "action":"showTextFromTopAction"],
        ["title":"Dialog", "action":"showDialogAction"],
        ["title":"Question", "action":"showQuestionAction"],
        ["title":"Bottom", "action":"showViewFromBottomAction"],
        ["title":"Hide", "action":"hideAnyPopupAction"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.samplePopupView.hidden = true
    }
    
    
    func showViewFromTopAction() {
        
        let popup = APNotificationAlertView.popupWithView(self.samplePopupView)
        
        popup.show()
        
    }
    
    func showViewFromBottomAction() {
        
        let popup = APNotificationAlertView.popupWithView(self.samplePopupView)
        
        popup.position = APNotificationAlertViewPosition.Bottom
        
        popup.height = 150
        
        popup.show()
        
    }
    
    
    func showTextFromTopAction() {
        
        let popup = APNotificationAlertView.popupWithText("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.")
        
        popup.hideAfterDelay = 3
        
        popup.animationDuration = 1
        
        popup.show()
         
    }

  
    func showDialogAction() {
        
        let question = "Lorem ipsum dolor sit amet?"
        
        let buttonTitles = ["Yes", "No", "Oh No!"]
        
        let popup = APNotificationAlertView.popupDialogWithText(question, options: buttonTitles)
        
        popup.customCompletionHandler = {
            (index: Int) -> Void in
            
            APNotificationAlertView.hideAnimated(true)
            
            let alert = UIAlertController(title: "Taped button", message: "at index: \(index)", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Ok",
                style: UIAlertActionStyle.Default,
                handler: { (action) -> Void in
                    
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)   
        
        }
        
        popup.animationDuration = 1
        
        popup.show()
        
    }
    
    func showQuestionAction(){
    
        let question = "Lorem ipsum dolor sit amet?"
        
        let popup = APNotificationAlertView.popupWithQuestion(question)
        
        popup.customCompletionHandler = {
            (index: Int) -> Void in
            
            APNotificationAlertView.hideAnimated(true)
            
            print("Taped button at index: \(index)")
            
        }
        
        popup.show()
        
    }
    
    func hideAnyPopupAction() {
        
        APNotificationAlertView.hideAnimated(true)
        
    }
    
    
    //Sample View
    
    @IBAction func hideFromPopupAction(sender: AnyObject) {
        
        APNotificationAlertView.hideAnimated(true)
        
    }
    
    @IBAction func valueSelectorAction(sender: UISlider) {
        
        self.valueLabel.text = "Lorem ipsum dolor \(sender.value)"
        
    }
    
    //CollectionView
    
    internal func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return dataSource.count
    
    }
    

    internal func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
   
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LabelCollectionViewCell", forIndexPath: indexPath) as! LabelCollectionViewCell
        
        cell.label.text = self.dataSource[indexPath.row]["title"]
        
        return cell
    }
    
    internal func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        let action = self.dataSource[indexPath.row]["action"]!
        
        self.performSelector( Selector(action) )
    
    
    }
    

    
    
    
}

