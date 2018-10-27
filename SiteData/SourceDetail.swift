//
//  SourceDetail.swift
//  SiteData
//
//  Created by Mark Lyons on 10/27/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import UIKit
import ScrollableGraphView

class SourceDetail: UIViewController, ScrollableGraphViewDataSource {
    @IBOutlet weak var sourceTitle: UILabel!
    @IBOutlet weak var sourceEmail: UILabel!
    @IBOutlet weak var sourceTag: UILabel!
    @IBOutlet weak var graphView: UIView!
    
    var reportingSource : Source?
    var linePlotData : [Int]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        linePlotData = [70, 30, 20, 60]
        let graphRect = CGRect(x: -7.0, y: 0.0, width: graphView.frame.width, height: graphView.frame.height)
        let graph = ScrollableGraphView(frame: graphRect, dataSource: self)
        graphView.layer.cornerRadius = 4
        
        let linePlot = LinePlot(identifier: "line")
        linePlot.lineWidth = 1
        linePlot.lineColor = hexStringToUIColor(hex: "#0365D5")
        linePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        linePlot.shouldFill = true
        linePlot.fillType = ScrollableGraphViewFillType.solid
        linePlot.fillColor = hexStringToUIColor(hex: "#0365D5").withAlphaComponent(0.5)
        
        let dotPlot = DotPlot(identifier: "dot")
        dotPlot.dataPointType = ScrollableGraphViewDataPointType.circle
        dotPlot.dataPointSize = 3
        
        let referenceLines = ReferenceLines()
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.1)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(1)
        
        graph.addPlot(plot: linePlot)
        graph.addReferenceLines(referenceLines: referenceLines)
        graph.backgroundFillColor = hexStringToUIColor(hex: "#262626")
        graph.dataPointSpacing = graphView.frame.width / 5
        
        graphView.addSubview(graph)
        
        if let thisSource = reportingSource as? AmazonAssociatesAccount {
            sourceTitle.text = "Amazon Associates"
            sourceEmail.text = thisSource.email?.uppercased()
            sourceTag.text = thisSource.storeIds
        } else if let thisSource = reportingSource as? EzoicAccount {
            sourceTitle.text = "Ezoic"
            sourceEmail.text = thisSource.email
            sourceTag.isHidden = true
        }
    }
    
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        switch(plot.identifier) {
        case "line":
            return Double(linePlotData![pointIndex])
        default:
            return 0
        }
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return "Week \(pointIndex + 1)"
    }
    
    func numberOfPoints() -> Int {
        return linePlotData!.count
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
