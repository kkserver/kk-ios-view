//
//  KKDocument.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/26.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import UIKit

public extension KKElement {

    public var document:KKDocument? {
        get {
            if self is KKDocument {
                return self as? KKDocument
            } else if(self.parent != nil) {
                return self.parent!.document
            } else {
                return nil
            }
        }
    }
}


public class KKDocument: KKElement,KKViewElementProtocol,KKLayerElementProtocol,XMLParserDelegate {
    
    private var _styleSheet:KKStyleSheet?
    private var _body:KKElement?
    private weak var _view:UIView?;
    private var _animations:Dictionary<String,KKAnimationElement>?
    
    public var view:UIView {
        get {
            return _view!
        }
    }
    
    public var layer:CALayer {
        get {
            return _view!.layer
        }
    }
    
    public var body:KKElement? {
        get {
            return _body
        }
    }
    
    public var styleSheet:KKStyleSheet? {
        get {
            return _styleSheet
        }
    }
    
    public init(view:UIView) {
        _view = view;
        super.init()
        onInit();
    }
    
    public required init() {
        super.init()
        onInit()
    }
    
    public required init(element: KKElement) {
        _view = type(of: (element as! KKViewElementProtocol).view).init(frame: CGRect.zero);
        super.init(element:element)
        onInit()
    }
    
    public required init(name: String) {
        
        var clazz:AnyClass? = nil
        
        if(name.contains(":")) {
            clazz = NSClassFromString(name.components(separatedBy: ":").last!)
        }
        
        if(clazz == nil) {
            _view = UIView.init(frame:CGRect.zero)
        }
        else {
            _view = (clazz! as! UIView.Type).init(frame:CGRect.zero);
        }
        
        super.init()
        onInit()
    }
    
    internal func onInit() ->Void {
    }
    
    public func loadXML(parser:XMLParser) ->Void {
        parser.delegate = self
    }
    
    public func loadXML(data:Data) ->Void {
        loadXML(parser: XMLParser.init(data: data))
    }
    
    public func loadXML(stream:InputStream) ->Void {
        loadXML(parser: XMLParser.init(stream: stream))
    }
    
    public func loadXML(contentsOf:URL) ->Void {
        loadXML(parser: XMLParser.init(contentsOf: contentsOf)!)
    }
    
    public func loadXML(content:String) ->Void {
        loadXML(parser: XMLParser.init(data: content.data(using: String.Encoding.utf8)!))
    }
    
    private var _element:KKElement?
    private var _text:NSMutableString?
    
    internal func onStartDocument() ->Void {
        
    }
    
    internal func onEndDocument() ->Void {
        
    }
    
    internal func onStartElement(_ element:KKElement,_ name:String) ->Void {
        
    }
    
    internal func onEndElement(_ element:KKElement,_ name:String) ->Void {
        
        if(name == "style") {
            _styleSheet?.load(cssContent: _element!.get(KKProperty.Text, defaultValue: ""))
        }
        
        if(_element is KKAnimationElement) {
            _animations![_element!.get(KKProperty.Name, defaultValue: "")] = _element as? KKAnimationElement
        }
        
    }
    
    public func parserDidStartDocument(_ parser: XMLParser) {
        removeAllChildren()
        _element = self
        _body = nil
        _text = nil
        _animations = Dictionary.init()
        _styleSheet = KKStyleSheet.init();
        onStartDocument()
    }
    
    public func parserDidEndDocument(_ parser: XMLParser) {
        _element = nil
        _text = nil
        onEndDocument()
    }
   
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        let e = styleSheet!.newElement(_element, qName!)
        
        e.appendTo(_element!)
        
        for (key,value) in attributeDict {
            KKStyle.set(element: e, key, value)
        }
        
        if(_element == self && qName == "body") {
            _body = e
        }
        
        _element = e
        _text = nil
        
        onStartElement(_element!,qName!)
        
    }
    
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if(_text != nil) {
            _element!.set(KKProperty.Text,_text)
            _text = nil
        }
        
        onEndElement(_element!,qName!)
        
        _element = _element!.parent
    }
    
   
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        if(_text == nil) {
            _text = NSMutableString.init();
        }
        _text?.append(string);
    }
    
    public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        
        if(_text == nil) {
            _text = NSMutableString.init();
        }
        
        _text!.append(String.init(data: CDATABlock, encoding: String.Encoding.utf8)!)
        
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        NSLog("[KK][KKView][KKDocument] %@", parseError.localizedDescription)
        print(parseError)
    }
    
    
    public func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        NSLog("[KK][KKView][KKDocument] %@", validationError.localizedDescription)
        print(validationError)
    }
    
    public func getAnimation(_ name:String) ->CAAnimation? {
        let anim = _animations![name]
        if(anim != nil) {
            return anim!.getAnimation()
        }
        return nil
    }
}
