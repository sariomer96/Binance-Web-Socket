//
//  CryptoPrice.swift
//  Binance Web Socket
//
//  Created by Omer on 25.04.2026.
//

import Foundation

struct CryptoPrice: Sendable {
    let symbol: String
    let price: Decimal
    let eventTime: Date
    let tradeId: Int
}
