//
//  ContentView.swift
//  SwiftAPIPractice
//
//  Created by 川人悠生 on 2023/02/15.
//

import SwiftUI
import RealmSwift
import Network



struct FavoriteCurrencyPair: View {
    
    @ObservedResults(CurrencyPairModel_04.self, filter: NSPredicate(format: "register = true")) var pairs
    @Binding var rows: [[String: String]]
    @StateObject var storeKit = StoreKitManager()
    @State var isPurchased: Bool = false
    @Binding var updatedLastTime: Date?
    @State var textDate = ""
    @State var isBoolUpdate = false
    @State var error: Error?
    @ObservedObject var network = MonitoringNetworkState()
        
    var body: some View {
        
        NavigationStack {
            VStack {
                List(pairs, id: \.self) { pair in
                    if pair.selected {
                        Row(pair: pair, rows: $rows)
                            .listRowBackground(Color.green)
                    }else {
                        Row(pair: pair, rows: $rows)
                    }
                }
            }
            .navigationTitle("通貨ペア")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                //製品が購入済か調べる
                Task {
                    isPurchased = (try? await storeKit.isPurchased()) ?? false
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        //ダミー
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .opacity(0)
                        Spacer()
                        
                        VStack {
                            Text("最終更新日時").font(.caption).padding(.bottom, 1)
                            Text("\(textDate)").font(.callout).padding(.bottom, 1)
                        }
                        
                        Spacer()
                        Image(systemName: "arrow.clockwise").font(.title3).foregroundColor(Color.mint)
                            .opacity(isBoolUpdate && network.isConnected ? 1 : 0)
                            .onTapGesture {
                                print(network.isConnected)
                                if isBoolUpdate && network.isConnected {
                                    fetch(newValue: network.isConnected)
                                    updatedLastTime = Date()
                                    let df = DateFormatter()
                                    df.dateFormat = "yyyy/MM/dd HH:mm"
                                    textDate = df.string(from: updatedLastTime!)
                                    isBoolUpdate = false
                                }
                            }
                    }
                    .onAppear {
                        setDateTime(DateTime: updatedLastTime)
                    }
                    .onChange(of: updatedLastTime) { newValue in
                        setDateTime(DateTime: newValue)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    VStack {
                        NavigationLink {
                            CurrencyPairList(isPurchased: isPurchased)
                        } label: {
                            Image(systemName: "plus").font(.title3)
                        }
                    }
                }
            }
        }
    }
    
    func fetch(newValue: Bool) {
        Task {
            do {
                let fetchedRows = try await fetchRows()
                DispatchQueue.main.async {
                    rows = fetchedRows
                    self.error = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error
                }
            }
        }
        @Sendable func fetchRows() async throws -> [[String: String]] {
            
            guard let url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/1URRKa2jW3WMx34GgtDUU21kCYMKvdlG5fKmWwPUSnTE/values/finance?key=AIzaSyA0w_ZecwgQJ9XHcrfsxLpW92i_FacfzRU") else {
                throw FetchError.invalidURL
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(GoogleSheetResponse.self, from: data)
            return response.values.map { row in
                ["currencyPair": row[0], "price": row[1]]
            }
        }
    }
    
    func setDateTime(DateTime: Date?) {
        if let DateTime {
            let df = DateFormatter()
            df.dateFormat = "yyyy/MM/dd HH:mm"
            textDate = df.string(from: DateTime)
            let calender = Calendar.init(identifier: .gregorian)
            let nowDate = Date()
            isBoolUpdate = calender.dateComponents([.minute], from: DateTime, to: nowDate).minute! >= 1
        }
    }
}



struct Row: View {
    
    @ObservedRealmObject var pair: CurrencyPairModel_04
    @Binding var rows: [[String : String]]
    
    var body: some View {
        HStack {
            if let currencyPair = rows.first(where: { $0["currencyPair"] == pair.currencyPair }) {
                //JPYの場合レイアウトがズレるので調整が必要
                if pair.currencyPair.suffix(3) == "JPY" {
                    Text(pair.currencyPair).padding(.trailing, 5).font(.callout).fontWeight(.bold).fontWeight(.medium)
                }else {
                    Text(pair.currencyPair).font(.callout).fontWeight(.bold).fontWeight(.medium)
                }
                NationalFlag(currencyPair: pair.currencyPair)
                Spacer()
                Price(currencyPair: pair.currencyPair, price: currencyPair["price"]!)
            }else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .onTapGesture {
            updateCurrencyPairModel()
        }
        
    }
    func updateCurrencyPairModel() -> Void {
        let realm = try! Realm()
        let getRecord = realm.objects(CurrencyPairModel_04.self).where{ $0.selected == true }.first!
        if  pair.currencyPair == getRecord.currencyPair {
            return
        }else {
            let newRecord = CurrencyPairModel_04(value: ["currencyPair": pair.currencyPair, "selected": true, "register": true] as [String : Any])
            let oldRecord = CurrencyPairModel_04(value: ["currencyPair": getRecord.currencyPair, "selected": false, "register": true] as [String : Any])
            try! realm.write {
                realm.add(newRecord, update: .modified)
                realm.add(oldRecord, update: .modified)
            }
        }
    }
}

struct Price: View {
    
    let currencyPair: String
    let price: String
    
    init(currencyPair: String, price: String) {
        
        self.currencyPair = currencyPair
        let currency = currencyPair.suffix(3)
        
        if let priceDouble = Double(price) {
            
            if currencyPair == "XAU/USD" {
                self.price = String(format: "%.2f", priceDouble)
            }else {
                switch currency {
                    case "JPY": self.price = String(format: "%.3f", priceDouble)
                    default: self.price = String(format: "%.5f", priceDouble)
                }
            }
        }else {
            self.price = ""
        }
    }
    var body: some View {
        HStack {
            if currencyPair != "XAU/USD" {
                Text(price.prefix(price.count-3)).font(.title3) +
                Text(price.suffix(3).prefix(2)).font(.title).fontWeight(.bold) +
                Text(price.suffix(1))
            }else {
                Text(price.prefix(price.count-2)).font(.title3) +
                Text(price.suffix(2)).font(.title).fontWeight(.bold)
            }
        }
    }
}


struct NationalFlag: View{
    
    let currencyPair: String
    
    let fromImage: Image
    let toImage: Image
    
    init(currencyPair: String) {
        self.currencyPair = currencyPair
        let fromCurrency = currencyPair.prefix(3)
        let ToCurrency = currencyPair.suffix(3)
        
        switch fromCurrency {
            case "JPY": self.fromImage = Image("JPY")
            case "AUD": self.fromImage = Image("AUD")
            case "CHF": self.fromImage = Image("CHF")
            case "GBP": self.fromImage = Image("GBP")
            case "EUR": self.fromImage = Image("EUR")
            case "CAD": self.fromImage = Image("CAD")
            case "NZD": self.fromImage = Image("NZD")
            case "XAU": self.fromImage = Image("XAU")
            default: self.fromImage = Image("USD")
        }
        
        switch ToCurrency {
            case "JPY": self.toImage = Image("JPY")
            case "AUD": self.toImage = Image("AUD")
            case "CHF": self.toImage = Image("CHF")
            case "GBP": self.toImage = Image("GBP")
            case "EUR": self.toImage = Image("EUR")
            case "CAD": self.toImage = Image("CAD")
            case "NZD": self.toImage = Image("NZD")
            default: self.toImage = Image("USD")
        }
    }
    
    var body: some View {
        HStack {
            fromImage
                .resizable()
                .scaledToFit()
                .frame(width: 50)
                .clipShape(Circle())
            toImage
                .resizable()
                .scaledToFit()
                .frame(width: 50)
                .clipShape(Circle())
        }
    }
}




