//
//  KKSize.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/16.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import Foundation


public struct KKSize {
    
    public static let Zero = KKSize.init(width: KKValue.Zero, height: KKValue.Zero)
    
    public var width:KKValue;
    public var height:KKValue;
    
    public static func valueOf(_ value:String)->KKSize {
        
        var v:KKSize = KKSize.init(width: KKValue.Zero, height: KKValue.Zero);
        
        let vs:[String] = value.components(separatedBy: " ");
        
        if(vs.count > 0) {
            
            v.width = KKValue.valueOf(vs[0]);
            
            if(vs.count > 1) {
                v.height = KKValue.valueOf(vs[1]);
            }
            
        }
        
        return v;
    }
    
}
