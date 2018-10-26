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
    
    var db: Connection?
    
    func initDatabase() {
        do {
            db = try Connection("SourceData.sqlite")
        } catch {
            print("Error occured in initialization")
        }
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
        
    }
    
    func createEzoicAccountsTable() {
        
    }
    
    func createAmazonAccountsTable() {
        
    }
    
    func createAmazonOrdersTable() {
        
    }
    
    
    
    func addEzoicAccount(email: String, password: String) {
        
    }
    
    func addAmazonAccount(email : String, password: String, storeIds: String) {
        
    }
    
    func getAllAmazonAccounts() -> [AmazonAssociatesAccount] {
        
    }
    
    func getAllEzoicAccounts() -> [EzoicAccount] {
        
    }
    
    func getAmazonAccount(id: Int32) -> AmazonAssociatesAccount {
        
    }
    
    //Also updates time, of course
    func updateEzoicEarningsToday(currId: Int, newEarnings: Double) {
        
    }
    
    //Also updates time, of course
    func updateAmazonEstEarningsToday(currId : Int, newEarnings : Double) {
        
    }
}
