//
//  KKControlElement.swift
//  KKView
//
//  Created by 张海龙 on 2017/3/15.
//  Copyright © 2017年 kkserver.cn. All rights reserved.
//

import UIKit
import KKObserver

open class KKControlElement: KKViewElement {
    

    public override class func defaultView() -> UIView {
        return UIControl.init(frame: CGRect.zero)
    }
    
    internal override func onInit() ->Void {
        super.onInit()
        (self.view as! UIControl).addTarget(self, action: #selector(KKControlElement.onAction), for: UIControlEvents.touchUpInside)
        self.view.addObserver(self, forKeyPath: "enabled", options: .new, context: nil)
        self.view.addObserver(self, forKeyPath: "highlighted", options: .new, context: nil)
        self.view.addObserver(self, forKeyPath: "selected", options: .new, context: nil)
    }
    
    deinit {
        self.view.removeObserver(self, forKeyPath: "enabled")
        self.view.removeObserver(self, forKeyPath: "highlighted")
        self.view.removeObserver(self, forKeyPath: "selected")
    }
    
    internal func onAction() ->Void {
        let name = get(KKProperty.Action,defaultValue:"")
        if name != "" {
            sendEvent(name, KKElementEvent.init(element: self))
        }
    }
    
    internal func refreshState() ->Void {
        
        let v = (self.view as! UIControl)
        if v.isEnabled {
            if v.isSelected {
                set(KKProperty.Status,"selected")
            } else if(v.isHighlighted) {
                set(KKProperty.Status,"hover")
            } else {
                set(KKProperty.Status,"")
            }
        } else {
            set(KKProperty.Status,"disabled")
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if(keyPath == "enabled" || keyPath == "highlighted" || keyPath == "selected") {
            refreshState()
        }
        
    }

    
}
