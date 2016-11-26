//
//  KKViewElement.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/26.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import UIKit

public class KKViewElement: KKElement,KKViewElementProtocol , KKLayerElementProtocol{
    
    private let _view:UIView;
    
    public var view:UIView {
        get {
            return _view;
        }
    }
    
    public var layer:CALayer {
        get {
            return _view.layer;
        }
    }
    
    public init(view:UIView) {
        _view = view
        super.init()
        onInit();
    }
    
    public required init() {
        _view = UIView.init(frame: CGRect.zero)
        super.init()
        onInit()
    }
    
    public required init(element: KKElement) {
        _view = type(of: (element as! KKViewElementProtocol).view).init(frame: CGRect.zero);
        super.init(element:element)
        onInit()
    }
    
    public required init(name: String) {
        
        var clazz:AnyClass? = nil
        
        if(name.contains(":")) {
            clazz = NSClassFromString(name.components(separatedBy: ":").last!)
        }
        
        if(clazz == nil) {
            _view = UIView.init(frame:CGRect.zero)
        }
        else {
            _view = (clazz! as! UIView.Type).init(frame:CGRect.zero);
        }
        
        super.init()
        onInit()
    }
    
    internal func onInit() ->Void {
    }
    
    override public func onAddToParent(_ element:KKElement) {
        
        if(element is KKViewElementProtocol) {
            let pview = (element as! KKViewElementProtocol).view
            pview.addSubview(_view)
        }
        
        super.onAddToParent(element)
    }
    
    override public func onRemoveFromParent(_ element:KKElement) {
        
        _view.removeFromSuperview()
        
        super.onRemoveFromParent(element)
    }
    
    override internal func onPropertyChanged(_ property:KKProperty,_ value:Any?,_ newValue:Any?) {
        _view.KKElementSetProperty(self, property, value, newValue)
        super.onPropertyChanged(property, value, newValue)
    }

    
}

public extension UIView {
    
    public func KKElementSetProperty(_ element:KKViewElement,_ property:KKProperty,_ value:Any?,_ newValue:Any?) -> Void {
        
        let view = element.view;
        
        if(property == KKProperty.Frame) {
            
            let frame:CGRect? = newValue as! CGRect?
            
            if(frame != nil) {
                view.frame = frame!
            }
            
        }
        else if(property == KKProperty.BackgroundColor) {
            let v = newValue as! UIColor?
            if(v == nil) {
                view.backgroundColor = nil
            }
            else {
                view.backgroundColor = v!;
            }
        }
        else if(property == KKProperty.BorderColor) {
            let v = newValue as! UIColor?
            if(v == nil) {
                view.layer.borderColor = nil
            }
            else {
                view.layer.borderColor = v!.cgColor;
            }
        }
        else if(property == KKProperty.BorderWidth) {
            let v = newValue as! KKValue?
            if(v == nil) {
                view.layer.borderWidth = 0;
            }
            else {
                view.layer.borderWidth = v!.floatValue(layer.bounds.size.width);
            }
        }
        else if(property == KKProperty.BorderRadius) {
            
            let v = newValue as! KKValue?
            
            if(v == nil) {
                view.layer.cornerRadius = 0;
            }
            else {
                view.layer.cornerRadius = v!.floatValue(layer.bounds.size.width)
            }
            
        }
        else if(property == KKProperty.Hidden) {
            view.isHidden = newValue as! Bool;
        }
        else if(property == KKProperty.Gravity) {
            let v = newValue as! String?
            if(v == nil) {
                view.layer.contentsGravity = "resize"
            }
            else {
                view.layer.contentsGravity = v!;
            }
        }
        else if(property == KKProperty.ShadowColor) {
            let v = newValue as! UIColor?
            if(v == nil) {
                view.layer.shadowColor = nil
            }
            else {
                view.layer.shadowColor = v!.cgColor;
            }
        }
        else if(property == KKProperty.ShadowRadius) {
            let v = newValue as! KKValue?
            
            if(v == nil) {
                view.layer.shadowRadius = 0;
            }
            else {
                view.layer.shadowRadius = v!.floatValue(layer.bounds.size.width)
            }
        }
        else if(property == KKProperty.ShadowOpacity) {
            view.layer.shadowOpacity = newValue as! Float
        }
        else if(property == KKProperty.ShadowOffset) {
            let v = newValue as! KKSize?
            if(v == nil) {
                view.layer.shadowOffset = CGSize.zero
            }
            else {
                view.layer.shadowOffset = CGSize.init(width: v!.width.floatValue(layer.bounds.size.width), height: v!.height.floatValue(layer.bounds.size.height));
            }
        }
        else if(property == KKProperty.Animation) {
            
            if(newValue == nil) {
                view.layer.removeAllAnimations()
            } else {
                let doc = element.document
                if(doc != nil){
                    let anim = doc!.getAnimation(newValue as! String)
                    if anim != nil {
                        view.layer.add(anim!, forKey: newValue as? String)
                    }
                }
            }
            
        }
        
    }

}
