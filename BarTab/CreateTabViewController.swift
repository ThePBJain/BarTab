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
        let url = URL(string: "http://ec2-54-213-202-21.us-west-2.compute.amazonaws.com:5000/newtab/\(customerID)")
        
        let task = URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
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
        task.resume()
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
        print(nearbyMerchants(latitude: lat, longitude: long));
    }
    func nearbyMerchants(latitude: String, longitude: String) -> String{
        var baseURL = "http://192.168.1.111:3000/api/v1/merchants/nearby?long=\(longitude)&lat=\(latitude)";
        
        let urlString = URL(string: baseURL)
        if let url = urlString {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error)
                } else {
                    if let usableData = data {
                        print(usableData) //JSONSerialization
                    }
                }
            }
            task.resume()
        }
        /*
        var request = URLRequest(url: URL(string: "http://localhost:3000/api/v1/merchants/nearby")!)
        request.httpMethod = "POST"
        let postString = "id=13&name=Jack"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()*/
        
        return "HI"
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
