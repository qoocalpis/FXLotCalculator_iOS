//
//  SettingView.swift
//  SwiftAPIPractice
//
//  Created by 川人悠生 on 2023/02/23.
//

import SwiftUI
import RealmSwift

struct Settings: View {
    
    @ObservedResults(TradeModel_04.self) var tradeModel
    @StateObject var storeKit: StoreKitManager
    @State var isPurchased: Bool = false
    @State var isProgress: Bool = false
    
    var body: some View {
        NavigationStack {
            if isProgress {
                ZStack {
                    Color.gray
                        .opacity(0.5)
                        .ignoresSafeArea()
                    ProgressView()
                }
            }else {
                VStack {
                    ZStack {
                        RectangleItem()
                        LotSize(lotPrice: tradeModel.first!.lot)
                    }
                    ZStack {
                        RectangleItem()
                        LosCutLevel(losCutPercent: tradeModel.first!.losCutPercent)
                    }
                    ZStack {
                        RectangleItem()
                        HStack {
                            Text("起動時の通貨ペア")
                            Spacer()
                            DefaultPairView()
                        }.padding(.horizontal, 30).padding(.bottom)
                    }
                    ZStack {
                        RectangleItem()
                        HStack {
                            Text("通貨ペア一覧")
                            Spacer()
                            NavigationLink {
                                CurrencyPairList(isPurchased: isPurchased)
                            } label: {
                                HStack {
                                    Image(systemName: "list.star").font(.title3).foregroundColor(Color.orange)
                                    Text("＞")
                                }
                            }
                        }.padding(.horizontal, 30).padding(.bottom)
                    }
                    ZStack {
                        ProductView(storeKit: storeKit, isPurchased: $isPurchased, isProgress: $isProgress)
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            //製品が購入済か調べる
            Task {
                isPurchased = (try? await storeKit.isPurchased()) ?? false
            }
        }
    }
}




struct LotSize: View {
    
    @ObservedResults(TradeModel_04.self) var tradeModel
    @State var lotPrice = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        HStack {
            Text("1 Lot")
            Spacer()
            NavigationLink {
                LotView()
            } label: {
                if colorScheme == .light {
                    // ライトモード
                    Text("\(lotPrice) 通貨").foregroundColor(Color.black)
                } else {
                    // ダークモード
                    Text("\(lotPrice) 通貨").foregroundColor(Color.white)
                }
                Text("＞")
            }
        }
        .padding(.horizontal, 30).padding(.bottom)
        .onAppear{
            lotPrice = tradeModel.first!.lot
        }
    }
}


struct LosCutLevel: View {
    @State var losCutPercent: Int
    @State private var selectedNumber = 1
    @State var isHarfSheet = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Text("損失許容額(%)")
            Spacer()
            Button {
                isHarfSheet.toggle()
            } label: {
                HStack {
                    // ライトモード
                    if colorScheme == .light {
                        if losCutPercent == 0 {
                            Text("未設定").foregroundColor(Color.black)
                        }else {
                            Text("\(losCutPercent) %").foregroundColor(Color.black)
                        }
                        // ダークモード
                    } else {
                        if losCutPercent == 0 {
                            Text("未設定").foregroundColor(Color.white)
                        }else {
                            Text("\(losCutPercent) %").foregroundColor(Color.white)
                        }
                    }
                    Text("＞")
                }
            }
        }
        .padding(.horizontal, 30).padding(.bottom)
        .sheet(isPresented: $isHarfSheet) {
            ScrollNumber(losCutPercent: $losCutPercent).presentationDetents([.medium])
        }
    }
}

struct ScrollNumber: View {
    let numArray = Array(0...100)
    @Binding var losCutPercent: Int
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
                                    if losCutPercent == num { return }
                                    else {
                                        let realm = try! Realm()
                                        let record = realm.objects(TradeModel_04.self).first!
                                        try! realm.write {
                                            let newRecord = TradeModel_04(value: ["id": 0, "lot": record.lot, "losCutPercent": num, "defaultCurrencyPair": record.defaultCurrencyPair] as [String : Any])
                                            realm.add(newRecord, update: .modified)
                                        }
                                        losCutPercent = num
                                    }
                                } label: {
                                    if losCutPercent == num {
                                        if num == 0 {
                                            Text("未設定")
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
                                            Text("未設定")
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
                        scrollView.scrollTo(losCutPercent)
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


struct RectangleItem: View {
    let screenSizeHeight = UIScreen.main.bounds.height
    var body: some View {
        Rectangle()
            .fill(Color("SettingColor"))
            .frame(height: screenSizeHeight/9)
            .cornerRadius(25)
            .padding(.horizontal, 20)
            .shadow(radius: 10)
            .padding(.bottom)
    }
}



//struct SettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        Settings()
//    }
//}
