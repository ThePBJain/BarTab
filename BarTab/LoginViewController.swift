//
//  LoginViewController.swift
//  Conductor
//
//  Created by Pranav Jain on 4/24/16.
//  Copyright © 2016 Pranav Jain. All rights reserved.
//

import UIKit
import OAuth2
class LoginViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var signUpConstraint: NSLayoutConstraint!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    var fieldsAreShown = false
    
    @IBOutlet weak var conductorLabel: UILabel!
    
    /*let settings = [
        "client_id": "my_swift_app",
        "client_secret": "C7447242-A0CF-47C5-BAC7-B38BA91970A9",
        "authorize_uri": "https://auth.htt-cloud.catalysts.cc/auth/confirm",
        "token_uri": "https://token.htt-cloud.catalysts.cc/",   // code grant only
        "scope": "profile email",
        "redirect_uris": ["myapp://oauth/callback"],   // register the "myapp" scheme in Info.plist
        "keychain": false,     // if you DON'T want keychain integration
        ] as OAuth2JSON*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.layer.borderWidth = 1
        signInButton.layer.borderColor = UIColor.darkGrayColor().CGColor
        signUpConstraint.constant = view.bounds.height*0.25
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "CoverPage")!)
        // Do any additional setup after loading the view.
        username.attributedPlaceholder = NSAttributedString(string:"Username",
                                                            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        password.attributedPlaceholder = NSAttributedString(string:"Password",
                                                            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        username.delegate = self
        password.delegate = self
        self.view.layoutIfNeeded()
    }
    func genericOAuth2Password(username: String, password: String) -> OAuth2PasswordGrant {
        return OAuth2PasswordGrant(settings: [
            "client_id": "\(username)", //"schutzengel",
            "client_secret": "\(password)",
            "authorize_uri": "https://token.htt-cloud.catalysts.cc/oauth/check_token",
            "token_uri": "https://auth.htt-cloud.catalysts.cc/auth/token",
            "username":"\(username)",
            "password":"\(password)",
            "keychain": false,
            ])
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SignInAction(sender: AnyObject) {
        if(!fieldsAreShown){
            
            self.view.layoutIfNeeded()
            //move sign up button down
            UIView.animateWithDuration(0.5, delay: 0.0,
                                   options: [.CurveEaseOut], animations: {
                                    //animate signIn and signUp
                                    self.signUpConstraint.constant -= self.view.bounds.width/6
                                    self.signInButton.center.y += self.view.bounds.width/6
                                    self.signUpButton.center.y += self.view.bounds.width/6
                                    self.view.layoutIfNeeded()
                                    self.username.alpha = 1.0
                                    self.password.alpha = 1.0
                                    self.conductorLabel.alpha = 0.0
                                    self.signUpButton.alpha = 0.0
                }, completion: { finished in
                    if(finished){
                        self.signUpButton.hidden = true
                        self.conductorLabel.hidden = true
                    }
            })
            //draw username path
            let passwordPath = UIBezierPath()
            passwordPath.moveToPoint(CGPointMake((self.view.bounds.width/2.0 - 135.0), (2.0*self.view.bounds.height/3.0 + 5)))
            passwordPath.addLineToPoint(CGPointMake((self.view.bounds.width/2.0 + 125.0), (2.0*self.view.bounds.height/3.0 + 5)))
            
            //draw password path.
            let usernamePath = UIBezierPath()
            //usernamePath.moveToPoint(CGPointMake((self.view.bounds.width/2.0 - 200.0), 2.0*self.view.bounds.height/3.0))
            //usernamePath.addLineToPoint(CGPointMake((self.view.bounds.width/2.0 + 200), 2.0*self.view.bounds.height/3.0))
            usernamePath.moveToPoint(CGPointMake((self.view.bounds.width/2.0 - 135.0),
                                                    (2.0*self.view.bounds.height/3.0 - 60)))
            usernamePath.addLineToPoint(CGPointMake((self.view.bounds.width/2.0 + 125.0),
                                                        (2.0*self.view.bounds.height/3.0 - 60)))
            //Create a CAShape Layer for username path
            let pathLayerUser: CAShapeLayer = CAShapeLayer()
            pathLayerUser.frame = self.view.bounds
            pathLayerUser.path = usernamePath.CGPath
            pathLayerUser.strokeColor = UIColor.whiteColor().CGColor
            pathLayerUser.fillColor = nil
            pathLayerUser.lineWidth = 0.7
            pathLayerUser.lineJoin = kCALineJoinBevel
            
            //Create a CAShape Layer for password path
            let pathLayerPass: CAShapeLayer = CAShapeLayer()
            pathLayerPass.frame = self.view.bounds
            pathLayerPass.path = passwordPath.CGPath
            pathLayerPass.strokeColor = UIColor.whiteColor().CGColor
            pathLayerPass.fillColor = nil
            pathLayerPass.lineWidth = 0.7
            pathLayerPass.lineJoin = kCALineJoinBevel
            
            //Add the layers to your view's layer
            self.view.layer.addSublayer(pathLayerUser)
            self.view.layer.addSublayer(pathLayerPass)
            
            //This is basic animation, quite a few other methods exist to handle animation see the reference site answers
            let pathAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathAnimation.duration = 0.3
            pathAnimation.fromValue = NSNumber(float: 0.0)
            pathAnimation.toValue = NSNumber(float: 1.0)
            
            //Animation will happen right away  
            pathLayerUser.addAnimation(pathAnimation, forKey: "strokeEnd")
            
            pathAnimation.duration = 0.4
            pathLayerPass.addAnimation(pathAnimation, forKey: "strokeEnd")
            
            fieldsAreShown = true
        }else{
            let username = self.username.text
            let password = self.password.text
            let oauth = genericOAuth2Password(username!, password: password!)
            //let parts = username!.characters.split() { $0 == "&" }.map() { String($0) }
            //oauth.authorize(params: OAuth2StringDict(minimumCapacity: <#T##Int#>)
            //oauth.authConfig.secretInBody = true
            oauth.authorize()
            oauth.onAuthorize = { parameters in
                print("Did authorize with parameters: \(parameters)")
                
                //change the view
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainView")
                //self.navigationController!.pushViewController(viewController, animated: true)
                self.presentViewController(viewController, animated: true, completion: nil)
            }
            oauth.onFailure = { error in        // `error` is nil on cancel
                if let error = error {
                    print("Authorization went wrong: \(error)")
                    let alert = UIAlertController(title: "Login Failed", message: "The user name or password is incorrect. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            
            /*
            let req = oauth.request(forURL: oauth.authURL)
            let task = oauth.session.dataTaskWithRequest(req) { data, response, error in
                if let error = error {
                    // something went wrong, check the error
                    print("Something went wrong: \(error)")

                }
                else {
                    // check the response and the data
                    // you have just received data with an OAuth2-signed request!
                }
            }
            task.resume()*/
            //preform login check
            
        }
       
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTage=textField.tag+1;
        // Try to find next responder
        let nextResponder=textField.superview?.viewWithTag(nextTage) as UIResponder!
        
        if (nextResponder != nil){
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        }
        else
        {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }
        return false // We do not want UITextField to insert line-breaks.
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
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
