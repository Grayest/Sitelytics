//
//  DataActions.swift
//  SiteData
//
//  Created by Mark Lyons on 10/18/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import Foundation
import SQLite3

extension String: Error {}
class DataActions {
    var db: OpaquePointer?
    
    let createAmazonAssociatesAccountTable = "CREATE TABLE IF NOT EXISTS amazon_associates_accounts (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT, password TEXT, storeIds TEXT, lastUpdatedTimestamp TEXT, estEarningsToday DOUBLE)"
    let createAmazonAssociatesOrdersTable = "CREATE TABLE IF NOT EXISTS amazon_associates_orders (id INTEGER PRIMARY KEY AUTOINCREMENT, price INTEGER, quantity INTEGER, product_name TEXT, product_category TEXT, store_id TEXT)"
    let createEzoicAccountTable = "CREATE TABLE IF NOT EXISTS ezoic_accounts (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT, password TEXT, lastUpdatedTimestamp TEXT, estEarningsToday DOUBLE)"
    
    func getAllAmazonAccounts() -> [AmazonAssociatesAccount] {
        let getAllQuery = "SELECT * from amazon_associates_accounts"
        var amazonAccounts : [AmazonAssociatesAccount] = []
        var stmt : OpaquePointer?
        
        if(sqlite3_prepare(db, getAllQuery, -1, &stmt, nil) != SQLITE_OK) {
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing select query: \(errMsg)")
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            let id = sqlite3_column_int(stmt, 0)
            print("Current id: \(id)")
            let email = String(cString: sqlite3_column_text(stmt, 1))
            let password = String(cString: sqlite3_column_text(stmt, 2))
            let storeIds = String(cString: sqlite3_column_text(stmt, 3))
            let lastUpdated = Date(timeIntervalSinceReferenceDate: sqlite3_column_double(stmt, 4))
            let estEarningsToday = Double(sqlite3_column_double(stmt, 5))
           
            let currAmznAccount = AmazonAssociatesAccount(id: Int(id), amazonEmail: email, password: password, storeIds: storeIds, lastUpdatedTime: lastUpdated, estimatedEarningsToday: estEarningsToday)
            
            amazonAccounts.append(currAmznAccount)
        }
        
        sqlite3_finalize(stmt)
        return amazonAccounts
    }
    
    func getAllEzoicAccounts() -> [EzoicAccount] {
        let getAllQuery = "SELECT * from ezoic_accounts"
        var ezoicAccounts : [EzoicAccount] = []
        var stmt : OpaquePointer?
        
        if(sqlite3_prepare(db, getAllQuery, -1, &stmt, nil) != SQLITE_OK) {
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing select query: \(errMsg)")
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            let id = sqlite3_column_int(stmt, 0)
            let email = String(cString: sqlite3_column_text(stmt, 1))
            let password = String(cString: sqlite3_column_text(stmt, 2))
            let lastUpdated = Date(timeIntervalSinceReferenceDate: sqlite3_column_double(stmt, 3))
            let estEarningsToday = Double(sqlite3_column_double(stmt, 4))
            
            let currEzoicAccount = EzoicAccount(id: Int(id), ezoicEmail: email, password: password, lastUpdatedTime: lastUpdated, estimatedEarningsToday: estEarningsToday)
            ezoicAccounts.append(currEzoicAccount)
        }
        
        sqlite3_finalize(stmt)
        return ezoicAccounts
    }
    
    func getAmazonAccount(id: Int32) -> AmazonAssociatesAccount {
        var stmt : OpaquePointer?
        var amazonAccount : AmazonAssociatesAccount?
        let getQuery = "SELECT * FROM amazon_associates_accounts WHERE id = ?"

        if (sqlite3_prepare(db, getQuery, -1, &stmt, nil) != SQLITE_OK) { print("Cant prepare db.") }
        if (sqlite3_bind_int(stmt, 1, id) != SQLITE_OK) { print("Cant bind int.")}
        
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            let id = sqlite3_column_int(stmt, 0)
            let email = String(cString: sqlite3_column_text(stmt, 1))
            let password = String(cString: sqlite3_column_text(stmt, 2))
            let storeIds = String(cString: sqlite3_column_text(stmt, 3))
            let lastUpdated = Date(timeIntervalSinceReferenceDate: sqlite3_column_double(stmt, 4))
            let estEarningsToday = Double(sqlite3_column_double(stmt, 5))
            
           amazonAccount = AmazonAssociatesAccount(id: Int(id), amazonEmail: email, password: password, storeIds: storeIds, lastUpdatedTime: lastUpdated, estimatedEarningsToday: estEarningsToday)
        }
        
        sqlite3_finalize(stmt)
        return amazonAccount!
    }
    
    //Also updates time, of course
    func updateAmazonEstEarningsToday(currId : Int, newEarnings : Double) {
        var stmt : OpaquePointer?
        let updateQuery = "UPDATE amazon_associates_accounts SET estEarningsToday = ?, lastUpdatedTimestamp = ? WHERE id = ?"
        
        if (sqlite3_prepare_v2(db, updateQuery, -1, &stmt, nil) != SQLITE_OK) {
            let errMsg = String(cString: sqlite3_errmsg(stmt))
            print("Error in db preparation: \(errMsg)")
        }
        
        if (sqlite3_bind_double(stmt, 1, newEarnings) != SQLITE_OK) { print("Cant bind new earnings double.") }
        
        let lastUpdatedDateFmt = Date()
        if(sqlite3_bind_double(stmt, 2, lastUpdatedDateFmt.timeIntervalSinceReferenceDate) != SQLITE_OK) {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding date: \(errmsg)")
            return
        }
        
        if (sqlite3_bind_int(stmt, 3, Int32(currId)) != SQLITE_OK) { print("Cant bind id.") }
        
        if sqlite3_step(stmt) == SQLITE_DONE {
            print("Successfully updated row.")
        } else {
            print("Could not update row.")
        }
        
        sqlite3_finalize(stmt)
    }
    
    //Just for testing, will need to be done if any structure changes are necessary
    func firebombDatabase() {
        let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("SourceData.sqlite")
        let fm = FileManager.default
        do {
            try fm.removeItem(at:url)
        } catch {
            NSLog("Error deleting file: \(url)")
        }
    }
    
    func createTable(createTableQuery : String) {
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    
    func createEzoicTable() {
        createTable(createTableQuery: createEzoicAccountTable)
    }
    
    func createAmazonAccountsTable() {
        createTable(createTableQuery: createAmazonAssociatesAccountTable)
    }
    
    func createAmazonOrdersTable() {
        createTable(createTableQuery: createAmazonAssociatesOrdersTable)
    }
    
    func initDatabase() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("SourceData.sqlite")
        
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database.")
        }
    }
    
    func addEzoicAccount(email: String, password: String) {
        var stmt: OpaquePointer?
        let addToEzoicAccounts = "INSERT INTO ezoic_accounts (email, password, lastUpdatedTimestamp, estEarningsToday) VALUES (?, ?, ?, ?)"
        if(sqlite3_prepare(db, addToEzoicAccounts, -1, &stmt, nil) != SQLITE_OK) {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        } else {
            print("successfully prepared for insertion")
        }
        
        if sqlite3_bind_text(stmt, 1, email, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 2, password, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        //Initialize as now as we will update right away
        let lastUpdatedDateFmt = Date()
        if(sqlite3_bind_double(stmt, 3, lastUpdatedDateFmt.timeIntervalSinceReferenceDate) != SQLITE_OK) {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if(sqlite3_bind_double(stmt, 4, 0.0) != SQLITE_OK) {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting record: \(errmsg)")
            return
        } else {
            print("Successfully inserted record.")
        }
        
        sqlite3_finalize(stmt)
    }
    
    func addAmazonAccount(email : String, password: String, storeIds: String) {
        var stmt: OpaquePointer?
        let addToAmazonAssociatesAccounts = "INSERT INTO amazon_associates_accounts (email, password, storeIds, lastUpdatedTimestamp, estEarningsToday) VALUES (?, ?, ?, ?, ?)"
        if(sqlite3_prepare(db, addToAmazonAssociatesAccounts, -1, &stmt, nil) != SQLITE_OK) {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        } else {
            print("successfully prepared for insertion")
        }
        
        //binding the parameters
        if sqlite3_bind_text(stmt, 1, email, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 2, password, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 3, storeIds, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        //Initialize as now as we will update right away
        let lastUpdatedDateFmt = Date()
        if(sqlite3_bind_double(stmt, 4, lastUpdatedDateFmt.timeIntervalSinceReferenceDate) != SQLITE_OK) {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if(sqlite3_bind_double(stmt, 5, 0.0) != SQLITE_OK) {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting record: \(errmsg)")
            return
        } else {
            print("Successfully inserted record.")
        }
        
        sqlite3_finalize(stmt)
    }
}
