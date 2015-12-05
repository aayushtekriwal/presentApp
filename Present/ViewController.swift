//
//  ViewController.swift
//  Present
//

import UIKit
import Parse
import LocalAuthentication
import CoreBluetooth
import CoreLocation

class ViewController: UIViewController, CBPeripheralManagerDelegate, UITextFieldDelegate {
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Present_Background.jpg")!)
        //        self.UsernameTextField.becomeFirstResponder()
        self.UsernameTextField.autocorrectionType = .No
        self.PasswordTextField.autocorrectionType = .No
        self.UsernameTextField.delegate = self;
        self.PasswordTextField.delegate = self;
        
        
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        login()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func login() {
        let user = PFUser()
        user.username = UsernameTextField.text
        user.password = PasswordTextField.text
        
        PFUser.logInWithUsernameInBackground(UsernameTextField.text!, password: PasswordTextField.text!, block: {(User : PFUser?, Error : NSError?) -> Void in
            
            if Error == nil {
                dispatch_async(dispatch_get_main_queue()){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let currentUser = PFUser.currentUser()
                    let query = PFUser.query()
                    query!.getObjectInBackgroundWithId(currentUser?.objectId! as String!, block: { (result:PFObject?, error:NSError?) -> Void in
                        if(result!.objectForKey("role") as! String == "Professor") {
                            print("Teacher")
                            let home : UIViewController = storyboard.instantiateViewControllerWithIdentifier("Home")
                            self.presentViewController(home, animated: true, completion: nil)
                        }
                        else {
                            print("Student")
                            let studentHome : UIViewController = storyboard.instantiateViewControllerWithIdentifier("StudentHome")
                            self.presentViewController(studentHome, animated: true, completion: nil)
                        }
                        
                    })
                }
            }else {
                NSLog("Wrong password")
                self.UsernameTextField.text = ""
                self.PasswordTextField.text = ""
                let alert = UIAlertController(title: "Login Failed", message: "Invalid login details", preferredStyle: UIAlertControllerStyle.Alert)
                self.UsernameTextField.becomeFirstResponder()
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //Beacon Code Below
    
    
    @IBAction func startBeacon(sender: AnyObject) {
        startLocalBeacon()
    }
    
    func stopLocalBeacon() {
        peripheralManager.stopAdvertising()
        peripheralManager = nil
        beaconPeripheralData = nil
        localBeacon = nil
    }
    
    func startLocalBeacon() {
        if localBeacon != nil {
            stopLocalBeacon()
        }
        
        let localBeaconUUID = "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"
        let localBeaconMajor: CLBeaconMajorValue = 123
        let localBeaconMinor: CLBeaconMinorValue = 456
        
        let uuid = NSUUID(UUIDString: localBeaconUUID)!
        localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: "Your private identifer here")
        
        beaconPeripheralData = localBeacon.peripheralDataWithMeasuredPower(nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state == .PoweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]!)
        } else if peripheral.state == .PoweredOff {
            peripheralManager.stopAdvertising()
        }
    }
    
    
    
    
    
    
    
    
    
    //    //TouchID Authentication Below
    //    func authenticateUser() {
    //
    //        let context = LAContext()
    //        var error: NSError?
    //        let reasonString = "Authentication required to access this application"
    //        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
    //            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: {(success, policyError) -> Void in
    //                if success {
    //                    print ("Authentication Successful", terminator: "")
    //                }
    //                else {
    //                    switch policyError!.code{
    //                    case LAError.SystemCancel.rawValue:
    //                        print("Authentication was cancelled by system", terminator: "")
    //                    case LAError.UserCancel.rawValue:
    //                        print("Authentication was cancelled by user", terminator: "")
    //                    case LAError.UserFallback.rawValue:
    //                        print("User selected to enter password", terminator: "")
    //                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
    //                            self.showPasswordAlert()
    //                        })
    //                    default:
    //                        print("Authentication failed!", terminator: "")
    //                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
    //                            self.showPasswordAlert()
    //                        })
    //                    }
    //                }
    //            })
    //
    //        } else {
    ////            let error = NSError.self
    //            print(error?.localizeDescription, terminator: "")
    //            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
    //                self.showPasswordAlert()
    //            })
    //        }
    //    }
    //    func showPasswordAlert() {
    //
    //        let alertController = UIAlertController(title: "Touch ID Password", message: "Please enter your password", preferredStyle: .Alert)
    //
    //        let defaultAction = UIAlertAction(title: "OK", style: .Cancel) { (action) -> Void in
    //            if let textField = alertController.textFields?.first {
    //                if textField.text == "password"{
    //                    print("Authentication Successful", terminator: "")
    //                }
    //                else{
    //                    self.showPasswordAlert()
    //                }
    //            }
    //        }
    //
    //        alertController.addAction(defaultAction)
    //
    //        alertController.addTextFieldWithConfigurationHandler{ (textField) -> Void in
    //            textField.placeholder = "Password"
    //            textField.secureTextEntry = true
    //        }
    //        self.presentViewController(alertController, animated: true, completion: nil)
    //    }
    
    
    
}