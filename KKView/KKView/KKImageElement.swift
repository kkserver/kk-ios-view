//
//  KKImageElement.swift
//  KKView
//
//  Created by 张海龙 on 2017/3/15.
//  Copyright © 2017年 kkserver.cn. All rights reserved.
//

import UIKit
import KKHttp

open class KKImageElement: KKCanvasElement {
    
    open class Layout : KKLayout {
        
        public override func layoutChildren(_ element:KKElement) -> CGSize {
            let width = element.get(KKProperty.Width, defaultValue: KKValue.Zero)
            let height = element.get(KKProperty.Height, defaultValue: KKValue.Zero)
            let frame = element.get(KKProperty.Frame, defaultValue: CGRect.zero)
            
            if width.isAuto() || height.isAuto() {
                
                var size = CGSize.init(width: frame.size.width, height: frame.size.height)
                
                let e = element as! KKImageElement
                
                let image = e.visibleImage
                
                if image != nil {
                    if width.isAuto() {
                        
                        size.width = image!.size.width
                        let min = element.get(KKProperty.MinWidth, defaultValue: KKValue.Zero)
                        if !min.isZero()  {
                            let v = min.floatValue(image!.size.width)
                            if size.width < v {
                                size.width = v
                            }
                        }
                        let max = element.get(KKProperty.MaxWidth, defaultValue: KKValue.Zero)
                        if !max.isZero()  {
                            let v = max.floatValue(image!.size.width)
                            if size.width > v {
                                size.width = v
                            }
                        }
                    }
                    
                    if height.isAuto() {
                        
                        size.height = image!.size.height
                        let min = element.get(KKProperty.MinHeight, defaultValue: KKValue.Zero)
                        if !min.isZero()  {
                            let v = min.floatValue(image!.size.height)
                            if size.height < v {
                                size.height = v
                            }
                        }
                        let max = element.get(KKProperty.MaxHeight, defaultValue: KKValue.Zero)
                        if !max.isZero()  {
                            let v = max.floatValue(image!.size.height)
                            if size.height > v {
                                size.height = v
                            }
                        }
                    }
                }
                
                return size
            }
            
            return frame.size
        }
        
    }
    
    enum Status {
        case None
        case Loading
        case Fail
    }
    
    private var _image:UIImage?
    private var _defaultImage:UIImage?
    private var _failImage:UIImage?
    private var _status:Status = .None
    private var _http:KKHttpTask?
    
    private static var _onload = { (image:Any?, error:Error?, element:AnyObject?) in
        if element != nil {
            let e = (element as! KKImageElement?)!
            if image != nil {
                e._status = .None
                e._image = image as! UIImage?
                e.layer.contents = e._image?.cgImage
            } else {
                e._status = .Fail
                e.layer.contents = e.visibleImage?.cgImage
            }
        }
    }
    
    private static var _onfail = { (error:Error?, element:AnyObject?) in
        if element != nil {
            let e = (element as! KKImageElement?)!
            e._status = .Fail
            e.layer.contents = e.visibleImage?.cgImage
        }
    }
    
    public static func imageWithURI(_ uri:String) ->UIImage? {
        if uri.hasPrefix("@") {
            return UIImage.init(named: uri.substring(from: uri.index(uri.startIndex, offsetBy: 1)))
        } else if uri.hasPrefix("/") {
            return UIImage.init(named: uri)
        } else {
            let (path,_,ok) = KKHttpOptions.cachePath(url: uri)
            if ok {
                return UIImage.init(named: path)
            }
        }
        return nil
    }
    
    public var visibleImage:UIImage? {
        get {
            var image = self.image
            if image == nil {
                
                if _status == .Fail {
                    image = self.failImage
                }
                
                if image == nil {
                    image = self.defaultImage
                }
            }
            return image
        }
    }
    
    public var image:UIImage? {
        
        get {
            if _image == nil {
                let v = get(KKProperty.Src, defaultValue: "")
                if v != "" {
                    _image = KKImageElement.imageWithURI(v)
                    if( _image == nil &&  _status == .None) {
                        _http?.cancel()
                        let options = KKHttpOptions.init(url: v)
                        options.type = KKHttpOptions.TypeImage
                        options.onLoad = KKImageElement._onload
                        options.onFail = KKImageElement._onfail
                        _http = try? KKHttp.main.send(options, self)
                        _status = .Loading
                    }
                }
            }
            return _image
        }
    }
    
    public var defaultImage:UIImage? {
        get {
            if _defaultImage == nil {
                let v = get(KKProperty.DefaultSrc, defaultValue: "")
                if v != "" {
                    _defaultImage = KKImageElement.imageWithURI(v)
                }
            }
            return _defaultImage
        }
    }
    
    public var failImage:UIImage? {
        get {
            if _failImage == nil {
                let v = get(KKProperty.FailSrc, defaultValue: "")
                if v != "" {
                    _failImage = KKImageElement.imageWithURI(v)
                }
            }
            return _failImage
        }
    }
    
    override internal func onPropertyChanged(_ property:KKProperty,_ value:Any?,_ newValue:Any?) {
        
        if(property == KKProperty.Src
            || property == KKProperty.DefaultSrc
            || property == KKProperty.FailSrc) {
            
            if(property == KKProperty.Src) {
                _http?.cancel()
                _http = nil
                _status = .None
            }
            
            let image = self.visibleImage
           
            if image == nil {
                self.layer.contents = nil
            } else {
                self.layer.contents = image?.cgImage
            }
        }
        
        super.onPropertyChanged(property, value, newValue);
    }
    
    internal override func onInit() ->Void {
        super.onInit()
        set(KKProperty.Layout,Layout.init())
        set(KKProperty.Width,"auto")
        set(KKProperty.Height,"auto")
    }
    
    internal override func onPropertyChanging(_ property:KKProperty,_ value:Any?,_ newValue:Any?) -> Bool {
        
        if property == KKProperty.Layout {
            if newValue == nil || newValue is Layout {
                return true
            }
            return false;
        }
        
        return super.onPropertyChanging(property, value, newValue)
    }
    
}
