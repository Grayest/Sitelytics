//
//  SourceDetail.swift
//  SiteData
//
//  Created by Mark Lyons on 10/27/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import UIKit

class SourceDetail: UIViewController {
    @IBOutlet weak var sourceTitle: UILabel!
    @IBOutlet weak var sourceEmail: UILabel!
    @IBOutlet weak var sourceTag: UILabel!
    
    var reportingSource : Source?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    


}
