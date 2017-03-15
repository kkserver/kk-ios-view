//
//  KKPagerViewElement.swift
//  KKView
//
//  Created by 张海龙 on 2017/3/15.
//  Copyright © 2017年 kkserver.cn. All rights reserved.
//

import UIKit
import KKObserver

open class KKPagerViewElement: KKContainerViewElement {

    internal override func onInit() ->Void {
        super.onInit()
        set(KKProperty.PagingEnabled,true)
        set(KKProperty.ScrollbarY,false)
        set(KKProperty.ScrollbarX,false)
    }
    
    private func toLocation(_ toBeginIndex:Bool) {
        let scrollView = self.view as! UIScrollView
        let size = scrollView.bounds.size
        
        if size.width > 0 {
            let count = Int.init(ceil(scrollView.contentSize.width / scrollView.bounds.size.width))
            let index = Int.init(ceil(scrollView.contentOffset.x / scrollView.bounds.size.width))
            if count >= 4 {
                if toBeginIndex {
                    scrollView.setContentOffset(CGPoint.init(x: size.width, y: 0), animated: false)
                } else if index == 0 {
                    scrollView.setContentOffset(CGPoint.init(x: CGFloat.init(count-2) * size.width, y: 0), animated: false)
                } else if(index + 1 == count) {
                    scrollView.setContentOffset(CGPoint.init(x: size.width, y: 0), animated: false)
                }
            }
            if toBeginIndex == false{
                let v = get(KKProperty.Action, defaultValue:"")
                if v != "" {
                    set(data: NSNumber.init(value: count), key: "count")
                    set(data: NSNumber.init(value: index), key: "index")
                    sendEvent(v, KKElementEvent.init(element: self))
                }
            }
        }
        
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
             toLocation(false)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        toLocation(false)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        toLocation(false)
    }
    
    
    override internal func onPropertyChanged(_ property:KKProperty,_ value:Any?,_ newValue:Any?) {
        super.onPropertyChanged(property, value, newValue);
        
        if(property == KKProperty.ContentSize) {
            toLocation(true)
        }
    }
}
