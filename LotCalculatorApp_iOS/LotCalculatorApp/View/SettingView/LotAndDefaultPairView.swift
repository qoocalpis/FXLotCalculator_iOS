//
//  LotAndDefaultPairView.swift
//  LotCalculatorApp
//
//  Created by 川人悠生 on 2023/03/25.
//

import SwiftUI
import RealmSwift

struct LotView: View {
    @ObservedResults(TradeModel_04.self) var tradeModel
    let priceArray = [1000, 10000, 50000, 100000]
    
    var body: some View {
        List(priceArray, id: \.self) { price in
            PriceRow(price: price).frame(height: 75)
            
        }
    }
    struct PriceRow: View {
        @ObservedResults(TradeModel_04.self) var vm
        @State var price: Int
        var body: some View {
            HStack {
                if price == vm.first!.lot {
                    Image(systemName: "checkmark.seal.fill").foregroundColor(Color.green)
                }else {
                    Image(systemName: "checkmark.seal.fill").opacity(0)
                }
                Text("\(price) 通貨")
                Spacer()
            }
            .contentShape(RoundedRectangle(cornerRadius: 20))
            .onTapGesture {
                let realm = try! Realm()
                try! realm.write {
                    let record = TradeModel_04(value: ["id": 0, "lot": price, "losCutPercent": vm.first!.losCutPercent, "defaultCurrencyPair": vm.first!.defaultCurrencyPair] as [String : Any])
                    realm.add(record, update: .modified)
                }
            }
        }
    }
}



struct DefaultPairView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var array: [String] = fetchArray()
    @State private var intValue: Int = fetchIntValue()
    var body: some View {
        VStack {
            //プロパティsize(Int)によって切り替える
            Picker("起動時の通貨ペア", selection: $intValue) {
                ForEach(0..<array.count, id: \.self) { num in
                    if colorScheme == .light{
                    Text(array[num]).foregroundColor(Color.black)
                    }else {
                        Text(array[num]).foregroundColor(Color.white)
                    }
                }
            }
        }
        .onAppear {
            array = fetchArray()
            intValue = fetchIntValue()
        }
        .onChange(of: intValue) { newValue in
            let realm = try! Realm()
            let tradeModelRecord = realm.objects(TradeModel_04.self).first!
            try! realm.write {
                let record = TradeModel_04(value: ["id": 0, "lot": tradeModelRecord.lot, "losCutPercent": tradeModelRecord.losCutPercent, "defaultCurrencyPair": array[newValue]] as [String : Any])
                realm.add(record, update: .modified)
            }
            array = fetchArray()
        }
    }
}

func fetchArray() -> [String] {
    var array: [String] = []
    let realm = try! Realm()
    let record = realm.objects(CurrencyPairModel_04.self).where{ $0.register == true }
    for i in record {
        array.append(i.currencyPair)
    }
    return array
}
func fetchIntValue() -> Int {
    var array: [String] = []
    let realm = try! Realm()
    let record = realm.objects(CurrencyPairModel_04.self).where{ $0.register == true }
    for i in record {
        array.append(i.currencyPair)
    }
    let tradeModelRecord = realm.objects(TradeModel_04.self).first!
    if let index = array.firstIndex(of: tradeModelRecord.defaultCurrencyPair) {
        return index
    } else {
        return 0
    }
}

struct LotAndDefaultPairView_Previews: PreviewProvider {
    static var previews: some View {
        LotView()
    }
}
