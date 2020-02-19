//
//  BaseAlertView.swift
//  AlertDemo
//
//  Created by mingqi.yin on 2020/2/19.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class BaseAlertView: UIView {
    /// when use RPBaseAlertView,
    /// you should bind backgroundView/bgViewBottomConstraint to your xib
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var bgViewBottomConstraint: NSLayoutConstraint!
    
    static var alertView: BaseAlertView? = nil
        
        class func show() {
            
            let view = self.sharedInstance()
            view.frame = CGRect(x: 0, y: 0,
                                width: UIScreen.main.bounds.width,
                                height: UIScreen.main.bounds.height)
            view.backgroundColor = UIColor.black.withAlphaComponent(0)
            let bgHeight = view.backgroundView.frame.height
            view.bgViewBottomConstraint.constant = -bgHeight
            view.layoutIfNeeded()
            UIApplication.shared.keyWindow?.addSubview(view)
            
            UIView.animate(withDuration: 0.2) {
                view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                view.bgViewBottomConstraint.constant = 0
                view.layoutIfNeeded()
            }
        }
        
        class func hidden() {
            let view = self.sharedInstance()
            
            UIView.animate(withDuration: 0.2, animations: {
                view.backgroundColor = UIColor.black.withAlphaComponent(0)
                
                let bgHeight = view.backgroundView.frame.height
                view.bgViewBottomConstraint.constant = -bgHeight
                
                view.layoutIfNeeded()
            }) { (finish) in
                if finish {
                    
                    ///if you have some class of alert,  add `alertView = nil`
                    //alertView = nil
                    
                    view.removeFromSuperview()
                    
                }
            }
        }
        
        class func sharedInstance() -> BaseAlertView {
            if  alertView == nil {
                alertView = self.create()
                return alertView!
            }
            return alertView!
        }
        
        class func create() -> BaseAlertView {
            /// AlertDemo.DemoAlertView -> DemoAlertView
            let className = NSStringFromClass(self)
            
            print("====\(className)======")
            
            let range: Range = className.range(of: ".")!
            let location: Int = className.distance(from: className.startIndex, to: range.upperBound)
            let subClassName = className.suffix(className.count - location)
            
            let view =  Bundle.main.loadNibNamed(
                String(subClassName),
                owner: self,
                options: nil)?.first as! BaseAlertView
            return view
        }
        
        override func awakeFromNib() {
            super.awakeFromNib()
            
            addPanGR()
        }
        
        func addPanGR() {
            
            let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panAction(gesture:)))
            backgroundView.addGestureRecognizer(pan)
            
        }
        

        @objc private func panAction(gesture: UIPanGestureRecognizer) {
            
            let panPoint = gesture.translation(in: backgroundView)
            let orginY: CGFloat = 0
            let defaultY: CGFloat = -20
            
            if panPoint.y > 0 {
                /// down
                bgViewBottomConstraint.constant = -panPoint.y
                
            } else if panPoint.y < 0 {
                /// up
                if bgViewBottomConstraint.constant - panPoint.y < 0 {
                    bgViewBottomConstraint.constant = -panPoint.y
                }
            }
            if gesture.state == .failed || gesture.state == .ended {
                if gesture.view?.center.y ?? 0 > backgroundView.frame.origin.y {
                    if bgViewBottomConstraint.constant < defaultY {
                        BaseAlertView.hidden()
                    } else {
                        bgViewBottomConstraint.constant = orginY
                    }
                }
            }
            layoutIfNeeded()
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            for touch in touches {
                if touch.view?.isDescendant(of: backgroundView) ?? false {
                    return
                }
                BaseAlertView.hidden()
            }
        }
    }

