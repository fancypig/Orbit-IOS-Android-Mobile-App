//
//  Outbox.swift
//  Orbit
//
//  Created by Percy teng on 2016-06-21.
//  Copyright © 2016 Percy teng. All rights reserved.
//

import UIKit

class Outbox: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var toolBar: UIToolbar!
    var username = String()
    var values:NSArray = []
    var myActivityIndicator:UIActivityIndicatorView!
    var show = true


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Open: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        myActivityIndicator = ActivityIndicator().StartActivityIndicator(self);

        Open.target = self.revealViewController()
        Open.action = #selector(SWRevealViewController.revealToggle(_:))
        username = tempUser.username
            // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Inbox.methodhandlingTheNotificationEvent), name:"deleteMessage", object: nil)
    }
    func methodhandlingTheNotificationEvent(notification:NSNotification){
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let from = userInfo["from"]
        let to = userInfo["to"]
        let subject = userInfo["subject"]
        print ("check\(from)&\(to)&\(subject)")
        var temp = NSMutableArray()
        for ele in values{
            if ele["toText"] as! String != to! || ele["fromText"] as! String != from! || ele["subject"] as! String != subject!{
                temp.addObject(ele)
            }
        }
        values = temp as NSArray
        tableView.reloadData()
        print("heee")
        get()
        
    }

    override func viewWillAppear(animated: Bool) {
        get()
    }
    override func viewDidAppear(animated: Bool) {
        ActivityIndicator().StopActivityIndicator(self,indicator: myActivityIndicator);

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func get(){
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.percyteng.com/orbit/getInbox.php")!)
        request.HTTPMethod = "POST"
        let postString = "user=ios"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            if error != nil {
                
                print("error=\(error)")
                return
            }
            
            print("response = \(response)")
            let responseString = try! NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
            if responseString!["success"] as! Int == 0{
                return
            }
            let array:NSArray = responseString!["all"] as! NSArray
            var temp = NSMutableArray()
            //            let array = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                for ele in array{
                    if ele["fromText"] as! String == self.username{
                        temp.addObject(ele)
                    }
                }
                self.values = temp as NSArray
                self.tableView?.reloadData();
            }
            
        }
        task.resume()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if show == true{
            ActivityIndicator().StopActivityIndicator(self,indicator: myActivityIndicator);
            show = false
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as!MessageCell
        let maindata = values[values.count-1-indexPath.row]
        if let url = NSURL(string: "http://percyteng.com/orbit/pictures/\(maindata["toText"] as! String).JPG") {
            if let data = NSData(contentsOfURL: url) {
                cell.messageImage.image = UIImage(data: data)
            }
        }
//        cell.messageImage.image = UIImage(named: "tile_events")
        cell.titleTXT.text = maindata["subject"] as! String
        cell.targetTXT.text = "To: \(maindata["toText"] as! String)"
        cell.timeStamp.text = maindata["time"] as! String
        cell.from = maindata["fromText"] as! String
        cell.to = maindata["toText"] as! String
        cell.subject = maindata["subject"] as! String
        cell.content = maindata["content"] as! String
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("showMessages") as! showMessage
        
        tempUser.typeMessage = "Outbox"

        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMoveToParentViewController(self)
        let maindata = values[values.count-1-indexPath.row]
        popOverVC.from.text = "  To: \(maindata["toText"] as! String)"
        if let url = NSURL(string: "http://percyteng.com/orbit/pictures/\(maindata["toText"] as! String).JPG") {
            if let data = NSData(contentsOfURL: url) {
                popOverVC.profile.image = UIImage(data: data)
            }
        }
        popOverVC.subjectLabel.text = maindata["subject"] as! String
        popOverVC.whereFrom.text = maindata["cameFrom"] as! String
        popOverVC.timeLabel.text = maindata["time"] as! String
        popOverVC.content.text = maindata["content"] as! String
    }

}
