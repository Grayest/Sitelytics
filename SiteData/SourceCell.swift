//
//  SourceCell.swift
//  SiteData
//
//  Created by Mark Lyons on 10/14/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import UIKit
import UICircularProgressRing

class SourceCell: UITableViewCell {
    @IBOutlet weak var sourceName : UILabel!
    @IBOutlet weak var sourceEmail: UILabel!
    @IBOutlet weak var innerView : UIView!
    @IBOutlet weak var progressCircle: UICircularProgressRing!
    @IBOutlet weak var sourceData: UILabel!
    @IBOutlet weak var sourceDataLabel: UILabel!
    @IBOutlet weak var lastUpdated: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
