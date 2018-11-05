//
//  EbayParser.swift
//  SiteData
//
//  Created by Mark Lyons on 11/3/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import Foundation
import WebKit
import UIKit

class EbayParser: UIViewController, WKNavigationDelegate, Parser {
    private var email : String?
    private var password : String?
    private var pageCount : Int = 0
    var webView : WKWebView!
    var correspondingCell : SourceCell?
    var dashboardVC : FirstViewController?
    var ebayAccount : EbayAccount?
    
    var loginPageUrl : String = "https://signin.ebay.com/ws/eBayISAPI.dll?SignIn&UsingSSL=1&siteid=0&co_partnerId=2&pageType=2066541&ru=http%3A%2F%2Fepn.ebay.com%2F"
    var clickLoginJS : String?
    var insertCredentialsJS : String?
    var updateContactInfoJS : String?
    
    func updateData(cellCalledBy : SourceCell) {
        correspondingCell = cellCalledBy
        ebayAccount = cellCalledBy.correspondingSource as? EbayAccount
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
    
    func clickLogin() {
        clickLoginJS = "document.getElementById('PROCEED-TO-DEFAULT-BTN').click();"
        insertCredentialsJS = "document.getElementById('userid').value = '\(email!)'; document.getElementById('pass').value = '\(password!)'; document.getElementById('sgnBt').click();"
        
        webView.evaluateJavaScript(clickLoginJS!, completionHandler: {(result, error) in
            self.correspondingCell?.progressCircle.startProgress(to: 31, duration: 1)
            self.webView.evaluateJavaScript(self.insertCredentialsJS!, completionHandler: nil)
        })
    }
    
    func processAccountData() {
        print("i am here")
    }
    
    func updateContactInfo() {
        let isContact = "window.location.toString();"
        let pressMaybeLater = "document.getElementById('rmdLtr').click();"
        
        webView.evaluateJavaScript(isContact, completionHandler: {(result, error) in
            let strRes = result as! String
            if(strRes.contains("UpdateContactInfo")) {
                self.webView.evaluateJavaScript(pressMaybeLater, completionHandler: {(resultInner, errorInner) in
                    self.processAccountData()
                }
            )} else {
                self.processAccountData()
            }
        })
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if(pageCount == 0) {
            self.correspondingCell?.progressCircle.startProgress(to: 20, duration: 1)
            clickLogin()
        } else if(pageCount == 1) {
            self.correspondingCell?.progressCircle.startProgress(to: 46, duration: 1)
            updateContactInfo()
        } else if(pageCount == 2) {
            //captcha...
        }
        
        pageCount = pageCount + 1
    }
    
}
