//
//  KKElement.swift
//  KKView
//
//  Created by zhanghailong on 2016/10/17.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import Foundation
import KKObserver

open class KKElementEvent : KKEvent {
    
    public var cancelBubble:Bool=false
    public let element:KKElement
    
    public init(element:KKElement) {
        self.element = element
        super.init()
    }
    
}

open class KKElement : KKEventEmitter,NSCopying {
    
    private weak var _parent:KKElement? = nil
    private var _firstChild:KKElement? = nil
    private var _lastChild:KKElement? = nil
    private var _nextSibling:KKElement? = nil
    private weak var _prevSibling:KKElement? = nil
    
    public var parent:KKElement? {
        get {
            return _parent
        }
    }
    
    public var firstChild:KKElement? {
        get {
            return _firstChild
        }
    }
    
    public var lastChild:KKElement? {
        get {
            return _lastChild
        }
    }
    
    public var nextSibling:KKElement? {
        get {
            return _nextSibling
        }
    }
    
    public var prevSibling:KKElement? {
        get {
            return _prevSibling
        }
    }
    
    public func append(_ element:KKElement) -> Void {
        
        let e = element
        
        e.remove()
        
        if _lastChild != nil {
            _lastChild!._nextSibling = e
            e._prevSibling = _lastChild
            _lastChild = e
        } else {
            _firstChild = e
            _lastChild = e
        }
        
        e._parent = self
        
        onAddChildren(element)
        
    }
    
    public func appendTo(_ element:KKElement) -> Void {
        element.append(self)
    }
    
    public func remove() -> Void {
        
        let p = _parent
        let e = self
        
        if _prevSibling != nil {
            _prevSibling!._nextSibling = _nextSibling
            
            if _nextSibling != nil {
                _nextSibling!._prevSibling = _prevSibling
            } else if _parent != nil {
                _parent!._lastChild = _prevSibling
            }
        } else if _parent != nil {
            _parent!._firstChild = _nextSibling
            if _nextSibling != nil {
                _nextSibling!._prevSibling = nil
            } else {
                _parent!._lastChild = _nextSibling
            }
        }
        
        _parent = nil
        _nextSibling = nil
        _prevSibling = nil
        
        if p != nil {
            p?.onRemoveChildren(e)
        }
        
    }
    
    public func removeAllChildren() -> Void  {
        var p = _firstChild
        while p != nil {
            let n = p!.nextSibling
            p!.remove()
            p = n
        }
    }
    
    public func before(_ element:KKElement) -> Void {
        
        let e = element
        
        e.remove()
        
        if _parent != nil {
            
            e._parent = _parent
            
            if _prevSibling != nil {
                _prevSibling!._nextSibling = e
                e._prevSibling = _prevSibling
                e._nextSibling = self
                _prevSibling = e
            } else {
                _parent?._firstChild = e
                e._nextSibling = self
                _prevSibling = e
            }
            
            _parent!.onAddChildren(e)
            
        }
    }
    
    public func beforeTo(_ element:KKElement) -> Void {
        element.before(self)
    }
    
    public func after(_ element:KKElement) -> Void {
        
        let e = element
        
        e.remove()
        
        if _parent != nil {
            
            e._parent = _parent
            
            if _nextSibling != nil {
                e._nextSibling = _nextSibling
                e._prevSibling = self
                _nextSibling!._prevSibling = e
                _nextSibling = e
            } else {
                _parent?._lastChild = e
                e._prevSibling = self
                _nextSibling = e
            }
            
            _parent!.onAddChildren(e)
            
        }
    }
    
    public func afterTo(_ element:KKElement) -> Void {
        element.after(self)
    }
    
    public func onRemoveChildren(_ element:KKElement) -> Void {
        
        element.onRemoveFromParent(self)
        
    }
    
    public func onAddChildren(_ element:KKElement) -> Void {
        
        element.onAddToParent(self)
        
    }
    
    public func onAddToParent(_ element:KKElement) -> Void {
        
    }
    
    public func onRemoveFromParent(_ element:KKElement) -> Void {
        
    }
    
    public func sendEvent(_ name:String,_ event:KKEvent) -> Void {
        emit(name, event)
        if event is KKElementEvent && !(event as! KKElementEvent).cancelBubble && _parent != nil {
            _parent!.sendEvent(name, event)
        }
    }
    
    public func dispatchEvent(_ name:String,_ event:KKEvent) -> KKElement? {
        
        var r:KKElement? = self
        
        var p = _lastChild
        
        while p != nil {
            
            r = dispatchChildrenEvent(p!, name, event)
            
            if r != nil {
                return r
            }
            
            p = p?.prevSibling
        }
        
        return r
    }
    
    public func dispatchChildrenEvent(_ element:KKElement,_ name:String,_ event:KKEvent) -> KKElement? {
        return element.dispatchEvent(name, event)
    }
    
    public required override init() {
        super.init()
    }
    
    public required init(element:KKElement) {
        super.init()
    }
    
    public required init(name:String) {
        super.init()
    }
    
    public func copyElement(with zone: NSZone? = nil) -> KKElement {
        
        let v:KKElement = type(of: self).init(element:self)
        
        for (key,value) in _values {
            if(!key.virtual) {
                v.set(key, value);
            }
        }
        
        return v;
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        
        let v:KKElement = copyElement(with: zone);
        
        var p = firstChild;
        
        while(p != nil) {
            if( p is ReflectElementProtocol) {
                
            }
            else {
                (p!.copy(with: zone) as! KKElement).appendTo(v);
            }
            p = p!.nextSibling
        }
        
        return v
    }
    
    public func newChildrenElement(_ name:String) -> KKElement? {
        return nil;
    }
    
    private var _values:Dictionary<KKProperty,Any> = Dictionary.init();
    
    public var values:Dictionary<KKProperty,Any> {
        get {
            return _values;
        }
    }
    
    public var style:KKStyle? {
        get {
            return get(KKProperty.Style) as! KKStyle?;
        }
    }
    
    public var status:String {
        get {
            var v:String? = get(KKProperty.Status) as! String?;
            if(v == nil) {
                v = get(KKProperty.InStatus) as! String?;
            }
            if(v == nil) {
                return "";
            }
            return v!;
        }
    }
    
    public func get(_ property:KKProperty) -> Any? {
        
        var v:Any? = _values[property];
        
        if(v == nil
            && property != KKProperty.Style
            && property != KKProperty.Status
            && property != KKProperty.InStatus) {
            let s:KKStyle? = style;
            if(s != nil) {
                v = s?.get(property, status);
            }
        }
        
        return v;
    }
    
    public func get<T>(_ property:KKProperty,defaultValue:T) -> T {
        let v:Any? = get(property);
        if(v == nil) {
            return defaultValue;
        }
        return v as! T;
    }
    
    internal func onPropertyChanged(_ property:KKProperty,_ value:Any?,_ newValue:Any?) {
        
        if(property == KKProperty.Status || property == KKProperty.InStatus) {
            
            let v:KKStyle? = style;
            
            if(v != nil) {
                let s:String = status;
                for prop in v!.propertys {
                    if(prop != KKProperty.Status && prop != KKProperty.InStatus && prop != KKProperty.Style) {
                        set(prop,v!.get(prop,s));
                    }
                }
            }
            
            var p:KKElement? = firstChild;
            
            while(p != nil) {
                p!.set(KKProperty.InStatus,newValue);
                p = p!.nextSibling;
            }
        }
        else if(property == KKProperty.Style) {
            
            let v:KKStyle? = newValue as! KKStyle?;
            
            if(v != nil) {
                let s:String = status;
                for prop in v!.propertys {
                    if(prop != KKProperty.Status && prop != KKProperty.InStatus && prop != KKProperty.Style) {
                        set(prop,v!.get(prop,s));
                    }
                }
            }
        }
        else if(property == KKProperty.Observer) {
            
            let observer:KKObserver? = newValue as! KKObserver?
            var key:String? = get(KKProperty.Key) as! String?;
            
            if(key == nil) {
                obtainObserver(observer);
            }
            else {
                
                var obs:KKObserver? = observer;
                
                while(key!.hasPrefix("^") && obs != nil) {
                    key = key!.substring(from: key!.index(key!.startIndex, offsetBy: 1));
                    obs = obs!.parent;
                }
                
                let keys:[String] = key!.components(separatedBy: ".");
                
                var withObserver:KKWithObserver? = get(KKProperty.WithObserver) as! KKWithObserver?;
                
                if(obs == nil) {
                    if(withObserver != nil) {
                        withObserver!.recycle();
                    }
                    set(KKProperty.WithObserver,nil);
                }
                else {
                    if(withObserver == nil) {
                        withObserver = obs!.with(keys);
                        set(KKProperty.WithObserver,withObserver);
                    }
                    else {
                        withObserver!.obtain(obs!, keys, nil)
                    }
                    set(KKProperty.Object,withObserver!.get([]));
                }
                
                obtainObserver(withObserver);
                
            }
            
        }
        
    }
    
    public func set(_ property:KKProperty,_ value:Any?) -> Void {
        let newValue = property.function(property, value)
        let v:Any? = _values[property];
        if(newValue == nil) {
            _values.removeValue(forKey: property);
        }
        else {
            _values[property] = newValue!;
        }
        onPropertyChanged(property,v,newValue);
    }
    
    public func change(_ property:KKProperty) -> Void {
        let v:Any? = _values[property];
        onPropertyChanged(property,v,v);
    }
    
    public func obtainObserver(_ observer:KKObserver? ) -> Void {
        
        var p:KKElement? = firstChild;
        
        while(p != nil) {
            if(p is ReflectElementProtocol) {
                
            }
            else {
                p!.set(KKProperty.Observer,observer);
            }
            p = p!.nextSibling;
        }
        
    }
    
}
