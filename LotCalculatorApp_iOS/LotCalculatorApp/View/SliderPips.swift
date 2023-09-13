//
//  SliderPips.swift
//  LotCalculatorApp
//
//  Created by 川人悠生 on 2023/05/11.
//

import SwiftUI

struct SliderPips: View {
    
    
    @Binding var tpPips: Double
    @Binding var slPips: Double
    @Binding var risk: String
    @Binding var reward: String
    //    @State var tpPips: Double = 0
    //    @State var slPips: Double = 0
    
    let rangeArray: [ClosedRange<Double>] = [0...100, 101...200, 201...300]
    @State var rangeTp: ClosedRange<Double> = 0...100
    @State var rangeSl: ClosedRange<Double> = 0...100
    @State var index = 0
    let limitPips = ["~100pips", "~200pips", "~300pips"]
    @State var selectedRangeTp = "~100pips"
    @State var selectedRangeSl = "~100pips"
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        VStack {
            HStack {
                Text("利確Pips")
                    .foregroundColor(Color.mint)
                    .fontWeight(.bold)
                    .font(.title2)
                    .padding(.leading)
                    .padding(.bottom)
                Spacer()
            }
            HStack {
                Spacer()
                Picker("Pick a language", selection: $selectedRangeTp) {
                    ForEach(limitPips, id: \.self) { item in
                        Text(item)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Slider(value: $tpPips,
                   in: rangeTp,
                   step : 1.0
            )
            .accentColor(.mint)
            .padding()
            .onChange(of: selectedRangeTp) { newValue in
                if let i = limitPips.firstIndex(of: newValue) {
                    index = i
                    rangeTp = rangeArray[index]
                }
            }
            
            
            Text("\(Int(tpPips))")
            
            
            HStack {
                Text("損切Pips")
                    .foregroundColor(Color.red)
                    .fontWeight(.bold)
                    .font(.title2)
                    .padding(.leading)
                    .padding(.bottom)
                Spacer()
            }
            HStack {
                Spacer()
                Picker("Pick a language", selection: $selectedRangeSl) { // 3
                    ForEach(limitPips, id: \.self) { item in // 4
                        Text(item) // 5
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Slider(value: $slPips,
                   in: rangeSl,
                   step : 1
            )
            .accentColor(.red)
            .padding()
            .onChange(of: selectedRangeSl) { newValue in
                if let i = limitPips.firstIndex(of: newValue) {
                    index = i
                    rangeSl = rangeArray[index]
                }
            }
            
            Text("\(Int(slPips))")
            
            Button {
                let sl = Int(slPips)
                let tp = Int(tpPips)
                let temp = String(tpPips / slPips)
                risk = "1"
                if sl > 0 && tp > 0 {
                    if sl == tp {
                        reward = "1"
                    }else {
                        if (temp.suffix(1) == "0") {
                            reward = String(temp.prefix(temp.count-2))
                        }else {
                            reward = String(format: "%.2f",tpPips / slPips)
                        }
                    }
                }
                if sl == 0 {
                    risk = "0"
                    reward = String(tp)
                }
                if sl > 0 && tp == 0 { reward = "--" }
                dismiss()
            } label: {
                Text("戻る")
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .padding()
        .onAppear {
            if tpPips <= 100 {
                selectedRangeTp = "~100pips"
            }else if 100 < tpPips && tpPips <= 200 {
                selectedRangeTp = "~200pips"
            }else {
                selectedRangeTp = "~300pips"
            }
            
            if slPips <= 100 {
                selectedRangeSl = "~100pips"
            }else if 100 < slPips && slPips <= 200 {
                selectedRangeSl = "~200pips"
            }else {
                selectedRangeSl = "~300pips"
            }
        }
    }
}

//struct SliderPips_Previews: PreviewProvider {
//    static var previews: some View {
//        SliderPips()
//    }
//}
