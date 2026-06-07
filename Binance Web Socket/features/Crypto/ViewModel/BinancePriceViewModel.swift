//
//  BinancePriceViewModel.swift
//  Binance Web Socket
//
//  Created by Omer on 25.04.2026.
//

import Combine
import Foundation

@MainActor
final class BinancePriceViewModel: ObservableObject {
    @Published private(set) var symbol = "BTCUSDT"
    @Published private(set) var priceText = "--"
    @Published private(set) var eventTimeText = "--:--:--"
    @Published private(set) var tradeIdText = "-"
    @Published private(set) var isConnected = false
    @Published private(set) var errorText: String?

    private let service: BinancePriceService
    private var streamTask: Task<Void, Never>?
    private let priceFormatter: NumberFormatter
    private let timeFormatter: DateFormatter

    init(service: BinancePriceService = BinancePriceService()) {
        self.service = service

        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .decimal
        priceFormatter.minimumFractionDigits = 2
        priceFormatter.maximumFractionDigits = 2
        priceFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.priceFormatter = priceFormatter

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        self.timeFormatter = timeFormatter
    }

    func start() {
        guard streamTask == nil else { return }

        errorText = nil

        streamTask = Task {
            let stream = await service.priceStream()

            for await price in stream {
                isConnected = true
                symbol = price.symbol
                priceText = format(price: price.price)
                eventTimeText = timeFormatter.string(from: price.eventTime)
                tradeIdText = "\(price.tradeId)"
            }

            if !Task.isCancelled {
                isConnected = false
                errorText = "Baglanti sonlandi"
                streamTask = nil
            }
        }
    }

    func stop() {
        streamTask?.cancel()
        streamTask = nil
        isConnected = false

        Task {
            await service.disconnect()
        }
    }

    deinit {
        streamTask?.cancel()
        let service = service

        Task {
            await service.disconnect()
        }
    }

    var connectionText: String {
        isConnected ? "Live data is being received." : "Waiting for connection"
    }

    private func format(price: Decimal) -> String {
        let number = price as NSDecimalNumber
        return "$\(priceFormatter.string(from: number) ?? number.stringValue)"
    }
}
