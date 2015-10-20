//
//  AddClassViewController.swift
//  Present
//
//

import UIKit
import Parse

class AddClassViewController: UIViewController {
    
    let currentUser = PFUser.currentUser()!

    @IBOutlet weak var majorInput: UITextField!
    @IBOutlet weak var minorInput: UITextField!
    
    @IBAction func saveClass(sender: AnyObject) {
        addClass()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//  *-*-*-*-*-*-*-*-*  New code by Aayush *-*-*-*-*-*-*-*-*
        self.majorInput.becomeFirstResponder() //focuses the first empty field by default. This way the keyboard is already open, so the user has to do one less click
        self.majorInput.keyboardType = UIKeyboardType.PhonePad // This brings up a special keyboard to enter a major value
        self.minorInput.keyboardType = UIKeyboardType.PhonePad // This brings up a special keyboard to enter a minor value
//  *-*-*-*-*-*-*-*-*  End of new code by Aayush *-*-*-*-*-*-*-*-*

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addClass() {
        if (majorInput.text!.isEmpty || minorInput.text!.isEmpty) {
            let alert = UIAlertView()
            alert.title = "Missing Fields"
            alert.message = "One or more of the fields are blank...please complete"
            alert.addButtonWithTitle("Ok")
            alert.show()
        } else {
            let allCourses = PFQuery(className: "Event")
            let major = Int(majorInput.text!)
            let minor = Int(minorInput.text!)
            allCourses.whereKey("major", equalTo: major!)
            allCourses.whereKey("minor", equalTo: minor!)
            var courseObjects : [AnyObject] = []
            do {
                courseObjects = try allCourses.findObjects() as [PFObject]
            } catch _ {
                courseObjects = []
            }

//  *-*-*-*-*-*-*-*-*  New code by Aayush *-*-*-*-*-*-*-*-* NOTE: 
//*******The code below does not work. The intention was to add validation so that the app refresed the add class form rather than crashing when the entered values are wrong.
            if courseObjects.count == 0 {
                self.majorInput.text = ""
                self.minorInput.text = ""
                let alert = UIAlertController(title: "Invalid Major and Minor details", message: "No class exists with entered major and minor numbers", preferredStyle: UIAlertControllerStyle.Alert)
                self.majorInput.becomeFirstResponder()
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
//  *-*-*-*-*-*-*-*-*  End of new code by Aayush *-*-*-*-*-*-*-*-*

            
            let courseObject = courseObjects[0]
            let userEvent = PFObject(className: "User_Event")
            userEvent.setObject(courseObject, forKey: "eventId")
            userEvent.setObject(currentUser, forKey: "userId")
            
            userEvent.saveInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    _ = error.userInfo["error"] as? NSString
                    // Show the errorString somewhere and let the user try again.
                } else {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
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
