//
//  KKLayout.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/16.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import Foundation

public extension KKElement {
    
    public func layout(_ size:CGSize) -> Void {
        
        let v = get(KKProperty.Layout) as! KKLayout?;
        
        if(v != nil) {
            v!.layout(self, size);
        }
        
    }
    
    public func layoutChildren() -> Void {
        
        let v = get(KKProperty.Layout) as! KKLayout?;
        
        if(v != nil) {
            _ = v!.layoutChildren(self);
        }
    }
    
}

open class KKLayout {
    
    public func layout(_ element:KKElement,_ size:CGSize) -> Void {
        
        let width = element.get(KKProperty.Width, defaultValue: KKValue.Zero)
        let height = element.get(KKProperty.Height, defaultValue: KKValue.Zero)
        
        var frame = element.get(KKProperty.Frame, defaultValue: CGRect.zero)
        
        frame.size.width = width.isAuto() ? 0 : width.floatValue(size.width)
        frame.size.height = height.isAuto() ? 0 : height.floatValue(size.height)
        
        if(width.isAuto() || height.isAuto()) {
            
            element.set(KKProperty.Frame,frame)
            
            let v:KKLayout? = element.get(KKProperty.Layout) as! KKLayout?
            var contentSize:CGSize = CGSize.zero
            
            if(v != nil) {
                contentSize = v!.layoutChildren(element)
            }
            
            if(width.isAuto()) {
                
                let max = element.get(KKProperty.MaxWidth, defaultValue: KKValue.Zero)
                let min = element.get(KKProperty.MinWidth, defaultValue: KKValue.Zero)
                
                frame.size.width = contentSize.width
                
                if( !max.isZero() ) {
                    let vv = max.floatValue(size.width)
                    if(frame.size.width > vv) {
                        frame.size.width = vv
                    }
                }
                
                if( !min.isZero() ) {
                    let vv = min.floatValue(size.width)
                    if(frame.size.width < vv) {
                        frame.size.width = vv
                    }
                }
                
            }
            
            if(height.isAuto()) {
                
                let max = element.get(KKProperty.MaxHeight, defaultValue: KKValue.Zero)
                let min = element.get(KKProperty.MinHeight, defaultValue: KKValue.Zero)
                
                frame.size.height = contentSize.height
                
                if( !max.isZero() ) {
                    let vv = max.floatValue(size.height)
                    if(frame.size.height > vv) {
                        frame.size.height = vv
                    }
                }
                
                if( !min.isZero() ) {
                    let vv = min.floatValue(size.height)
                    if(frame.size.height < vv) {
                        frame.size.height = vv
                    }
                }
                
            }

            element.set(KKProperty.Frame,frame)

        }
        else {
            
            element.set(KKProperty.Frame,frame)
            
            let v:KKLayout? = element.get(KKProperty.Layout) as! KKLayout?
            
            if(v != nil) {
                _ = v!.layoutChildren(element)
            }
            
        }
        
    }
    
    public func layoutChildren(_ element:KKElement) -> CGSize {
        let v = element.get(KKProperty.Frame, defaultValue: CGRect.zero)
        return v.size
    }
    
    public static func valueOf(_ value:String) -> KKLayout? {

        if(value == "relative") {
            return KKRelativeLayout.init()
        }
        else if(value == "flow") {
            return KKFlowLayout.init(nowarp: false)
        }
        else if(value == "flow-nowarp") {
            return KKFlowLayout.init(nowarp: false)
        }
        else if(value == "none") {
            return KKLayout.init()
        }
        
        return nil
    }
    
    open class KKRelativeLayout : KKLayout {
     
        override public func layoutChildren(_ element:KKElement) -> CGSize {
            var size:CGSize = CGSize.zero
            let padding = element.get(KKProperty.Padding, defaultValue: KKEdge.Zero)
            var frame = element.get(KKProperty.Frame, defaultValue: CGRect.zero)
            let paddingLeft = padding.left.floatValue(frame.size.width)
            let paddingTop = padding.top.floatValue(frame.size.height)
            let paddingRight = padding.right.floatValue(frame.size.width)
            let paddingBottom = padding.bottom.floatValue(frame.size.height)
            let width = element.get(KKProperty.Width, defaultValue: KKValue.Zero)
            let height = element.get(KKProperty.Width, defaultValue: KKValue.Zero)
            
            if(width.isAuto()) {
                frame.size.width = CGFloat.init(Int32.max)
            }
            
            if(height.isAuto()) {
                frame.size.height = CGFloat.init(Int32.min)
            }
            
            let inSize = CGSize.init(width: frame.size.width - paddingLeft - paddingRight, height: frame.size.height - paddingTop - paddingBottom)
            
            size.width = paddingLeft + paddingRight
            size.height = paddingTop + paddingBottom
            
            var p = element.firstChild
            
            while(p != nil) {
                
                let layout = p!.get(KKProperty.Layout) as! KKLayout?
                
                if(layout != nil) {
                    
                    layout!.layout(p!, inSize)
                    
                    var r = p!.get(KKProperty.Frame, defaultValue: CGRect.zero)
                    let left = p!.get(KKProperty.Left, defaultValue: KKValue.Zero)
                    let right = p!.get(KKProperty.Right, defaultValue: KKValue.Zero)
                    let top = p!.get(KKProperty.Top, defaultValue: KKValue.Zero)
                    let bottom = p!.get(KKProperty.Bottom, defaultValue: KKValue.Zero)
                    
                    if(left.isAuto()) {
                        if(right.isAuto()) {
                            r.origin.x = paddingLeft + (inSize.width - r.size.width) * 0.5
                        }
                        else {
                            r.origin.x = paddingLeft + (inSize.width - r.size.width - right.floatValue(inSize.width))
                        }
                    }
                    
                    if(top.isAuto()) {
                        if(bottom.isAuto()) {
                            r.origin.y = paddingTop + (inSize.height - r.size.height) * 0.5
                        }
                        else {
                            r.origin.y = paddingTop + (inSize.height - r.size.height - bottom.floatValue(inSize.height))
                        }
                    }
                    else {
                        r.origin.y = paddingTop + top.floatValue(inSize.height)
                    }
                    
                    if(r.origin.x + r.size.width + paddingRight > size.width) {
                        size.width = r.origin.x + r.size.width + paddingRight
                    }
                    
                    if(r.origin.y + r.size.height + paddingBottom > size.height) {
                        size.height = r.origin.y + r.size.height + paddingBottom
                    }
                    
                    p!.set(KKProperty.Frame,r)
                    
                }
                
                p = p!.nextSibling
            }
            
            element.set(KKProperty.ContentSize,size)
            
            return size
        }
        
    }
    
    open class KKFlowLayout : KKLayout {
        
        private let _nowarp:Bool
        
        public init(nowarp:Bool) {
            _nowarp = nowarp
            super.init()
        }
        
        override public func layoutChildren(_ element:KKElement) -> CGSize {
            var size:CGSize = CGSize.zero
            let padding = element.get(KKProperty.Padding, defaultValue: KKEdge.Zero)
            var frame = element.get(KKProperty.Frame, defaultValue: CGRect.zero)
            let paddingLeft = padding.left.floatValue(frame.size.width)
            let paddingTop = padding.top.floatValue(frame.size.height)
            let paddingRight = padding.right.floatValue(frame.size.width)
            let paddingBottom = padding.bottom.floatValue(frame.size.height)
            let width = element.get(KKProperty.Width, defaultValue: KKValue.Zero)
            let height = element.get(KKProperty.Width, defaultValue: KKValue.Zero)
            
            if(width.isAuto()) {
                frame.size.width = CGFloat.init(Int32.max)
            }
            
            if(height.isAuto()) {
                frame.size.height = CGFloat.init(Int32.min)
            }
            
            let inSize = CGSize.init(width: frame.size.width - paddingLeft - paddingRight, height: frame.size.height - paddingTop - paddingBottom)
            
            var p:CGPoint = CGPoint.init(x: paddingLeft, y: paddingTop)
            var lineHeight:CGFloat = 0
            var maxWidth = frame.size.width
            
            let v = element.get(KKProperty.MaxWidth, defaultValue: KKValue.Zero)
            if(width.isAuto() && !v.isZero()) {
                maxWidth = v.floatValue(frame.size.width)
            }
        
            var e = element.firstChild
            
            while(e != nil) {
                
                let layout = e!.get(KKProperty.Frame) as! KKLayout?
                let hidden = e!.get(KKProperty.Hidden, defaultValue: false)
                
                if(layout != nil && !hidden) {
                    
                    let margin = e!.get(KKProperty.Margin, defaultValue:KKEdge.Zero)
                    let marginLeft = margin.left.floatValue(inSize.width)
                    let marginTop = margin.top.floatValue(inSize.height)
                    let marginRight = margin.right.floatValue(inSize.width)
                    let marginBottom = margin.bottom.floatValue(inSize.height)
                    
                    layout?.layout(e!, CGSize.init(width: inSize.width - marginLeft - marginRight, height: inSize.height - marginTop - marginBottom))
                    
                    var r = e!.get(KKProperty.Frame, defaultValue:CGRect.zero)
                    
                    if(_nowarp || (p.x + r.size.width + marginLeft + marginRight <= maxWidth - paddingRight)) {
                        r.origin.x = p.x + marginLeft
                        r.origin.y = p.y + marginTop
                        
                        p.x += r.size.width + marginLeft + marginRight
                        
                        if(lineHeight < r.size.height + marginTop + marginBottom) {
                            lineHeight = r.size.height + marginTop + marginBottom
                        }
                        if(size.width < p.x + paddingRight) {
                            size.width = p.x + paddingRight
                        }
                    }
                    else {
                        p.x = paddingLeft
                        p.y += lineHeight
                        lineHeight = r.size.height + marginTop + marginBottom
                        r.origin.x = p.x + marginLeft
                        r.origin.y = p.y + marginTop
                        p.x += r.size.width + marginLeft + marginRight
                        if(size.width < p.x + paddingRight) {
                            size.width = p.x + paddingRight
                        }
                    }
                    
                    e!.set(KKProperty.Frame,r)
                    
                }
                
                e = e!.nextSibling
            }
            
            size.height = p.y + lineHeight + paddingBottom
            
            element.set(KKProperty.ContentSize,size)
            
            return size
        }
    }
}
