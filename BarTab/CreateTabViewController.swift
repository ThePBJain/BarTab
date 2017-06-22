//
//  CreateTabViewController.swift
//  BarTab
//
//  Created by Pranav Jain on 4/9/16.
//  Copyright © 2016 Pranav Jain. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
class CreateTabViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var createTabButton: UIButton!
    let locationManager = CLLocationManager()
    
    //authentication and user data that is passed between views
    var token : HTTPHeaders = ["Authorization": ""]
    var userID : String = ""
    var merchants : [String : String] = [:]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        if(!success){
            checkTab()
        }else{
            let alert = UIAlertController(title: "Success!", message:"You have paid your bar tab.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
            self.present(alert, animated: true){}
            success = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createTabButton.layer.cornerRadius = 5
        createTabButton.layer.borderWidth = 1
        createTabButton.layer.borderColor = UIColor.clear.cgColor
        
        //set background
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "BarTab.png")!)
        //self.view.backgroundColor = UIColor(p)
        
    }

    @IBAction func createTab(_ sender: AnyObject) {
        let (email, merchantID) = self.merchants.first!
        let parameters: [String: Any] = [
            "id" : merchantID
        ]
        Alamofire.request("http://192.168.1.111:3000/tabs/open", method: .post, parameters: parameters, headers: token)
            .responseJSON{ response in
                print(response)
                //move to next view and pass data
                tabExists = true
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabView") as! ViewController
                viewController.token = self.token;
                viewController.userID = self.userID;
                viewController.merchantID = merchantID;
                self.present(viewController, animated: true, completion: nil)
        }
        /*let task = URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
            if error != nil {
                print(error)
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        do {
                            if let data = data, let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                                print(jsonResult)
                                tabExists = true
                                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabView") 
                                self.present(viewController, animated: true, completion: nil)
                                
                            }
                        } catch let JSONError as NSError {
                            print(JSONError)
                        }
                    }
                } else {
                    print("Can't cast response to NSHTTPURLResponse")
                }
            }
        }) 
        task.resume()*/
    }
    func checkTab(){
        let url : String = "http://ec2-54-213-202-21.us-west-2.compute.amazonaws.com:5000/checktab/\(customerID)"
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.url = URL(string: url)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error)
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        do {
                            if let data = data, let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                                print(jsonResult)
                                //self.performSegueWithIdentifier("SuccessSignin", sender: self)
                                let message = jsonResult["message"] as! String
                                if(message.contains("exists")){
                                    tabExists = true
                                    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabView") as! ViewController
                                    viewController.token = self.token;
                                    viewController.userID = self.userID;
                                    self.present(viewController, animated: true, completion: nil)
                                }
                            }
                        } catch let JSONError as NSError {
                            print(JSONError)
                        }
                    }else{
                       print("\(httpResponse.statusCode) error occurred..")
                    }
                } else {
                    print("Can't cast response to NSHTTPURLResponse")
                }
            }
        }) 
        task.resume()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        let lat = "\(locValue.latitude)"
        let long = "\(locValue.longitude)"
        //call this every 10 seconds if possible...
        nearbyMerchants(latitude: lat, longitude: long);
    }
    func nearbyMerchants(latitude: String, longitude: String){
        let baseURL = "http://192.168.1.111:3000/api/v1/merchants/nearby?long=\(longitude)&lat=\(latitude)";
        
        let parameters = ["long": longitude, "lat": latitude]
        Alamofire.request("http://192.168.1.111:3000/api/v1/merchants/nearby", parameters: parameters, headers: token)
            .responseJSON{ response in
                //print(response)
                if let status = response.response?.statusCode {
                    switch(status){
                    case 200:
                        print("example success")
                    default:
                        print("error with response status: \(status)")
                    }
                }
                //to get JSON return value
                if let result = response.result.value {
                    let JSON = result as! NSDictionary
                    print(JSON)
                    if let nearMerchants = (JSON.object(forKey: "data") as? [NSDictionary]) {
                        nearMerchants.forEach { merchant in
                            if let merch = merchant["obj"] as? NSDictionary {
                                
                                //here you add new nearby merchants to list or remove ones no longer nearby
                                let id = merch["_id"] as! String;
                                let email = merch["email"] as! String;
                                self.merchants[email] = id;
                                print("Merchants Dict looks like this: \(self.merchants)")
                                
                                
                            }
                        }
                        //over here call some function that creates a button for each item in self.merchants
                    }
                    
                }
                
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
