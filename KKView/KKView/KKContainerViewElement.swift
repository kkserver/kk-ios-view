//
//  KKContainerViewElement.swift
//  KKView
//
//  Created by 张海龙 on 2017/3/9.
//  Copyright © 2017年 kkserver.cn. All rights reserved.
//

import UIKit
import KKObserver

open class KKContainerViewElement: KKViewElement ,UIScrollViewDelegate{

    public class Item {
        public let keys:String
        public let reuse:String
        public var frame:CGRect
        public var offset:CGPoint
        public var element:ItemElement?
        
        public init(keys:String,reuse:String,frame:CGRect,offset:CGPoint) {
            self.keys = keys
            self.reuse = reuse
            self.frame = frame
            self.offset = offset
            
        }
    }
    
    public class Container : NSObject {
        
        public var size:CGSize = CGSize.zero
        public var items = Array<Item>.init()
        public var cells = Dictionary<String,CellElement>.init()
        public var observer:KKObserver? = nil
        public var elements = NSMutableDictionary.init()
        
        public func enqueue(element:ItemElement) -> Void {
            let reuse = element.get(KKProperty.Reuse, defaultValue: "")
            let vs = elements[reuse]
            if vs == nil {
                elements[reuse] = NSMutableArray.init(object: element)
            } else {
                (vs as! NSMutableArray).add(element)
            }
        }
        
        public func dequeue(reuse:String) ->ItemElement {
            let vs = elements[reuse]
            let element = (vs as! NSMutableArray?)?.lastObject
            if element == nil {
                let cell = cells[reuse]
                if cell != nil {
                    return cell!.newElement(with: nil) as! ItemElement
                } else {
                    return ItemElement.init()
                }
            } else {
                (vs as! NSMutableArray?)?.removeLastObject()
            }
            return element as! ItemElement
        }
    }
    
    public class ItemElement: KKViewElement {
    }
    
    public class CellElement: KKElement {
        
        public var item:Item? = nil
        
        public func newElement(with zone: NSZone? = nil) -> KKElement {
            
            let v:KKElement = ItemElement.init()
            
            copyAttributes(v, with: zone)
            
            var p = firstChild;
            
            while(p != nil) {
                if( p is ReflectElementProtocol) {
                    
                }
                else {
                    (p!.copy(with: zone) as! KKElement).appendTo(v);
                }
                p = p!.nextSibling
            }
            
            return v;
        }
        
        override internal func onPropertyChanged(_ property:KKProperty,_ value:Any?,_ newValue:Any?) {
            
            if(property == KKProperty.Frame) {
                
                let v = newValue as! CGRect?
                
                if(v != nil && item != nil) {
                    item!.frame = v!
                    if item!.element != nil {
                        item!.element!.set(KKProperty.Frame, v!)
                        item!.element!.layoutChildren()
                    }
                }
                
            }
            
            super.onPropertyChanged(property, value, newValue);
        }
        
        override internal func onInit() ->Void {
            super.onInit()
            set(KKProperty.Layout,"relative")
        }
    }

    
    public class ItemIterator : KKElementBaseIterator {
        
        private let _container:Container
        private var _i = 0
        
        public init(container:Container) {
            _container = container;
            super.init()
        }
        
        override public func next() -> Element? {
            
            if _container.observer == nil {
                return nil
            }
            
            while(_i < _container.items.count) {
                
                let item = _container.items[_i]
                let cell = _container.cells[item.reuse]
                
                _i = _i + 1
                
                if cell == nil {
                    continue
                }
                
                cell!.item = item
                cell!.set(KKProperty.Key, item.keys)
                cell!.set(KKProperty.Observer, _container.observer)
                
                return cell
            }
            
            return nil
        }

    }
    
    override public class func defaultView() -> UIView {
        return UIScrollView.init(frame: CGRect.zero)
    }
    
    public required init() {
        super.init(view:UIScrollView.init(frame: CGRect.zero))
    }
    
    public required init(style: KKStyle) {
        super.init(style: style)
    }
    
    public required init(element: KKElement) {
        super.init(element: element)
    }
    
    deinit {
        self.view.removeObserver(self, forKeyPath: "contentOffset")
        (self.view as! UIScrollView).delegate = nil
    }
    
    internal override func onInit() ->Void {
        super.onInit()
        (self.view as! UIScrollView).delegate = self
        self.view.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    
    private let container = Container.init()
    
    public override func makeIterator() -> Iterator {
        return ItemIterator.init(container: container)
    }
    
    public func reloadData() {
        
        var p = firstChild
        var n:KKElement?
        
        while p != nil {
            if p is ItemElement {
                container.enqueue(element: (p as! ItemElement?)!)
                n = p!.nextSibling
                p!.remove()
                p = n
            } else {
                p = p!.nextSibling
            }
        }
        
        container.items.removeAll()
        
        let v = get(KKProperty.WithObserver) as! KKWithObserver?
        
        if v != nil {
            
            container.observer = v
            
            let reuseKey = get(KKProperty.ReuseKey, defaultValue: "reuse")
            let reuseKeys:[String] = reuseKey == "" ? [] : reuseKey.components(separatedBy: ".")
            
            KKObject.forEach(v!.get([])) { (key, value) in
                
                let reuse = reuseKeys.count == 0 ? "" : KKObject.stringValue(KKObject.get(value, reuseKeys),"")!
              
                container.items.append(Item.init(keys: KKObject.stringValue(key, "")!, reuse: reuse, frame: CGRect.zero, offset: CGPoint.zero))
                
            }
        
        } else {
            container.observer = nil
        }
       
        layoutChildren()
        reloadElements()
        
    }
    
    internal func isVisibleRect(frame:CGRect) -> Bool {
        var f = self.view.bounds
        if self.view is UIScrollView {
            f.origin = (self.view as! UIScrollView).contentOffset
        }
        let v = f.intersection(frame)
        return v.size.width > 0 && v.size.height > 0
    }
    
    public func reloadElements() {
        
        for item in container.items {
            
            if isVisibleRect(frame: item.frame) {
                
                if item.element == nil {
                    let e = container.dequeue(reuse: item.reuse)
                    e.set(KKProperty.Frame, item.frame)
                    e.set(KKProperty.ContentOffset, item.offset)
                    let obs = e.get(KKProperty.Observer) as? KKObserver
                    let key = e.get(KKProperty.Key) as? String
                    if obs != container.observer || key != item.keys {
                        e.set(KKProperty.Key,item.keys)
                        e.set(KKProperty.Observer,container.observer)
                        e.layoutChildren()
                    }
                    e.appendTo(self)
                    item.element = e
                }
                
            } else if(item.element != nil) {
                container.enqueue(element: item.element!)
                item.element!.remove()
                item.element = nil
            }
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
       
        if(keyPath == "contentOffset") {
            reloadElements()
        }
        
    }
    
    override internal func onPropertyChanged(_ property:KKProperty,_ value:Any?,_ newValue:Any?) {
        super.onPropertyChanged(property, value, newValue);
        
        if(property == KKProperty.ContentSize) {
            self.reloadElements()
        } else if(property == KKProperty.Frame) {
            let r = newValue as! CGRect
            container.size = r.size
        }
        
    }
    
    
    override public func obtainObserver(_ observer:KKObserver? ) -> Void {
        
        let key:String? = get(KKProperty.Key) as! String?;
        
        if key != nil {
            
            reloadData()
            
            observer!.on([], { ( _ observer :KKObserver, _ changedKeys:[String], _ weakObject:AnyObject?) in
                
                if weakObject != nil {
                    let v = weakObject! as! KKContainerViewElement
                    v.reloadData()
                }
                
            }, self)
        }
        
    }
    
    override public func newChildrenElement(_ name:String) -> KKElement? {
        if(name == "cell") {
            return CellElement.init()
        }
        return super.newChildrenElement(name)
    }
    
    override public func onAddChildren(_ element:KKElement) -> Void {
        super.onAddChildren(element)
        
        if(element is CellElement) {
            let reuse = element.get(KKProperty.Reuse, defaultValue: "")
            container.cells[reuse] = element as? CellElement
        }
        
    }
    
    override public func onRemoveChildren(_ element:KKElement) -> Void {
        super.onRemoveChildren(element)
        if(element is CellElement) {
            let reuse = element.get(KKProperty.Reuse, defaultValue: "")
            if container.cells[reuse] == element {
                container.cells.removeValue(forKey: reuse)
            }
        }
    }
    
}
