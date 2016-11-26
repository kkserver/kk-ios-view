//
//  KKPoint.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/15.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import Foundation

public struct KKPoint {
    public var x:KKValue;
    public var y:KKValue;
    
    public static func valueOf(_ value:String)->KKPoint {
        
        var v:KKPoint = KKPoint.init(x: KKValue.Zero, y: KKValue.Zero);
        
        let vs:[String] = value.components(separatedBy: " ");
        
        if(vs.count > 0) {
            
            v.x = KKValue.valueOf(vs[0]);
            
            if(vs.count > 1) {
                v.y = KKValue.valueOf(vs[1]);
            }
            
        }
        
        return v;
    }
    
}

