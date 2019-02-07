//
//  NotificationsVC.swift
//  Escalate
//
//  Created by call soft on 20/07/18.
//  Copyright © 2018 call soft. All rights reserved.
//

import UIKit
import SDWebImage
class NotificationsVC: UIViewController {
    
    
    
    //MARK:- OUTLETS
    //MARK:
    
    
    @IBOutlet var tblNotifications: UITableView!
    
    
    //MARK:- VARIABLES
    //MARK:
    
    
    let WebserviceConnection  = AlmofireWrapper()
    
    var notificationDataArray = NSArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
          ScreeNNameClass.shareScreenInstance.screenName = "NotificationsVC"
        
        NotificationCenter.default.addObserver(self,selector:#selector(NotificationsVC.reloadNotificationsListApi(_:)),name:NSNotification.Name(rawValue: "NOTIFICATION_NOTIFYRELOAD"),object: nil)
        
        notificationList()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
         ScreeNNameClass.shareScreenInstance.screenName = "NotificationsVC"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    //TODO:- WEB SERVICES
    
    @objc func reloadNotificationsListApi(_ notification: Notification){
        
        
        
        notificationList()
        
    }
    
    
    func notificationList(){
        
        
        
        let infoArray = UserDefaults.standard.value(forKey: "USERINFO") as? NSArray ?? []
        //print(infoArray)
        let infoDict = infoArray.object(at: 0) as? NSDictionary ?? [:]
        
        //print(infoDict)
        
        let user_id = infoDict.value(forKey: "user_id") as? String ?? ""
        
        //print(user_id)
        
        
        if InternetConnection.internetshared.isConnectedToNetwork() {
            
            Indicator.shared.showProgressView(self.view)
            
            
            
            WebserviceConnection.requestGETURL("notifylist/\(user_id)", success: { (responseJson) in
                
                if responseJson["status"].stringValue == "SUCCESS" {
                    
                    Indicator.shared.hideProgressView()
                    
                    print("SUCCESS")
                    
                    print(responseJson)
                    self.tblNotifications.tableFooterView = UIView()
                    
                    self.notificationDataArray = responseJson["data"].arrayObject as? NSArray ?? []
                    
                    
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    
                    UserDefaults.standard.set(0, forKey: "BADGECOUNT")
                    
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    
                    self.tblNotifications.dataSource = self
                    self.tblNotifications.delegate = self
                    
                    self.tblNotifications.reloadData()
                 
                    
                    
                }else{
                    
                    print(responseJson)
                    
                    Indicator.shared.hideProgressView()
                    
                    let message  = responseJson["message"].stringValue as? String ?? ""
                    
                    _ = SweetAlert().showAlert("Escalate", subTitle: message, style: AlertStyle.error)
                    
                    if message == "Login Token Expire"{
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LogInVC") as! LogInVC
                        
                        self.navigationController!.pushViewController(vc, animated: true)
                    }else{
                        
                        print("do Nothing")
                    }
                    
                }
                
                
            },failure: { (Error) in
                
                _ = SweetAlert().showAlert("Escalate", subTitle: "Something went wrong.Please try again!", style: AlertStyle.error)
                Indicator.shared.hideProgressView()
                
                
            })
            
            
        }else{
            
            _ = SweetAlert().showAlert("Escalate", subTitle: "No interter connection!", style: AlertStyle.error)
            Indicator.shared.hideProgressView()
            
        }
        
        
        
    }
    
    
    

    
    
    //MARK:- ACTIONS
    //MARK:
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
  
    
}



//MARK:- EXTENTION TABLE VIEW
//MARK:

extension NotificationsVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        tblNotifications.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatTableViewCell")
        
        let cell = tblNotifications.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        
        if notificationDataArray.count > 0{
            
            
            let dataDict = notificationDataArray.object(at: indexPath.row) as? NSDictionary ?? [:]
            
            cell.lblNotificationBody.sizeToFit()
            
            cell.lblNotificationBody.text = dataDict.value(forKey: "msg") as? String ?? ""
            cell.lblTime.text = dataDict.value(forKey: "time") as? String ?? ""
            let imgString = dataDict.value(forKey: "image") as? String ?? ""
            
            
            cell.imgProfile.sd_setImage(with: URL(string: imgString as? String ?? ""), placeholderImage: UIImage(named: "user_signup"))
//
//            self.imgProfile.sd_setImage(with: URL(string: image as? String ?? ""), placeholderImage: UIImage(named: "user_signup"))
            
        }
        
//        var normalText = "You have a booking on"
//        
//        var boldText  = " 28/05/2018."
//        
//        var attributedString = NSMutableAttributedString(string:normalText)
//        
//        var attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14 )]
//        
//        var boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
//        
//        attributedString.append(boldString)
//        cell?.lblDescriptionNotification.attributedText = attributedString
        
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
    }
    
}

