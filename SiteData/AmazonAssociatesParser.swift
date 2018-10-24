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
    private var email : String?
    private var password : String?
    private var pageCount : Int = 0
    var webView : WKWebView!
    var loginPageUrl : String = "https://www.amazon.com/ap/signin?openid.return_to=https%3A%2F%2Faffiliate-program.amazon.com%2F&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.assoc_handle=amzn_associates_us&openid.mode=checkid_setup&marketPlaceId=ATVPDKIKX0DER&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.pape.max_auth_age=0"
    var todayReqUrl : String?
    var extractAllJSON : String = "document.body.innerText;"
    var insertEmailJS : String?
    var insertPwdJS : String?
    var clickLoginJS : String?
    var returnedJSON : String?
    var dashboardVC : FirstViewController?
    var correspondingCell : SourceCell?
    var amazonAccount : AmazonAssociatesAccount?
    
    func updateData(cellCalledBy : SourceCell) {
        amazonAccount = cellCalledBy.correspondingSource as! AmazonAssociatesAccount
        print("AMZN STORE ID: \((amazonAccount?.storeIds)!)")
        correspondingCell = cellCalledBy
        email = cellCalledBy.correspondingSource?.email
        password = cellCalledBy.correspondingSource?.password
        
        print("using password \(password!)")
        todayReqUrl = generateTodayReqURL(storeID: (amazonAccount?.storeIds)!)
        loadView()
    }
    
    override func loadView() {
        dashboardVC = self.parent as? FirstViewController
        deleteCache()
        webView = WKWebView()
        webView.isHidden = false
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
        insertEmailJS = "document.getElementById('ap_email').value = '\(email!)';"
        insertPwdJS = "document.getElementById('ap_password').value = '\(password!)';"
        clickLoginJS = "document.getElementById('auth-signin-button').click(); document.getElementById('signInSubmit').click();"
        
        //Change to nil or something that makes sure it grabbed from local storage
        if(email != "" && password != "") {
            webView.evaluateJavaScript(insertEmailJS!)
            webView.evaluateJavaScript(insertPwdJS!)
            webView.evaluateJavaScript(clickLoginJS!)
        } else {
            print("Email and password not set or cannot be retrieved.")
        }
    }
    
    func getTodaysOrders() {
        let escapedUrl = todayReqUrl!.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
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
                var estimatedCommission : Double = 0
                
                for record in records {
                    let currentAmount = Double(record["ordered_items"]!)!
                    let currentPrice = Double(record["price"]!)!
                    let currentRevenue = currentAmount * currentPrice
                    let currentCategory = record["product_category"]!
                    let currentCommission = self.productCommission(category: currentCategory)
                    let currentCommissionFees = currentRevenue * currentCommission
                    
                    estimatedCommission = estimatedCommission + currentCommissionFees
                    amtOrderedItems = amtOrderedItems + currentAmount
                    totalOrderedRevenue = totalOrderedRevenue + currentRevenue
                }
                
                self.correspondingCell?.progressCircle.startProgress(to: 100, duration: 0.5, completion: {
                    let updateVal : [String : Any] = [
                        "TOTAL_ORDERED_REVENUE" : totalOrderedRevenue,
                        "ESTIMATED_COMMISSION" : estimatedCommission,
                        "AMT_ITEMS_ORDERED" : amtOrderedItems,
                        "ORDERS_DETAIL" : records,
                    ]
                    
                    let extractedId = Int((self.correspondingCell?.id)!)
                    self.dashboardVC?.databaseMgr.updateAmazonEstEarningsToday(currId: extractedId, newEarnings: estimatedCommission)
                    
                    self.correspondingCell?.progressCircle.startProgress(to: 100, duration: 1)
                    self.correspondingCell?.progressCircle.isHidden = true
                    self.correspondingCell?.progressCircle.value = 0
                    self.correspondingCell?.lastUpdated.text = "Last updated just now"
                    self.correspondingCell?.sourceData.text = String(format: "$%.02f", estimatedCommission)
                    self.correspondingCell?.sourceData.isHidden = false
                    self.correspondingCell?.sourceDataLabel.isHidden = false
                })
                
            } catch let error as NSError {
                print("ERROR FOUND: \(error)")
            }
            
        })
    }
    
    func productCommission(category : String) -> Double {
        if (["Amazon Fashion Women", "Men & Kids Private Label", "Luxury Beauty", "Amazon Coins"].contains(category)) { return 0.1 }
        if (["Furniture", "Home", "Home Improvement", "Lawn & Garden", "Pets Products", "Pantry"].contains(category)) { return 0.08 }
        if (["Apparel", "Amazon Cloud Cam Devices", "Amazon Element Smart TV (with Fire TV)", "Amazon Fire TV Devices", "Jewelry", "Luggage", "Shoes", "Handbags"].contains(category)) { return 0.07 }
        if (["Headphones", "Beauty", "Musical Instruments", "Business & Industrial Supplies"].contains(category)) { return 0.06 }
        if (["Outdoors", "Tools"].contains(category)) { return 0.055 }
        if (["Digital Music", "Grocery", "Physical Music", "Handmade", "Digital Videos"].contains(category)) { return 0.05 }
        if (["Physical Books", "Health & Personal Care", "Sports", "Kitchen", "Automotive", "Baby Products"].contains(category)) { return 0.045 }
        if (["Amazon Fire Tablet Devices", "Dash Buttons", "Amazon Kindle Devices"].contains(category)) { return 0.04 }
        if (["Amazon Fresh", "Toys"].contains(category)) { return 0.03 }
        if (["PC", "PC Components", "DVD & Blu-Ray"].contains(category)) { return 0.025 }
        if (["Televisions", "Digital Video Games"].contains(category)) { return 0.02 }
        if (["Video Games & Video Game Consoles", "Video Games", "Video Game Consoles"].contains(category)) { return 0.01 }
        if (["Amazon Gift Cards", "Wireless Service Plans", "Alcoholic Beverages", "Digital Kindle Products", "Amazon Appstore", "Prime Now", "Amazon Pay Places", "Prime Wardrobe", "Purchases"].contains(category)) { return 0 }
        
        //All else is 4%
        return 0.04
    }
    
    func generateTodayReqURL(storeID : String) -> String {
        return "https://affiliate-program.amazon.com/home/reports/table.json?query[type]=realtime&query[start_date]=2018-10-14&query[end_date]=2018-10-14&query[order]=desc&query[tag_id]=all&query[columns]=product_title,asin,product_category,merchant_name,ordered_items,tracking_id,price&query[skip]=0&query[sort]=day&query[limit]=25&store_id=\(storeID)"
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if(pageCount == 0) {
            self.correspondingCell?.progressCircle.startProgress(to: 32, duration: 1)
            loginToAccount()
        } else if(pageCount == 1) {
            self.correspondingCell?.progressCircle.startProgress(to: 58, duration: 1)
            getTodaysOrders()
        } else if(pageCount == 2) {
            self.correspondingCell?.progressCircle.startProgress(to: 90, duration: 1)
            parseJSONResponse()
        }
        
        pageCount = pageCount + 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
