//
//  KKProperty.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/15.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import UIKit
import KKObserver

public enum VerticalAlignment : Int {
    case top;
    case middle;
    case bottom;
}

public struct KKProperty : Hashable {
    
    public typealias Function = (KKProperty,Any?)->Any?

    public let name:String;
    public let function:Function;
    public let virtual:Bool;
    
    public static let ObjectFunction = {(property:KKProperty,value:Any?)->Any? in
        return value;
    
    };
    
    public var hashValue: Int {
        return name.hashValue;
    }
    
    public static func == (lhs: KKProperty, rhs: KKProperty) -> Bool {
        return lhs.name == rhs.name;
    }
    
    public func valueOf(_ value:Any?) -> Any? {
        return function(self,value);
    }
    
    public static let ColorFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        if(value is UIColor) {
            return value as! UIColor;
        }
        
        if(value is String || value is NSString) {
            
            let v:String = value as! String;
            
            if(v == "clear") {
                return UIColor.clear;
            }
            
            let vs:[String] = v.components(separatedBy: " ");
            let vv:String = vs[0];
            var alpha:Float = 1.0;
            var r:Int = 0;
            var g:Int = 0;
            var b:Int = 0;
            var a:Int = 0;
            
            if(vv.hasPrefix("#")) {
                let len:Int = vv.lengthOfBytes(using: String.Encoding.utf8);
                if(len == 4) {
                    r = Int.init(vv.substring(with: vv.index(vv.startIndex, offsetBy: 1)..<vv.index(vv.startIndex, offsetBy: 2)), radix: 16)!;
                    g = Int.init(vv.substring(with: vv.index(vv.startIndex, offsetBy: 2)..<vv.index(vv.startIndex, offsetBy: 3)), radix: 16)!;
                    b = Int.init(vv.substring(with: vv.index(vv.startIndex, offsetBy: 3)..<vv.index(vv.startIndex, offsetBy: 4)), radix: 16)!;
                    r = r | (r << 4);
                    g = g | (g << 4);
                    b = b | (b << 4);
                }
                else if(len == 7) {
                    r = Int.init(vv.substring(with: vv.index(vv.startIndex, offsetBy: 1)..<vv.index(vv.startIndex, offsetBy: 3)), radix: 16)!;
                    g = Int.init(vv.substring(with: vv.index(vv.startIndex, offsetBy: 3)..<vv.index(vv.startIndex, offsetBy: 5)), radix: 16)!;
                    b = Int.init(vv.substring(with: vv.index(vv.startIndex, offsetBy: 5)..<vv.index(vv.startIndex, offsetBy: 7)), radix: 16)!;
                }
                else if(len == 9) {
                    a = Int.init(vv.substring(with: vv.index(vv.startIndex, offsetBy: 1)..<vv.index(vv.startIndex, offsetBy: 3)), radix: 16)!;
                    r = Int.init(vv.substring(with: vv.index(vv.startIndex, offsetBy: 3)..<vv.index(vv.startIndex, offsetBy: 4)), radix: 16)!;
                    g = Int.init(vv.substring(with: vv.index(vv.startIndex, offsetBy: 5)..<vv.index(vv.startIndex, offsetBy: 7)), radix: 16)!;
                    b = Int.init(vv.substring(with: vv.index(vv.startIndex, offsetBy: 7)..<vv.index(vv.startIndex, offsetBy: 9)), radix: 16)!;
                    alpha = Float.init(Double(a) / 255.0);
                }
            }
            
            if(vs.count > 1) {
                alpha = Float.init(vs[1])!;
            }
            
            return UIColor.init(red:CGFloat.init(Double(r) / 255.0),green:CGFloat.init(Double(r) / 255.0),blue:CGFloat.init(Double(r) / 255.0),alpha:CGFloat.init(alpha));
            
        }
        
        return nil;
    
    };
    
    public static let FontFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        if(value is UIFont) {
            return value as! UIFont;
        }
        
        if(value is String || value is NSString) {
            
            let v:String = value as! String;
            
            let vs:[String] = v.components(separatedBy: " ");
            var bold:Bool = false;
            var italic:Bool = false;
            var name:String? = nil;
            var size:KKValue = KKValue.Zero;
            
            for vv:String in vs {
                if( vv == "bold") {
                    bold = true;
                }
                else if(vv == "italic") {
                    italic = true;
                }
                else if(vv.hasSuffix("dp") || vv.hasSuffix("px") || vv.hasSuffix("sp")) {
                    size = KKValue.valueOf(vv);
                }
                else {
                    name = vv;
                }
            }
            
            if(bold) {
                return UIFont.boldSystemFont(ofSize:CGFloat.init(size.floatValue(0)));
            }
            
            if(italic) {
                return UIFont.italicSystemFont(ofSize:CGFloat.init(size.floatValue(0)));
            }
            
            if(name != nil) {
                return UIFont.init(name:name!,size:CGFloat.init(size.floatValue(0)));
            }
            
            return UIFont.systemFont(ofSize:CGFloat.init(size.floatValue(0)));
        }
        
        
        return nil;
    };

    public static let TextAlignmentFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return NSTextAlignment.left;
        }
        
        if(value is NSTextAlignment) {
            return value as! NSTextAlignment;
        }
        
        if(value is String || value is NSString) {
            
            let v:String = value as! String;
            
            if(v == "center") {
                return NSTextAlignment.center;
            }

            if(v == "right") {
                return NSTextAlignment.right;
            }
            
            if(v == "justified") {
                return NSTextAlignment.justified;
            }
            
            if(v == "natural") {
                return NSTextAlignment.natural;
            }
            
        }
        
        return NSTextAlignment.left;
    };
    
    public static let VerticalAlignmentFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return VerticalAlignment.top;
        }
        
        if(value is VerticalAlignment) {
            return value as! VerticalAlignment;
        }
        
        if(value is String || value is NSString) {
            
            let v:String = value as! String;
            
            if(v == "middle") {
                return VerticalAlignment.middle;
            }
            
            if(v == "bottom") {
                return VerticalAlignment.bottom;
            }
        }
        
        return VerticalAlignment.top;
    };

    public static let StringFunction = {(property:KKProperty,value:Any?)->Any? in
        return KKObject.stringValue(value,nil);
    };
    
    public static let BooleanFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        return KKObject.booleanValue(value,false);
    };
    
    public static let KKValueFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        if(value is KKValue) {
            return value as! KKValue;
        }
        
        if(value is String || value is NSString) {
            
            let v:String = value as! String;
            
            return KKValue.valueOf(v);
        }
        
        return nil;
    };
    
    public static let KKEdgeFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        if(value is KKEdge) {
            return value as! KKEdge;
        }
        
        if(value is String || value is NSString) {
            
            let v:String = value as! String;
            
            return KKEdge.valueOf(v);
        }
        
        return nil;
    };
    
    public static let CGFloatFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        if(value is CGFloat) {
            return value as! CGFloat;
        }
    
        return CGFloat.init(KKObject.floatValue(value,0));
    };
    
    public static let IntFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        return KKObject.intValue(value,0);
    };
    
    public static let FloatFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        return KKObject.floatValue(value,0);
    };
    
    public static let CGSizeFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        if(value is CGSize) {
            return value as! CGSize;
        }
        
        if(value is String || value is NSString) {
            
            let v:String = value as! String;
            
            return CGSizeFromString(v);
        }

        
        return nil;
    };
    
    public static let CGRectFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        if(value is CGRect) {
            return value as! CGRect;
        }
        
        if(value is String || value is NSString) {
            
            let v:String = value as! String;
            
            return CGRectFromString(v);
        }
        
        
        return nil;
    };
    
    public static let UIBarStyleFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        if(value is UIBarStyle) {
            return value as! UIBarStyle;
        }
        
        if(value is String || value is NSString) {
            
            let v:String = value as! String;
            
            if(v == "translucent") {
                return UIBarStyle.blackTranslucent;
            }
            else if(v == "black") {
                return UIBarStyle.black;
            }
            else {
                return UIBarStyle.default
            }

        }
        
        
        return nil;
    };
    
    public static let KKPointFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        if(value is KKPoint) {
            return value as! KKPoint;
        }
        
        if(value is String || value is NSString) {
            
            let v:String = value as! String;
            
            return KKPoint.valueOf(v);
            
        }
        
        
        return nil;
    };
    
    public static let KKSizeFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        if(value is KKSize) {
            return value as! KKPoint;
        }
        
        if(value is String || value is NSString) {
            
            let v:String = value as! String;
            
            return KKSize.valueOf(v);
            
        }
        
        
        return nil;
    };

    
    public static let ClassFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        if(value is AnyClass) {
            return value as! AnyClass;
        }
        
        if(value is String || value is NSString) {
            
            let v:String = value as! String;
            
            return NSClassFromString(v);
            
        }
        
        
        return nil;
    };
    
    public static let ImageFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        if(value is UIImage) {
            return value as! UIImage;
        }
        
        return nil;
    };
    
    public static let KKStyleFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        if(value is KKStyle) {
            return value as! KKStyle;
        }
        
        if(value is String || value is NSString) {
            
            let v:String = value as! String;
            
            return KKStyle.valueOf(v);
            
        }
        
        return nil;
    };
    
    public static let KKObserverFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        if(value is KKObserver) {
            return value as! KKObserver;
        }
        
        return nil;
    };
    
    public static let KKWithObserverFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        if(value is KKWithObserver) {
            return value as! KKWithObserver;
        }
        
        return nil;
    };
    
    public static let KKLayoutFunction = {(property:KKProperty,value:Any?)->Any? in
        
        if(value == nil) {
            return nil;
        }
        
        if(value is KKLayout) {
            return value as! KKLayout;
        }
        
        if(value is String || value is NSString) {
            
            let v:String = value as! String;
            
            return KKLayout.valueOf(v);
            
        }
        
        return nil;
    };
    
    public static let BackgroundColor:KKProperty = KKProperty.init(name: "background-color", function: KKProperty.ColorFunction, virtual: false);
    
    public static let BorderColor:KKProperty = KKProperty.init(name: "border-color", function: KKProperty.ColorFunction, virtual: false);
    
    public static let BorderWidth:KKProperty = KKProperty.init(name: "border-width", function: KKProperty.KKValueFunction, virtual: false);
    
    public static let BorderRadius:KKProperty = KKProperty.init(name: "border-radius", function: KKProperty.KKValueFunction, virtual: false);
    
    public static let Font:KKProperty = KKProperty.init(name: "font", function: KKProperty.FontFunction, virtual: false);
    
    public static let Color:KKProperty = KKProperty.init(name: "color", function: KKProperty.ColorFunction, virtual: false);
    
    public static let TextAlign:KKProperty = KKProperty.init(name: "text-align", function: KKProperty.TextAlignmentFunction, virtual: false);
    
    public static let VerticalAlign:KKProperty = KKProperty.init(name: "vertical-align", function: KKProperty.VerticalAlignmentFunction, virtual: false);
    
    public static let Hidden:KKProperty = KKProperty.init(name: "hidden", function: KKProperty.BooleanFunction, virtual: false);
    
    public static let Enabled:KKProperty = KKProperty.init(name: "enabled", function: KKProperty.BooleanFunction, virtual: false);
    
    public static let Selected:KKProperty = KKProperty.init(name: "selected", function: KKProperty.BooleanFunction, virtual: false);
    
    public static let Highlighted:KKProperty = KKProperty.init(name: "highlighted", function: KKProperty.BooleanFunction, virtual: false);
    
    public static let Status:KKProperty = KKProperty.init(name: "status", function: KKProperty.StringFunction, virtual: false);
    
    public static let InStatus:KKProperty = KKProperty.init(name: "in-status", function: KKProperty.StringFunction, virtual: false);
    
    public static let Name:KKProperty = KKProperty.init(name: "name", function: KKProperty.StringFunction, virtual: false);
    
    public static let TType:KKProperty = KKProperty.init(name: "type", function: KKProperty.StringFunction, virtual: false);
    
    public static let Selector:KKProperty = KKProperty.init(name: "selector", function: KKProperty.StringFunction, virtual: false);
    
    public static let Source:KKProperty = KKProperty.init(name: "source", function: KKProperty.ObjectFunction, virtual: false);
    
    public static let Target:KKProperty = KKProperty.init(name: "target", function: KKProperty.StringFunction, virtual: false);
    
    public static let Key:KKProperty = KKProperty.init(name: "key", function: KKProperty.StringFunction, virtual: false);
    
    public static let ContentInest:KKProperty = KKProperty.init(name: "content-inest", function: KKProperty.KKEdgeFunction, virtual: false);
    
    public static let ScrollInest:KKProperty = KKProperty.init(name: "scroll-inest", function: KKProperty.KKEdgeFunction, virtual: false);
    
    public static let TintColor:KKProperty = KKProperty.init(name: "tint-color", function: KKProperty.ColorFunction, virtual: false);
    
    public static let BarTintColor:KKProperty = KKProperty.init(name: "bar-tint-color", function: KKProperty.ColorFunction, virtual: false);
    
    public static let BarStyleColor:KKProperty = KKProperty.init(name: "bar-style", function: KKProperty.UIBarStyleFunction, virtual: false);
    
    public static let ShadowColor:KKProperty = KKProperty.init(name: "shadow-color", function: KKProperty.ColorFunction, virtual: false);
    
    public static let ShadowOffset:KKProperty = KKProperty.init(name: "shadow-offset", function: KKProperty.KKSizeFunction, virtual: false);
    
    public static let ShadowRadius:KKProperty = KKProperty.init(name: "shadow-radius", function: KKProperty.KKValueFunction, virtual: false);
    
    public static let ShadowOpacity:KKProperty = KKProperty.init(name: "shadow-opacity", function: KKProperty.CGFloatFunction, virtual: false);
    
    public static let Opacity:KKProperty = KKProperty.init(name: "opacity", function: KKProperty.KKValueFunction, virtual: false);
    
    public static let Left:KKProperty = KKProperty.init(name: "left", function: KKProperty.KKValueFunction, virtual: false);
    
    public static let Top:KKProperty = KKProperty.init(name: "top", function: KKProperty.KKValueFunction, virtual: false);
 
    public static let Right:KKProperty = KKProperty.init(name: "right", function: KKProperty.KKValueFunction, virtual: false);
    
    public static let Bottom:KKProperty = KKProperty.init(name: "bottom", function: KKProperty.KKValueFunction, virtual: false);
    
    public static let Width:KKProperty = KKProperty.init(name: "width", function: KKProperty.KKValueFunction, virtual: false);
    
    public static let MaxWidth:KKProperty = KKProperty.init(name: "max-width", function: KKProperty.KKValueFunction, virtual: false);
    
    public static let MinWidth:KKProperty = KKProperty.init(name: "min-width", function: KKProperty.KKValueFunction, virtual: false);
    
    public static let Height:KKProperty = KKProperty.init(name: "height", function: KKProperty.KKValueFunction, virtual: false);
    
    public static let MaxHeight:KKProperty = KKProperty.init(name: "max-height", function: KKProperty.KKValueFunction, virtual: false);
    
    public static let MinHeight:KKProperty = KKProperty.init(name: "min-height", function: KKProperty.KKValueFunction, virtual: false);
    
    public static let Padding:KKProperty = KKProperty.init(name: "padding", function: KKProperty.KKEdgeFunction, virtual: false);
    
    public static let Margin:KKProperty = KKProperty.init(name: "margin", function: KKProperty.KKEdgeFunction, virtual: false);
    
    public static let Reuse:KKProperty = KKProperty.init(name: "reuse", function: KKProperty.StringFunction, virtual: false);
    
    public static let Class:KKProperty = KKProperty.init(name: "class", function: KKProperty.ClassFunction, virtual: false);
    
    public static let Src:KKProperty = KKProperty.init(name: "src", function: KKProperty.StringFunction, virtual: false);
    
    public static let DefaultSrc:KKProperty = KKProperty.init(name: "default-src", function: KKProperty.StringFunction, virtual: false);
    
    public static let FailSrc:KKProperty = KKProperty.init(name: "fail-src", function: KKProperty.StringFunction, virtual: false);
    
    public static let Action:KKProperty = KKProperty.init(name: "action", function: KKProperty.StringFunction, virtual: false);
    
    public static let LongAction:KKProperty = KKProperty.init(name: "long-action", function: KKProperty.StringFunction, virtual: false);
    
    public static let X:KKProperty = KKProperty.init(name: "x", function: KKProperty.KKValueFunction, virtual: false);
    
    public static let Y:KKProperty = KKProperty.init(name: "y", function: KKProperty.KKValueFunction, virtual: false);
    
    public static let ToX:KKProperty = KKProperty.init(name: "to-x", function: KKProperty.KKValueFunction, virtual: false);
    
    public static let ToY:KKProperty = KKProperty.init(name: "to-y", function: KKProperty.KKValueFunction, virtual: false);

    public static let Duration:KKProperty = KKProperty.init(name: "duration", function: KKProperty.CGFloatFunction, virtual: false);
    
    public static let Autoreverse:KKProperty = KKProperty.init(name: "autoreverse", function: KKProperty.BooleanFunction, virtual: false);
    
    public static let ReplayCount:KKProperty = KKProperty.init(name: "replay-count", function: KKProperty.IntFunction, virtual: false);
    
    public static let AfterDelay:KKProperty = KKProperty.init(name: "after-delay", function: KKProperty.CGFloatFunction, virtual: false);
    
    public static let ToOpacity:KKProperty = KKProperty.init(name: "to-opacity", function: KKProperty.CGFloatFunction, virtual: false);
    
    public static let Degrees:KKProperty = KKProperty.init(name: "degrees", function: KKProperty.FloatFunction, virtual: false);
    
    public static let ToDegrees:KKProperty = KKProperty.init(name: "to-degrees", function: KKProperty.FloatFunction, virtual: false);
    
    public static let Animation:KKProperty = KKProperty.init(name: "animation", function: KKProperty.StringFunction, virtual: false);
    
    public static let Image:KKProperty = KKProperty.init(name: "image", function: KKProperty.ImageFunction, virtual: false);
    
    public static let Text:KKProperty = KKProperty.init(name: "text", function: KKProperty.StringFunction, virtual: false);
    
    public static let Gravity:KKProperty = KKProperty.init(name: "gravity", function: KKProperty.StringFunction, virtual: false);
    
    public static let PageCount:KKProperty = KKProperty.init(name: "page-count", function: KKProperty.IntFunction, virtual: false);

    public static let PageIndex:KKProperty = KKProperty.init(name: "page-index", function: KKProperty.IntFunction, virtual: false);
    
    public static let Property:KKProperty = KKProperty.init(name: "property", function: KKProperty.StringFunction, virtual: false);
    
    public static let Object:KKProperty = KKProperty.init(name: "object", function: KKProperty.ObjectFunction, virtual: false);

    public static let Style:KKProperty = KKProperty.init(name: "style", function: KKProperty.KKStyleFunction, virtual: false);
    
    public static let Observer:KKProperty = KKProperty.init(name: "observer", function: KKProperty.KKObserverFunction, virtual: true);
    
    public static let WithObserver:KKProperty = KKProperty.init(name: "with-observer", function: KKProperty.KKObserverFunction, virtual: true);
    
    public static let Frame:KKProperty = KKProperty.init(name: "frame", function: KKProperty.CGRectFunction, virtual: false);
    
    public static let ContentSize:KKProperty = KKProperty.init(name: "contentSize", function: KKProperty.KKLayoutFunction, virtual: false);
    
    public static let Layout:KKProperty = KKProperty.init(name: "layout", function: KKProperty.CGSizeFunction, virtual: false);
}
