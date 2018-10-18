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
    @IBOutlet weak var addNewButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    private var embedController : EmbedController?
    private let refreshControl = UIRefreshControl()
    var db: OpaquePointer?
    
    var amazonProgressCircle : UICircularProgressRing?
    var amazonRevenueToday : UILabel?
    var amazonRevenueTodayLabel : UILabel?
    var amazonUpdating : UILabel?
    
    var amazonAccounts = [AmazonAssociatesAccount]()
    var allSources : [Source] = []
    
    let createAmazonAssociatesAccountTable = "CREATE TABLE IF NOT EXISTS amazon_associates_accounts (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT, password TEXT, storeIds TEXT)"
    let createAmazonAssociatesOrdersTable = "CREATE TABLE IF NOT EXISTS amazon_associates_orders (id INTEGER PRIMARY KEY AUTOINCREMENT, price INTEGER, quantity INTEGER, product_name TEXT, product_category TEXT, store_id TEXT)"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initDatabase()
        
        //var stmt : OpaquePointer?
        //sqlite3_prepare(db, "DROP table amazon_associates_accounts", -1, &stmt, nil)
        //sqlite3_step(stmt)
        
        createTable(createTableQuery: createAmazonAssociatesAccountTable)
        createTable(createTableQuery: createAmazonAssociatesOrdersTable)
        getAllAmazonAccounts()
        combineAllAccounts()
        tableView.dataSource = self
        tableView.rowHeight = 105
        tableView.allowsSelection = false
        addNewButton.layer.cornerRadius = 5
        
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
    
    @IBAction func addNewClicked(_ sender: Any) {
        addAmazonAccount(email: "lyons340@gmail.com", password: "MArk44$$", storeIds: "zcarguide0c-20")
    }
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
    
    func addAmazonAccount(email : String, password: String, storeIds: String) {
        var stmt: OpaquePointer?
        let addToAmazonAssociatesAccounts = "INSERT INTO amazon_associates_accounts (email, password, storeIds) VALUES (?, ?, ?)"
        if(sqlite3_prepare(db, addToAmazonAssociatesAccounts, -1, &stmt, nil) != SQLITE_OK) {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        } else {
            print("successfully prepared for insertion")
        }
        
        //binding the parameters
        if sqlite3_bind_text(stmt, 1, email, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 2, password, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 3, storeIds, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting record: \(errmsg)")
            return
        } else {
            print("Successfully inserted record.")
        }
    }
    
    func combineAllAccounts() {
        for amazonAccount in amazonAccounts {
            allSources.append(amazonAccount)
        }
    }
    
    func getAllAmazonAccounts() {
        let getAllQuery = "SELECT * from amazon_associates_accounts"
        var stmt : OpaquePointer?
        
        if(sqlite3_prepare(db, getAllQuery, -1, &stmt, nil) != SQLITE_OK) {
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing select query: \(errMsg)")
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            let id = sqlite3_column_int(stmt, 0)
            let email = String(cString: sqlite3_column_text(stmt, 1))
            let password = String(cString: sqlite3_column_text(stmt, 2))
            let storeIds = String(cString: sqlite3_column_text(stmt, 3))
            print(id)
            print(email)
            print(password)
            print(storeIds)
            let currAmznAccount = AmazonAssociatesAccount(id: Int(id), amazonEmail: email, password: password, storeIds: [storeIds])
            amazonAccounts.append(currAmznAccount)
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
        return allSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sourceCell") as! SourceCell
        let source = allSources[indexPath.row] as Source
        cell.sourceName.text = source.name
        cell.lastUpdated.text = source.lastUpdated
        cell.sourceEmail.text = source.email
        
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

