//
//  KKScriptElement.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/26.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import UIKit

public protocol KKScriptElementFunction : NSObjectProtocol {
    
    func invoke(_ object:Any?) -> Any? ;
    
}


public protocol KKScriptElementRunnable : NSObjectProtocol {
    
    func compile(_ code:String) -> KKScriptElementFunction?;
    
}


public class KKScriptElement: KKElement {

    private static var _Runnables:Dictionary<String,KKScriptElementRunnable> = Dictionary.init();
    
    public static func use(_ type:String, _ runnable:KKScriptElementRunnable) {
        _Runnables[type] = runnable;
    }
    
    public static func runScriptElement(_ element:KKElement) ->Void {
        
        if element is KKScriptElement {
            (element as! KKScriptElement).runScript();
        } else {
            
            var p = element.firstChild;
            
            while(p != nil) {
                KKScriptElement.runScriptElement(p!);
                p = p!.nextSibling;
            }
            
        }
    }
    
    public func runScript() ->Void {
        
        let type = get(KKProperty.TType, defaultValue: "")
        let runnable = KKScriptElement._Runnables[type]
        
        if(runnable != nil) {
            onRunScript(runnable!)
        }
        
    }
    
    internal func onRunScript(_ runnable:KKScriptElementRunnable) ->Void {
        
        let text = get(KKProperty.Text, defaultValue: "")
        
        if(text != "") {
            let fn = runnable.compile(text);
            if fn != nil {
                _ = fn!.invoke(self);
            }
        }
        
    }
}
