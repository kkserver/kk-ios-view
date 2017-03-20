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


open class KKDocument: KKViewElement,XMLParserDelegate {
    
    private var _styleSheet:KKStyleSheet?
    private var _animations:Dictionary<String,KKAnimationElement>?
    public var bundle:Bundle?
    
    public var styleSheet:KKStyleSheet? {
        get {
            return _styleSheet
        }
    }
    
    internal override func onInit() ->Void {
        super.onInit()
        set(KKProperty.Layout,"relative");
        set(KKProperty.Width,"100%");
        set(KKProperty.Height,"100%");
    }
    
    override internal func onPropertyChanged(_ property:KKProperty,_ value:Any?,_ newValue:Any?) {
        super.onPropertyChanged(property, value, newValue)
    }
    
    public func loadXML(parser:XMLParser) ->Void {
        parser.delegate = self
        parser.parse()
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
            let src = element.get(KKProperty.Src, defaultValue: "")
            if src != "" {
                if src.hasPrefix("/") {
                    _styleSheet?.load(cssContent: try! String.init(contentsOfFile: src))
                } else if bundle != nil {
                    _styleSheet?.load(cssContent: try! String.init(contentsOfFile: (bundle?.resourcePath?.appendingFormat("/%@", src))!))
                } else {
                    _styleSheet?.load(cssContent: try! String.init(contentsOfFile: src))
                }
            } else {
                _styleSheet?.load(cssContent: _element!.get(KKProperty.Text, defaultValue: ""))
            }
        }
        
        if(_element is KKAnimationElement) {
            _animations![_element!.get(KKProperty.Name, defaultValue: "")] = _element as? KKAnimationElement
        }
        
    }
    
    public func parserDidStartDocument(_ parser: XMLParser) {
        removeAllChildren()
        _element = nil
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
        
        var e:KKElement
        
        if(_element == nil) {
            e = self
        } else {
            let v = attributeDict["class"];
            e = styleSheet!.newElement(_element, elementName, v != nil ? v!: elementName)
        }
        
        let data = NSMutableDictionary.init()
        
        for (key,value) in attributeDict {
            if key.hasPrefix("data-") {
                data[key.substring(from: key.index(key.startIndex, offsetBy: 5))] = value
            } else if(key != "class") {
                KKStyle.set(element: e, key, value)
            }
        }
        
        e.set(KKProperty.Data, data)
        
        if(_element != nil) {
            e.appendTo(_element!)
        }
        
        _element = e
        _text = nil
        
        onStartElement(_element!,elementName)
        
    }
    
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if(_text != nil) {
            if(_element?.firstChild == nil) {
                _element!.set(KKProperty.Text,_text)
            }
            _text = nil
        }
        
        onEndElement(_element!,elementName)
        
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
