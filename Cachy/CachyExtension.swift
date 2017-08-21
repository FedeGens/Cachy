//
//  CachyExtension.swift
//  Cachy
//
//  Created by Federico Gentile on 28/12/16.
//  Copyright © 2016 Federico Gentile. All rights reserved.
//

import UIKit

//Auxiliary classes and functions to store cachy properties inside UIImageView Cachy extension
private var cachyKey: UInt8 = 0
private class CachyProperties {
    var urlToSet = ""
}

private func associatedObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    initialiser: () -> ValueType)
    -> ValueType {
        if let associated = objc_getAssociatedObject(base, key)
            as? ValueType { return associated }
        let associated = initialiser()
        objc_setAssociatedObject(base, key, associated,
                                 .OBJC_ASSOCIATION_RETAIN)
        return associated
}

private func associateObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    value: ValueType) {
    objc_setAssociatedObject(base, key, value,
                             .OBJC_ASSOCIATION_RETAIN)
}

extension UIImageView {
    
    //cachy property to handle correct url image to assign
    private var properties: CachyProperties {
        get {
            return associatedObject(base: self, key: &cachyKey)
            { return CachyProperties() } // Set the initial value of the var
        }
        set { associateObject(base: self, key: &cachyKey, value: newValue) }
    }
    
    //func to validate url
    private func verifyUrl (urlString: String) -> Bool {
        if let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    //Cachy extension
    public func cachyImageFrom(link: String, withPlaceholder placeholder: UIImage? = nil, indicatorVisible: Bool = true, withHandler handler: ((_ success: Bool) -> ())? = nil) {
        var indicator : UIActivityIndicatorView! = nil
        
        DispatchQueue.main.async {
            indicator = UIActivityIndicatorView()
        }
        
        //queue
        let serialQueue = DispatchQueue(label: "cachyQueue")
        serialQueue.async {
            if Cachy.getFirstTime() {
                Cachy.refreshDirectory()
            }
            
            self.properties.urlToSet = link
            
            //check valid image url
            guard self.verifyUrl(urlString: link) else {
                DispatchQueue.main.async {
                    self.image = placeholder ?? self.image
                }
                return
            }
            
            //get from directory
            if let image = Cachy.getCachyImage(link: link) {
                guard self.properties.urlToSet == link else {
                    return
                }
                DispatchQueue.main.async {
                    self.image = image
                }
                handler?(true)
                return
            }
            
            //indicator
            DispatchQueue.main.async() { () -> Void in
                if indicatorVisible {
                    indicator.center = CGPoint.init(x: self.frame.width/2, y: self.frame.height/2)
                    indicator.activityIndicatorViewStyle = .whiteLarge
                    indicator.startAnimating()
                    self.addSubview(indicator)
                }
                self.image = placeholder ?? self.image
            }
            Cachy.downloadedFrom(link: link, completion: { (success, image) in
                if success {
                    guard self.properties.urlToSet == link else {
                        return
                    }
                    Cachy.saveImage(image: image!, name: link)
                    DispatchQueue.main.async() { () -> Void in
                        self.image = image
                        handler?(true)
                        indicator.removeFromSuperview()
                    }
                    return
                }
                DispatchQueue.main.async() { () -> Void in
                    self.image = placeholder
                    handler?(false)
                    indicator.removeFromSuperview()
                }
            })
        }
    }
}
