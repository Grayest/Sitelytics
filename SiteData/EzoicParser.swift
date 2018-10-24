//
//  EzoicParser.swift
//  SiteData
//
//  Created by Mark Lyons on 10/13/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import UIKit
import WebKit

class EzoicParser: UIViewController, WKNavigationDelegate, Parser{
    private var email : String?
    private var password : String?
    private var pageCount : Int = 0
    var webView : WKWebView!
    var ezoicAccount : EzoicAccount?
    var correspondingCell : SourceCell?
    var dashboardVC : FirstViewController?
    var insertEmailJS : String?
    var insertPwdJS : String?
    var clickLoginJS : String?
    
    var loginPageUrl : String = "https://svc.ezoic.com/publisher.php"
    
    func updateData(cellCalledBy : SourceCell) {
        correspondingCell = cellCalledBy
        ezoicAccount = cellCalledBy.correspondingSource as! EzoicAccount
        email = cellCalledBy.correspondingSource?.email
        password = cellCalledBy.correspondingSource?.password
        loadView()
    }
    
    func deleteCache() {
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        let cookieStorage = HTTPCookieStorage.shared
        guard let cookies = cookieStorage.cookies else { return }
        
        for cookie in cookies {
            cookieStorage.deleteCookie(cookie)
        }
    }
    
    override func loadView() {
        dashboardVC = self.parent as? FirstViewController
        deleteCache()
        webView = WKWebView()
        webView.isHidden = true
        webView.navigationDelegate = self
        view = webView
        loadLoginPage()
    }
    
    func loadLoginPage() {
        let url = URL(string: loginPageUrl)!
        webView.load(URLRequest(url : url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData))
    }
    
    func loginToAccount() {
        insertEmailJS = "document.getElementById('loginEmail').value = '\(email!)';"
        insertPwdJS = "document.getElementById('loginPassword').value = '\(password!)';"
        clickLoginJS = "document.getElementById('login').click();"
        
        //Change to nil or something that makes sure it grabbed from local storage
        if(email != "" && password != "") {
            webView.evaluateJavaScript(insertEmailJS!)
            webView.evaluateJavaScript(insertPwdJS!)
            webView.evaluateJavaScript(clickLoginJS!)
        } else {
            print("Email and password not set or cannot be retrieved.")
        }
    }
    
    func parseHTMLtoday() {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if(pageCount == 0) {
            self.correspondingCell?.progressCircle.startProgress(to: 32, duration: 1)
            loginToAccount()
        } else if(pageCount == 1) {
            self.correspondingCell?.progressCircle.startProgress(to: 78, duration: 1)
            parseHTMLtoday()
        }
        
        pageCount = pageCount + 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
