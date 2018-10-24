//
//  EzoicAccount.swift
//  SiteData
//
//  Created by Mark Lyons on 10/23/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import Foundation

class EzoicAccount : Source {
    var ezoicEmail : String?
    
    init(id: Int, ezoicEmail: String, password: String, lastUpdatedTime: Date, estimatedEarningsToday: Double) {
        super.init(id: id, name: "Ezoic", email: ezoicEmail, lastUpdated: lastUpdatedTime, dataPoint: estimatedEarningsToday, dataTitle: "REVENUE TODAY", password: password)
        self.ezoicEmail = ezoicEmail
    }
}
