//
//  AmazonAssociatesAccount.swift
//  SiteData
//
//  Created by Mark Lyons on 10/18/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import Foundation

class AmazonAssociatesAccount : Source {
    var id : Int?
    var amazonEmail : String?
    var password : String?
    var storeIds : [String]?
    
    init(id: Int, amazonEmail: String, password: String, storeIds: [String], lastUpdatedTime: Date) {
        super.init(name: "Amazon Associates", email: amazonEmail, lastUpdated: lastUpdatedTime, dataPoint: 10.0, dataTitle: "ESTIMATED FEES TODAY")
        self.id = id
        self.amazonEmail = amazonEmail
        self.password = password
        self.storeIds = storeIds
    }
    
    func update() {
        
    }
}
