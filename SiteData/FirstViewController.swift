//
//  FirstViewController.swift
//  SiteData
//
//  Created by Mark Lyons on 10/13/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    private var embedController : EmbedController?
    var amazonData : [String: Any]? {
        didSet {
            let totalOrderedRevenue = amazonData!["TOTAL_ORDERED_REVENUE"] as! Double
            //dataLabel.text = "TOTAL ORDERED REVENUE: \(totalOrderedRevenue)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.rowHeight = 125
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
        cell.innerView.layer.cornerRadius = 10
        return cell
    }

}

