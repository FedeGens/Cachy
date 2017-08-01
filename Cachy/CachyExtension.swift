//
//  CachyExtension.swift
//  Cachy
//
//  Created by Federico Gentile on 28/12/16.
//  Copyright © 2016 Federico Gentile. All rights reserved.
//

import UIKit

extension UIImageView {
    
    public func cachyImageFrom(link: String, withPlaceholder placeholder: UIImage? = nil, indicatorVisible: Bool = true, withHandler handler: ((_ success: Bool) -> ())? = nil) {
        let indicator = UIActivityIndicatorView()
        
        //indicator
        if indicatorVisible {
            indicator.center = CGPoint.init(x: self.frame.width/2, y: self.frame.height/2)
            indicator.activityIndicatorViewStyle = .whiteLarge
            indicator.startAnimating()
            self.addSubview(indicator)
        }
        
        //queue
        let serialQueue = DispatchQueue(label: "cachyQueue")
        serialQueue.async {
            if Cachy.getFirstTime() {
                Cachy.refreshDirectory()
            }
            
            if let image = Cachy.getCachyImage(link: link) {
                DispatchQueue.main.async() { () -> Void in
                    self.image = image
                    handler?(true)
                    indicator.removeFromSuperview()
                }
            } else {
                Cachy.downloadedFrom(link: link, completion: { (success, image) in
                    if success {
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
}
