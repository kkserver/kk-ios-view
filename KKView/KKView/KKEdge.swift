//
//  KKEdge.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/15.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import Foundation


public struct KKEdge {
    
    public var left:KKValue;
    public var top:KKValue;
    public var right:KKValue;
    public var bottom:KKValue;
    
    public static let Zero:KKEdge = KKEdge.init(left: KKValue.Zero, top: KKValue.Zero, right: KKValue.Zero, bottom: KKValue.Zero)
    
    public static func valueOf(_ value:String)->KKEdge {
        
        var v:KKEdge = KKEdge.init(left: KKValue.Zero, top: KKValue.Zero, right: KKValue.Zero, bottom: KKValue.Zero);
        
        let vs:[String] = value.components(separatedBy: " ");
        
        if(vs.count > 0) {
            v.left = KKValue.valueOf(vs[0]);
            
            if(vs.count > 1) {
                v.top = KKValue.valueOf(vs[1]);
                if(vs.count > 2) {
                    v.right = KKValue.valueOf(vs[2]);
                    if(vs.count > 3) {
                        v.bottom = KKValue.valueOf(vs[4]);
                    }
                    else {
                        v.bottom = v.top;
                    }
                }
                else {
                    v.right = v.left;
                    v.bottom = v.top;
                }
            }
            else {
                v.right = v.left;
                v.top = v.left;
                v.bottom = v.left;
            }
        }
        
        return v;
    }
}
