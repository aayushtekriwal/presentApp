//
//  StudentCourseViewController.swift
//  Present
//
//

import UIKit
import Parse
import CoreLocation

class StudentCourseViewController: UIViewController, CLLocationManagerDelegate {
    
    var course = PFObject(className: "Event")
    var currentUser = PFUser.currentUser()!
    var locationManager: CLLocationManager!
    var checkedIn = false
    
    //  *-*-*-*-*-*-*-*-*  New code by Aayush *-*-*-*-*-*-*-*-*
    //    @IBOutlet weak var courseNameLabel: UILabel!  // *******Delete this line of code******
    //  *-*-*-*-*-*-*-*-*  End of new code by Aayush *-*-*-*-*-*-*-*-*
    
    @IBAction func checkIn(sender: AnyObject) {
        getCheckedIn()
    }
    @IBOutlet weak var beaconStrength: UILabel!
    @IBOutlet weak var checkInStatus: UILabel!
    @IBOutlet weak var checkInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  *-*-*-*-*-*-*-*-*  New code by Aayush *-*-*-*-*-*-*-*-*
        //        courseNameLabel.text = course["name"] as? String // *******Delete this line of code******
        self.title = course["name"] as? String
        //  *-*-*-*-*-*-*-*-*  End of new code by Aayush *-*-*-*-*-*-*-*-*
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        getCheckInStatus()
    }
    
    func getCheckedIn() {
        let allUserEvents = PFQuery(className: "User_Event")
        allUserEvents.whereKey("userId", equalTo: currentUser)
        allUserEvents.whereKey("eventId", equalTo: course)
        var userEvents : [AnyObject] = []
        do {
            userEvents = try allUserEvents.findObjects() as [PFObject]
            
        } catch _ {
            userEvents = []
        }
        
        let userEvent = userEvents[0]
        
        let log = PFObject(className: "Log")
        log.setObject(userEvent, forKey: "userEventObjectId")
        
        //  *-*-*-*-*-*-*-*-*  New code by Aayush *-*-*-*-*-*-*-*-*
        log.setObject("Present", forKey: "type") // log can save variable type. We need to specify what type of log. Students can check-in to mark themselves present
        // "In future" we can propose the addition of a feature where the Professor can create a log to mark the student absent on purpose, and then alter conditions to display the student's status in the roster in red. This is the reason why I suggested changing unknown presence status from red to clear color in the first place.
        //  *-*-*-*-*-*-*-*-*  End of new code by Aayush *-*-*-*-*-*-*-*-*
        
        log.saveInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                _ = error.userInfo["error"] as? NSString
                // Show the errorString somewhere and let the user try again.
            } else {
                self.viewDidLoad()
            }
        }
    }
    
    func getCheckInStatus() {
        let allUserEvents = PFQuery(className: "User_Event")
        allUserEvents.whereKey("userId", equalTo: currentUser)
        allUserEvents.whereKey("eventId", equalTo: course)
        var userEvents : [AnyObject] = []
        do {
            userEvents = try allUserEvents.findObjects() as [PFObject]
            
        } catch _ {
            userEvents = []
        }
        let userEvent = userEvents[0]
        
        let allLogs = PFQuery(className: "Log")
        allLogs.whereKey("userEventObjectId", equalTo: userEvent)
        var logs : [AnyObject] = []
        do {
            logs = try allLogs.findObjects() as [PFObject]
            
        } catch _ {
            logs = []
        }
        if logs.count == 0 {
            self.checkInStatus.text = "Not Checked In"
            self.checkedIn = false
        }else {
            self.checkInStatus.text = "Checked In!"
            self.checkedIn = true
            self.checkInButton.enabled = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            if CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    print("in location manager func")
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        let courseUuid = course["uuid"] as! String
        let courseMajor = CLBeaconMajorValue(course["major"] as! Int)
        let courseMinor = CLBeaconMinorValue(course["minor"] as! Int)
        let uuid = NSUUID(UUIDString: courseUuid)
        let courseName = course["name"] as! String
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid!, major: courseMajor, minor: courseMinor, identifier: courseName)
        
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        if beacons.count > 0 {
            let beacon = beacons[0]
            updateDistance(beacon.proximity)
        } else {
            updateDistance(.Unknown)
        }
    }
    
    func updateDistance(distance: CLProximity) {
        UIView.animateWithDuration(0.8) {
            switch distance {
            case .Unknown:
                self.view.backgroundColor = UIColor.lightGrayColor()
                self.beaconStrength.text = "Not In Range"
                self.checkInButton.enabled = false
            case .Far:
                self.view.backgroundColor = UIColor.orangeColor()
                self.beaconStrength.text = "Weak"
                if (self.checkedIn==false) {
                    self.checkInButton.enabled = true
                    self.checkInButton.titleLabel?.textColor = UIColor.whiteColor()
                }
            case .Near:
                self.view.backgroundColor = UIColor.yellowColor()
                self.beaconStrength.text = "Average"
                if (self.checkedIn==false) {
                    self.checkInButton.enabled = true
                    self.checkInButton.titleLabel?.textColor = UIColor.whiteColor()
                }
            case .Immediate:
                self.view.backgroundColor = UIColor.greenColor()
                self.beaconStrength.text = "Strong"
                if (self.checkedIn==false) {
                    self.checkInButton.enabled = true
                    self.checkInButton.titleLabel?.textColor = UIColor.whiteColor()
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
