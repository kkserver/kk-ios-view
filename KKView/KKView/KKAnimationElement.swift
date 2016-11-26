//
//  KKAnimationElement.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/26.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import Foundation

public class KKAnimationElement : KKElement {
    
    public func setAnimation(animation:CAAnimation) ->Void {
        
        animation.duration = get(KKProperty.Duration, defaultValue: 0.0)
        animation.repeatCount = get(KKProperty.ReplayCount, defaultValue: 0)
        animation.autoreverses = get(KKProperty.Autoreverse, defaultValue: false)
        animation.timeOffset = get(KKProperty.AfterDelay, defaultValue:0.0)
    
    }
    
    public func getAnimation() -> CAAnimation {
        
        let a = CAAnimationGroup.init();
        
        var animations:[CAAnimation] = []
        
        var p = firstChild
        
        while(p != nil) {
            
            if(p is KKAnimationElement) {
                animations.append((p as! KKAnimationElement).getAnimation())
            }
            
            p = p!.nextSibling
        }
        
        a.animations = animations
        
        setAnimation(animation: a)
        
        return a;
    }
}
