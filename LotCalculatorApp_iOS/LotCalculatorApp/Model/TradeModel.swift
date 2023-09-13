//
//  TradeModel.swift
//  LotCalculatorApp
//
//  Created by 川人悠生 on 2023/03/07.
//

import SwiftUI
import RealmSwift

class TradeModel_04: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var id = 0
    @Persisted var lot: Int
    @Persisted var losCutPercent: Int
    @Persisted var defaultCurrencyPair: String
}

class CurrencyPairModel_04: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true)  var currencyPair: String
    @Persisted var selected: Bool
    @Persisted var register: Bool
    
}


func setModel() -> Void {
    
    let array: [String] = [
        "AUD/CAD"
        ,"AUD/CHF"
        ,"AUD/JPY"
        ,"AUD/NZD"
        ,"AUD/USD"
        ,"CAD/CHF"
        ,"CAD/JPY"
        ,"CHF/JPY"
        ,"EUR/AUD"
        ,"EUR/CAD"
        ,"EUR/CHF"
        ,"EUR/GBP"
        ,"EUR/JPY"
        ,"EUR/NZD"
        ,"EUR/USD"
        ,"GBP/AUD"
        ,"GBP/CAD"
        ,"GBP/CHF"
        ,"GBP/JPY"
        ,"GBP/NZD"
        ,"GBP/USD"
        ,"NZD/CAD"
        ,"NZD/JPY"
        ,"NZD/USD"
        ,"USD/CAD"
        ,"USD/CHF"
        ,"USD/JPY"
        ,"XAU/USD"
    ]
    
    let defautArray: [String] = ["USD/JPY", "EUR/USD", "GBP/JPY"]
    
    let realm = try! Realm()
    
    try! realm.write {
        let record = TradeModel_04(value: ["id": 0, "lot": 10000, "losCutPercent": 0, "defaultCurrencyPair": "USD/JPY"] as [String : Any])
        realm.add(record, update: .modified)
    }
    
    for item in array {
        if defautArray.contains(item) {
            try! realm.write {
                let record = CurrencyPairModel_04(value: ["currencyPair": item, "selected": false, "register": true] as [String : Any])
                realm.add(record, update: .modified)
            }
        }else {
            try! realm.write {
                let record = CurrencyPairModel_04(value: ["currencyPair": item, "selected": false, "register": false] as [String : Any])
                realm.add(record, update: .modified)
            }
        }
    }
    let targetRecord = realm.objects(TradeModel_04.self).first!
    let record = CurrencyPairModel_04(value: ["currencyPair": targetRecord.defaultCurrencyPair, "selected": true, "register": true] as [String : Any])
    try! realm.write {
        realm.add(record, update: .modified)
    }
}


func deleteAll() {
    let realm = try! Realm()
    try! realm.write {
        // Delete all objects from the realm.
        realm.deleteAll()
    }
}
