//
//  KKEventEmitter.swift
//  KKView
//
//  Created by zhanghailong on 2016/10/17.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import Foundation

open class KKEvent : NSObject {
    
}

open class KKEventEmitter : NSObject {
    
    public typealias Function = (String,KKEvent,AnyObject?)->Void
    
    private var callbacks:Array<KKEventCallback> = []
    
    public func emit(_ name:String,_ event:KKEvent) {
        
        var cbs:Array<KKEventCallback> = []
        
        for cb in callbacks {
            if cb.fn != nil && name.hasPrefix(cb.name)  {
                cbs.append(cb)
            }
        }
        
        for cb in cbs {
            cb.fn!(name,event,cb.weakObject)
        }
        
    }
    
    public func on(_ name:String,_ fn:Function?,_ weakObject:AnyObject?) {
        callbacks.append(KKEventCallback.init(name:name,fn:fn,weakObject:weakObject))
    }
    
    public func off(_ name:String?,_ weakObject:AnyObject?) {
        var i:Int = 0
        while i < callbacks.count {
            let cb = callbacks[i]
            if (name == nil || cb.name == name) && ( weakObject == nil || cb.weakObject === weakObject) {
                callbacks.remove(at: i)
                continue
            }
            i += 1
        }
    }
    
}

private class KKEventCallback : NSObject {
    
    var name:String
    var fn:KKEventEmitter.Function?
    weak var weakObject:AnyObject?
    
    init(name:String,fn:KKEventEmitter.Function?,weakObject:AnyObject?) {
        self.name = name
        self.fn = fn
        self.weakObject = weakObject
        super.init()
    }
    
}
