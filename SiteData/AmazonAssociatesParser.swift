//
//  AmazonAssociatesParser.swift
//  SiteData
//
//  Created by Mark Lyons on 10/13/18.
//  Copyright © 2018 Knoll Labs. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SQLite3

class AmazonAssociatesParser : UIViewController, WKNavigationDelegate, Parser {
    private var email : String = "lyons340@gmail.com"
    private var password : String = "MArk44$$44"
    private var pageCount : Int = 0
    var webView : WKWebView!
    var loginPageUrl : String = "https://www.amazon.com/ap/signin?openid.return_to=https%3A%2F%2Faffiliate-program.amazon.com%2F&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.assoc_handle=amzn_associates_us&openid.mode=checkid_setup&marketPlaceId=ATVPDKIKX0DER&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.pape.max_auth_age=0"
    var todayReqUrl : String = "https://affiliate-program.amazon.com/home/reports/table.json?query[type]=realtime&query[start_date]=2018-10-14&query[end_date]=2018-10-14&query[order]=desc&query[tag_id]=all&query[columns]=product_title,asin,product_category,merchant_name,ordered_items,tracking_id,price&query[skip]=0&query[sort]=day&query[limit]=25&store_id=zcarguide0c-20"
    var extractAllJSON : String = "document.body.innerText;"
    var insertEmailJS : String?
    var insertPwdJS : String?
    var clickLoginJS : String?
    var returnedJSON : String?
    var dashboardVC : FirstViewController?
    
    func initAmazonData(email : String, pass : String, storeId : String, cellIndex : Int) {
        
    }
    
    override func loadView() {
        dashboardVC = self.parent as! FirstViewController
        deleteCache()
        webView = WKWebView()
        webView.isHidden = true
        webView.navigationDelegate = self
        view = webView
        loadLoginPage()
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
    
    func loadLoginPage() {
        let url = URL(string: loginPageUrl)!
        webView.load(URLRequest(url : url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData))
    }
    
    //Maybe switch this to a request type thing later
    func loginToAccount() {
        insertEmailJS = "document.getElementById('ap_email').value = '\(email)';"
        insertPwdJS = "document.getElementById('ap_password').value = '\(password)';"
        clickLoginJS = "document.getElementById('auth-signin-button').click(); document.getElementById('signInSubmit').click();"
        
        //Change to nil or something that makes sure it grabbed from local storage
        if(email != "" && password != "") {
            webView.evaluateJavaScript(insertEmailJS!) {(result, error) in
                self.dashboardVC?.amazonProgressCircle?.startProgress(to: 40, duration: 1)
            }
            webView.evaluateJavaScript(insertPwdJS!)  {(result, error) in
                self.dashboardVC?.amazonProgressCircle?.startProgress(to: 46, duration: 1)
            }
            webView.evaluateJavaScript(clickLoginJS!) {(result, error) in
                self.dashboardVC?.amazonProgressCircle?.startProgress(to: 52, duration: 1)
            }
        } else {
            print("Email and password not set or cannot be retrieved.")
        }
    }
    
    func getTodaysOrders() {
        let escapedUrl = todayReqUrl.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
        let todayUrl = URL(string: escapedUrl!)!
        webView.load(URLRequest(url: todayUrl, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData))
    }
    
    func parseJSONResponse() {
        webView.evaluateJavaScript(extractAllJSON, completionHandler: {(result, error)  in
            self.returnedJSON = result as? String
            let data = self.returnedJSON!.data(using: .utf8)!
            do {
                let jsonObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any>
                let records = jsonObj!["records"] as! [Dictionary<String, String>]
                var amtOrderedItems : Double = 0
                var totalOrderedRevenue : Double = 0
                
                for record in records {
                    let currentAmount = Double(record["ordered_items"]!)!
                    let currentPrice = Double(record["price"]!)!
                    let currentRevenue = currentAmount * currentPrice
                    
                    amtOrderedItems = amtOrderedItems + currentAmount
                    totalOrderedRevenue = totalOrderedRevenue + currentRevenue
                }
                
                self.dashboardVC?.amazonProgressCircle?.startProgress(to: 100, duration: 0.5, completion: {
                    let updateVal : [String : Any] = [
                        "TOTAL_ORDERED_REVENUE" : totalOrderedRevenue,
                        "AMT_ITEMS_ORDERED" : amtOrderedItems,
                        "ORDERS_DETAIL" : records
                    ]
                    
                    self.dashboardVC!.amazonData = updateVal
                    self.dashboardVC!.amazonRevenueToday?.text = String(format: "$%.02f", totalOrderedRevenue)
                    self.dashboardVC!.amazonUpdating?.text = "Last updated 0 mins ago"
                })
                
            } catch let error as NSError {
                print("ERROR FOUND: \(error)")
            }
            
        })
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if(pageCount == 0) {
            loginToAccount()
            dashboardVC?.amazonProgressCircle?.startProgress(to: 33, duration: 1)
        } else if(pageCount == 1) {
            getTodaysOrders()
            dashboardVC?.amazonProgressCircle?.startProgress(to: 66, duration: 1)
        } else if(pageCount == 2) {
            parseJSONResponse()
            dashboardVC?.amazonProgressCircle?.startProgress(to: 90, duration: 1)
        }
        
        pageCount = pageCount + 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
