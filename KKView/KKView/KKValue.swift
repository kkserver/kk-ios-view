//
//  KKValue.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/15.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import Foundation

public struct KKValue {
    
    public static let UnitAuto:CGFloat = -1.0;
    public static let UnitZero:CGFloat = 0;
    public static let UnitPX:CGFloat = 1.0;
    public static var UnitDP:CGFloat = 1.0;
    public static var UnitSP:CGFloat = 1.0;
    
    public static let Auto:KKValue = KKValue.init(ratio: 0, value: 0, unit: UnitAuto);
    public static let Zero:KKValue = KKValue.init(ratio: 0, value: 0, unit: 0);
    public static let AutoValue:CGFloat = CGFloat.init(Int32.max);
    
    
    public var ratio:CGFloat;
    public var value:CGFloat;
    public var unit:CGFloat;
    
    public func floatValue(_ baseValue:CGFloat) -> CGFloat {
        return unit == KKValue.UnitAuto ? KKValue.AutoValue : ratio * baseValue * 0.01 + value * unit;
    }
    
    public func isAuto()->Bool {
        return unit == KKValue.UnitAuto ;
    }
    
    public func isZero()->Bool {
        return unit == KKValue.UnitZero;
    }
    
    public static func valueOf(_ value:String)->KKValue {
        var v:KKValue = KKValue.init(ratio: 0, value: 0, unit: 0);
        
        if(value == "auto") {
            v.unit = KKValue.UnitAuto;
            return v;
        }
        
        if(value.hasSuffix("%")) {
            v.unit = KKValue.UnitPX;
            v.ratio = CGFloat.init(Float.init(value.substring(to:value.index(value.endIndex, offsetBy: -1)))!);
            return v;
        }
        
        let vs:[String] = value.components(separatedBy: "%");
        var vv:String = vs[0];
        
        if(vs.count > 1) {
            vv = vs[1];
            v.ratio = CGFloat.init(Float.init(vs[0])!);
        }
        
        if(vv.hasSuffix("px")) {
            v.value = CGFloat.init(Float.init(vv.substring(to:vv.index(vv.endIndex, offsetBy: -2)))!);
            v.unit = KKValue.UnitPX;
        }
        else if(vv.hasSuffix("dp")) {
            v.value = CGFloat.init(Float.init(vv.substring(to:vv.index(vv.endIndex, offsetBy: -2)))!);
            v.unit = KKValue.UnitDP;
        }
        else if(vv.hasSuffix("sp")) {
            v.value = CGFloat.init(Float.init(vv.substring(to:vv.index(vv.endIndex, offsetBy: -2)))!);
            v.unit = KKValue.UnitSP;
        }
        else {
            v.unit = KKValue.UnitPX;
        }
        
        return v;
    }
}
