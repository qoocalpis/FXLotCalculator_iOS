//
//  ToolView.swift
//  SwiftAPIPractice
//
//  Created by 川人悠生 on 2023/02/18.
//

import SwiftUI
import Combine
import RealmSwift

class Info: ObservableObject {
    @Published var rate = ""
    @Published var balance = ""
    @Published var percent = fetchPercent()
    @Published var yen = ""
    @Published var pip = ""
    @Published var currencyPair = ""
    @Published var isBool = false
}

func fetchPercent() -> Int {
    let realm = try! Realm()
    let record = realm.objects(TradeModel_04.self).first!
    return record.losCutPercent
}

struct LotCalculator: View {
    
    @ObservedResults(CurrencyPairModel_04.self, filter: NSPredicate(format: "selected = true")) var currencyPair
    @Binding var rows: [[String: String]]
    @ObservedObject var vm: Info
    @Binding var focusKeyboard: Bool
    @Binding var updatedLastTime: Date?
    @State var price = ""
    @State private var isSwipeEnabled = true
    @State var isAlert = false
    @State var updatedFirstLastTimeTorigger = false
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Spacer()
                Balance(vm: vm, focusKeyboard: $focusKeyboard)
                StopLoss(vm: vm, focusKeyboard: $focusKeyboard)
                Text("通貨ペア").fontWeight(.medium).padding(.top).padding(.bottom, 5)
                Text(currencyPair.first!.currencyPair).font(.title).fontWeight(.bold).padding()
                HStack {
                    Text("レート")//.padding(1)
                    if price == "" {
                        ProgressView()
                            .frame(width: 80, alignment: .center)
                            .font(.system(size: 100))
                    }else {
                        Text(price).font(.title3)
                    }
                }
                .onChange(of: price, perform: { newValue in
                    if newValue != "" && !updatedFirstLastTimeTorigger {
                        updatedLastTime = Date()
//                        updatedLastTime.dateFormat = "yyyy/MM/dd HH:mm"
                        updatedFirstLastTimeTorigger.toggle()
                    }
                })
                Spacer()
                Lot(vm: vm, rows: $rows)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            vm.rate = fetchRate(currencyPair: currencyPair.first!.currencyPair)
                            price = vm.rate
                        }
                        vm.currencyPair = currencyPair.first!.currencyPair
                    }
                    .onChange(of: rows, perform: { newValue in
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            vm.rate = fetchRate(currencyPair: currencyPair.first!.currencyPair)
                            price = vm.rate
                        }
                        vm.currencyPair = currencyPair.first!.currencyPair
                    })
                Spacer()
            }
            .navigationTitle("Position Size Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                ///vm.rate(price) 6秒のタイムアウト設定
                DispatchQueue.main.asyncAfter(deadline: .now()+10) {
                    if price == "" {
                        isAlert = true
                    }
                }
            }
            .alert(isPresented: $isAlert) {
                Alert(title: Text("タイムアウト"),
                      message: Text("タイムアウトしました。ネットワーク接続を確認してください"))   // 詳細メッセージの追加
            }
        }
    }
    func fetchRate(currencyPair: String) -> String {
        let realm = try! Realm()
        let record = realm.objects(CurrencyPairModel_04.self).filter("selected = true").first!
        let currency = currencyPair.suffix(3)
        if let result = self.rows.first(where: { $0["currencyPair"] == record.currencyPair }) {
            if let priceDouble = Double(result["price"]!) {
                if currencyPair == "XAU/USD" {
                    return String(format: "%.2f", priceDouble)
                }else {
                    switch currency {
                        case "JPY": return String(format: "%.3f", priceDouble)
                        default: return String(format: "%.5f", priceDouble)
                    }
                }
            }else {
                return ""
            }
        } else {
            return ""
        }
    }
}

struct Balance: View {
    
    @ObservedObject var vm: Info
    @FocusState var focusBalance: Bool
    @FocusState var focusPercent: Bool
    @FocusState var focusYen: Bool
    @State var isSheet = false
    @Environment(\.colorScheme) var colorScheme
    @Binding var focusKeyboard: Bool
    
    var body: some View {
        VStack {
            Text("口座残高(円)").font(.title3).fontWeight(.medium).padding(.top)
            TextField("", text: $vm.balance)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .frame(width: 270, height: 35)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                .focused(self.$focusBalance)
                .padding(.vertical)
            //入力文字数制限
                .onReceive(Just(vm.balance)) { _ in
                    if vm.balance.count > 8 {
                        vm.balance = String(vm.balance.prefix(8))
                    }
                }
                .toolbar {
                    if focusBalance {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()         // 右寄せにする
                            Button("閉じる") {
                                focusBalance = false  //  フォーカスを外す
                            }
                        }
                    }
                }
            HStack {
                Text("損失許容額").foregroundColor(Color.blue).fontWeight(.medium).padding(.top).backgroundStyle(Color.blue)
                Spacer()
                Text("\(vm.percent) %")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .background(.mint)
                    .cornerRadius(5)
                    .frame(width: 150, height: 35)
                    .onTapGesture {
                        isSheet.toggle()
                    }
            }
            .padding(.horizontal, 30)
            .padding(.vertical)
            .sheet(isPresented: $isSheet) {
                ScrollNumberSub(vm: vm).presentationDetents([.medium])
            }
            .onAppear { if vm.percent == 0 { vm.yen = "0" } }
        }
    }
}

struct ScrollNumberSub: View {
    let numArray = Array(0...100)
    @ObservedObject var vm: Info
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationStack {
            ScrollView {
                ScrollViewReader { scrollView in
                    VStack {
                        ForEach(numArray, id: \.self) { num in
                            ZStack {
                                Rectangle()
                                    .opacity(0)
                                Button {
                                    if vm.percent == num { return }
                                    else {
                                        vm.percent = num
                                    }
                                } label: {
                                    if vm.percent == num {
                                        if num == 0 {
                                            Text("0")
                                                .frame(width: 150, height: 50)
                                                .foregroundColor(Color.black)
                                                .background(Color.green)
                                                .cornerRadius(10)
                                        }else {
                                            Text("\(num)")
                                                .frame(width: 150, height: 50)
                                                .foregroundColor(Color.black)
                                                .background(Color.green)
                                                .cornerRadius(10)
                                        }
                                    }else {
                                        if num == 0 {
                                            Text("0")
                                                .frame(width: 150, height: 50)
                                                .foregroundColor(Color.black)
                                                .background(Color.yellow)
                                                .cornerRadius(10)
                                        }else {
                                            Text("\(num)")
                                                .frame(width: 150, height: 50)
                                                .foregroundColor(Color.black)
                                                .background(Color.yellow)
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .onAppear {
                        // 最初のアイテムにスクロール
                        scrollView.scrollTo(vm.percent)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image(systemName: "xmark").font(.title3).fontWeight(.bold)
                            }
                        }
                    }
                }
            }
        }
    }
}


struct StopLoss: View {
    @ObservedObject var vm: Info
    @Environment(\.colorScheme) var colorScheme
    @FocusState var focus: Bool
    @Binding var focusKeyboard: Bool
    
    var body: some View {
        HStack {
            Text("ストップロス").foregroundColor(Color.blue).fontWeight(.medium).padding(.top).backgroundStyle(Color.blue)
            Spacer()
            VStack {
                TextField("", text: $vm.pip)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                    .frame(width: 70, height: 35)
                    .focused(self.$focus)
                //入力文字数制限
                    .onReceive(Just(vm.pip)) { _ in
                        if  vm.pip.count > 4 {
                            vm.pip = String(vm.pip.prefix(4))
                        }
                    }
                    .toolbar {
                        if focus {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()         // 右寄せにする
                                Button("閉じる") {
                                    focus = false  //  フォーカスを外す
                                }
                            }
                        }
                    }
                if colorScheme == .light {
                    // ライトモード
                    Divider().frame(width: 70).background(Color.red)
                } else {
                    // ダークモード
                    Divider().frame(width: 70).background(Color.white)
                }
            }
            .onChange(of: vm.pip) { newValue in
                if newValue.count == 4 { vm.pip = "1000" }
            }
            Text("pips")
        }
        .padding(.horizontal,30)
        .padding(.vertical)
    }
}


struct Lot: View {
    @ObservedObject var vm: Info
    @Binding var rows: [[String: String]]
    var body: some View {
        
        Calculator(vm: vm, rows: $rows)
        
    }
}

struct Calculator: View {
    @State var oneLot: String = ""
    @State var lotSize: String = ""
    @ObservedObject var vm: Info
    @Binding var rows: [[String: String]]
    @State var isShow = false
    var body: some View {
        
        Button {
            calculation(vm: vm)
        } label: {
            ZStack {
                Rectangle()
                    .fill(vm.isBool ? Color("CalculatorColor") : Color(.gray))
                    .shadow(radius: 10)
                    .frame(width: 120, height: 50)
                    .cornerRadius(10)
                Text("計算").foregroundColor(Color.black)
            }
        }
        .sheet(isPresented: $isShow) {
            ResultLotSize(vm: vm, oneLot: $oneLot, lotSize: $lotSize)
        }
        .onChange(of: vm.balance) { _ in checkIsBool() }
        .onChange(of: vm.pip) { _ in checkIsBool()}
        .onChange(of: vm.percent) { _ in checkIsBool() }
    }
    
    func checkIsBool() {
        if vm.balance != "" && vm.pip != "" && vm.rate != "" && vm.percent > 0 {
            vm.isBool = true
        }else {
            vm.isBool = false
        }
    }
    
    func calculation(vm: Info) -> Void {
        
        let testBool: Bool = vm.balance != ""  && vm.pip != "" && vm.rate != "" && vm.isBool
        
        if !testBool { return }
        
        
        if let IntBalance = Int(vm.balance){
            let result = IntBalance * vm.percent / 100
            vm.yen = String(result)
        }
        
        let realm = try! Realm()
        let oneLot = realm.objects(TradeModel_04.self).first!.lot
        var RateYen: Double = 0
        let currency = vm.currencyPair.suffix(3)
        
        if currency == "JPY" {
            RateYen = 1000
        }else {
            if let result = self.rows.first(where: { $0["currencyPair"] == currency.suffix(3) + "/JPY"}) {
                if let priceDouble = Double(result["price"]!) {
                    RateYen = priceDouble * 10
                }
                print(result["currencyPair"]!)
            }
        }
        
        let result = Double(vm.yen)! / Double(vm.pip)! / RateYen
        
        lotSize = ""
        print(Double(vm.yen)!)
        print(result)
        
        if oneLot == 1000 {
            lotSize = String(round(result * 10000) / 100)
            print("A")
        }else if oneLot == 10000 {
            lotSize = String(round(result * 1000) / 100)
            print("B")
        }else if oneLot == 50000 {
            lotSize = String(round((result / 2) * 1000) / 100)
            print("C")
        }else {
            lotSize = String(round(result * 100) / 100)
            print("D")
        }
        
        print(lotSize)
        
        self.oneLot = String(oneLot)
        if lotSize != "" {
            isShow.toggle()
        }
    }
}






