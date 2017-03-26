//
//  KKViewElement.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/26.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import UIKit

open class KKViewElement: KKElement,KKViewElementProtocol , KKLayerElementProtocol{
    
    public class func defaultView() -> UIView {
        return UIView.init(frame: CGRect.zero)
    }
    
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
    }
    
    public required init() {
        _view = UIView.init(frame: CGRect.zero)
        super.init()
    }
    
    public required init(element: KKElement) {
        _view = type(of: (element as! KKViewElementProtocol).view).init(frame: CGRect.zero);
        super.init(element:element)
    }
    
    public required init(style: KKStyle) {
        
        let v = style.get(KKProperty.View, "")
        
        if(v == nil) {
            _view = type(of: self).defaultView()
        }
        else {
            _view = (v! as! UIView.Type).init(frame:CGRect.zero);
        }
        
        super.init(style:style)
    }
    
    internal override func onInit() ->Void {
        super.onInit()
        set(KKProperty.Layout,"relative");
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
        
        let view = _view
        
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
                view.layer.borderWidth = v!.floatValue(view.bounds.size.width);
            }
        }
        else if(property == KKProperty.BorderRadius) {
            
            let v = newValue as! KKValue?
            
            if(v == nil) {
                view.layer.cornerRadius = 0;
            }
            else {
                view.layer.cornerRadius = v!.floatValue(view.bounds.size.width)
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
                view.layer.shadowRadius = v!.floatValue(view.bounds.size.width)
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
                view.layer.shadowOffset = CGSize.init(width: v!.width.floatValue(view.bounds.size.width), height: v!.height.floatValue(view.bounds.size.height));
            }
        }
        else if(property == KKProperty.Animation) {
            
            if(newValue == nil) {
                view.layer.removeAllAnimations()
            } else {
                let doc = document
                if(doc != nil){
                    let anim = doc!.getAnimation(newValue as! String)
                    if anim != nil {
                        view.layer.add(anim!, forKey: newValue as? String)
                    }
                }
            }
            
        } else if(property == KKProperty.Clips) {
            view.clipsToBounds = newValue == nil ? false : newValue as! Bool
        } else if(property == KKProperty.MaskColor) {
            if newValue == nil {
                view.layer.mask = nil
            } else {
                var f = view.layer.bounds
                f.origin = CGPoint.zero
                let mask = CALayer.init()
                mask.frame = f
                mask.backgroundColor = (newValue as! UIColor).cgColor
                view.layer.mask = mask
            }
        } else if(property == KKProperty.Enabled) {
            if view is UIControl {
                (view as! UIControl).isEnabled = newValue == nil ? true : newValue as! Bool
            } else {
                view.isUserInteractionEnabled = newValue == nil ? true : newValue as! Bool
            }
        } else if(property == KKProperty.Selected) {
            if view is UIControl {
                (view as! UIControl).isSelected = newValue == nil ? false : newValue as! Bool
            }
        }
        
        if view is UIScrollView {
            
            let scrollView = view as! UIScrollView
            
            if property == KKProperty.ContentSize
                || property == KKProperty.MinContentSize
                || property == KKProperty.Frame {
                let e = self
                let frame = e.get(KKProperty.Frame, defaultValue: CGRect.zero)
                var contentSize = e.get(KKProperty.ContentSize, defaultValue: CGSize.zero)
                let minSize = e.get(KKProperty.MinContentSize, defaultValue: KKSize.Zero)
                let size = CGSize.init(width: minSize.width.floatValue(frame.size.width), height: minSize.height.floatValue(frame.size.height))
                if contentSize.width < size.width {
                    contentSize.width = size.width
                }
                if contentSize.height < size.height {
                    contentSize.height = size.height
                }
                scrollView.contentSize = contentSize
            } else if(property == KKProperty.PagingEnabled) {
                scrollView.isPagingEnabled = newValue as! Bool
            } else if(property == KKProperty.ScrollbarY) {
                scrollView.showsVerticalScrollIndicator = newValue as! Bool
            } else if(property == KKProperty.ScrollbarX) {
                scrollView.showsHorizontalScrollIndicator = newValue as! Bool
            } else if(property == KKProperty.ContentInest) {
                let v = newValue as! KKEdge
                scrollView.contentInset = UIEdgeInsetsMake(v.top.floatValue(0), v.left.floatValue(0), v.bottom.floatValue(0), v.right.floatValue(0))
            }
        }
        
        if view is KKElementPropertyProtocol {
            (view as! KKElementPropertyProtocol).setElement(self, property: property, value: value, newValue: newValue)
        }
  
        super.onPropertyChanged(property, value, newValue)
    }

    
}
