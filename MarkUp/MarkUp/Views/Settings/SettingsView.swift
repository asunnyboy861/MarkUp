import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Subscription") {
                    if viewModel.purchaseManager.isPro {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                            Text("MarkUp Pro")
                                .font(.headline)
                            Spacer()
                            Text("Active")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        }
                    } else {
                        NavigationLink {
                            PaywallView()
                        } label: {
                            HStack {
                                Image(systemName: "crown")
                                Text("Upgrade to Pro")
                            }
                        }
                    }

                    Button {
                        Task {
                            await viewModel.purchaseManager.restorePurchases()
                        }
                    } label: {
                        Text("Restore Purchases")
                    }
                }

                Section("Preferences") {
                    Toggle("Remember Tool Settings", isOn: $viewModel.rememberToolSettings)
                    Toggle("High Quality Export", isOn: $viewModel.highQualityExport)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(viewModel.buildNumber)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Legal") {
                    Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/MarkUp/privacy")!)
                    Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/MarkUp/terms")!)
                }

                Section("Support") {
                    NavigationLink {
                        ContactSupportView()
                    } label: {
                        Label("Contact Support", systemImage: "envelope")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
