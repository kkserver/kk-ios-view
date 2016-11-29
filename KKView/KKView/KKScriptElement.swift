//
//  KKScriptElement.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/26.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import UIKit

@objc public protocol KKScriptElementFunction : NSObjectProtocol {
    
    func invoke(object:AnyObject?) -> AnyObject?
    
}


@objc public protocol KKScriptElementRunnable : NSObjectProtocol {
    
    func compile(code:NSString) -> KKScriptElementFunction?
    
}

@objc public protocol KKScriptContext : NSObjectProtocol {
    
    func useScriptRunnable(type:String) -> KKScriptElementRunnable?
    
}


open class KKScriptElement: KKElement {

    public static func runScriptElement(_ element:KKElement,_ context:KKScriptContext) ->Void {
        
        if element is KKScriptElement {
            (element as! KKScriptElement).runScript(context);
        } else {
            
            var p = element.firstChild;
            
            while(p != nil) {
                KKScriptElement.runScriptElement(p!,context);
                p = p!.nextSibling;
            }
            
        }
    }
    
    public func runScript(_ context:KKScriptContext) ->Void {
        
        let type = get(KKProperty.TType, defaultValue: "")
        let runnable = context.useScriptRunnable(type: type)
        
        if(runnable != nil) {
            onRunScript(runnable!)
        }
        
    }
    
    internal func onRunScript(_ runnable:KKScriptElementRunnable) ->Void {
        
        let text = get(KKProperty.Text, defaultValue: "")
        
        if(text != "") {
            let fn = runnable.compile(code: text as NSString);
            if fn != nil {
                _ = fn!.invoke(object:self);
            }
        }
        
    }
}
