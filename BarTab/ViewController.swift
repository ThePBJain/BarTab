//
//  ViewController.swift
//  BarTab
//
//  Created by Pranav Jain on 4/9/16.
//  Copyright © 2016 Pranav Jain. All rights reserved.
//

import UIKit
import Alamofire

var tabExists = false
var success = false
var customerID: Int = 124

class BarTabResource {
    static let sharedInstance = BarTabResource()
    fileprivate var barTab: String = "0.00"
    
    func getBarTab() -> String {
        return barTab
    }
    
    func setBarTab(_ tab: String) {
        self.barTab = tab
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var payTabButton: UIButton!
    @IBOutlet weak var titleBar: UILabel!
    
    //authentication and user data that is passed between views
    var token : HTTPHeaders = ["Authorization": ""]
    var userID : String = ""
    var merchantID: String = ""
//    var barTab: String = "0.00" {
//        didSet{
//            updateLabel()
//        }
//    }
    fileprivate var customerID: Int = 124
    var timer = Timer()
    var timer1 = Timer()
    
    
    @IBOutlet weak var barLabel: UILabel!
    override func viewDidAppear(_ animated: Bool) {
        if(!tabExists){
            super.viewDidAppear(animated)
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateTab")
            self.present(viewController, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check to see if tab exists yet or not
       /* let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateTab")
        self.presentViewController(viewController, animated: true, completion: nil)
        */
        
        // Do any additional setup after loading the view, typically from a nib.
        payTabButton.layer.cornerRadius = 5
        payTabButton.layer.borderWidth = 1
        payTabButton.layer.borderColor = UIColor.clear.cgColor
        titleBar.layer.cornerRadius = 5
        titleBar.layer.borderWidth = 1
        titleBar.layer.borderColor = UIColor.clear.cgColor
        
        
        updateBarTab()
        //update bartab i.e get function
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(ViewController.updateBarTab), userInfo: nil, repeats: true)
        timer1 = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ViewController.updateLabel), userInfo: nil, repeats: true)
    }
    @IBAction func refresh(_ sender: AnyObject) {
        print(BarTabResource.sharedInstance.getBarTab())
        barLabel.text = "$\(BarTabResource.sharedInstance.getBarTab())"
    }
    func updateLabel(){
        barLabel.text = "$\(BarTabResource.sharedInstance.getBarTab())"
        //print(barTab)
        //print(barLabel.text)
    }
    func updateBarTab(){
        if(tabExists){
            let url : String = "http://localhost:3000/update/add/\(customerID)"
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
                                    //self.barTab = jsonResult["total"] as! String
                                    DispatchQueue.main.async {
                                        BarTabResource.sharedInstance.setBarTab(jsonResult["total"] as! String)
                                       
                                    }
                                }
                            } catch let JSONError as NSError {
                                print(JSONError)
                            }
                        } else if (httpResponse.statusCode == 422) {
                            print("422 Error Occured...")
                        }
                    } else {
                        print("Can't cast response to NSHTTPURLResponse")
                    }
                }
            }) 
            task.resume()
        }
    }
    
    
    @IBAction func closeBarTab(_ sender: AnyObject) {
        //let fBarTab = String(format: "%.2f", barTab)
        
        let jsonString:String = "{\"TransactionAmount\": \"\(BarTabResource.sharedInstance.getBarTab())\"}"
        let params = convertStringToDictionary(jsonString)
        let url = "http://ec2-54-213-202-21.us-west-2.compute.amazonaws.com:5001/payme/\(customerID)"
        postData(url, params: params!) { (data, response, error) -> Void in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString)")
            let failString = "fail"
            //if(!failString.containsString(responseString?.valueForKey("message") as! String)){
                tabExists = false
                success = true
            //}
            
        }
        tabExists = false
        success = true
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateTab") as! CreateTabViewController
        viewController.token = self.token;
        viewController.userID = self.userID;
        self.present(viewController, animated: true, completion: nil)

    }
    func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    //post data function
    func postData(_ url: String, params: [String:AnyObject], completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: NSError?) -> ()) {
        
        // Indicate download
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = URL(string: url)!
        //        print("URL: \(url)")
        let request = NSMutableURLRequest(url: url)
        let session = URLSession.shared
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Verify downloading data is allowed
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch let error as NSError {
            print("Error in request post: \(error)")
            request.httpBody = nil
        } catch {
            print("Catch all error: \(error)")
        }
        
        // Post the data
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            completionHandler(data, response, error as! NSError)
            
            // Stop download indication
            UIApplication.shared.isNetworkActivityIndicatorVisible = false // Stop download indication
            
        }) 
        
        task.resume()
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

