//
//  KKStyle.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/15.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import Foundation


public class KKStyle : NSObject{
    
    private static var _PropertyDictionary:Dictionary<String,KKProperty> = Dictionary.init();
    
    open override class func initialize() {
        super.initialize();
        
        for v in Propertys {
            _PropertyDictionary[v.name] = v;
        }
        
    }
    
    public static func get(_ name:String)->KKProperty? {
        return _PropertyDictionary[name];
    }
    
    public static let Propertys:[KKProperty] = [
        KKProperty.BackgroundColor,KKProperty.BorderColor,KKProperty.BorderWidth,KKProperty.BorderRadius,
        KKProperty.ShadowColor,KKProperty.ShadowOffset,KKProperty.ShadowRadius,KKProperty.ShadowOpacity,
        KKProperty.Font,KKProperty.Color,KKProperty.TextAlign,KKProperty.VerticalAlign,KKProperty.Hidden,
        KKProperty.Enabled,KKProperty.Selected,KKProperty.Opacity,
        KKProperty.Left,KKProperty.Top,KKProperty.Right,KKProperty.Bottom,
        KKProperty.Width,KKProperty.MaxWidth,KKProperty.MinWidth,KKProperty.Height,KKProperty.MaxHeight,KKProperty.MinHeight,
        KKProperty.Padding,KKProperty.Margin,KKProperty.Class,KKProperty.Src,KKProperty.DefaultSrc,KKProperty.FailSrc,
        KKProperty.Key,KKProperty.Name,KKProperty.TType,KKProperty.Property,KKProperty.Object,KKProperty.Action,
        KKProperty.LongAction,KKProperty.X,KKProperty.Y,KKProperty.ToX,KKProperty.ToY,KKProperty.Duration,KKProperty.Autoreverse,
        KKProperty.ReplayCount,KKProperty.AfterDelay,KKProperty.ToOpacity,KKProperty.Degrees,KKProperty.ToDegrees,
        KKProperty.Animation,KKProperty.Image,KKProperty.Text,KKProperty.Gravity,KKProperty.PageIndex,KKProperty.PageCount,
        KKProperty.TintColor
    ];
    
    private var _propertys:Set<KKProperty> = Set.init();
    private var _values:Dictionary<String,Dictionary<KKProperty,Any?>> = Dictionary.init()
    
    public var propertys:Set<KKProperty> {
        get {
            return _propertys;
        }
    }
    
    public func load(cssContent:String,status:String) {
        
        let items:[String] = cssContent.components(separatedBy: ";");
        
        for item in items {
            
            let kv:[String] = item.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                .components(separatedBy: ":");
            
            let key:String = kv[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines);
            
            let prop:KKProperty? = KKStyle.get(key);
            
            if(prop != nil) {
                let v:String? = kv.count > 1 ? kv[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) : nil;
                set(prop!, v , status);
            }
        }
        
    }
    
    public func set(_ property:KKProperty,_ value:Any?,_ status:String) -> Void {
    
        _propertys.insert(property);
        
        var vs:Dictionary<KKProperty,Any?>? = _values[status];
        
        if(vs == nil) {
            vs = Dictionary.init();
            _values[status] = vs!;
        }
        
        vs![property] = property.valueOf(value);
    }
    
    public func get(_ property:KKProperty,_ status:String) -> Any? {
        
        let vs:Dictionary<KKProperty,Any?>? = _values[status];
        
        if(vs != nil) {
            return vs![property];
        }
        
        return nil;
    }
    
    public func get<T>(_ property:KKProperty,_ status:String, defaultValue:T) -> T {
        let v:Any? = get(property,status);
        if(v == nil) {
            return defaultValue;
        }
        return v as! T;
    }

    
    public static func valueOf(_ value:String) -> KKStyle {
        let v:KKStyle = KKStyle.init();
        v.load(cssContent:value,status:"");
        return v;
    }
    
    public static func set(element:KKElement,_ name:String, _ value:Any?) ->Void {
        let prop = KKStyle.get(name);
        if(prop != nil) {
            element.set(prop!, value);
        }
    }
    
    public static func get(element:KKElement,_ name:String) ->Any? {
        let prop = KKStyle.get(name);
        if(prop != nil) {
            return element.get(prop!);
        }
        return nil;
    }
    
}
