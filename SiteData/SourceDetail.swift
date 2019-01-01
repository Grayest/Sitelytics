//
//  SourceDetail.swift
//  SiteData
//
//  Created by Mark Lyons on 10/27/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import UIKit
import ScrollableGraphView

extension String {
    func trunc(length: Int, trailing: String = "…") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
}

class SourceDetail: UIViewController, ScrollableGraphViewDataSource, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var sourceTitle: UILabel!
    @IBOutlet weak var sourceEmail: UILabel!
    @IBOutlet weak var sourceTag: UILabel!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var monthTitle: UILabel!
    @IBOutlet weak var dataBox1: UIView!
    @IBOutlet weak var dataBox2: UIView!
    @IBOutlet weak var dataBox3: UIView!
    @IBOutlet weak var dataStat1UI: UILabel!
    @IBOutlet weak var dataStat2UI: UILabel!
    @IBOutlet weak var dataStat3UI: UILabel!
    @IBOutlet weak var dataStatLabel1UI: UILabel!
    @IBOutlet weak var dataStatLabel2UI: UILabel!
    @IBOutlet weak var dataStatLabel3UI: UILabel!
    @IBOutlet weak var thirdDataLabel: UILabel!
    @IBOutlet weak var ordersTable: UITableView!
    @IBOutlet weak var ordersTableHeight: NSLayoutConstraint!
    @IBOutlet weak var ordersDate: UILabel!
    
    var reportingSource : Source?
    var linePlotData : [Double]?
    var databaseMgr : DataActions?
    var dataStats : [String: String]?
    var ordersToday : [(String, String, Int64, String, Double)]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ordersTable.dataSource = self
        ordersTable.delegate = self
        ordersTable.rowHeight = 88
        ordersTable.separatorStyle = .none
        ordersTable.isScrollEnabled = false
        
        //Get today's date
        let timestampString = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        ordersDate.text = timestampString
        
        if let thisSource = reportingSource as? AmazonAssociatesAccount {
            sourceTitle.text = "Amazon Associates"
            sourceEmail.text = thisSource.email
            sourceTag.text = thisSource.storeIds
            
            linePlotData = databaseMgr!.getAmazonMonthlyEarningsByDay()
            dataStats = databaseMgr!.getAmazonBoxStats()
            ordersToday = databaseMgr!.getAllAmazonOrdersToday()
            
            if(dataStats?.count != 0) {
                let dataKeys = Array(dataStats!.keys)
                dataStatLabel1UI.text = dataKeys[0]
                dataStatLabel2UI.text = dataKeys[1]
                dataStatLabel3UI.text = dataKeys[2]
                dataStat1UI.text = dataStats![dataKeys[0]]
                dataStat2UI.text = dataStats![dataKeys[1]]
                dataStat3UI.text = dataStats![dataKeys[2]]
                
                //Also dynamically set height of table because we're already in a scrollview
                let newHeight = 88 * (ordersToday?.count ?? 0)
                self.ordersTableHeight.constant = CGFloat(newHeight)
            }
        } else if let thisSource = reportingSource as? EzoicAccount {
            sourceTitle.text = "Ezoic"
            sourceEmail.text = thisSource.email
            sourceTag.isHidden = true
            ordersDate.isHidden = true
            
            thirdDataLabel.isHidden = true
            linePlotData = databaseMgr!.getAllEzoicMonthly()
            
            let sum : Double = linePlotData!.reduce(0, +)
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 0
            let boxStr = formatter.string(from: NSNumber(value: sum))
            
            dataBox1.isHidden = true
            dataBox3.isHidden = true
            dataStatLabel2UI.text = "EARNINGS THIS MONTH"
            dataStat2UI.text = boxStr
        }
        
        monthTitle.text = getMonthTitle()
        dataBox1.layer.cornerRadius = 5
        dataBox2.layer.cornerRadius = 5
        dataBox3.layer.cornerRadius = 5
        
        let graphRect = CGRect(x: -7.0, y: 0.0, width: self.view.frame.width + 7, height: graphView.frame.height)
        let graph = ScrollableGraphView(frame: graphRect, dataSource: self)
        
        let linePlot = LinePlot(identifier: "line")
        linePlot.lineWidth = 1
        linePlot.lineColor = hexStringToUIColor(hex: "#0365D5")
        linePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        linePlot.shouldFill = true
        linePlot.fillType = ScrollableGraphViewFillType.gradient
        linePlot.fillGradientStartColor = hexStringToUIColor(hex: "#0365D5").withAlphaComponent(0.7)
        linePlot.fillGradientEndColor = hexStringToUIColor(hex: "#0365D5").withAlphaComponent(0.0)
        
        let dotPlot = DotPlot(identifier: "dot")
        dotPlot.dataPointType = ScrollableGraphViewDataPointType.circle
        dotPlot.dataPointSize = 2
        dotPlot.dataPointFillColor = hexStringToUIColor(hex: "#0365D5")
        
        let referenceLines = ReferenceLines()
        referenceLines.referenceLineLabelFont = UIFont.systemFont(ofSize: 8.0)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.1)
        referenceLines.referenceLineLabelColor = UIColor.white
        
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(1)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        referenceLines.referenceLineNumberStyle = .currency
        
        graph.addPlot(plot: linePlot)
        graph.addPlot(plot: dotPlot)
        graph.addReferenceLines(referenceLines: referenceLines)
        graph.shouldAdaptRange = true
        graph.backgroundFillColor = hexStringToUIColor(hex: "#2E2E2E")
        graph.dataPointSpacing = 58
        
        graphView.addSubview(graph)
    }
    
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        switch(plot.identifier) {
        case "line":
            return Double(linePlotData![pointIndex])
        case "dot":
            return Double(linePlotData![pointIndex])
        default:
            return 0
        }
    }
    
    func label(atIndex pointIndex: Int) -> String {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month], from: date)
        let monthNum = components.month
        let retVal = "\(monthNum!)/\(pointIndex+1)"
        return retVal
    }
    
    func numberOfPoints() -> Int {
        if(linePlotData != nil) {
            return linePlotData!.count
        }
        
        return 0
    }
    
    func getMonthTitle() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let strMonth = dateFormatter.string(from: date)
        return strMonth
    }
    
    /* Table view required methods: */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ordersToday?.count ?? 0 // coalesces to return 0 if no items ordered
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ordersTable.dequeueReusableCell(withIdentifier: "itemOrdered") as! ItemOrderedCell
        cell.selectionStyle = .none
        
        let currentItem = ordersToday![indexPath.row]
        let currentTitle = currentItem.0
        let currentQuantity = currentItem.2
        let currentCategory = currentItem.3
        let currentPrice = currentItem.4
        let estCommissionDec = productCommission(category: currentCategory)
        let estCommissionInt = Double(estCommissionDec * 100)
        let estActualCommission = currentPrice * estCommissionDec
        let formattedPrice = String(format: "$%.02f", currentPrice)
    
        cell.itemTitle.text = currentTitle
        cell.numberOrdered.text = "\(currentQuantity)"
        cell.itemCategory.text = currentCategory
        cell.itemRate.text = "\(estCommissionInt)% of \(formattedPrice)"
        cell.itemCommission.text = String(format: "$%.02f", estActualCommission)
        cell.numberContainer.layer.cornerRadius = 15
        
        //Variable corner rounding
        cell.topHeadingContainer.clipsToBounds = true
        cell.bodyContent.clipsToBounds = true
        cell.topHeadingContainer.layer.cornerRadius = 5
        cell.bodyContent.layer.cornerRadius = 5
        cell.topHeadingContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] //top left, right
        cell.bodyContent.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner] //bottom left, right
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemSelected = ordersToday![indexPath.row]
        let amazonURL = "https://www.amazon.com/gp/product/\(itemSelected.1)"
        
        guard let url = URL(string: amazonURL) else { return }
        UIApplication.shared.open(url)
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
    
    //Should really use global functions for stuff like this.
    //Will probably be making this more dynamic later from user input. Or just ask people to submit on r/juststart
    func productCommission(category : String) -> Double {
        if (["Amazon Fashion Women", "Men & Kids Private Label", "Luxury Beauty", "Amazon Coins"].contains(category)) { return 0.1 }
        if (["Furniture", "Home", "Home Improvement", "Lawn & Garden", "Pets Products", "Pantry"].contains(category)) { return 0.08 }
        if (["Apparel", "Amazon Cloud Cam Devices", "Amazon Element Smart TV (with Fire TV)", "Amazon Fire TV Devices", "Jewelry", "Luggage", "Shoes", "Handbags"].contains(category)) { return 0.07 }
        if (["Headphones", "Beauty", "Musical Instruments", "Business & Industrial Supplies"].contains(category)) { return 0.06 }
        if (["Outdoors", "Tools", "Industrial & Scientific"].contains(category)) { return 0.055 }
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
}
