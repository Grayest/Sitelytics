//
//  EzoicParser.swift
//  SiteData
//
//  Created by Mark Lyons on 10/13/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import UIKit
import WebKit

class EzoicParser: UIViewController, WKNavigationDelegate {
    var webView : WKWebView!
    
    var loginPageUrl : String = "https://svc.ezoic.com/publisher.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadLoginPage() {
        let url = URL(string: loginPageUrl)!
        webView.load(URLRequest(url : url))
    }

}
