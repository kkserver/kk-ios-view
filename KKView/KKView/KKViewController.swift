//
//  KKViewController.swift
//  KKView
//
//  Created by zhanghailong on 2016/11/26.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import UIKit
import KKObserver

public class KKViewController: UIViewController {

    private var _observer:KKObserver?
    private var _document:KKDocument?

    public var document:KKDocument {
        get {
            if(_document == nil) {
                _document = KKDocument.init(view: self.view)
            }
            return _document!
        }
    }
    
    public var observer:KKObserver {
        get {
            if(_observer == nil) {
                _observer = KKObserver.init()
            }
            return _observer!
        }
        set {
            _observer = newValue
        }
    }
    
    public var name:String?
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if(name != nil) {
            let bundle = nibBundle == nil ? Bundle.main : nibBundle!
            document.loadXML(contentsOf: bundle.url(forResource: name, withExtension: "xml")!)
            KKScriptElement.runScriptElement(document)
            document.set(KKProperty.Observer, observer)
        }
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
