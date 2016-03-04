//
//  UserTokenViewController.swift
//  Drive Thru
//
//  Created by Nanite Solutions on 1/29/16.
//  Copyright © 2016 Nanite Solutions. All rights reserved.
//

import UIKit
import PusherSwift
class UserTokenViewController: UIViewController {
    
    var status:String!
    var isImageChange:[Bool] = [false, false, false, false, false]
    var noImageClicked:Bool = false
    var rating:Float = 0.0
    var consumerId:String = String()
    var TokenId:String = ""
    var OrderId:String = ""
    var displayOrderId:String = ""
    var shapeLayer = CAShapeLayer()
    let defaults = NSUserDefaults.standardUserDefaults()
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var mapVC = MapViewController()
    // var consumerId:int
    @IBOutlet var imgPickedUp: UIImageView!
    @IBOutlet var imgGreenPickupReady: UIImageView!
    @IBOutlet var imgGreenOrderPlaced: UIImageView!
    @IBOutlet var imgGreenPreparation: UIImageView!
    @IBOutlet var imgGreenKiosk: UIImageView!
    @IBOutlet var imgShopImage: UIImageView!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblOrderId: UILabel!
    @IBOutlet var lblDisplayOrderId: UILabel!
    @IBOutlet var lblToken: UILabel!
    @IBOutlet var lblDisplayTokenId: UILabel!
    @IBOutlet var imgOrderPlaced: UIImageView!
    @IBOutlet var imgPreparation: UIImageView!
    @IBOutlet var imgKioskReady: UIImageView!
    @IBOutlet var imgPickupReady: UIImageView!
    @IBOutlet var lblRateYourExperience: UILabel!
    @IBOutlet var btnRatingStar1: UIButton!
    @IBOutlet var btnRatingStar2: UIButton!
    @IBOutlet var btnRatingStar3: UIButton!
    @IBOutlet var btnRatingStar4: UIButton!
    @IBOutlet var btnRatingStar5: UIButton!
    @IBOutlet weak var viewToken: UIView!
    @IBOutlet var merchantImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        displayMerchantImage()
        lblDisplayTokenId.text = TokenId
        lblDisplayOrderId.text = OrderId
        status = "placed"
//        imgOrderPlaced.image = UIImage(named:"OrderPlaced_green.png")
//        if imgOrderPlaced.image == UIImage(named: "OrderPlaced_green.png"){
//            imgOrderPlaced.frame = CGRectMake(self.view.frame.origin.x/2, 522, 180, 180)
//        }
        self.setLabelCornerRadius()
        self.pushNotification()
        lblAddress.text = defaults.objectForKey("StoreAddress") as? String
        if appDelegate.isPreferenceChanged
        {
            DataManager.setPreference()
        }
        // consumerId = (defaults.objectForKey("user_ID") as? String)!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayMerchantImage()
    {
        let imageName = self.appDelegate.MerchantImageUrlString
        let url = NSURL(string: imageName)
        let request: NSURLRequest = NSURLRequest(URL: url!)
        let mainQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
            if error == nil {
                // Convert the downloaded data in to a UIImage object
                let image = UIImage(data: data!)
                // Store the image in to our cache
                // Update the cell
                dispatch_async(dispatch_get_main_queue(), {
                    // if let cellToUpdate = menuCV.cellForRowAtIndexPath(indexPath) as? menuCollectionViewCell {
                    // cellToUpdate.imageView?.image = image
                    self.merchantImageView.image = image
                    
                    // }
                })
                
            }
            else {
                print("Error: \(error!.localizedDescription)")
            }
        })
        
        
    }

    
    
    func setLabelCornerRadius(){
        lblOrderId.layer.borderWidth = 1.0
        lblOrderId.layer.cornerRadius = 5.0
        lblOrderId.layer.borderColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0).CGColor
        lblDisplayOrderId.layer.borderWidth = 1.0
        lblDisplayOrderId.layer.cornerRadius = 5.0
        lblDisplayOrderId.layer.borderColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0).CGColor
        lblToken.layer.borderWidth = 1.0
        lblToken.layer.cornerRadius = 5.0
        lblToken.layer.borderColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0).CGColor
        
        lblDisplayTokenId.layer.cornerRadius = lblDisplayTokenId.frame.width/2
        //        lblDisplayTokenId.bounds = CGRectMake(lblDisplayTokenId.frame.origin.x, lblDisplayTokenId.frame.origin.y, lblDisplayTokenId.frame.width, lblDisplayTokenId.frame.height)
        //        lblDisplayTokenId.layer.cornerRadius = lblDisplayTokenId.frame.width / 2.5
        //        lblDisplayTokenId.layer.borderWidth = 1.0
        //        lblDisplayTokenId.layer.backgroundColor = UIColor.clearColor().CGColor
        //        lblDisplayTokenId.layer.borderColor = UIColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 1.0).CGColor
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 0 + (viewToken.frame.size.width/2) ,y: 0 + (viewToken.frame.size.height/2)), radius: CGFloat((viewToken.frame.size.width/2)-3), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        
        shapeLayer.path = circlePath.CGPath
        
        //change the fill color
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 1.0).CGColor
        //you can change the line width
        shapeLayer.lineWidth = 1.0
        viewToken.layer.addSublayer(shapeLayer)
        self.viewToken.bringSubviewToFront(lblDisplayTokenId)
    }
    func pushNotification()
    {
        let pusher = Pusher(key: "1f006f9bd40000fbe5e8", options: ["secret": "118ce01e86e2ff6aa374"])
        pusher.connect()
        let chan = pusher.subscribe("consumer_10")
        chan.bind("consumer_event", callback: { (data: AnyObject?) -> Void in
            if let vstatus = data?.objectForKey("order_status") as? String
            {
                self.status = vstatus
            }
            if let vorder_id = data?.objectForKey("orderID") as? String
            {
                self.displayOrderId = vorder_id
            }
            if let vtoken = data?.objectForKey("token"){
                self.lblDisplayTokenId.text = String(vtoken)
            }
            if self.displayOrderId  == self.OrderId{
                switch self.status
                {                case "placed":
                    self.imgOrderPlaced.image = UIImage(named: "OrderPlaced_green.png")
                    self.imgKioskReady.image = UIImage(named: "forDelivery.png")
                    self.imgPreparation.image = UIImage(named: "cooking.png")
                    self.imgPickupReady.image = UIImage(named: "ReadyForPickup3.png")
                   // self.imgOrderPlaced.frame = CGRectMake(245, 517, 80, 80)

                    // self.imgOrderPlaced.image = self.resizeImage(UIImage(named: "OrderPlaced_green.png")!,  scaledToSize: CGSizeMake(180,180))
                    self.imgPickedUp.hidden = true
                    return
                case "inprogress":
                    self.imgPreparation.image = UIImage(named: "Preparation_Green.png")
                    self.imgOrderPlaced.image = UIImage(named: "Cart.png")
                    self.imgKioskReady.image = UIImage(named: "forDelivery.png")
                    self.imgPickupReady.image = UIImage(named: "ReadyForPickup3.png")
                   // self.imgPreparation.frame = CGRectMake(200, 450, 80, 80)
                    self.imgPickedUp.hidden = true
                    return
                case "for_delivery":
                    self.imgKioskReady.image = UIImage(named: "KioskReady_green.png")
                    self.imgPreparation.image = UIImage(named: "cooking.png")
                    self.imgOrderPlaced.image = UIImage(named: "Cart.png")
                    self.imgPickupReady.image = UIImage(named: "ReadyForPickup3.png")
                    self.imgPickedUp.hidden = true
                    //self.imgKioskReady.frame = CGRectMake(185, 517, 80, 80)
                    return
                case "ready_to_pickup":
                    let localnotification = UILocalNotification()
                    localnotification.alertAction = "Drive Thru"
                    localnotification.alertBody = "Your order is ready to pickup"
                    localnotification.timeZone = NSTimeZone.defaultTimeZone()
                    UIApplication.sharedApplication().scheduleLocalNotification(localnotification)
                    
                    self.shapeLayer.fillColor = UIColor(red: 51/100, green: 51/100, blue: 51/100, alpha: 1).CGColor
                    self.lblDisplayTokenId.textColor = UIColor(red: 34/100, green: 255/100, blue: 7/100, alpha: 1)
                    self.imgPickupReady.image = UIImage(named: "PickupReady_green.png")
                    self.imgOrderPlaced.image = UIImage(named: "Cart.png")
                    self.imgPreparation.image = UIImage(named: "cooking.png")
                    self.imgKioskReady.image = UIImage(named: "forDelivery.png")
                    self.imgPickedUp.hidden = true
                    self.shapeLayer.contents = self.lblDisplayTokenId
                    return
                default:
                    self.imgPickedUp.hidden = false
                    self.lblDisplayTokenId.addSubview(self.imgPickedUp)
                    self.imgPickupReady.image = UIImage(named: "ReadyForPickup3.png")
                    self.imgOrderPlaced.image = UIImage(named: "Cart.png")
                    self.imgPreparation.image = UIImage(named: "cooking.png")
                    self.imgKioskReady.image = UIImage(named: "forDelivery.png")
                    self.lblRateYourExperience.hidden = false
                    self.btnRatingStar1.hidden = false
                    self.btnRatingStar2.hidden = false
                    self.btnRatingStar3.hidden = false
                    self.btnRatingStar4.hidden = false
                    self.btnRatingStar5.hidden = false
                }
            }
        })
    }
    
    func resizeImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    @IBAction func btnStar1_Click(sender: AnyObject) {
        if(isImageChange[0] == false)
        {
            btnRatingStar1.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            isImageChange[0]=true
            rating = 1
            if(noImageClicked==true )
            {
                btnRatingStar2.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
                btnRatingStar3.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
                btnRatingStar4.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
                btnRatingStar5.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
            }
        }
        else
        {
            if(noImageClicked==true )
            {
                btnRatingStar2.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
                btnRatingStar3.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
                btnRatingStar4.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
                btnRatingStar5.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
                
            }
            isImageChange[0] = false
            rating = 0.0
        }
        noImageClicked=true
    }
    @IBAction func btnStar2_Click(sender: AnyObject) {
        if(isImageChange[1] == false)
        {
            btnRatingStar1.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            btnRatingStar2.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            rating = 2.0
            if(noImageClicked==true )
            {
                btnRatingStar3.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
                btnRatingStar4.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
                btnRatingStar5.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
            }
            isImageChange[1]=true
        }
        else
        {
            btnRatingStar1.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            rating = 1.0
            if(noImageClicked==true )
            {
                btnRatingStar3.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
                btnRatingStar4.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
                btnRatingStar5.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
            }
            isImageChange[1] = false
        }
        noImageClicked=true
    }
    @IBAction func btnStar3_Click(sender: AnyObject) {
        if(isImageChange[2] == false)
        {
            btnRatingStar1.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            btnRatingStar2.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            btnRatingStar3.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            rating = 3.0
            isImageChange[2]=true
            if(noImageClicked==true )
            {
                btnRatingStar4.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
                btnRatingStar5.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
            }
        }
        else
        {
            btnRatingStar1.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            btnRatingStar2.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            isImageChange[2] = false
            rating = 2.0
            if(noImageClicked==true )
            {
                btnRatingStar4.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
                btnRatingStar5.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
            }
        }
        noImageClicked=true
    }
    @IBAction func btnStar4_Click(sender: AnyObject) {
        if(isImageChange[3] == false)
        {
            btnRatingStar1.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            btnRatingStar2.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            btnRatingStar3.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            btnRatingStar4.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            rating = 4.0
            isImageChange[3]=true
            if(noImageClicked==true )
            {
                btnRatingStar5.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
            }
        }
        else
        {
            btnRatingStar1.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            btnRatingStar2.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            btnRatingStar3.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            isImageChange[3] = false
            rating = 3.0
            if(noImageClicked==true )
            {
                btnRatingStar5.setImage(UIImage(named:"star_blank.png"), forState: UIControlState.Normal)
            }
        }
        noImageClicked=true
    }
    @IBAction func btnStar5_Click(sender: AnyObject) {
        if(isImageChange[4] == false)
        {
            btnRatingStar1.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            btnRatingStar2.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            btnRatingStar3.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            btnRatingStar4.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            btnRatingStar5.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            rating = 5.0
            isImageChange[4]=true
        }
        else
        {
            btnRatingStar1.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            btnRatingStar2.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            btnRatingStar3.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            btnRatingStar4.setImage(UIImage(named:"star_full.png"), forState: UIControlState.Normal)
            isImageChange[4] = false
            rating = 4.0
        }
        noImageClicked=true
        
    }
    
}
