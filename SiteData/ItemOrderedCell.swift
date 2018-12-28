//
//  ItemOrderedCell.swift
//  SiteData
//
//  Created by Mark Lyons on 12/27/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import Foundation
import UIKit

class ItemOrderedCell: UITableViewCell {
    @IBOutlet weak var numberContainer: UIView!
    @IBOutlet weak var numberOrdered: UILabel!
    @IBOutlet weak var topHeadingContainer: UIView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var bodyContent: UIView!
    @IBOutlet weak var itemCategory: UILabel!
    @IBOutlet weak var itemRate: UILabel!
    @IBOutlet weak var itemCommission: UILabel!
}
