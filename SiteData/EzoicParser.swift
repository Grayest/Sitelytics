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
    var editDatesJS : String?
    var earningAmtsFlt : [Double]?
    
    var loginPageUrl : String = "https://svc.ezoic.com/publisher.php"
    var earningsPageUrl : String = "https://svc.ezoic.com/svc/pub/earnings/earnings.php"
    var dashboardPageUrl : String = "https://svc.ezoic.com/svc/pub/stats/dashboard.php"
    var extractTodaysEarnings : String = "var earns = document.querySelector('ul.earnings'); var all_li = earns.querySelectorAll('li'); var lastOne = all_li[all_li.length-1]; var amountOuter = lastOne.querySelector('.currency'); amountOuter.querySelector('.dollar-sign').remove(); amountOuter.textContent;"
    
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
    
    func loadEarningsPage() {
        let url = URL(string: earningsPageUrl)!
        webView.load(URLRequest(url : url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData))
    }
    
    func loadDashboard() {
        let url = URL(string: dashboardPageUrl)!
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
    
    func startMonthlyDataGrab() {
        let dateToday = Date()
        
        let todayFormatter = DateFormatter()
        let eomFormatter = DateFormatter()
        todayFormatter.dateFormat = "yyyy-MM-dd"
        eomFormatter.dateFormat = "yyyy-MM-01"
        
        let firstOfTheMonth = eomFormatter.string(from: dateToday)
        let yesterdayDate = todayFormatter.string(from: dateToday)
        
        self.editDatesJS = "document.getElementById('start_date').value = '\(firstOfTheMonth)'; document.getElementById('end_date').value = '\(yesterdayDate)'; document.querySelector('.btn.btn-primary.apply').click();"
        print(self.editDatesJS!)
        
        self.webView.evaluateJavaScript(self.editDatesJS!, completionHandler: { (result, error) in
            //Have to wait for response.
            //This is probably not a great idea, but is a 99% solution.
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                let getAllRows = "var tbod = document.querySelector('table#earningsTable tbody'); var allElms = tbod.querySelectorAll('tr'); var retStr = ''; for (var i = 0; i < allElms.length; i++) { if(i != 0) {retStr = retStr + parseFloat(allElms[i].querySelector('.text-center').textContent.replace('$', '')) + ',';}}document.querySelector('.paginate_button.next').click();var tbod = document.querySelector('table#earningsTable tbody');var allElms = tbod.querySelectorAll('tr');for (var i = 0; i < allElms.length; i++) {retStr = retStr + parseFloat(allElms[i].querySelector('.text-center').textContent.replace('$', '')) + ',';} retStr.substring(0, retStr.length - 1);"
                self.webView.evaluateJavaScript(getAllRows, completionHandler: { (result, error) in
                    let strRes = result as! String
                    print(strRes)
                    let allEarningAmts = strRes.split(separator: ",")
                    if(allEarningAmts.count > 0) {
                        self.dashboardVC?.databaseMgr!.deleteEzoicMonthlStats()
                        self.correspondingCell?.progressCircle.startProgress(to: 89, duration: 1, completion: {() in
                            for earningAmt in allEarningAmts {
                                self.dashboardVC?.databaseMgr!.addEzoicMonthlyData(amt: Double(earningAmt)!)
                            }
                            
                            self.parseHTMLtoday()
                        })
                    }
                })
            })
        })
    }
    
    func parseHTMLtoday() {
        print(extractTodaysEarnings)
        webView.evaluateJavaScript(extractTodaysEarnings, completionHandler: {(result, error)  in
            let strResult = result as! String
            let trimmedResult = strResult.trimmingCharacters(in: .whitespacesAndNewlines)
            let currRev = Double(trimmedResult)
            
            let extractedId = Int((self.correspondingCell?.id)!)
            self.dashboardVC?.databaseMgr!.updateEzoicEarningsToday(currId: extractedId, newEarnings: currRev!)
            
            self.correspondingCell?.progressCircle.startProgress(to: 100, duration: 1, completion: {() in
                self.correspondingCell?.progressCircle.isHidden = true
                self.correspondingCell?.progressCircle.value = 0
                self.correspondingCell?.lastUpdated.text = "Last updated just now"
                self.correspondingCell?.sourceData.text = String(format: "$%.02f", currRev!)
                self.correspondingCell?.sourceData.isHidden = false
                self.correspondingCell?.sourceDataLabel.isHidden = false
            })
            
        })
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if(pageCount == 0) {
            self.correspondingCell?.progressCircle.startProgress(to: 32, duration: 1)
            loginToAccount()
        } else if(pageCount == 1) {
            self.correspondingCell?.progressCircle.startProgress(to: 63, duration: 1)
            loadEarningsPage()
        } else if(pageCount == 2) {
            startMonthlyDataGrab()
        }
        
        pageCount = pageCount + 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
