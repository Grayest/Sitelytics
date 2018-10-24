//
//  LoginViewController.swift
//  SiteData
//
//  Created by Mark Lyons on 10/23/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    var databaseMgr : DataActions?
    var selectedSource : String = ""

    @IBOutlet weak var loginTitle: UILabel!
    @IBOutlet weak var loginSubline: UILabel!
    @IBOutlet weak var usernameEmail: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var storeID: UITextField!
    @IBOutlet weak var loginButtonFinal: UIButton!
    
    @IBAction func loginClicked(_ sender: Any) {
        databaseMgr?.addAmazonAccount(email: usernameEmail.text!, password: passwordInput.text!, storeIds: storeID.text!)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButtonFinal.layer.cornerRadius = 5

        if(selectedSource == "Amazon Associates") {
            loginTitle.text = "Login to Amazon Associates"
            loginSubline.text = "Login using your normal credentials. Make sure you are using the correct Store ID!"
            usernameEmail.placeholder = "Your Associates email"
            passwordInput.placeholder = "Your Associates password"
            storeID.placeholder = "Your Associates Store ID"
            storeID.isHidden = false
        } else if(selectedSource == "Google AdSense") {
            loginTitle.text = "Login to Google AdSense"
        } else if(selectedSource == "eBay Partner Network") {
            loginTitle.text = "Login to eBay Partner Network"
        } else if(selectedSource == "Ezoic") {
            loginTitle.text = "Login to Ezoic"
        }
        
        
    }
}
