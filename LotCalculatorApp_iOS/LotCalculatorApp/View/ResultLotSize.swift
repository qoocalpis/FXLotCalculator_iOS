//
//  ResultLotSize.swift
//  LotCalculatorApp
//
//  Created by 川人悠生 on 2023/04/27.
//

import SwiftUI

struct ResultLotSize: View {
    @ObservedObject var vm: Info
    @Binding var oneLot: String
    @Binding var lotSize: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("適正ロット").font(.title3)
                Text("\(lotSize) ").font(.largeTitle) + Text("Lots")
                HStack {
                    Text("証拠金")
                    Spacer()
                    Text("\(vm.balance) 円")
                }
                .padding()
                HStack {
                    Text("損失許容額(円)")
                    Spacer()
                    Text("\(vm.yen) 円")
                }
                .padding()
                HStack {
                    Text("損失許容額(%)")
                    Spacer()
                    Text("\(vm.percent) %")
                }
                .padding()
                HStack {
                    Text("ストップロス")
                    Spacer()
                    Text("\(vm.pip) pips")
                }
                .padding()
                HStack {
                    Text("通貨ペア")
                    Spacer()
                    Text("\(vm.currencyPair)")
                }
                .padding()
                HStack {
                    Text("レート")
                    Spacer()
                    Text("\(vm.rate)")
                }
                .padding()
                HStack {
                    Text("1 ロット")
                    Spacer()
                    Text("\(oneLot) 通貨")
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark").font(.title3).fontWeight(.bold)
                    }
                }
            }
        }
    }
}

//struct ResultLotSize_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultLotSize()
//    }
//}
