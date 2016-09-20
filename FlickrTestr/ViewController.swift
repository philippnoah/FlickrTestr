//
//  ViewController.swift
//  FlickrTestr
//
//  Created by Philipp Eibl on 9/16/16.
//  Copyright © 2016 Philipp Eibl. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet var myImageView: UIImageView!
    @IBOutlet var myTextField: UITextField!
    @IBAction func getPicturesButton(_ sender: UIButton) {
        download_request()
    }
    
    let locManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locManager.requestWhenInUseAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func download_request()
    {
        let stringToArray = myTextField.text?.components(separatedBy: " ")
        let stringFromArray = stringToArray?.joined(separator: "+")
        print(stringFromArray!)
        
        var currentLocation = CLLocation()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            currentLocation = self.locManager.location!
        }
        
        var url:NSURL = NSURL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=5101fad95a5632452cab48341826c518&text="+stringFromArray!+"&format=json&nojsoncallback=1")!
        url = NSURL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=5101fad95a5632452cab48341826c518&lon=" + String(currentLocation.coordinate.longitude) + "&lat=" + String(currentLocation.coordinate.latitude) + "&format=json&nojsoncallback=1")!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "GET"
        //request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let paramString = ""
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        
        let task = session.downloadTask(with: request as URLRequest) {
            (location, response, error) in
            guard let _:NSURL = location as NSURL?, let _:URLResponse = response, error == nil else {
                print(error ?? "error is nil wtf")
                return
            }
            
            let urlContents = try? NSString(contentsOf: location!, encoding: String.Encoding.utf8.rawValue )
            //let urlImage = try? UIImage(contentsOfFile: location!.path)
            
            guard let _:NSString = urlContents else {
                print(error ?? "wtfizzle", response)
                return
            }
            
            let test = String(urlContents as! String)
            let data = test?.data(using: .utf8)!
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! NSDictionary
            let var1 = (json!["photos"] as! NSDictionary)["photo"]
            let var2 = ((var1 as! NSArray)[3] as! NSDictionary)
            print(var2)
            
            let farm = var2["farm"]! as! Int
            let id = var2["id"]! as! String
            let owner = var2["owner"]! as! String
            let server = var2["server"]! as! String
            let title = var2["title"]! as! String
            let secret = var2["secret"]! as! String
            print(farm, id, owner, server, title)
            
            let imageURL = "http://farm" + String(farm) + ".staticflickr.com/" + server + "/" + id + "_" + secret + "_c.jpg"
            print(imageURL)
            self.download_image(url: imageURL)
        }
        
        task.resume()
        
    }
    
    func download_image(url: String) {
        DispatchQueue.main.async {
            print("async code")
        }
        
        
        DispatchQueue.main.async {
            if let url = NSURL(string: url) {
                if let data = NSData(contentsOf: url as URL) {
                    
                    self.myImageView.image = UIImage(data: data as Data)
                }
            }
        }
        

    }
}

