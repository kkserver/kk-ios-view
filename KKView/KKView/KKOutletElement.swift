//
//  KKOutletElement.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/26.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import UIKit
import KKObserver

public extension KKElement {

    public func set(outlet:KKOutletElement, prop:KKProperty, value:Any?) ->Void {
        set(prop, value);
    }
    
}

open class KKOutletElement: KKScriptElement {

    public static let Done:NSObject = NSObject.init()
    
    private var _fn:KKScriptElementFunction?
    
    override internal func onRunScript(_ runnable:KKScriptElementRunnable) ->Void {
    
        let text = get(KKProperty.Text, defaultValue: "")
        
        if(text != "") {
            _fn = runnable.compile(code: text as NSString);
        }

    }
    
    override internal func onPropertyChanged(_ property:KKProperty,_ value:Any?,_ newValue:Any?) {
        
        if(property == KKProperty.WithObserver) {
            
            let obs = newValue as! KKWithObserver?
            
            if(obs != nil) {
                
                let name = get(KKProperty.Name,defaultValue: "")
                
                let prop = KKStyle.get(name)
                
                if prop != nil {
                    
                    onValueChanged(observer: obs!, changedKeys: [], prop: prop!, value: obs!.get([]));
                    
                    obs!.on([], { (obs:KKObserver, changedKeys:[String], weakObject:AnyObject?) in
                        if(weakObject != nil) {
                            (weakObject as! KKOutletElement?)!.onValueChanged(observer: obs, changedKeys: changedKeys,prop: prop!, value: obs.get([]));
                        }
                        }, self);
                }
                
            }
            
        }
        
        super.onPropertyChanged(property, value, newValue);
    }
    
    internal func onValueChanged(observer:KKObserver, changedKeys:[String], prop:KKProperty, value: Any?) ->Void {
        
        var v = value;
        
        if(_fn != nil) {
            let object = NSMutableDictionary.init(capacity: 4)
            object["value"] = value
            object["element"] = self
            object["observer"] = observer
            object["changedKeys"] = changedKeys
            v = _fn!.invoke(object: object)
        }
        
        if(v != nil && v is NSObject && (v as! NSObject) == KKOutletElement.Done) {
            
        } else {
            
            let target = self.value(forKeyPath: get(KKProperty.Target, defaultValue: "parent")) as! KKElement?
            
            if(target != nil) {
                target!.set(outlet: self, prop: prop, value: v);
            }
        }
    }
}
