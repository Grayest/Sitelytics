//
//  DataActions.swift
//  SiteData
//
//  Created by Mark Lyons on 10/18/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import Foundation
import SQLite3

class DataActions {
    var db: OpaquePointer?
    
    let createAmazonAssociatesAccountTable = "CREATE TABLE IF NOT EXISTS amazon_associates_accounts (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT, password TEXT, storeIds TEXT, lastUpdatedTimestamp TEXT)"
    let createAmazonAssociatesOrdersTable = "CREATE TABLE IF NOT EXISTS amazon_associates_orders (id INTEGER PRIMARY KEY AUTOINCREMENT, price INTEGER, quantity INTEGER, product_name TEXT, product_category TEXT, store_id TEXT)"
    
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
            let email = String(cString: sqlite3_column_text(stmt, 1))
            let password = String(cString: sqlite3_column_text(stmt, 2))
            let storeIds = String(cString: sqlite3_column_text(stmt, 3))
            let lastUpdated = Date(
            print(id)
            print(email)
            print(password)
            print(storeIds)
            let currAmznAccount = AmazonAssociatesAccount(id: Int(id), amazonEmail: email, password: password, storeIds: [storeIds], lastUpdated: )
            amazonAccounts.append(currAmznAccount)
        }
        
        return amazonAccounts
    }
    
    func createTable(createTableQuery : String) {
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
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
    
    func addAmazonAccount(email : String, password: String, storeIds: String) {
        var stmt: OpaquePointer?
        let addToAmazonAssociatesAccounts = "INSERT INTO amazon_associates_accounts (email, password, storeIds) VALUES (?, ?, ?)"
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
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting record: \(errmsg)")
            return
        } else {
            print("Successfully inserted record.")
        }
    }
}
