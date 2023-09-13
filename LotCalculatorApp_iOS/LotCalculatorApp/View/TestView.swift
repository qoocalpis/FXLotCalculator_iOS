//
//  TestView.swift
//  LotCalculatorApp
//
//  Created by 川人悠生 on 2023/03/18.
//

import SwiftUI
import RealmSwift


struct TestView: View {
    @State  private var selection:Int = 1
    
    //イニシャライザ
    init(){
        //TabViewの背景色の設定（青色）
        UITabBar.appearance().backgroundColor = UIColor.blue
    }
    
    var body: some View {
        TabView(selection: $selection) {
            Text("Tab Content 1").tabItem { Text("Tab Label 1") }.tag(1)
            Text("Tab Content 2").tabItem { Text("Tab Label 2") }.tag(2)
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}


//struct TestView_Previews: PreviewProvider {
//    static var previews: some View {
//        OView()
//    }
//}
