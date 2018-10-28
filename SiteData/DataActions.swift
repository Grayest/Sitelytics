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
    let amazon_associates_monthly = Table("amazon_associates_orders")
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
    
    let az_mo_id = Expression<Int64>("id")
    let az_mo_associated_account_id = Expression<Int64>("associated_account_id")
    let az_mo_bounty_earnings = Expression<Double>("bounty_earnings")
    let az_mo_ordered_items = Expression<Int64>("ordered_items")
    let az_mo_revenue = Expression<Double>("revenue")
    let az_mo_returned_items = Expression<Int64>("returned_items")
    let az_mo_commission_earnings = Expression<Double>("commission_earnings")
    let az_mo_returned_revenue = Expression<Double>("returned_revenue")
    let az_mo_returned_earnings = Expression<Double>("returned_earnings")
    let az_mo_shipped_items = Expression<Int64>("shipped_items")
    let az_mo_bounty_events = Expression<Int64>("bounty_events")
    let az_mo_day = Expression<String>("day")
    let az_mo_clicks = Expression<Int64>("clicks")
    
    init(givenDb : Connection) {
        db = givenDb
    }
    
    func createEzoicAccountsTable() {
        do {
            try db.run(ezoic_accounts.create{t in
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
    
    func createAmazonMonthlyChart() {
        do {
            try db.run(amazon_associates_monthly.create{t in
                t.column(az_mo_id, primaryKey: true)
                t.column(az_mo_associated_account_id)
                t.column(az_mo_bounty_earnings)
                t.column(az_mo_revenue)
                t.column(az_mo_ordered_items)
                t.column(az_mo_returned_items)
                t.column(az_mo_commission_earnings)
                t.column(az_mo_returned_revenue)
                t.column(az_mo_returned_earnings)
                t.column(az_mo_shipped_items)
                t.column(az_mo_bounty_events)
                t.column(az_mo_day)
                t.column(az_mo_clicks)
            })
        } catch let error {
            print("Error in creating Amazon Monthly table. Reason given: \(error)")
        }
    }
    
    func addAmazonMonthlyItem(acct_id: Int64, bounty_earnings: Double, revenue: Double, ordered_items: Int64, returned_items: Int64, commission_earnings: Double, returned_revenue: Double, returned_earnings: Double, shipped_items: Int64, bounty_events: Int64, day: String, clicks: Int64) {
        do{
            let insert = amazon_associates_monthly.insert(
                az_mo_associated_account_id <- acct_id,
                az_mo_bounty_earnings <- bounty_earnings,
                az_mo_revenue <- revenue,
                az_mo_ordered_items <- ordered_items,
                az_mo_returned_items <- returned_items,
                az_mo_commission_earnings <- commission_earnings,
                az_mo_returned_revenue <- returned_revenue,
                az_mo_returned_earnings <- returned_earnings,
                az_mo_shipped_items <- shipped_items,
                az_mo_bounty_events <- bounty_events,
                az_mo_day <- day,
                az_mo_clicks <- clicks
            )
            
            try db.run(insert)
        } catch {
            print("Error adding new Amazon monthly item.")
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
            try db.run(insert)
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
    
    func deleteAmazonMonthlyStats() {
        do {
            try db.run(amazon_associates_monthly.drop())
        } catch {
            print("Error in dropping table.")
        }
    }
    
    func getAmazonMonthlyEarningsByDay() -> [Double] {
        var allEarningsDays : [Double] = []
        
        do {
            for amazonEarningDay in try (db.prepare(amazon_associates_monthly)) {
                let currCommissionEarnings = amazonEarningDay[az_mo_commission_earnings]
                let currBountyEarnings = amazonEarningDay[az_mo_bounty_earnings]
                let currReturnedEarnings = amazonEarningDay[az_mo_returned_earnings]
                let overallIncome = currCommissionEarnings + currBountyEarnings - currReturnedEarnings
                allEarningsDays.append(overallIncome)
            }
        } catch {
            print("Error grabbing all day earnings for Amazon.")
        }
        
        return allEarningsDays
    }
    
    func getAmazonBoxStats() -> [String : String] {
        var shippedRevenue = 0.0
        var commissionEarnings = 0.0
        var orderedItems = 0
        
        do {
            for amazonEarningDay in try (db.prepare(amazon_associates_monthly)) {
                let revenue = amazonEarningDay[az_mo_revenue]
                let commission_earnings = amazonEarningDay[az_mo_commission_earnings]
                let ordered_items = amazonEarningDay[az_mo_ordered_items]
                
                shippedRevenue = shippedRevenue + revenue
                commissionEarnings = commissionEarnings + commission_earnings
                orderedItems = orderedItems + Int(ordered_items)
            }
        } catch {
            print("Error grabbing all day earnings for Amazon.")
        }
        
        let shippedRevenue_fmt = String(format: "$%.02f", shippedRevenue)
        let commissionEarnings_fmt = String(format: "$%.02f", commissionEarnings)
        let orderedItems_fmt = "\(orderedItems)"
        
        let retDict : [String : String] = [
            "SHIPPED ITEMS REVENUE" : shippedRevenue_fmt,
            "COMMISSION EARNINGS" : commissionEarnings_fmt,
            "ORDERED ITEMS" : orderedItems_fmt
        ]
        
        return retDict
    }
    
    //Also updates time, of course
    func updateEzoicEarningsToday(currId: Int, newEarnings: Double) {
        do {
            let lastUpdatedDateFmt = Date()
            let lastUpdatedTimestamp = String(lastUpdatedDateFmt.timeIntervalSinceReferenceDate)
            let currEzoicAcc = ezoic_accounts.filter(az_id_ac == Int64(currId))
            try db.run(currEzoicAcc.update([ez_lastUpdatedTimestamp_ac <- lastUpdatedTimestamp, ez_estEarningsToday_ac <- newEarnings]))
        } catch {
            print("Error updating Ezoic accounts table.")
        }
    }
    
    //Also updates time, of course
    func updateAmazonEstEarningsToday(currId : Int, newEarnings : Double) {
        do {
            let lastUpdatedDateFmt = Date()
            let lastUpdatedTimestamp = String(lastUpdatedDateFmt.timeIntervalSinceReferenceDate)
            let currAmazonAcc = amazon_associates_accounts.filter(az_id_ac == Int64(currId))
            try db.run(currAmazonAcc.update([az_lastUpdatedTimestamp_ac <- lastUpdatedTimestamp, az_estEarningsToday_ac <- newEarnings]))
        } catch {
            print("Error updating Amazon accounts table.")
        }
    }
}
