//
//  LoginViewController.swift
//  SiteData
//
//  Created by Mark Lyons on 10/23/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    var databaseMgr : DataActions?
    var selectedSource : String = ""

    @IBOutlet weak var loginTitle: UILabel!
    @IBOutlet weak var loginSubline: UILabel!
    @IBOutlet weak var usernameEmail: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var storeID: UITextField!
    @IBOutlet weak var loginButtonFinal: UIButton!
    
    @IBAction func loginClicked(_ sender: Any) {
        if(selectedSource == "Amazon Associates") {
            databaseMgr?.addAmazonAccount(email: usernameEmail.text!, password: passwordInput.text!, storeIds: storeID.text!)
            
        } else if(selectedSource == "Ezoic") {
            databaseMgr?.addEzoicAccount(email: usernameEmail.text!, password: passwordInput.text!)
        } else if(selectedSource == "eBay Partner Network") {
            databaseMgr?.addEbayAccount(email: usernameEmail.text!, password: passwordInput.text!)
        }
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameEmail.delegate = self
        passwordInput.delegate = self
        storeID.delegate = self
        loginButtonFinal.layer.cornerRadius = 5
        
        usernameEmail.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: usernameEmail.frame.height))
        usernameEmail.leftViewMode = .always

        if(selectedSource == "Amazon Associates") {
            loginTitle.text = "Login to Amazon Associates"
            loginSubline.text = "Login using your normal Amazon Associates credentials."
            usernameEmail.attributedPlaceholder = NSAttributedString(string: "Your Amazon Email", attributes: [NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "C0C0C0")])
            passwordInput.placeholder = "Your Amazon Password"
            storeID.isHidden = true
        } else if(selectedSource == "Google AdSense") {
            loginTitle.text = "Login to Google AdSense"
        } else if(selectedSource == "eBay Partner Network") {
            loginTitle.text = "Login to eBay Partner Network"
        } else if(selectedSource == "Ezoic") {
            loginTitle.text = "Login to Ezoic"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        textField.resignFirstResponder()
        return true
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
