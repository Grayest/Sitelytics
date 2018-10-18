//
//  Source.swift
//  
//
//  Created by Mark Lyons on 10/18/18.
//

import Foundation

class Source {
    var name : String?
    var email : String?
    var lastUpdated : String?
    var dataPoint : Double?
    var dataTitle : String?
    
    init(name: String, email: String, lastUpdated: String, dataPoint: Double, dataTitle: String) {
        self.name = name
        self.email = email
        self.lastUpdated = lastUpdated
        self.dataPoint = dataPoint
        self.dataTitle = dataTitle
    }
}
