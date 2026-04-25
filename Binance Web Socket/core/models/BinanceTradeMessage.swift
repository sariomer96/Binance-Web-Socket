//
//  BinanceTradeMessage.swift
//  Binance Web Socket
//
//  Created by Omer on 25.04.2026.
//

import Foundation

struct BinanceTradeMessage: Decodable {
    let eventType: String
    let eventTime: TimeInterval
    let symbol: String
    let tradeId: Int
    let price: String

    enum CodingKeys: String, CodingKey {
        case eventType = "e"
        case eventTime = "E"
        case symbol = "s"
        case tradeId = "t"
        case price = "p"
    }
}
