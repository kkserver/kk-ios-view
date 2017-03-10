//
//  KKContainerViewElement.swift
//  KKView
//
//  Created by 张海龙 on 2017/3/9.
//  Copyright © 2017年 kkserver.cn. All rights reserved.
//

import UIKit
import KKObserver

open class KKContainerViewElement: KKViewElement {

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
        
        public var items = Array<Item>.init()
        public var cells = Dictionary<String,CellElement>.init()
        public var observer:KKObserver? = nil
        public var elements = Dictionary<String,Array<ItemElement>>.init()
        
        public func enqueue(element:ItemElement) -> Void {
            let reuse = element.get(KKProperty.Reuse, defaultValue: "")
            var vs = elements[reuse]
            if vs == nil {
                elements[reuse] = [element]
            } else {
                vs!.append(element)
            }
        }
        
        public func dequeue(reuse:String) ->ItemElement {
            let element = elements[reuse]?.popLast()
            if element == nil {
                let cell = cells[reuse]
                if cell != nil {
                    return cell!.copy(with: nil) as! ItemElement
                } else {
                    return ItemElement.init()
                }
            }
            return element!
        }
    }
    
    public class ItemElement: KKViewElement {
    }
    
    public class CellElement: KKElement {
        
        public let name:String
        public var item:Item? = nil
        
        public required init(name:String) {
            self.name = name
            super.init(name:name)
        }
        
        public required init(element: KKElement) {
            self.name = ""
            super.init(element:element)
        }
        
        public required init() {
            self.name = ""
            super.init()
        }
        
        public override func copyElement(with zone: NSZone? = nil) -> KKElement {
            
            let v:KKElement = ItemElement.init(name:name)
            
            for (key,value) in self.values {
                if(!key.virtual) {
                    v.set(key, value);
                }
            }
            
            return v;
        }
        
        override internal func onPropertyChanged(_ property:KKProperty,_ value:Any?,_ newValue:Any?) {
            
            if(property == KKProperty.Frame) {
                
                let v = newValue as! CGRect?
                
                if(v != nil && item != nil) {
                    item!.frame = v!
                }
                
            }
            
            super.onPropertyChanged(property, value, newValue);
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
                
                _i = _i + 1
                
                let item = _container.items[_i]
                let cell = _container.cells[item.reuse]
                
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
    
    public required init(name: String) {
        super.init(name: name)
    }
    
    public required init(element: KKElement) {
        super.init(element: element)
    }
    
    deinit {
        self.view.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    internal override func onInit() ->Void {
        super.onInit()
        self.view.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    
    private let container = Container.init()
    
    public override func makeIterator() -> Iterator {
        return ItemIterator.init(container: container)
    }
    
    public func reloadData() {
        
        container.items.removeAll()
        
        let v = get(KKProperty.WithObserver) as! KKWithObserver?
        
        if v != nil {
            
            container.observer = v
            
            let reuseKey = get(KKProperty.ReuseKey, defaultValue: "")
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
        return frame.intersects(f)
    }
    
    public func reloadElements() {
        
        for item in container.items {
            
            if isVisibleRect(frame: item.frame) {
                
                if item.element == nil {
                    item.element = container.dequeue(reuse: item.reuse)
                    item.element!.set(KKProperty.Frame, item.frame)
                    item.element!.layoutChildren()
                    item.element!.set(KKProperty.ContentOffset, item.frame)
                    item.element!.appendTo(self)
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
        
        if(property == KKProperty.WithObserver) {
            
            let obs = newValue as! KKWithObserver?
            
            if(obs != nil) {
                
                reloadData()
                
                obs!.on([], { ( _ observer :KKObserver, _ changedKeys:[String], _ weakObject:AnyObject?) in
                    
                    if weakObject != nil {
                        let v = weakObject! as! KKContainerViewElement
                        v.reloadData()
                    }
                    
                }, self)
                
            }
            
        }
        
        super.onPropertyChanged(property, value, newValue);
    }
    
    
    override public func obtainObserver(_ observer:KKObserver? ) -> Void {
        
        
    }
    
    override public func newChildrenElement(_ name:String) -> KKElement? {
        if(name == "cell") {
            return CellElement.init(name: name)
        }
        return super.newChildrenElement(name);
    }
    
    
}
