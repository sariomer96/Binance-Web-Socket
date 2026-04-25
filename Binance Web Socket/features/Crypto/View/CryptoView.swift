//
//  ContentView.swift
//  Binance Web Socket
//
//  Created by Omer on 25.04.2026.
//

import SwiftUI

struct CryptoView: View {
    @StateObject private var viewModel = BinancePriceViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.06, green: 0.09, blue: 0.16), Color(red: 0.02, green: 0.03, blue: 0.06)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                header
                priceCard
                statusRow
                Spacer()
            }
            .padding(24)
        }
        .task {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Live Crypto")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Binance Spot WebSocket ile BTC/USDT anlik fiyat akisi")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
        }
    }

    private var priceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.symbol)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.7))

            Text(viewModel.priceText)
                .font(.system(size: 42, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: 12) {
                Label(viewModel.eventTimeText, systemImage: "clock")
                Label(viewModel.tradeIdText, systemImage: "arrow.left.arrow.right")
            }
            .font(.footnote)
            .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private var statusRow: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(viewModel.isConnected ? Color.green : Color.orange)
                .frame(width: 10, height: 10)

            Text(viewModel.connectionText)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)

            Spacer()

            if let errorText = viewModel.errorText {
                Text(errorText)
                    .font(.footnote)
                    .foregroundStyle(.red.opacity(0.9))
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.horizontal, 4)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CryptoView()
    }
}
