//
//  CurrencyPairList.swift
//  LotCalculatorApp
//
//  Created by 川人悠生 on 2023/03/22.
//

import SwiftUI
import RealmSwift

struct CurrencyPairList: View {
    @ObservedResults(CurrencyPairModel_04.self) var pairs
    let isPurchased: Bool
    var body: some View {
        if !isPurchased {
            List {
                Section("Free") {
                    ForEach(pairs, id: \.self) { item in
                        if item.currencyPair == "USD/JPY" || item.currencyPair == "EUR/USD" || item.currencyPair == "GBP/JPY" {
                            ItemFreeRow(item: item)
                        }
                    }
                }
                Section("Pro+") {
                    ForEach(pairs, id: \.self) { item in
                        ItemRow(item: item, isPurchased: isPurchased)
                    }
                }
            }
        }else {
            List {
                Section("Pro+") {
                    ForEach(pairs, id: \.self) { item in
                        ItemRow(item: item, isPurchased: isPurchased)
                    }
                }
            }
        }
    }
}

struct ItemFreeRow: View {
    @ObservedRealmObject var item: CurrencyPairModel_04
    @ObservedResults(TradeModel_04.self) var tradeModel
    var body: some View {
        
        HStack {
            if item.selected {
                Image(systemName: "star.fill")
                    .foregroundColor(Color.green)
                    .opacity(item.register ? 1:0)
            }else {
                Image(systemName: "star.fill")
                    .foregroundColor(Color.yellow)
                    .opacity(item.register ? 1:0)
            }
            Spacer()
            VStack {
                HStack {
                    Text(item.currencyPair).font(.title3)
                    Spacer()
                }
                FullCurrencyPairName(currencyPair: item.currencyPair)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture {
            updateCurrencyPairModel(item: item)
        }
    }
}

struct ItemRow: View {
    @ObservedRealmObject var item: CurrencyPairModel_04
    @ObservedResults(TradeModel_04.self) var tradeModel
    let isPurchased: Bool
    var body: some View {
        if isPurchased {
            HStack {
                if item.selected {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.green)
                        .opacity(item.register ? 1:0)
                }else {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.yellow)
                        .opacity(item.register ? 1:0)
                }
                Spacer()
                VStack {
                    HStack {
                        Text(item.currencyPair).font(.title3)
                        Spacer()
                    }
                    FullCurrencyPairName(currencyPair: item.currencyPair)
                }
                
            }
            .contentShape(RoundedRectangle(cornerRadius: 20))
            .onTapGesture {
                updateCurrencyPairModel(item: item)
            }
        }else {
            HStack {
                //ダミーImage
                Image(systemName: "star.fill")
                    .foregroundColor(Color.green)
                    .opacity(0)
                Spacer()
                VStack {
                    HStack {
                        Text(item.currencyPair).font(.title3).opacity(0.2)
                        Spacer()
                    }
                    FullCurrencyPairName(currencyPair: item.currencyPair).opacity(0.2)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

struct FullCurrencyPairName: View {
    
    let currencyPair: String
    let front: String
    let end: String
    
    
    init(currencyPair: String) {
        self.currencyPair = currencyPair
        
        switch currencyPair.prefix(3) {
            case "JPY": self.front = "Japanese Yen"
            case "EUR": self.front = "Euro"
            case "GBP": self.front = "Great Britain Pound"
            case "AUD": self.front = "Australian Dollar"
            case "NZD": self.front = "New Zealand Dollar"
            case "CAD": self.front = "Canadian Dollar"
            case "CHF": self.front = "Swiss Franc"
            case "XAU": self.front = "Gold"
            default: self.front = "US Dollar"
        }
        switch currencyPair.suffix(3) {
            case "JPY": self.end = "Japanese Yen"
            case "EUR": self.end = "Euro"
            case "GBP": self.end = "Great Britain Pound"
            case "AUD": self.end = "Australian Dollar"
            case "NZD": self.end = "New Zealand Dollar"
            case "CAD": self.end = "Canadian Dollar"
            case "CHF": self.end = "Swiss Franc"
            default: self.end = "US Dollar"
        }
        
    }
    
    var body: some View {
        HStack {
            Text("\(front) VS \(end)").font(.caption)
            Spacer()
        }
    }
}

func updateCurrencyPairModel(item: CurrencyPairModel_04) {
    
    let realm = try! Realm()
    let tradeModelRecord = realm.objects(TradeModel_04.self).first!
    let CurrencyModelSelected = realm.objects(CurrencyPairModel_04.self).where{ $0.selected == true }.first!
    
    let changeBool: Bool
    if item.register { changeBool = false } else { changeBool = true }
    
    if item.selected { return }
    
    if item.currencyPair != tradeModelRecord.defaultCurrencyPair {
        
        try! realm.write {
            let record = CurrencyPairModel_04(value: ["currencyPair": item.currencyPair, "selected": item.selected, "register": changeBool] as [String : Any])
            realm.add(record, update: .modified)
        }
        return
    }
    if item.currencyPair == tradeModelRecord.defaultCurrencyPair {
        try! realm.write {
            let record = TradeModel_04(value: ["id": 0, "lot": tradeModelRecord.lot, "losCutPercent": tradeModelRecord.losCutPercent, "defaultCurrencyPair": CurrencyModelSelected.currencyPair] as [String : Any])
            realm.add(record, update: .modified)
        }
        try! realm.write {
            let record = CurrencyPairModel_04(value: ["currencyPair": item.currencyPair, "selected": item.selected, "register": changeBool] as [String : Any])
            realm.add(record, update: .modified)
        }
        return
    }
}

