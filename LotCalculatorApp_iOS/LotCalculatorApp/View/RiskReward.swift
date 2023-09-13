//
//  RiskReward.swift
//  LotCalculatorApp
//
//  Created by 川人悠生 on 2023/02/25.
//

import SwiftUI
import Charts

struct RiskReward: View {
    // @Binding var rows: [[String: String]]
    let TP = "利確"
    let SL = "損切"
    @State private var tpPips: Double = 0
    @State private var slPips: Double = 0
    @State private var risk = "0"
    @State private var reward = "0"
    @State private var showSheet = false
    @State var pos = false
    let screenSizeWidth = UIScreen.main.bounds.width
    let screenSizeHeight = UIScreen.main.bounds.height

    
    var body: some View {
            VStack {
                
                Chart {
                    BarMark(
                        x: .value("Name", TP),
                        y: .value("Name", tpPips)
                    )
                    .foregroundStyle(Color.mint)
                    .annotation(position: .top) {
                        Text("\(Int(tpPips)) pips")
                    }
                    BarMark(
                        x: .value("Name", SL),
                        y: .value("Name", slPips * -1)
                    )
                    .foregroundStyle(Color.red)
                    .annotation(position: pos ? .bottom:.top) {
                        Text("\(Int(slPips * -1)) pips")
                    }
                }
                .padding([.all],20)
                .frame(height: screenSizeHeight/2)
                
                Button {
                    showSheet.toggle()
                } label: {
                    Text("損益pips設定")
                        .padding(10)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(Color.white)
                        .padding()
                }
                .padding(10)
                .sheet(isPresented: $showSheet) {
                    SliderPips(tpPips: $tpPips, slPips: $slPips, risk: $risk, reward: $reward)
                }
                .onChange(of: slPips, perform: { newValue in
                    if Int(newValue) != 0 { pos = true }else { pos = false }
                })
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: screenSizeWidth - 50, height: screenSizeHeight/11)
                        .cornerRadius(7)
                        .shadow(radius: 5)
                    HStack {
                        VStack {
                            Text("Risk").foregroundColor(Color.black).font(.title3)
                            Text("\(risk)").foregroundColor(Color.black).font(.largeTitle)
                        }
                        .padding(.horizontal)
                        VStack {
                            Text("")
                            Text(":").foregroundColor(Color.black).font(.title3)
                        }
                        .padding(.horizontal)
                        VStack {
                            Text("Reward").foregroundColor(Color.black).font(.title3)
                            Text("\(reward)").foregroundColor(Color.black).font(.largeTitle)
                        }
                    }
                    .frame(width: screenSizeWidth - 50, height: 100)
                }
            }
            .navigationTitle("RiskRewardRecio")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct RiskReward_Previews: PreviewProvider {
    static var previews: some View {
        RiskReward()
    }
}
