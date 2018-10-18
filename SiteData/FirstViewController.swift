//
//  FirstViewController.swift
//  SiteData
//
//  Created by Mark Lyons on 10/13/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import UIKit
import UICircularProgressRing
import SQLite3

class FirstViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    private var embedController : EmbedController?
    private let refreshControl = UIRefreshControl()
    var db: OpaquePointer?
    
    var amazonProgressCircle : UICircularProgressRing?
    var amazonRevenueToday : UILabel?
    var amazonRevenueTodayLabel : UILabel?
    var amazonUpdating : UILabel?
    
    let createAmazonAssociatesAccountTable = "CREATE TABLE IF NOT EXISTS amazon_associates_accounts (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT, password TEXT)"
    let createAmazonAssociatesOrdersTable = "CREATE TABLE IF NOT EXISTS amazon_associates_orders (id INTEGER PRIMARY KEY AUTOINCREMENT, price INTEGER, quantity INTEGER, product_name TEXT, product_category TEXT, store_id TEXT])"
    
    var amazonData : [String: Any]? {
        didSet {
            let totalOrderedRevenue = amazonData!["TOTAL_ORDERED_REVENUE"] as! Double
            print("TOTAL ORDERED REVENUE: \(totalOrderedRevenue)")
            amazonProgressCircle?.isHidden = true
            amazonProgressCircle?.value = 0
            amazonRevenueToday?.isHidden = false
            amazonRevenueTodayLabel?.isHidden = false
        }
    }
    
    @objc private func refreshAllSources() {
        for currCell in tableView.visibleCells {
            let amznCell = currCell as! SourceCell
            refreshSource(sourceCell: amznCell)
        }
    }
    
    func addAccountRecord(table: String, email : String, password: String) {
        var stmt: OpaquePointer?
        let addToAmazonAssociatesAccounts = "INSERT INTO \(table) (email, password) VALUES (\(email), \(password)"
        if(sqlite3_prepare(db, addToAmazonAssociatesAccounts, -1, &stmt, nil) != SQLITE_OK) {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        } else {
            print("successfully inserted")
        }
    }
    
    func createTable(createTableQuery : String) {
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    
    func initDatabase() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("SourceData.sqlite")
        
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initDatabase()
        createTable(createTableQuery: createAmazonAssociatesAccountTable)
        createTable(createTableQuery: createAmazonAssociatesOrdersTable)
        addAccountRecord(table: "amazon_associates_accounts", email: "lyons340@gmail.com", password: "MArk44$$")
        
        tableView.dataSource = self
        tableView.rowHeight = 105
        tableView.allowsSelection = false
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshAllSources), for: .valueChanged)
        
        var attributes = [NSAttributedStringKey: AnyObject]()
        attributes[.foregroundColor] = hexStringToUIColor(hex: "D8D8D8")
        
        refreshControl.tintColor = hexStringToUIColor(hex: "D8D8D8")
        refreshControl.attributedTitle = NSAttributedString(string: "Establishing connections...", attributes: attributes)
        
        
        embedController = EmbedController(rootViewController: self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func getAmazonData() {
        embedView(containVC: AmazonAssociatesParser()).loadView()
    }
    
    func createBackgroundView() -> UIView{
        let bgView = UIView()
        bgView.frame = CGRect(x: 0, y: 0, width: 318, height: 535)
        self.view.addSubview(bgView)
        return bgView
    }
    
    func embedView(containVC : UIViewController) -> Parser {
        containVC.view = createBackgroundView()
        embedController?.append(viewController: containVC)
        return containVC as! Parser
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sourceCell") as! SourceCell
        cell.sourceName.text = "Amazon Associates"
        cell.innerView.layer.cornerRadius = 5
        amazonProgressCircle = cell.progressCircle
        amazonRevenueToday = cell.sourceData
        amazonRevenueTodayLabel = cell.sourceDataLabel
        amazonUpdating = cell.lastUpdated
        return cell
    }
    
    
    
    func refreshSource(sourceCell : SourceCell) {
        // Put your code which should be executed with a delay here
        sourceCell.progressCircle.isHidden = false
        sourceCell.lastUpdated.text = "Updating source..."
        sourceCell.sourceData.isHidden = true
        sourceCell.sourceDataLabel.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.refreshControl.endRefreshing()
            self.getAmazonData()
        })
        
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

