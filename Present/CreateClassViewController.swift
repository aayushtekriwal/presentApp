//
//  CreateClassViewController.swift
//  Present
//

import UIKit
import Parse

class CreateClassViewController: UIViewController {
    
    @IBOutlet var className: UITextField!
    @IBOutlet var classDpt: UITextField!
    @IBOutlet var classDesc: UITextField!
    @IBOutlet var classLateAfter: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//  *-*-*-*-*-*-*-*-*  New code by Aayush *-*-*-*-*-*-*-*-*
        self.className.becomeFirstResponder() //focuses the first empty field by default. This way the keyboard is already open, so the user has to do one less click
        self.classLateAfter.keyboardType = UIKeyboardType.PhonePad // This brings up a special keyboard to enter a major value
//  *-*-*-*-*-*-*-*-*  End of new code by Aayush *-*-*-*-*-*-*-*-*
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveCourse(sender: AnyObject) {
        createCourse()
    }
    
//  *-*-*-*-*-*-*-*-*  New code by Aayush *-*-*-*-*-*-*-*-* 
    
//***Replace the complete original create course function as new validations have been added to allow user to only enter name, and possibly leave the other fields black. Course name is the only required field.
    func createCourse() {
        let course = PFObject(className: "Event")
        
        if (className.text!.isEmpty) {
            let alert = UIAlertView()
            alert.title = "No Course Name Entered"
            alert.message = "The course name is blank...please complete"
            alert.addButtonWithTitle("Ok")
            alert.show()
        } else {
            course.setObject(className.text!, forKey: "name")
            
            if (classDpt.text!.isEmpty) {
                course.setObject("", forKey: "department")
            } else{
                course.setObject(classDpt.text!, forKey: "department")
            }
            
            if (classDesc.text!.isEmpty) {
                course.setObject("", forKey: "description")
            } else{
                course.setObject(classDesc.text!, forKey: "description")
            }
            course.setValue("5A4BCFCE-174E-4BAC-A814-092E77F6B7E5", forKey: "uuid")
            course.setValue(randomMajMin(), forKey: "major")
            course.setValue(randomMajMin(), forKey: "minor")
            
            if (!(classLateAfter.text!.isEmpty)){
                course.setObject(Int(classLateAfter.text!)!, forKey: "lateAfter")
            }
            course.saveInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    _ = error.userInfo["error"] as? NSString
                    // Show the errorString somewhere and let the user try again.
                } else {
                    let userEvent = PFObject(className: "User_Event")
                    userEvent.setObject(course, forKey: "eventId")
                    userEvent.setObject(PFUser.currentUser()!, forKey: "userId")
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
        }
    }
    
//  *-*-*-*-*-*-*-*-*  End of new code by Aayush *-*-*-*-*-*-*-*-*
    
    func randomMajMin() -> Int {
        let lower : UInt32 = 1
        let upper : UInt32 = 65534
        let randomNumber = arc4random_uniform(upper - lower) + lower
        return Int(randomNumber)
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
