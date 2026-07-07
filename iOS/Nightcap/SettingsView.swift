import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Categories") {
                    Toggle("Show category one", isOn: $store.settings.categoryToggleOne)
                        .accessibilityIdentifier("categoryToggleOne")
                        .onChange(of: store.settings.categoryToggleOne) { _ in store.save() }
                    Toggle("Show category two", isOn: $store.settings.categoryToggleTwo)
                        .accessibilityIdentifier("categoryToggleTwo")
                        .onChange(of: store.settings.categoryToggleTwo) { _ in store.save() }
                }
                Section("Pro") {
                    if purchases.isPurchased {
                        Label("Pro unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundColor(Theme.accent)
                    } else {
                        Button("Upgrade to Pro") {
                            showPaywall = true
                        }
                        .accessibilityIdentifier("upgradeButton")
                    }
                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("restoreButton")
                }
                Section("Legal") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/nightcap-app/privacy.html")!)
                    Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/nightcap-app/terms.html")!)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("settingsDoneButton")
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}
