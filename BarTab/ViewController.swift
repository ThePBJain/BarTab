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
    @IBAction func refresh(_ sender: UIButton) {
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
            let url : String = "http://192.168.1.111:3000/tabs/tab/\(merchantID)"
            
            //let parameters = ["long": longitude, "lat": latitude]
            Alamofire.request(url, headers: token)
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
                        DispatchQueue.main.async {
                            
                            BarTabResource.sharedInstance.setBarTab(((JSON.object(forKey: "data") as? [String: String])?["tabTotal"])!)
                            
                        }
                        
                    }
                    
            }
            
        }
    }
    
    
    @IBAction func closeBarTab(_ sender: AnyObject) {
        //let fBarTab = String(format: "%.2f", barTab)
        let parameters: [String: Any] = [
            "id" : merchantID
        ]
        Alamofire.request("http://192.168.1.111:3000/tabs/close", method: .post, parameters: parameters, headers: token)
            .responseJSON{ response in
                print(response)
                tabExists = false
                success = true
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateTab") as! CreateTabViewController
                viewController.token = self.token;
                viewController.userID = self.userID;
                self.present(viewController, animated: true, completion: nil)
        }

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

