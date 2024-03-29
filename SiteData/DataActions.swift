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
    
    /* TABLES
        Amazon Associates [accounts, monthly data, today's data]
        Ezoic [accounts, monthly data]
        eBay Partner Network [accounts, monthly data]
    */
    let amazon_associates_accounts = Table("amazon_associates_accounts")
    let amazon_associates_monthly = Table("amazon_associates_monthly")
    let amazon_associates_today = Table("amazon_associates_today")
    let ezoic_accounts = Table("ezoic_accounts")
    let ezoic_monthly_data = Table("ezoic_monthly")
    let ebay_accounts = Table("ebay_accounts")
    let ebay_monthly = Table("ebay_monthly")
    
    let az_id_ac = Expression<Int64>("id")
    let az_email_ac = Expression<String>("email")
    let az_password_ac = Expression<String>("password")
    let az_storeIds_ac = Expression<String>("storeIds")
    let az_lastUpdatedTimestamp_ac = Expression<String>("lastUpdatedTimestamp")
    let az_estEarningsToday_ac = Expression<Double>("estEarningsToday")
    
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
    
    let az_day_id = Expression<Int64>("id")
    let az_day_qty = Expression<Int64>("quantity")
    let az_day_price = Expression<Double>("price")
    let az_day_category = Expression<String>("category")
    let az_day_item_title = Expression<String>("product_title")
    let az_day_item_asin = Expression<String>("asin")
    
    let ez_id_ac = Expression<Int64>("id")
    let ez_email_ac = Expression<String>("email")
    let ez_password_ac = Expression<String>("password")
    let ez_lastUpdatedTimestamp_ac = Expression<String>("lastUpdatedTimestamp")
    let ez_estEarningsToday_ac = Expression<Double>("estEarningsToday")
    
    let ez_mo_id = Expression<Int64>("id")
    let ez_mo_amt = Expression<Double>("earnings_amt")
    
    let epn_id_ac = Expression<Int64>("id")
    let epn_email_ac = Expression<String>("email")
    let epn_password_ac = Expression<String>("password")
    let epn_lastUpdatedTimestamp_ac = Expression<String>("lastUpdatedTimestamp")
    let epn_clicksToday_ac = Expression<Int64>("clicksToday")
    
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
    
    func createAmazonTodayChart() {
        do {
            try db.run(amazon_associates_today.create{t in
                t.column(az_day_id, primaryKey: true)
                t.column(az_day_qty)
                t.column(az_day_price)
                t.column(az_day_category)
                t.column(az_day_item_title)
                t.column(az_day_item_asin)
            })
        } catch let error {
            print("Error creating today's chart for Amazon. Reason given: \(error)")
        }
    }
    
    func createEzoicMonthly() {
        do {
            try db.run(ezoic_monthly_data.create{t in
                t.column(ez_mo_id, primaryKey: true)
                t.column(ez_mo_amt)
            })
        } catch let error {
            print("Error creating Ezoic Monthly chart. Reason given: \(error)")
        }
    }
    
    func createEbayAccountsTable() {
        do {
            try db.run(ebay_accounts.create{t in
                t.column(epn_id_ac, primaryKey: true)
                t.column(epn_email_ac)
                t.column(epn_password_ac)
                t.column(epn_lastUpdatedTimestamp_ac)
                t.column(epn_clicksToday_ac)
            })
        } catch let error {
            print("Error creating EPN accounts table. Reason given: \(error)")
        }
    }
    
    func addEzoicMonthlyData(amt: Double) {
        do {
            let insert = ezoic_monthly_data.insert(
                ez_mo_amt <- amt
            )
            
            try db.run(insert)
        } catch let error {
            print("Error adding new item for Ezoic [monthly]. Reason given: \(error)")
        }
    }
    
    func addAmazonDailyItem(qty: Int64, price: Double, category: String, title: String, asin: String) {
        do {
            let insert = amazon_associates_today.insert(
                az_day_qty <- qty,
                az_day_price <- price,
                az_day_category <- category,
                az_day_item_title <- title,
                az_day_item_asin <- asin
            )
            
            try db.run(insert)
        } catch let error {
            print("Error adding new item for Amazon [today]. Reason given: \(error)")
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
            print("Error adding new Amazon monthly item. Reason given: \(error)")
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
    
    func addEbayAccount(email: String, password: String) {
        do {
            let lastUpdatedDateFmt = Date()
            let lastUpdatedTimestamp = String(lastUpdatedDateFmt.timeIntervalSinceReferenceDate)
            
            let insert = ebay_accounts.insert(
                epn_email_ac <- email,
                epn_password_ac <- password,
                epn_lastUpdatedTimestamp_ac <- lastUpdatedTimestamp,
                epn_clicksToday_ac <- 0
            )
            
            try db.run(insert)
        } catch {
            print("Error in insertion of EPN Account.")
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
    
    func getAllEbayAccounts() -> [EbayAccount] {
        var allEbayAccounts : [EbayAccount] = []
        
        do {
            for ebayAccount in try(db.prepare(ebay_accounts)) {
                let id = ebayAccount[epn_id_ac]
                let email = ebayAccount[epn_email_ac]
                let password = ebayAccount[epn_password_ac]
                let lastUpdatedTS = ebayAccount[epn_lastUpdatedTimestamp_ac]
                let lastUpdatedTS_Double = Double(lastUpdatedTS)!
                let final_lastUpdatedTS = Date(timeIntervalSinceReferenceDate: lastUpdatedTS_Double)
                let clicksToday = ebayAccount[epn_clicksToday_ac]
                
                let currEbayAcc = EbayAccount(id: Int(id), email: email, password: password, lastUpdatedTime: final_lastUpdatedTS, clicksToday: Int(clicksToday))
                allEbayAccounts.append(currEbayAcc)
            }
        } catch {
            print("Error getting all Ebay Accounts.")
        }
        
        return allEbayAccounts
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
    
    func deleteAmazonTodayStats() {
        do {
            try db.run(amazon_associates_today.delete())
        } catch {
            print("Error in dropping table.")
        }
    }
    
    func deleteAmazonMonthlyStats() {
        do {
            try db.run(amazon_associates_monthly.delete())
        } catch {
            print("Error in dropping table.")
        }
    }
    
    func deleteEzoicMonthlStats() {
        do {
            try db.run(ezoic_monthly_data.delete())
        } catch {
            print("Error in dropping Ezoic monthly table.")
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
    
    
    func getAllEzoicMonthly() -> [Double] {
        var allEarnings : [Double] = []
        
        do {
            for ezoicEarningDay in try (db.prepare(ezoic_monthly_data)) {
                let currEarn = ezoicEarningDay[ez_mo_amt]
                allEarnings.append(currEarn)
            }
        } catch {
            print("Error grabbing all day earnings for Ezoic.")
        }
        
        //Have to reverse as these are stored in descending order by date
        return allEarnings.reversed()
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
                let returned_revenue = amazonEarningDay[az_mo_returned_revenue]
                let returned_earnings = amazonEarningDay[az_mo_returned_earnings]
                
                shippedRevenue = shippedRevenue + revenue - returned_revenue
                commissionEarnings = commissionEarnings + commission_earnings - returned_earnings
                orderedItems = orderedItems + Int(ordered_items)
            }
        } catch {
            print("Error grabbing all day earnings for Amazon.")
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        
        let shippedRevenue_fmt = formatter.string(from: NSNumber(value: shippedRevenue))
        let commissionEarnings_fmt = formatter.string(from: NSNumber(value: commissionEarnings))
        let orderedItems_fmt = "\(orderedItems)"
        
        let retDict : [String : String] = [
            "SHIPPED REV. THIS MONTH" : shippedRevenue_fmt!,
            "COMMISSION THIS MONTH" : commissionEarnings_fmt!,
            "ITEMS ORDERED THIS MONTH" : orderedItems_fmt
        ]
        
        return retDict
    }
    
    func getAllAmazonOrdersToday() -> [(String, String, Int64, String, Double)]{
        var ordersTupleLst : [(String, String, Int64, String, Double)] = []
        
        do {
            for amazonOrder in try (db.prepare(amazon_associates_today)) {
                let productTitle = amazonOrder[az_day_item_title]
                let productAsin = amazonOrder[az_day_item_asin]
                let qtyOrdered = amazonOrder[az_day_qty]
                let productCategory = amazonOrder[az_day_category]
                let productPrice = amazonOrder[az_day_price]
                let currTuple = (productTitle, productAsin, qtyOrdered, productCategory, productPrice)
                ordersTupleLst.append(currTuple)
            }
        } catch {
            print("Error getting today's Amazon orders.")
        }
        
        return ordersTupleLst
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
