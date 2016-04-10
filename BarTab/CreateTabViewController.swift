//
//  CreateTabViewController.swift
//  BarTab
//
//  Created by Pranav Jain on 4/9/16.
//  Copyright © 2016 Pranav Jain. All rights reserved.
//

import UIKit

class CreateTabViewController: UIViewController {

    @IBOutlet weak var createTabButton: UIButton!
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(!success){
            checkTab()
        }else{
            let alert = UIAlertController(title: "Success!", message:"You have paid your bar tab.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
            success = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createTabButton.layer.cornerRadius = 5
        createTabButton.layer.borderWidth = 1
        createTabButton.layer.borderColor = UIColor.clearColor().CGColor
        
        //set background
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "BarTab.png")!)
        //self.view.backgroundColor = UIColor(p)
        
    }

    @IBAction func createTab(sender: AnyObject) {
        let url = NSURL(string: "http://ec2-54-213-39-17.us-west-2.compute.amazonaws.com:5000/newtab/\(customerID)")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            if error != nil {
                print(error!.description)
            } else {
                if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        do {
                            if let data = data, let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                                print(jsonResult)
                                tabExists = true
                                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TabView") 
                                self.presentViewController(viewController, animated: true, completion: nil)
                                
                            }
                        } catch let JSONError as NSError {
                            print(JSONError)
                        }
                    }
                } else {
                    print("Can't cast response to NSHTTPURLResponse")
                }
            }
        }
        task.resume()
    }
    func checkTab(){
        let url : String = "http://ec2-54-213-39-17.us-west-2.compute.amazonaws.com:5000/checktab/\(customerID)"
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
                                let message = jsonResult["message"] as! String
                                if(message.containsString("exists")){
                                    tabExists = true
                                    let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TabView")
                                    self.presentViewController(viewController, animated: true, completion: nil)
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
        }
        task.resume()
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
