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
        
        linePlotData = [10, 10, 20, 30, 15, 20]
        let graphRect = CGRect(x: 0.0, y: 0.0, width: graphView.frame.width-60, height: graphView.frame.height)
        let graph = ScrollableGraphView(frame: graphRect, dataSource: self)
        let linePlot = LinePlot(identifier: "line")
        let referenceLines = ReferenceLines()
        
        graph.addPlot(plot: linePlot)
        graph.addReferenceLines(referenceLines: referenceLines)
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
        return "FEB \(pointIndex)"
    }
    
    func numberOfPoints() -> Int {
        return linePlotData!.count
    }
}
