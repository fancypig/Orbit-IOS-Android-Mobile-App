//
//  createTutor.swift
//  Orbit
//
//  Created by Percy teng on 2016-06-23.
//  Copyright © 2016 Percy teng. All rights reserved.
//

import UIKit

class createTutor: UIViewController {
    @IBOutlet weak var subject: UITextField!
    var username = String()
    var school = String()
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var cost: UITextField!
    @IBOutlet weak var notes: KMPlaceholderTextView!
    let DoneToolbar: UIToolbar = UIToolbar()
    @IBOutlet weak var nameTag: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        profile.layer.borderWidth = 1
        username = tempUser.username
        self.view.layoutIfNeeded()
        profile.layer.masksToBounds = false
        profile.layer.cornerRadius = profile.frame.size.width/2
        profile.clipsToBounds = true
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.showAnimate()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(createTutor.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(createTutor.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        // Do any additional setup after loading the view.
        DoneToolbar.barStyle = UIBarStyle.Default
        DoneToolbar.items=[
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Bordered, target: self, action: #selector(showPostT.boopla))
        ]
        
        DoneToolbar.sizeToFit()
        subject.inputAccessoryView = DoneToolbar
        location.inputAccessoryView = DoneToolbar
        cost.inputAccessoryView = DoneToolbar
        notes.inputAccessoryView = DoneToolbar
        if let url = NSURL(string: "http://percyteng.com/orbit/pictures/\(tempUser.username).JPG") {
            if let data = NSData(contentsOfURL: url) {
                profile.image = UIImage(data: data)
            }
        }
    }
    func boopla () {
        subject.resignFirstResponder()
        location.resignFirstResponder()
        cost.resignFirstResponder()
        notes.resignFirstResponder()
    }
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(sender: AnyObject) {
        self.removeAnimate()

    }
    @IBAction func post(sender: AnyObject) {
        if subject.text!.isEmpty{
            let alert = UIAlertController(title: "Invalid subject", message:"Please enter a subject.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
            
        }
            
        else if location.text!.isEmpty{
            let alert = UIAlertController(title: "Invalid Location", message:"Please enter a location for the tutorial", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
            
        }
        else if cost.text!.isEmpty{
            let alert = UIAlertController(title: "Invalid price", message:"Please enter a price", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
            
        }
        else{

        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.percyteng.com/orbit/createTutors.php")!)
        request.HTTPMethod = "POST"
        let postString = "username=\(username)&location=\(location.text!)&cost=\(cost.text!)&notes=\(notes.text)&school=\(school)&subject=\(subject.text!)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            print("response = \(response)")
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
        }
        task.resume()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshyoo", object: nil,userInfo:["first":location.text!,
                "second":cost.text!,
                "third":notes.text!,
                "fourth": subject.text!,
                "school":school])
            NSNotificationCenter.defaultCenter().removeObserver(self)

            self.view.removeFromSuperview()
        }
    }
    func showAnimate(){
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.view.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations:{
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        })
    }
    func removeAnimate(){
        
        UIView.animateWithDuration(0.25, animations:{
            self.view.alpha = 0.0
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            }, completion: {(finished : Bool) in
                if (finished){
                    self.view.removeFromSuperview()
                }
        })
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
