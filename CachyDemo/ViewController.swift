//
//  ViewController.swift
//  Cachy
//
//  Created by Federico Gentile on 28/12/16.
//  Copyright © 2016 Federico Gentile. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView_: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageView_.contentMode = .scaleAspectFill
        imageView_.clipsToBounds = true
        imageView_.cachyImageFrom(link: "https://www.w3schools.com/w3images/fjords.jpg", withPlaceholder: UIImage(named: "gattino"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

