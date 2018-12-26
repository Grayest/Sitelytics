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
        usernameEmail.layer.cornerRadius = 4
        passwordInput.layer.cornerRadius = 4
        storeID.layer.cornerRadius = 4
        
        let usernameEmailImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        usernameEmailImg.image = UIImage(named: "email.png")
        let usernameEmailContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: usernameEmail.frame.height))
        usernameEmailContainer.addSubview(usernameEmailImg)
        usernameEmailImg.center = usernameEmailContainer.convert(usernameEmailContainer.center, from: usernameEmailContainer.superview)
        
        let passwordImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        passwordImg.image = UIImage(named: "password.png")
        let passwordContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: passwordInput.frame.height))
        passwordContainer.addSubview(passwordImg)
        passwordImg.center = passwordContainer.convert(passwordContainer.center, from: passwordContainer.superview)
        
        usernameEmail.leftView = usernameEmailContainer
        passwordInput.leftView = passwordContainer
        usernameEmail.leftViewMode = .always
        passwordInput.leftViewMode = .always

        if(selectedSource == "Amazon Associates") {
            loginTitle.text = "Login to Amazon Associates"
            loginSubline.text = "Login using your normal Amazon Associates credentials."
            usernameEmail.attributedPlaceholder = NSAttributedString(string: "Your Amazon Email", attributes: [NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "989898")])
            passwordInput.attributedPlaceholder = NSAttributedString(string: "Your Amazon Password", attributes: [NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "989898")])
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
