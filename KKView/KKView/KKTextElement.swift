//
//  KKTextElement.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/16.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import Foundation

open class KKTextElement :KKCanvasElement {
 
    open class Layout : KKLayout {
        
        public override func layoutChildren(_ element:KKElement) -> CGSize {
            let width = element.get(KKProperty.Width, defaultValue: KKValue.Zero)
            let height = element.get(KKProperty.Height, defaultValue: KKValue.Zero)
            var frame = element.get(KKProperty.Frame, defaultValue: CGRect.zero)
            
            
            if width.isAuto() || height.isAuto() {
                
                let e = element as! KKTextElement
                
                if width.isAuto() {
                    frame.size.width = CGFloat.greatestFiniteMagnitude
                }
                
                if height.isAuto() {
                    frame.size.height = CGFloat.greatestFiniteMagnitude
                }
                
                let bounds = e.bounds(size: frame.size)
                
                var size = bounds.size
                
                if width.isAuto() {
                    
                    let min = element.get(KKProperty.MinWidth, defaultValue: KKValue.Zero)
                    if !min.isZero()  {
                        let v = min.floatValue(frame.size.width)
                        if size.width < v {
                            size.width = v
                        }
                    }
                    let max = element.get(KKProperty.MaxWidth, defaultValue: KKValue.Zero)
                    if !max.isZero()  {
                        let v = max.floatValue(frame.size.width)
                        if size.width > v {
                            size.width = v
                        }
                    }
                } else {
                    size.width = width.floatValue(frame.size.width)
                }
                
                if height.isAuto() {
                    
                    let min = element.get(KKProperty.MinHeight, defaultValue: KKValue.Zero)
                    if !min.isZero()  {
                        let v = min.floatValue(frame.size.height)
                        if size.height < v {
                            size.height = v
                        }
                    }
                    let max = element.get(KKProperty.MaxHeight, defaultValue: KKValue.Zero)
                    if !max.isZero()  {
                        let v = max.floatValue(frame.size.height)
                        if size.height > v {
                            size.height = v
                        }
                    }
                } else {
                    size.height = height.floatValue(frame.size.height)
                }
                
                size.width = ceil(size.width)
                size.height = ceil(size.height)
                
                return size
            }
            
            return frame.size
        }
        
    }
    
    open class TextElement: KKElement {
        
        internal override func onPropertyChanging(_ property:KKProperty,_ value:Any?,_ newValue:Any?) -> Bool {
            
            if property == KKProperty.Layout {
                return false;
            }
            
            return super.onPropertyChanging(property, value, newValue)
        }

        
    }
    
    open class ImageElement : KKElement {
     
        private var _image:UIImage?
        
        public var image:UIImage? {
            get {
                if _image == nil {
                    _image = KKImageElement.imageWithURI(get(KKProperty.Src, defaultValue: ""))
                }
                return _image
            }
        }
        
        internal override func onPropertyChanging(_ property:KKProperty,_ value:Any?,_ newValue:Any?) -> Bool {
            
            if property == KKProperty.Layout {
                return false;
            }
            
            return super.onPropertyChanging(property, value, newValue)
        }
        
        public var bounds:CGRect {
            
            get {
                
                let image = self.image
                let width = get(KKProperty.Width, defaultValue:KKValue.Zero)
                let height = get(KKProperty.Height, defaultValue:KKValue.Zero)
                var r = CGRect.zero
                
                if width.isAuto() {
                    
                    if image != nil {
                        r.size.width = image!.size.width
                    } else {
                        r.size.width = 0
                    }
                    
                    let min = get(KKProperty.MinWidth, defaultValue:KKValue.Zero)
                    
                    if r.size.width < min.floatValue(0) {
                        r.size.width = min.floatValue(0)
                    }
                    
                    let max = get(KKProperty.MaxWidth, defaultValue:KKValue.Zero)
                    
                    if r.size.width > max.floatValue(0) {
                        r.size.width = max.floatValue(0)
                    }
                    
                } else {
                    r.size.width = width.floatValue(0)
                }
                
                if height.isAuto() {
                    
                    if image != nil {
                        r.size.height = image!.size.height
                    } else {
                        r.size.height = 0
                    }
                    
                    let min = get(KKProperty.MinHeight, defaultValue:KKValue.Zero)
                    
                    if r.size.height < min.floatValue(0) {
                        r.size.height = min.floatValue(0)
                    }
                    
                    let max = get(KKProperty.MinHeight, defaultValue:KKValue.Zero)
                    
                    if r.size.height > max.floatValue(0) {
                        r.size.height = max.floatValue(0)
                    }
                    
                } else {
                    r.size.height = height.floatValue(0)
                }
                
                let margin = get(KKProperty.Margin, defaultValue: KKEdge.Zero)
                let padding = get(KKProperty.Padding, defaultValue: KKEdge.Zero)
                
                r.size.width += margin.left.floatValue(0) + margin.right.floatValue(0)
                r.size.height += margin.top.floatValue(0) + margin.bottom.floatValue(0)
                
                r.origin.x = padding.left.floatValue(0)
                r.origin.y = padding.top.floatValue(0)
                
                return r
            }
        }
    }
    
    public override class func defaultLayer() -> CALayer {
        return CATextLayer.init()
    }
    
    public func attributes(element:KKElement) -> Dictionary<String,Any> {
        
        var attrs = Dictionary<String,Any>.init()
        
       
        attrs[NSForegroundColorAttributeName] = get(KKProperty.Color, defaultValue: UIColor.black)
        attrs[NSFontAttributeName] = get(KKProperty.Font, defaultValue: UIFont.systemFont(ofSize: 14 * KKValue.UnitDP))
        
        let style = NSMutableParagraphStyle.init()
        
        style.alignment = get(KKProperty.TextAlign, defaultValue: NSTextAlignment.left)
        style.lineSpacing = get(KKProperty.LineSpacing, defaultValue: KKValue.Zero).floatValue(0)
        style.paragraphSpacing = get(KKProperty.ParagraphSpacing, defaultValue: KKValue.Zero).floatValue(0)
        
        if element != self {
            
            for (key,value) in element.values {
                if(key == KKProperty.Color) {
                    attrs[NSForegroundColorAttributeName] = value as! UIColor
                } else if(key == KKProperty.Font) {
                    attrs[NSFontAttributeName] = value as! UIFont
                } else if(key == KKProperty.TextAlign) {
                    style.alignment = value as! NSTextAlignment
                } else if(key == KKProperty.LineSpacing) {
                    style.lineSpacing = (value as! KKValue).floatValue(0)
                } else if(key == KKProperty.ParagraphSpacing) {
                    style.paragraphSpacing = (value as! KKValue).floatValue(0)
                }
            }
        
        }
        
        attrs[NSParagraphStyleAttributeName] = style
        
        return attrs
    }
    
    private var _string:NSAttributedString?
    
    public var string:NSAttributedString {
        
        get {
            
            if _string == nil {
                
                var p = self.firstChild
                
                if p == nil {
                    let string = get(KKProperty.Text,defaultValue:"")
                    _string = NSAttributedString.init(string: string, attributes: attributes(element: self))
                } else {
                    
                    let string = NSMutableAttributedString.init()
                    
                    while(p != nil) {
                        
                        if p is ImageElement {
                            
                            let e = p as! ImageElement?
                            let image = NSTextAttachment.init()
                            image.image = e!.image
                            image.bounds = e!.bounds
                            string.append(NSAttributedString.init(attachment: image))
                            
                        } else if( p is TextElement )  {
                            string.append(NSAttributedString.init(string: p!.get(KKProperty.Text, defaultValue:""), attributes: attributes(element: p!)))
                        }
                        
                        p = p!.nextSibling
                    }
                    
                    _string = string
                }
            }
            
            return _string!
        }
        
    }
    
    private var _size:CGSize = CGSize.zero
    private var _bounds:CGRect = CGRect.zero
    
    public func bounds(size:CGSize) -> CGRect {
        if !_size.equalTo(size) {
            _bounds = string.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            _size = size
        }
        return _bounds
    }
    
    override internal func onPropertyChanged(_ property:KKProperty,_ value:Any?,_ newValue:Any?) {
        super.onPropertyChanged(property, value, newValue);
        
        let layer = (self.layer as! CATextLayer)
        
        if(property == KKProperty.Text) {
            setNeedsDisplay()
        } else if(property == KKProperty.Font) {
            setNeedsDisplay()
        } else if(property == KKProperty.Color) {
            setNeedsDisplay()
        } else if(property == KKProperty.Wrap) {
            layer.isWrapped = newValue as! Bool
        } else if(property == KKProperty.Truncation) {
            layer.truncationMode = newValue as! String
        } else if(property == KKProperty.TextAlign) {
            let v = newValue as! NSTextAlignment
            switch v {
            case .center:
                layer.alignmentMode = "center"
                break
            case .left:
                layer.alignmentMode = "left"
                break
            case .right:
                layer.alignmentMode = "right"
                break
            case .justified:
                layer.alignmentMode = "justified"
                break
            case .natural:
                layer.alignmentMode = "natural"
                break;
            }
        }
        
    }

    private var _displaying:Bool = false
    
    public func setNeedsDisplay() ->Void {
        if _displaying {
            return
        }
        _displaying = true
        let e = self.layer as! CATextLayer
        let v = self
        
        DispatchQueue.main.async {
            v._string = nil
            v._size = CGSize.zero
            v._bounds = CGRect.zero
            e.string = v.string
            v._displaying = false
        }
        
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
    
    override public func newChildrenElement(_ name:String) -> KKElement? {
        if(name == "img") {
            return ImageElement.init(name: name)
        } else if(name == "span") {
            return TextElement.init(name: name)
        }
        return super.newChildrenElement(name)
    }
    
    override public func onAddChildren(_ element:KKElement) -> Void {
        super.onAddChildren(element)
        setNeedsDisplay()
    }
    
    override public func onRemoveChildren(_ element:KKElement) -> Void {
        super.onRemoveChildren(element)
        setNeedsDisplay()
    }
}

