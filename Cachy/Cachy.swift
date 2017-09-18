//
//  Cachy.swift
//  Cachy
//
//  Created by Federico Gentile on 28/12/16.
//  Copyright © 2016 Federico Gentile. All rights reserved.
//

import UIKit

public class Cachy {
    private static var kMaxTime = 86400
    private static var kMaxImagesToSave = 100
    private static let kCachyFilePrefix = "ImgCachyPrefix"
    private static let kCachyFolderName = "ImgCachy"
    private static var cachyImageDataArray = [CachyImageData]()
    private static var isFirstTime = true
    private static let imageCache = NSCache<NSString, UIImage>()
    
    //MARK: internal methods
    //Cachy setup
    public static func setExpireTime(seconds: Int) {
        kMaxTime = seconds
    }
    
    public static func setMaxImages(number: Int) {
        kMaxImagesToSave = number
    }
    
    //clean all
    public static func purge() {
        removeAll()
    }
    
    public static func getFirstTime() -> Bool {
        return Cachy.isFirstTime
    }
    
    //called first time
    public static func refreshDirectory() {
        isFirstTime = false
        checkMainDirectory()
        getImagesReferencesFromDirectory()
        checkCachyImageTimestamp()
    }
    
    
    //check if image exists
    internal static func getCachyImage(link: String) -> UIImage? {
        let myLink = link.replacingOccurrences(of: "/", with: "--").replacingOccurrences(of: "_", with: "--").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        if let cachedImage = checkCache(link: myLink) {
            return cachedImage
        }
        
        guard let elem = cachyImageDataArray.filter({$0.imageName == myLink}).first else {
            return nil
        }
        
        return getImageFromDirectory(data: elem)
    }
    
    //save cachy image
    internal static func saveImage(image: UIImage, name: String) {
        saveImageToDirectory(image: image, name: name)
    }
    
    //MARK: - Check Cache
    private static func checkCache(link: String) -> UIImage? {
        if let cacheImage = imageCache.object(forKey: link as NSString) as UIImage?{
            return cacheImage
        }
        return nil
    }
    
    //MARK: Check main directory
    private static func checkMainDirectory() {
        if !checkMainDirectoryExists() {
            createMainDirectory()
        }
    }
    
    private static func createMainDirectory() {
        let documentsDirectory = getDocumentsDirectory()
        let dataPath = documentsDirectory.appendingPathComponent(kCachyFolderName)
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    private static func checkMainDirectoryExists() -> Bool {
        let url = getDocumentsDirectory()
        let filePath = url.appendingPathComponent(kCachyFolderName).path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            return true
        } else {
            return false
        }
    }
    
    //get image from directory and update timestamp
    private static func getImageFromDirectory(data: CachyImageData) -> UIImage? {
        if Int(CFAbsoluteTimeGetCurrent()) - Int(data.timestamp)! < 10 {
            let image = UIImage(contentsOfFile: getCachyDirectory().appendingPathComponent(data.getFilename()).path)!
            self.imageCache.setObject(image, forKey: data.imageName as NSString)
            return image
        }
        do {
            let path = getCachyDirectory()
            let originPath = path.appendingPathComponent(data.getFilename())
            
            let (timestamp, _, newName) = createFilename(name: data.imageName)
            let destinationPath = path.appendingPathComponent(newName)
            
            try FileManager.default.moveItem(at: originPath, to: destinationPath)
            //update timestamp
            let index = cachyImageDataArray.index(where: {$0.imageName == data.imageName})!
            cachyImageDataArray[index].timestamp = timestamp
            if let image = UIImage(contentsOfFile: getCachyDirectory().appendingPathComponent(cachyImageDataArray[index].getFilename()).path) {
                self.imageCache.setObject(image, forKey: data.imageName as NSString)
                return image
            }
            return nil
        } catch {
            //print(error)
            let image = getImageFromDirectoryWithName(name: data.imageName)
            self.imageCache.setObject(image, forKey: data.imageName as NSString)
            return image
        }
    }
    
    private static func getImageFromDirectoryWithName(name: String) -> UIImage {
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: getCachyDirectory(), includingPropertiesForKeys: nil, options: [])
            if let imageUrl = urls.filter({$0.absoluteString.contains(name)}).first {
                return UIImage(contentsOfFile: imageUrl.path)!
            }
        } catch {
            //print(error)
        }
        return UIImage()
    }
    
    private static func checkCachyImageTimestamp() {
        for elem in cachyImageDataArray {
            if !elem.isTimestampValid() {
                removeElem(data: elem)
            }
        }
    }
    
    
    //MARK: get image reference from directory
    private static func getImagesReferencesFromDirectory() {
        let documentsUrl =  getCachyDirectory()
        do {
            // Get directory contents url
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            //filter
            let imageFiles = directoryContents.filter{ $0.absoluteString.contains(kCachyFilePrefix) }
            createLocalCachyArray(myUrls: imageFiles)
        } catch _ as NSError {
            //print(error.localizedDescription)
        }
    }
    
    private static func createLocalCachyArray(myUrls: [URL]) {
        //init array
        cachyImageDataArray = [CachyImageData]()
        for url in myUrls {
            let myString = url.absoluteString.components(separatedBy: "_")
            cachyImageDataArray.append(CachyImageData.createCachyImageData(timestamp: myString[1], imageName: myString[2]))
        }
    }
    
    
    //MARK: Save image to directory
    private static func createFilename(name: String) -> (String, String, String) {
        let myName = name.replacingOccurrences(of: "/", with: "--").replacingOccurrences(of: "_", with: "--")
        
        let timestamp = String(Int(CFAbsoluteTimeGetCurrent()))
        let filename = kCachyFilePrefix + "_" + timestamp + "_" + myName
        
        return (timestamp, myName, filename.removingPercentEncoding!)
    }
    
    private static func saveImageToDirectory(image: UIImage, name: String) {
        if let data = UIImageJPEGRepresentation(image, 0.3) {
            let (timestamp, myName, myFilename) = createFilename(name: name)
            let filename = getCachyDirectory().appendingPathComponent(myFilename)
            if !checkImageExists(name: myName) {
                do {
                    try data.write(to: filename)
                    addElemToCachyArray(timestamp: timestamp, name: myName)
                    checkCachySize()
                } catch {
                    //print("error")
                }
            }
        }
    }
    
    private static func checkImageExists(name: String) -> Bool{
        if (cachyImageDataArray.filter({$0.imageName == name}).first == nil) {
            return false
        }
        return true
    }
    
    private static func addElemToCachyArray(timestamp: String, name: String) {
        cachyImageDataArray.append(CachyImageData.createCachyImageData(timestamp: timestamp, imageName: name))
    }
    
    //check size
    private static func checkCachySize() {
        if cachyImageDataArray.count > kMaxImagesToSave {
            removeElem(data: cachyImageDataArray[0])
        }
    }
    
    
    //MARK: Remove image from directory
    private static func removeElem(data: CachyImageData) {
        let fileManager = FileManager.default
        let path = getCachyDirectory()
        let filePath = path.appendingPathComponent(data.getFilename())
        do {
            try fileManager.removeItem(at: filePath)
            
            let index = cachyImageDataArray.index(where: {$0.imageName == data.imageName})!
            cachyImageDataArray.remove(at: index)
        } catch _ as NSError {
            //print(error.debugDescription)
        }
    }
    
    private static func removeAll() {
        let fileManager = FileManager.default
        let path = getCachyDirectory()
        
        do {
            try fileManager.removeItem(at: path)
            checkMainDirectory()
        } catch {
            //print(error)
        }
    }
    
    
    //MARK: Directory Utility
    private static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private static func getCachyDirectory() -> URL {
        let cachyDirectory = getDocumentsDirectory().appendingPathComponent(kCachyFolderName)
        return cachyDirectory
    }
    
    
    //MARK: cachy struct
    private struct CachyImageData {
        var timestamp = ""
        var imageName = ""
        
        static func createCachyImageData(timestamp: String, imageName: String) -> CachyImageData {
            var myCachyImageData = CachyImageData()
            myCachyImageData.timestamp = timestamp
            myCachyImageData.imageName = imageName
            
            return myCachyImageData
        }
        
        func getFilename() -> String {
            let encodedFilename = kCachyFilePrefix + "_" + String(timestamp) + "_" + imageName
            return encodedFilename.removingPercentEncoding!
        }
        
        func isTimestampValid() -> Bool {
            return (Int(CFAbsoluteTimeGetCurrent()) - Int(timestamp)!) < kMaxTime
        }
    }
    
    
    //MARK: Download images
    //download image from url
    internal static func downloadedFrom(url: URL, completion: @escaping (_ success: Bool, _ image: UIImage?) -> () ) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    completion(false, nil)
                    return
            }
            completion(true, image)
            
            }.resume()
    }
    
    //download image from string
    internal static func downloadedFrom(link: String, squared: Bool = false, completion: @escaping (_ success: Bool, _ image: UIImage?) -> () ) {
        guard let url = URL(string: link) else {
            completion(false, nil)
            return
        }
        downloadedFrom(url: url, completion: {
            (success, image) in
            if success {
                
                //cropping image if required
                if squared {
                    completion(true, image!.squared)
                    return
                }
                
                completion(true, image)
            } else {
                completion(false, nil)
            }
        })
    }
    
    
    //MARK: Get UIImage
    public static func cachyImageFrom(link: String, squared: Bool = false, withHandler handler: @escaping (_ success: Bool, _ image: UIImage?) -> ()) {
        let serialQueue = DispatchQueue(label: "cachyGetUIImageQueue")
        serialQueue.async {
            if self.getFirstTime() {
                self.refreshDirectory()
            }
            
            if let image = self.getCachyImage(link: link) {
                DispatchQueue.main.async {
                    handler(true, image)
                }
            } else {
                self.downloadedFrom(link: link, completion: { (success, image) in
                    if success {
                        self.saveImage(image: image!, name: link)
                        DispatchQueue.main.async {
                            handler(true, image)
                        }
                    }
                    DispatchQueue.main.async {
                        handler(false, nil)
                    }
                })
            }
        }
    }
    
}

