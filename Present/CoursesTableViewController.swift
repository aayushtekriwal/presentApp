//
//  CoursesTableViewController.swift
//  Present
//
//

import UIKit
import Parse

class CoursesTableViewController: UITableViewController {
    
    var currentUser = PFUser.currentUser()!
    var courses:[AnyObject] = []
    
//  *-*-*-*-*-*-*-*-*  New code by Aayush *-*-*-*-*-*-*-*-*
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
        let loginPage = self.storyboard?.instantiateViewControllerWithIdentifier("LoginNav")
        self.presentViewController(loginPage!, animated: true, completion: nil)
    }
//  *-*-*-*-*-*-*-*-*  End of new code by Aayush *-*-*-*-*-*-*-*-*

    override func viewWillAppear(animated: Bool) {
        courses = getCourses()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return courses.count
    }
    
    func getCourses() -> [AnyObject] {
        var allCourses : [AnyObject] = []
        let allUserEvents = PFQuery(className: "User_Event")
        allUserEvents.whereKey("userId", equalTo: currentUser)
        
        var userEvents : [AnyObject] = []
        
        do {
            userEvents = try allUserEvents.findObjects() as [PFObject]
        } catch _ {
            userEvents = []
        }
        
        for ue in userEvents {
            
            let courseId = ue["eventId"]!?.objectId
            let course = PFQuery(className: "Event")
            course.whereKey("objectId", equalTo: courseId!!)
            do {
                let courseObject = try course.getFirstObject()
                allCourses.append(courseObject)
            } catch _ {
//                let courseObject = "error"
            }
            
        }
        return allCourses
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "CoursesTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CoursesTableViewCell
        let course = courses[indexPath.row]
        let courseName = course["name"] as! String
        cell.courseNameLabel.text = courseName
        return cell
    }
    
    let rosterSegueIdentifier = "courseToRoster"
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == rosterSegueIdentifier {
            if let destination = segue.destinationViewController as? RosterTableViewController {
                if let courseIndex = tableView.indexPathForSelectedRow?.row {
                    destination.course = courses[courseIndex] as! PFObject
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    // Override to support editing the table view.
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
