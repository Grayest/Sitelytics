//
//  EbayAccount.swift
//  SiteData
//
//  Created by Mark Lyons on 11/3/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import Foundation

class EbayAccount : Source {
    init(id: Int, email: String, password: String, lastUpdatedTime: Date, clicksToday: Int) {
        super.init(id: id, name: "eBay Partner Network", email: email, lastUpdated: lastUpdatedTime, dataPoint: Double(clicksToday), dataTitle: "CLICKS TODAY", password: password)
    }
}
