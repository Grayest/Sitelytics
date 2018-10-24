//
//  AmazonAssociatesAccount.swift
//  SiteData
//
//  Created by Mark Lyons on 10/18/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import Foundation

class AmazonAssociatesAccount : Source {
    var amazonEmail : String?
    var storeIds : String?
    
    init(id: Int, amazonEmail: String, password: String, storeIds: String, lastUpdatedTime: Date, estimatedEarningsToday: Double) {
        super.init(id: id, name: "Amazon Associates", email: amazonEmail, lastUpdated: lastUpdatedTime, dataPoint: estimatedEarningsToday, dataTitle: "ESTIMATED FEES TODAY", password: password)
        self.amazonEmail = amazonEmail
        self.storeIds = storeIds
    }
}
