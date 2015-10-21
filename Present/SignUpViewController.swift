//
//  SignUpViewController.swift
//  Present
//
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBAction func createUser(sender: AnyObject) {
        signUp()
    }
    @IBOutlet weak var rolePicker: UIPickerView!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    var roles = ["Professor", "Student"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  *-*-*-*-*-*-*-*-*  New code by Aayush *-*-*-*-*-*-*-*-*
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Present_Background_light.jpg")!)
//        self.firstNameField.becomeFirstResponder()
        //  *-*-*-*-*-*-*-*-*  End of new code by Aayush *-*-*-*-*-*-*-*-*
        
        rolePicker.delegate = self
        rolePicker.dataSource = self
        
        //  *-*-*-*-*-*-*-*-*  New code by Aayush *-*-*-*-*-*-*-*-*
        self.phoneField.delegate = self;
        self.emailField.delegate = self;
        self.passwordField.delegate = self;
        self.usernameField.delegate = self;
        self.lastNameField.delegate = self;
        self.firstNameField.delegate = self;
        self.emailField.keyboardType = UIKeyboardType.EmailAddress // This brings up a special keyboard to enter an email address
        self.phoneField.keyboardType = UIKeyboardType.PhonePad // This brings up a special keyboard to enter a phone number
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = roles[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Gill Sans", size: 18.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel.attributedText = myTitle
        
        //color  and center the label's background
        pickerLabel.backgroundColor = UIColor(hue: 0.0, saturation: 0.0, brightness:1.0, alpha: 0.7)
        pickerLabel.textAlignment = .Center
        return pickerLabel
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    //  *-*-*-*-*-*-*-*-*  End of new code by Aayush *-*-*-*-*-*-*-*-*
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func signUp() {
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        user.email = emailField.text
        user.setObject(phoneField.text!, forKey: "phone")
        user.setObject(firstNameField.text!, forKey: "firstName")
        user.setObject(lastNameField.text!, forKey: "lastName")
        user.setValue(roles[rolePicker.selectedRowInComponent(0)], forKey: "role")
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                _ = error.userInfo["error"] as? NSString
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if(self.roles[self.rolePicker.selectedRowInComponent(0)]=="Professor"){
                    let home : UIViewController = storyboard.instantiateViewControllerWithIdentifier("Home")
                    self.presentViewController(home, animated: true, completion: nil)
                }
                else{
                    let studentHome : UIViewController = storyboard.instantiateViewControllerWithIdentifier("StudentHome")
                    self.presentViewController(studentHome, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    //Code for Picker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return roles.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return roles[row]
    }
}
