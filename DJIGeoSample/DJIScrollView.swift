//
//  DJIScrollView.swift
//  MediaManagerDemo
//
//  Created by Samuel Scherer on 4/14/21.
//  Copyright © 2021 DJI. All rights reserved.
//

import Foundation
import UIKit

class DJIScrollView : UIView, UIScrollViewDelegate {
    
    var fontSize : Float?
    var title : NSString?
    var statusTextView : UILabel?

    @IBOutlet var view: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    public class func viewWith(viewController:UIViewController) -> DJIScrollView {
        let scrollView = DJIScrollView()
        viewController.view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.setup()
        scrollView.setDefaultSize()
        
        scrollView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor).isActive = true
        scrollView.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor).isActive = true
        
        scrollView.isHidden = true
        return scrollView
    }
    
    public func setup() {
        //Bundle.main.loadNibNamed(NSStringFromClass(type(of: self.self)), owner: self, options: nil)
        //TODO: use type(of:) to get class type
        Bundle.main.loadNibNamed("DJIScrollView", owner: self, options: nil)
        self.addSubview(self.view)
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.2
        self.layer.borderColor = UIColor.gray.cgColor
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        let statusTextViewRect = CGRect(x: 10,
                                        y: 0,
                                        width: self.scrollView.frame.size.width - 15,
                                        height: self.scrollView.frame.size.height)
        
        self.statusTextView = UILabel(frame: statusTextViewRect)
        self.statusTextView?.numberOfLines = 0
        self.statusTextView?.font = UIFont.systemFont(ofSize: 15)
        self.statusTextView?.textAlignment = NSTextAlignment.left
        self.statusTextView?.backgroundColor = UIColor.clear
        self.statusTextView?.textColor = UIColor.white
        
        //TODO: revisit these force unwraps, check how cristina did UXSDK UIKit autolayout unwrapping
        self.scrollView.contentSize = (self.statusTextView?.bounds.size)!
        self.scrollView.addSubview(self.statusTextView!)
        self.scrollView.layer.borderColor = UIColor.black.cgColor
        self.scrollView.layer.borderWidth = 1.3
        self.scrollView.layer.cornerRadius = 3.0
        self.scrollView.layer.masksToBounds = true
        self.scrollView.isPagingEnabled = false
    }
    
    public func write(status:NSString) {//TODO: once usages are swift, use String not NSString
        self.statusTextView?.text = status as String
    }
    
    public func show() {
        self.superview?.bringSubviewToFront(self)//TODO: unnecessary?
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1.0
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
    }
    
    @IBAction func onCloseButtonClicked(_ sender: Any) {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0;
        }
    }
    
    public func setDefaultSize() {
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        //TODO: still have to use CGFloats/rects?
        let heightOffset = CGFloat(UIDevice().userInterfaceIdiom == UIUserInterfaceIdiom.pad ? 120.0 : 60.0)
        
        let screenRect = UIScreen.main.bounds
        let height = screenRect.size.height - heightOffset
        let width = screenRect.size.width
  
        self.view.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        self.view.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
        //TODO: unwrap these more appropriately?
        self.statusTextView?.translatesAutoresizingMaskIntoConstraints = false
        
        self.statusLabel.rightAnchor.constraint(equalTo: self.scrollView.leftAnchor).isActive = true
        self.statusTextView?.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        self.statusTextView?.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
    }

    
}
