//
//  BinancePriceService.swift
//  Binance Web Socket
//
//  Created by Omer on 25.04.2026.
//

import Foundation

actor BinancePriceService {
     
  //  private let endpoint = URL(string: "wss://stream.binance.com:9443/ws/btcusdt@trade")!
    private var webSocketTask: URLSessionWebSocketTask?
    private let session: URLSession

    
    private let endpoint: URL = {
        // 1. Info.plist'ten String değeri oku
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "urlKey") as? String else {
            fatalError("Info.plist içinde 'BinanceTradeStreamURL' bulunamadı.")
        }
        
        // 2. Okunan String'i URL'e çevir
        guard let url = URL(string: urlString) else {
            fatalError("Info.plist'teki URL geçersiz: \(urlString)")
        }
        
        return url
    }()
    init(session: URLSession = .shared) {
        self.session = session
    }

    func priceStream() -> AsyncStream<CryptoPrice> {
        AsyncStream { continuation in
            let task = session.webSocketTask(with: endpoint)
            webSocketTask = task
            task.resume()

            let receiveTask = Task {
                do {
                    while !Task.isCancelled {
                        let message = try await task.receive()
                        guard case let .string(text) = message else {
                            continue
                        }

                        if let price = try decodePrice(from: text) {
                            continuation.yield(price)
                        }
                    }
                } catch {
                    continuation.finish()
                }
            }

            continuation.onTermination = { [weak task] _ in
                receiveTask.cancel()
                task?.cancel(with: .goingAway, reason: nil)
            }
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
    }

    private func decodePrice(from text: String) throws -> CryptoPrice? {
        let data = Data(text.utf8)
        let trade = try JSONDecoder().decode(BinanceTradeMessage.self, from: data)

        guard trade.eventType == "trade", let decimalPrice = Decimal(string: trade.price) else {
            return nil
        }

        return CryptoPrice(
            symbol: trade.symbol,
            price: decimalPrice,
            eventTime: Date(timeIntervalSince1970: trade.eventTime / 1_000),
            tradeId: trade.tradeId
        )
    }
}
