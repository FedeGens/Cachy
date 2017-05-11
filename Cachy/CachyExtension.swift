//
//  CachyExtension.swift
//  Cachy
//
//  Created by Federico Gentile on 28/12/16.
//  Copyright © 2016 Federico Gentile. All rights reserved.
//

import UIKit

extension UIImageView {
    
    public func cachyImageFrom(link: String, withPlaceholder placeholder: UIImage?, withHandler handler: @escaping (_ success: Bool) -> ()) {
        let serialQueue = DispatchQueue(label: "cachyQueue")
        serialQueue.async {
            if Cachy.getFirstTime() {
                Cachy.refreshDirectory()
            }
            
            if let image = Cachy.getCachyImage(link: link) {
                DispatchQueue.main.async() { () -> Void in
                    self.image = image
                    handler(true)
                }
            } else {
                Cachy.downloadedFrom(link: link, completion: { (success, image) in
                    if success {
                        Cachy.saveImage(image: image!, name: link)
                        DispatchQueue.main.async() { () -> Void in
                            self.image = image
                            handler(true)
                        }
                    }
                    DispatchQueue.main.async() { () -> Void in
                        self.image = placeholder
                        handler(false)
                    }
                })
            }
        }
    }
    
    public func cachyImageFrom(link: String) {
        cachyImageFrom(link: link, withPlaceholder: nil ,withHandler: {_ in})
    }
    
    public func cachyImageFrom(link: String, withPlaceholder placeholder: UIImage?) {
        cachyImageFrom(link: link, withPlaceholder: placeholder, withHandler: {_ in})
    }
    
}
