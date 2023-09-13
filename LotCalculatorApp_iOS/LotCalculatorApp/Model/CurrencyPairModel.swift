//
//  CurrencyPairModel.swift
//  LotCalculatorApp
//
//  Created by 川人悠生 on 2023/03/09.
//

import SwiftUI




struct CurrencyPair {
    var currencyPair: String
    var price: String
    init(_ currencyPair: String, _ price: String) {
        self.currencyPair = currencyPair
        self.price = price
    }
}

func fetchCurrencyPair() async throws -> [CurrencyPair] {
    
    var array: [CurrencyPair] = []
    guard let url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/1URRKa2jW3WMx34GgtDUU21kCYMKvdlG5fKmWwPUSnTE/values/finance?key=AIzaSyA0w_ZecwgQJ9XHcrfsxLpW92i_FacfzRU") else {
        throw FetchError.invalidURL
    }
    let (data, _) = try await URLSession.shared.data(from: url)
    let response = try JSONDecoder().decode(GoogleSheetResponse.self, from: data)
    
    for row in response.values {
        array.append(CurrencyPair(row[0], row[1]))
    }
   // print(array)
    return array
}

struct GoogleSheetResponse: Decodable {
    let values: [[String]]
}

enum FetchError: Error {
    case invalidURL
}
