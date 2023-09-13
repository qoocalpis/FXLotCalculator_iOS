//
//  ProductView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2023/01/26.
//


import SwiftUI
import StoreKit



struct ProductView: View {
    
    @StateObject var storeKit:  StoreKitManager
    @Binding var isPurchased: Bool
    @Binding var isProgress: Bool

    var body: some View {
        VStack {
            
            if let product = storeKit.storeProducts.first {
                ZStack {
                    Rectangle()
                        .fill(isPurchased ? Color.black : Color.purple)
                        .opacity(isPurchased ? 0 : 1)
                        .frame(height: 100)
                        .cornerRadius(25)
                        .padding(.horizontal, 20)
                        .shadow(radius: 10)
                        .padding(.bottom)
                    HStack {
                        Text("現在の製品版")
                        Spacer()
                        if !isPurchased {
                            VStack {
                                Text("Free版")
                                Button(action: {
                                    if !isPurchased {
                                        isProgress = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            isProgress = false
                                        }
                                        Task { try await storeKit.purchase(product) }
                                    }
                                }) {
                                    Text("アップグレード")
                                        .padding(5)
                                        .background(Color.yellow)
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                        .padding(.top, 10)
                                }
                            }
                        }else {
                            Text("Pro+").font(.title3)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom)
                }
                .onChange(of: storeKit.purchasedCourses) { course in
                    Task {
                        isPurchased = (try? await storeKit.isPurchased(product)) ?? false
                    }
                }
            }
            
            HStack {
                Spacer()
                Button {
                    Task {
                        try? await AppStore.sync()
                    }
                } label: {
                    Text("復元").foregroundColor(Color.blue)
                }
                .padding(.horizontal, 40)
            }
        }
    }
}



//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProductView()
//    }
//}


