//
//  KKButton.swift
//  KKView
//
//  Created by 张海龙 on 2017/3/15.
//  Copyright © 2017年 kkserver.cn. All rights reserved.
//

import UIKit

open class KKButton: UIButton {

    private var _backgroundForState = Dictionary<UInt,UIColor>.init()
    
    public func backgroundColor(forState state:UIControlState) -> UIColor? {
        return _backgroundForState[state.rawValue]
    }
    
    public func setBackgroundColor(_ color:UIColor? ,forState state:UIControlState) ->Void {
        if color != nil {
            _backgroundForState[state.rawValue] = color
        } else {
            _backgroundForState.removeValue(forKey: state.rawValue)
        }
        refreshBackgroundColor()
    }
    
    internal func refreshBackgroundColor() -> Void {
        
        var v:UIColor? = nil
        
        if isEnabled {
            
            if isSelected {
                v = backgroundColor(forState: UIControlState.selected)
            } else if isHighlighted {
                v = backgroundColor(forState: UIControlState.highlighted)
            }
            
        } else {
            v = backgroundColor(forState: UIControlState.disabled)
        }
        
        if v == nil {
            v = backgroundColor(forState: UIControlState.normal)
        }
        
        self.backgroundColor = v
    }

    open override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set {
            super.isEnabled = newValue
            refreshBackgroundColor()
        }
    }
    
    open override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            super.isHighlighted = newValue
            refreshBackgroundColor()
        }
    }
    
    open override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            refreshBackgroundColor()
        }
    }
}
