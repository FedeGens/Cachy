# Cachy

Cachy is a simple image caching lib for iOS.


## Installation
Using Cocoapods:
```ruby
use_frameworks!
pod 'Cachy'
```
Alternatively you can just import the classes from "Cachy" folder.

##Requirements
- iOS 8.0+ 
- Swift 3.0

##How To Use

There's an imageView extension to use Cachy. Just pass to it your image url as a String:

```Swift
let yourImageView = UIImageView()
yourImageView.cachyImageFrom(link: YOUR_IMAGE_LINK_HERE)
```

There's an extension with a completion handler too, if you need it:

```Swift
let yourImageView = UIImageView()
yourImageView.cachyImageFrom(link: YOUR_IMAGE_LINK_HERE, withHandler: { (success) in
}
```

Super easy. isn't it?</br>
**Enjoy! ;D**

## App using Cachy
If you use this lib [contact me](mailto:fgentile95dev@icloud.com?subject=Cachy) and I will add it to the list below:

###Developed By
Federico Gentile - [fgentile95dev@icloud.com](mailto:fgentile95dev@icloud.com)

## License
```
The MIT License (MIT)

Copyright (c) 2016 Federico Gentile

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
