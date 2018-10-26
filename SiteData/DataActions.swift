//
//  DataActions.swift
//  SiteData
//
//  Created by Mark Lyons on 10/18/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import Foundation
import SQLite3
import SQLite

extension String: Error {}
class DataActions {
    var db: Connection
    let amazon_associates_accounts = Table("amazon_associates_accounts")
    let amazon_associates_orders = Table("amazon_associates_orders")
    let ezoic_accounts = Table("ezoic_accounts")
    
    let az_id_ac = Expression<Int64>("id")
    let az_email_ac = Expression<String>("email")
    let az_password_ac = Expression<String>("password")
    let az_storeIds_ac = Expression<String>("storeIds")
    let az_lastUpdatedTimestamp_ac = Expression<String>("lastUpdatedTimestamp")
    let az_estEarningsToday_ac = Expression<Double>("estEarningsToday")
    
    let ez_id_ac = Expression<Int64>("id")
    let ez_email_ac = Expression<String>("email")
    let ez_password_ac = Expression<String>("password")
    let ez_lastUpdatedTimestamp_ac = Expression<String>("lastUpdatedTimestamp")
    let ez_estEarningsToday_ac = Expression<Double>("estEarningsToday")
    
    init(givenDb : Connection) {
        db = givenDb
    }
    
    func createEzoicAccountsTable() {
        do {
            try db.run(amazon_associates_accounts.create{t in
                t.column(ez_id_ac, primaryKey: true)
                t.column(ez_email_ac)
                t.column(ez_password_ac)
                t.column(ez_lastUpdatedTimestamp_ac)
                t.column(ez_estEarningsToday_ac)
            })
        } catch {
            print("Error in creating Ezoic Accounts Table.")
        }
    }
    
    func createAmazonAccountsTable() {
        do {
            try db.run(amazon_associates_accounts.create{t in
                t.column(az_id_ac, primaryKey: true)
                t.column(az_email_ac)
                t.column(az_password_ac)
                t.column(az_storeIds_ac)
                t.column(az_lastUpdatedTimestamp_ac)
                t.column(az_estEarningsToday_ac)
            })
        } catch {
            print("Error in creating Amazon Accounts Table.")
        }
    }
    
    func addEzoicAccount(email: String, password: String) {
        do {
            let lastUpdatedDateFmt = Date()
            let lastUpdatedTimestamp = String(lastUpdatedDateFmt.timeIntervalSinceReferenceDate)
            let insert = ezoic_accounts.insert(
                ez_email_ac <- email,
                ez_password_ac <- password,
                ez_lastUpdatedTimestamp_ac <- lastUpdatedTimestamp,
                ez_estEarningsToday_ac <- 0.0
            )
        } catch {
            print("Error in insertion of Ezoic account.")
        }
    }
    
    func addAmazonAccount(email : String, password: String, storeIds: String) {
        do {
            let lastUpdatedDateFmt = Date()
            let lastUpdatedTimestamp = String(lastUpdatedDateFmt.timeIntervalSinceReferenceDate)
            let insert = amazon_associates_accounts.insert(
                az_email_ac <- email,
                az_password_ac <- password,
                az_storeIds_ac <- storeIds,
                az_lastUpdatedTimestamp_ac <- lastUpdatedTimestamp,
                az_estEarningsToday_ac <- 0.0
            )
            
            try db.run(insert)
        } catch {
            print("Error in insertion of Amazon Account.")
        }
    }
    
    func getAllAmazonAccounts() -> [AmazonAssociatesAccount] {
        var allAmazonAccounts : [AmazonAssociatesAccount] = []
        
        do {
            for amazonAccount in try (db.prepare(amazon_associates_accounts)) {
                let id = amazonAccount[az_id_ac]
                let email = amazonAccount[az_email_ac]
                let password = amazonAccount[az_password_ac]
                let storeIds = amazonAccount[az_storeIds_ac]
                let lastUpdatedTS = amazonAccount[az_lastUpdatedTimestamp_ac]
                let lastUpdatedTS_Double = Double(lastUpdatedTS)!
                let final_lastUpdatedTS = Date(timeIntervalSinceReferenceDate: lastUpdatedTS_Double)
                let estEarningsToday = amazonAccount[az_estEarningsToday_ac]
                
                let currAmznAcc = AmazonAssociatesAccount(id: Int(id), amazonEmail: email, password: password, storeIds: storeIds, lastUpdatedTime: final_lastUpdatedTS, estimatedEarningsToday: estEarningsToday)
                
                allAmazonAccounts.append(currAmznAcc)
            }
        } catch {
            print("Error in grabbing all Amazon accounts.")
        }
        
        return allAmazonAccounts
    }
    
    func getAllEzoicAccounts() -> [EzoicAccount] {
        var allEzoicAccounts : [EzoicAccount] = []
        
        do {
            for ezoicAccount in try (db.prepare(ezoic_accounts)) {
                let id = ezoicAccount[ez_id_ac]
                let email = ezoicAccount[ez_email_ac]
                let password = ezoicAccount[ez_password_ac]
                let lastUpdatedTS = ezoicAccount[ez_lastUpdatedTimestamp_ac]
                let lastUpdatedTS_Double = Double(lastUpdatedTS)!
                let final_lastUpdatedTS = Date(timeIntervalSinceReferenceDate: lastUpdatedTS_Double)
                let estEarningsToday = ezoicAccount[ez_estEarningsToday_ac]
                
                let currAmznAcc = EzoicAccount(id: Int(id), ezoicEmail: email, password: password, lastUpdatedTime: final_lastUpdatedTS, estimatedEarningsToday: estEarningsToday)
                
                allEzoicAccounts.append(currAmznAcc)
            }
        } catch {
            print("Error in grabbing all Ezoic accounts.")
        }
        
        return allEzoicAccounts
    }
    
    //Also updates time, of course
    func updateEzoicEarningsToday(currId: Int, newEarnings: Double) {
        
    }
    
    //Also updates time, of course
    func updateAmazonEstEarningsToday(currId : Int, newEarnings : Double) {
        
    }
}
