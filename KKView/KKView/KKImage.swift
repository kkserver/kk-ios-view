//
//  KKImage.swift
//  KKView
//
//  Created by 张海龙 on 2017/3/20.
//  Copyright © 2017年 kkserver.cn. All rights reserved.
//

import UIKit
import KKHttp

public extension UIImage {
    
    public class func image(uri:String) -> UIImage? {
        if uri.hasPrefix("@") {
            return UIImage.init(named: uri.substring(from: uri.index(uri.startIndex, offsetBy: 1)))
        } else if uri.hasPrefix("/") {
            return UIImage.init(named: uri)
        } else {
            let (path,_,ok) = KKHttpOptions.cachePath(url: uri)
            if ok {
                return UIImage.init(named: path)
            }
        }
        return nil
    }
}
