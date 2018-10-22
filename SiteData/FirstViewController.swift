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
    
    var amazonProgressCircle : UICircularProgressRing?
    var amazonRevenueToday : UILabel?
    var amazonRevenueTodayLabel : UILabel?
    var amazonUpdating : UILabel?
    
    var amazonAccounts = [AmazonAssociatesAccount]()
    var allSources : [Source] = []
    var databaseMgr : DataActions = DataActions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseMgr.firebombDatabase()
        databaseMgr.initDatabase()
        databaseMgr.createAmazonAccountsTable()
        databaseMgr.createAmazonOrdersTable()
        databaseMgr.addAmazonAccount(email: "lyons340@gmail.com", password: "MArk44$$", storeIds: "zcarguide-0c20")
        amazonAccounts = databaseMgr.getAllAmazonAccounts()
        
        //Need to coalesce all accounts before
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
    
    @objc private func refreshAllSources() {
        for currCell in tableView.visibleCells {
            let currSrcCell = currCell as! SourceCell
            refreshSource(sourceCell: currSrcCell)
        }
    }
    
    func combineAllAccounts() {
        for amazonAccount in amazonAccounts {
            allSources.append(amazonAccount)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func getData(sourceCell : SourceCell) {
        let amznParser : AmazonAssociatesParser = embedView(containVC: AmazonAssociatesParser()) as! AmazonAssociatesParser
        amznParser.updateData(cellCalledBy: sourceCell)
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
        let lastUpdatedFormatted = source.getLastUpdatedStr(numericDates: true)
        
        cell.sourceName.text = source.name
        cell.lastUpdated.text = "Last updated \(lastUpdatedFormatted)"
        cell.sourceData.text = String(format: "$%.02f", source.dataPoint!)
        cell.sourceEmail.text = source.email
        cell.innerView.layer.cornerRadius = 5
        
        return cell
    }
    
    func refreshSource(sourceCell : SourceCell) {
        sourceCell.progressCircle.isHidden = false
        sourceCell.lastUpdated.text = "Updating source..."
        sourceCell.sourceData.isHidden = true
        sourceCell.sourceDataLabel.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.refreshControl.endRefreshing()
            self.getData(sourceCell: sourceCell)
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

