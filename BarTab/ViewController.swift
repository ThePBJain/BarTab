//
//  ViewController.swift
//  BarTab
//
//  Created by Pranav Jain on 4/9/16.
//  Copyright © 2016 Pranav Jain. All rights reserved.
//

import UIKit

var tabExists = false
var success = false
var customerID: Int = 124

class BarTabResource {
    static let sharedInstance = BarTabResource()
    private var barTab: String = "0.00"
    
    func getBarTab() -> String {
        return barTab
    }
    
    func setBarTab(tab: String) {
        self.barTab = tab
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var payTabButton: UIButton!
    @IBOutlet weak var titleBar: UILabel!
//    var barTab: String = "0.00" {
//        didSet{
//            updateLabel()
//        }
//    }
    private var customerID: Int = 124
    var timer = NSTimer()
    var timer1 = NSTimer()
    
    @IBOutlet weak var barTabLabel: UITextField!
    
    @IBOutlet weak var barLabel: UILabel!
    override func viewDidAppear(animated: Bool) {
        if(!tabExists){
            super.viewDidAppear(animated)
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateTab")
            self.presentViewController(viewController, animated: true, completion: nil)
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
        payTabButton.layer.borderColor = UIColor.clearColor().CGColor
        titleBar.layer.cornerRadius = 5
        titleBar.layer.borderWidth = 1
        titleBar.layer.borderColor = UIColor.clearColor().CGColor
        
        
        updateBarTab()
        //update bartab i.e get function
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(ViewController.updateBarTab), userInfo: nil, repeats: true)
        timer1 = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(ViewController.updateLabel), userInfo: nil, repeats: true)
    }
    @IBAction func refresh(sender: AnyObject) {
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
            let url : String = "http://ec2-54-213-39-17.us-west-2.compute.amazonaws.com/items/\(customerID)"
            let request : NSMutableURLRequest = NSMutableURLRequest()
            request.URL = NSURL(string: url)
            request.HTTPMethod = "GET"
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                if error != nil {
                    print(error!.description)
                } else {
                    if let httpResponse = response as? NSHTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            do {
                                if let data = data, let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                                    print(jsonResult)
                                    //self.performSegueWithIdentifier("SuccessSignin", sender: self)
                                    //self.barTab = jsonResult["total"] as! String
                                    dispatch_async(dispatch_get_main_queue()) {
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
            }
            task.resume()
        }
    }
    
    
    @IBAction func closeBarTab(sender: AnyObject) {
        //let fBarTab = String(format: "%.2f", barTab)
        
        let jsonString:String = "{\"TransactionAmount\": \"\(BarTabResource.sharedInstance.getBarTab())\"}"
        let params = convertStringToDictionary(jsonString)
        let url = "http://ec2-54-213-39-17.us-west-2.compute.amazonaws.com/payme/\(customerID)"
        postData(url, params: params!) { (data, response, error) -> Void in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
        }
        tabExists = false
        success = true
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateTab")
        self.presentViewController(viewController, animated: true, completion: nil)

    }
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    //post data function
    func postData(url: String, params: [String:AnyObject], completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> ()) {
        
        // Indicate download
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let url = NSURL(string: url)!
        //        print("URL: \(url)")
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Verify downloading data is allowed
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            print("Error in request post: \(error)")
            request.HTTPBody = nil
        } catch {
            print("Catch all error: \(error)")
        }
        
        // Post the data
        let task = session.dataTaskWithRequest(request) { data, response, error in
            completionHandler(data: data, response: response, error: error)
            
            // Stop download indication
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false // Stop download indication
            
        }
        
        task.resume()
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

