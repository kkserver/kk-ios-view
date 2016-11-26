//
//  KKStyleSheet.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/15.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import Foundation

public class KKStyleSheet : NSObject {
    
    private var _styles:Dictionary<String,KKStyle> = Dictionary.init();
    
    public func get(_ name:String)-> KKStyle? {
        return _styles[name];
    }
    
    public func load(cssContent:String) {
        
        let items:[String] = cssContent.components(separatedBy: "}");
        
        for item in items {
            
            let nstyle:[String] = item.components(separatedBy: "{");
            
            if(nstyle.count > 1) {
                let nstatus:[String] = nstyle[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).components(separatedBy: ":");
                let name:String = nstatus[0];
                let status:String = nstatus.count > 1 ? nstatus[1] : "";
                var v:KKStyle? = _styles[name];
                if( v == nil) {
                    v = KKStyle.init();
                    _styles[name] = v!;
                }
                v!.load(cssContent: nstyle[1], status: status);
            }
            
        }
        
    }
    
    public static func valueOf(_ value:String)->KKStyleSheet {
        let v:KKStyleSheet = KKStyleSheet.init();
        v.load(cssContent: value);
        return v;
    }
    
    public func newElement(_ element:KKElement? ,_ name:String) -> KKElement {
        
        var e:KKElement? = nil
        
        if(element != nil) {
            e = element!.newChildrenElement(name);
        }
        
        if e == nil {
            
            let v = get(name)
            
            if(v != nil) {
                
                let vv = v!.get(KKProperty.Class, "", defaultValue:"KKElement")
                let clazz:AnyClass? = NSClassFromString(vv)
                
                if( clazz != nil) {
                    e = (clazz as! KKElement.Type).init(name: name)
                }
                
            }
        }
        
        if(e != nil) {
            return e!
        }
        
        return KKElement.init();
    }
}