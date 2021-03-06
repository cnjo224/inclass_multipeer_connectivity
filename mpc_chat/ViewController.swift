//
//  ViewController.swift
//  
//
//  Created by Corey Baker on 10/9/18.
//  Copyright © 2018 University of Kentucky - CS 485G. All rights reserved.
//  Followed and made additions to original tutorial by Gabriel Theodoropoulos
//  Swift: http://www.appcoda.com/chat-app-swift-tutorial/
//  Objective C: http://www.appcoda.com/intro-multipeer-connectivity-framework-ios-programming/
//

import UIKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPCManagerDelegate {
    
    let appDelagate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var tblPeers: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        tblPeers.delegate = self
        tblPeers.dataSource = self
        
        appDelagate.mpcManager.delegate = self
        
        // Register cell classes
        tblPeers.register(UITableViewCell.self, forCellReuseIdentifier: "idCellPeer")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: IBAction method implementation
    
    @IBAction func startStopAdvertising(_ sender: AnyObject) {
        let actionSheet = UIAlertController(title: "", message: "Change Visibility", preferredStyle: UIAlertController.Style.actionSheet)
        
        var actionTitle: String
        let isAdvertising = appDelagate.mpcManager.getIsAdvertising
        
        if isAdvertising == true {
            actionTitle = "Make me invisible to others"
        }else {
            
            actionTitle = "Make me visible to others"
        }
        
        let visibilityAction: UIAlertAction = UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default) { (alertAction) -> Void in
            if isAdvertising == true {
                self.appDelagate.mpcManager.stopAdvertising()
            }else {
                self.appDelagate.mpcManager.startAdvertising()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (alertAction) -> Void in
            
        }
        
        actionSheet.addAction(visibilityAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    
    // MARK: UITableView related method implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return appDelagate.mpcManager.foundPeerHashValues.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCellPeer") as! UITableViewCell
        
        let peerHashValue = appDelagate.mpcManager.foundPeerHashValues[indexPath.row]
        
        guard let displayName = appDelagate.mpcManager.getPeerDisplayName(peerHashValue) else{
            return cell
        }
        
        cell.textLabel?.text = displayName
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let peerHashValue = appDelagate.mpcManager.foundPeerHashValues[indexPath.row]
        
        //TODO: This function is used to send peer info we are interested in
        appDelagate.mpcManager.invitePeer(peerHashValue)
        
    }
    
    // MARK: MPCManager delegate method implementation
    func foundPeer() {
        tblPeers.reloadData()
    }
    
    func lostPeer() {
        tblPeers.reloadData()
    }
    
   
    func invitationWasReceived(_ fromPeer: String, completion: @escaping (_ fromPeer: String, _ accept: Bool) ->Void) {
        
        
        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you.", preferredStyle: UIAlertController.Style.alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertAction.Style.default)  {(alertAction) -> Void in
            completion(fromPeer, true)
        }
        
        let declineAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {(alertAction) -> Void in
            completion(fromPeer, false)
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        OperationQueue.main.addOperation{ () -> Void in
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    func connectedWithPeer(_ peerHash: Int) {
        
        OperationQueue.main.addOperation{ () -> Void in
            self.performSegue(withIdentifier: "idSegueChat", sender: self)
        }
        
    }
    
}


