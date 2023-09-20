//
//  HomeTabView.swift
//  SwiftAPIPractice
//
//  Created by 川人悠生 on 2023/02/19.
//

import SwiftUI
import RealmSwift
import Network


struct HomeTabView: View {
    
    @ObservedRealmObject var tradeModel: TradeModel_04
    @ObservedResults(CurrencyPairModel_04.self) var currencyPairModel
    @ObservedObject var vm = Info()
    
    @State private var isConnected = false
    @State var flag = 0
    @State var selected = 0
    @State var rows = [[String: String]]()
    @State var error: Error?
    @State var focusKeyboard = false
    @StateObject var storeKit = StoreKitManager()
    @State var isPurchased = false
    @State var isSelected = true
    @State var updatedLastTime: Date? = nil
    
    var body: some View {
        if let _ = error {
            Text("API取得エラー")
        }else {
            NavigationStack {
                VStack(spacing: 0) {
                    
                    TabView(selection: $selected) {
                        LotCalculator(rows: $rows, vm: vm, focusKeyboard: $focusKeyboard, updatedLastTime: $updatedLastTime).tag(0)
                        RiskReward().tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    ZStack {
                        Rectangle()
                            .frame(width: 50, height: 20)
                            .background(Color.gray)
                            .cornerRadius(5)
                            .opacity(0.1)
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.callout)
                                .foregroundColor(isSelected ? Color("colorCircle") : Color.gray)
                                .opacity(isSelected ? 1:0.2)
                            Image(systemName: "circle.fill")
                                .font(.callout)
                                .foregroundColor(isSelected ? Color.gray : Color("colorCircle"))
                                .opacity(isSelected ? 0.2:1)
                        }
                        .animation(.spring(), value: isSelected)
                    }
                    .padding(.bottom)
                    HStack {
                        /// 画面遷移リンクの定義
                        NavigationLink {
                            Settings(storeKit: storeKit)                // 遷移先View
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: UIScreen.main.bounds.height/22))
                        }
                        .padding()
                        Spacer()
                        NavigationLink {
                            FavoriteCurrencyPair(rows: $rows, updatedLastTime: $updatedLastTime)
                        } label: {
                            Image("rate")
                                .resizable()
                                .scaledToFit()
                                .frame(height: UIScreen.main.bounds.height/22)
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/13)
                    .background(Color("TabColor"))
                    
                }
                .ignoresSafeArea(.keyboard, edges: focusKeyboard ? .top : .bottom)
                .onAppear {
                    checkConnectivity()
                    fetch(newValue: isConnected)
                }
                .onChange(of: isConnected, perform: { newValue in
                    fetch(newValue: newValue)
                })
                .onChange(of: selected, perform: { newValue in
                    isSelected = newValue == 0
                    print(newValue)
                })
            }
        }
    }
    
    private func checkConnectivity() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Monitor")
        
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
    }
    func fetch(newValue: Bool) {
        if newValue && flag == 0 {
            Task {
                do {
                    let fetchedRows = try await fetchRows()
                    DispatchQueue.main.async {
                        rows = fetchedRows
                        self.error = nil
                        flag = 1
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.error = error
                    }
                }
            }
        }
        func fetchRows() async throws -> [[String: String]] {
            
            guard let url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/::::::::::::::::") else {
                throw FetchError.invalidURL
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(GoogleSheetResponse.self, from: data)
            return response.values.map { row in
                ["currencyPair": row[0], "price": row[1]]
            }
        }
    }
}

