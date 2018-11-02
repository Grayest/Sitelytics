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

class SourceDetail: UIViewController, ScrollableGraphViewDataSource {
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
    @IBOutlet weak var thirdDataText: UILabel!
    
    var reportingSource : Source?
    var linePlotData : [Double]?
    var databaseMgr : DataActions?
    var dataStats : [String: String]?
    var ordersToday : [(String, String, Int64)]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let thisSource = reportingSource as? AmazonAssociatesAccount {
            sourceTitle.text = "Amazon Associates"
            //sourceEmail.text = thisSource.email
            sourceEmail.text = "test@test.com"
            //sourceTag.text = thisSource.storeIds
            sourceTag.text = "test-tag"
            
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
            }
            
            thirdDataLabel.text = "Orders Today"
            //this is sloppy
            var retStr : String = ""
            if ordersToday!.count > 0 {
                for orderToday in ordersToday! {
                    let currNumLines = thirdDataText.numberOfLines
                    thirdDataText.numberOfLines = currNumLines + 1
                    let truncdLine = orderToday.0.trunc(length: 30)
                    retStr = "\(retStr)(\(orderToday.2)) \(truncdLine) \n"
                }
                
                thirdDataText.text = retStr
            } else {
                thirdDataText.text = "No orders today"
            }
        } else if let thisSource = reportingSource as? EzoicAccount {
            sourceTitle.text = "Ezoic"
            sourceEmail.text = thisSource.email
            sourceTag.isHidden = true
            
            thirdDataText.isHidden = true
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
