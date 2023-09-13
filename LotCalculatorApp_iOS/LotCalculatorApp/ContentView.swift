import SwiftUI
import RealmSwift

struct ContentView: View {
    
    @ObservedResults(TradeModel_04.self) var tradeModel

    var body: some View {
        
        if let tradeModel = tradeModel.first {
            
            HomeTabView(tradeModel: tradeModel)
                .onAppear {
                    //                    deleteAll()
                    setDefaultModel()
                }
        } else {
            
            ProgressView()
                .onAppear {
                    setModel()
                    //deleteAll()
                }
        }
    }
    func setDefaultModel() {
        
        let realm = try! Realm()
        
        try! realm.write {
            let getRecord = realm.objects(CurrencyPairModel_04.self).where{ $0.selected == true }.first!
            let record = CurrencyPairModel_04(value: ["currencyPair": getRecord.currencyPair, "selected": false, "register": true] as [String : Any])
            realm.add(record, update: .modified)
        }
        
        try! realm.write {
            let getRecord = realm.objects(TradeModel_04.self).first!
            let record = CurrencyPairModel_04(value: ["currencyPair": getRecord.defaultCurrencyPair, "selected": true, "register": true] as [String : Any])
            realm.add(record, update: .modified)
        }
    }
}
