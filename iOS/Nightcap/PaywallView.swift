import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 56))
                        .foregroundColor(Theme.accent)
                    Text("Nightcap Pro")
                        .font(Theme.titleFont)
                        .foregroundColor(Theme.textPrimary)
                    Text("See your favorite ingredients across logs and build a home-bar recipe book.")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    if let product = purchases.product {
                        Text(product.displayPrice + "")
                            .font(.title2.bold())
                            .foregroundColor(Theme.accent)
                    }
                    Button {
                        Task {
                            await purchases.purchase()
                            if purchases.isPurchased { dismiss() }
                        }
                    } label: {
                        Text("Unlock Pro")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .cornerRadius(14)
                    }
                    .accessibilityIdentifier("unlockProButton")
                    .padding(.horizontal)
                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("paywallRestoreButton")
                    .foregroundColor(Theme.textSecondary)
                    Button("Not Now") { dismiss() }
                        .accessibilityIdentifier("paywallDismissButton")
                        .foregroundColor(Theme.textSecondary)
                }
                .padding()
            }
        }
    }
}
