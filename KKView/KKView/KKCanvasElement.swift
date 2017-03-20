//
//  KKCanvasElement.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/16.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import Foundation

open class KKCanvasElement : KKElement,CALayerDelegate,KKLayerElementProtocol {

    public class func defaultLayer() -> CALayer {
        return CALayer.init()
    }
    
    private let _layer:CALayer;
    
    public var layer:CALayer {
        get {
            return _layer;
        }
    }
    
    public init(layer:CALayer) {
        _layer = layer
        super.init()
    }
    
    deinit {
        _layer.delegate = nil
    }
    
    public required init() {
        _layer = CALayer.init()
        super.init()
    }
    
    public required init(element: KKElement) {
        _layer = type(of: (element as! KKLayerElementProtocol).layer).init();
        super.init(element: element);
    }
    
    public required init(style: KKStyle) {
        
        let v = style.get(KKProperty.Layer, "")
        
        if(v == nil) {
            _layer = type(of: self).defaultLayer()
        }
        else {
            _layer = (v! as! CALayer.Type).init();
        }
    
        super.init(style: style)
    }
    
    internal override func onInit() ->Void {
        super.onInit()
        _layer.delegate = self
        _layer.contentsScale = UIScreen.main.scale
    }
    
    public func draw(_ layer: CALayer, in ctx: CGContext) {
        
    }
    
    override public func onAddToParent(_ element:KKElement) {
        
        if(element is KKLayerElementProtocol) {
            let pLayer = (element as! KKLayerElementProtocol).layer
            pLayer.addSublayer(_layer)
        }
        
        super.onAddToParent(element)
    }
    
    override public func onRemoveFromParent(_ element:KKElement) {
        
        _layer.removeFromSuperlayer()
        
        super.onRemoveFromParent(element)
    }
    
    override internal func onPropertyChanged(_ property:KKProperty,_ value:Any?,_ newValue:Any?) {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true);
        
        let layer = self.layer;
        
        if(property == KKProperty.Frame) {
            
            let frame:CGRect? = newValue as! CGRect?
            
            if(frame != nil) {
                layer.frame = frame!
            }
            
        }
        else if(property == KKProperty.BackgroundColor) {
            let v = newValue as! UIColor?
            if(v == nil) {
                layer.backgroundColor = nil
            }
            else {
                layer.backgroundColor = v!.cgColor;
            }
        }
        else if(property == KKProperty.BorderColor) {
            let v = newValue as! UIColor?
            if(v == nil) {
                layer.borderColor = nil
            }
            else {
                layer.borderColor = v!.cgColor;
            }
        }
        else if(property == KKProperty.BorderWidth) {
            let v = newValue as! KKValue?
            if(v == nil) {
                layer.borderWidth = 0;
            }
            else {
                layer.borderWidth = v!.floatValue(layer.bounds.size.width);
            }
        }
        else if(property == KKProperty.BorderRadius) {
            
            let v = newValue as! KKValue?
            
            if(v == nil) {
                layer.cornerRadius = 0;
            }
            else {
                layer.cornerRadius = v!.floatValue(layer.bounds.size.width)
            }
            
        }
        else if(property == KKProperty.Hidden) {
            layer.isHidden = newValue as! Bool;
        }
        else if(property == KKProperty.Gravity) {
            let v = newValue as! String?
            if(v == nil) {
                layer.contentsGravity = "resize"
            }
            else {
                layer.contentsGravity = v!;
            }
        }
        else if(property == KKProperty.ShadowColor) {
            let v = newValue as! UIColor?
            if(v == nil) {
                layer.shadowColor = nil
            }
            else {
                layer.shadowColor = v!.cgColor;
            }
        }
        else if(property == KKProperty.ShadowRadius) {
            let v = newValue as! KKValue?
            
            if(v == nil) {
                layer.shadowRadius = 0;
            }
            else {
                layer.shadowRadius = v!.floatValue(layer.bounds.size.width)
            }
        }
        else if(property == KKProperty.ShadowOpacity) {
            layer.shadowOpacity = newValue as! Float
        }
        else if(property == KKProperty.ShadowOffset) {
            let v = newValue as! KKSize?
            if(v == nil) {
                layer.shadowOffset = CGSize.zero
            }
            else {
                layer.shadowOffset = CGSize.init(width: v!.width.floatValue(layer.bounds.size.width), height: v!.height.floatValue(layer.bounds.size.height));
            }
        }
        else if(property == KKProperty.Animation) {
            
            if(newValue == nil) {
                layer.removeAllAnimations()
            } else {
                let doc = document
                if(doc != nil){
                    let anim = doc!.getAnimation(newValue as! String)
                    if anim != nil {
                        layer.add(anim!, forKey: newValue as? String)
                    }
                }
            }
            
        } else if(property == KKProperty.Clips) {
            layer.masksToBounds = newValue != nil ? newValue as! Bool : false
        } else if(property == KKProperty.MaskColor) {
            if newValue == nil {
                layer.mask = nil
            } else {
                var f = layer.bounds
                f.origin = CGPoint.zero
                let mask = CALayer.init()
                mask.frame = f
                mask.backgroundColor = (newValue as! UIColor).cgColor
                layer.mask = mask
            }
        }
        
        CATransaction.commit();
        
        if layer is KKElementPropertyProtocol {
            (layer as! KKElementPropertyProtocol).setElement(self, property: property, value: value, newValue: newValue)
        }
        
        super.onPropertyChanged(property, value, newValue)
    }
    
}


