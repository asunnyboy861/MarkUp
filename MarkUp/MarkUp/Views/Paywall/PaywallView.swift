import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var purchaseManager = PurchaseManager()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.yellow)

                    Text("MarkUp Pro")
                        .font(.largeTitle.weight(.bold))

                    Text("Unlock all premium features")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 12) {
                        FeatureRow(icon: "magnifyingglass", title: "Loupe / Magnifier", description: "Zoom into details")
                        FeatureRow(icon: "circle", title: "Hollow Shapes", description: "Outline circles, rectangles, and more")
                        FeatureRow(icon: "arrow.right", title: "Free-Angle Arrows", description: "Point anywhere with precision")
                        FeatureRow(icon: "doc.richtext", title: "PDF Export", description: "Export as high-quality PDF")
                        FeatureRow(icon: "paintbrush", title: "All Drawing Tools", description: "Pen, marker, pencil, and highlight")
                        FeatureRow(icon: "rectangle.dashed", title: "Blur & Pixelate", description: "Hide sensitive information")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    VStack(spacing: 12) {
                        if let monthly = purchaseManager.monthlyProduct {
                            SubscriptionOption(
                                title: "Monthly",
                                price: monthly.displayPrice,
                                description: "per month",
                                isSelected: selectedProduct?.id == monthly.id
                            ) {
                                selectedProduct = monthly
                            }
                        }

                        if let yearly = purchaseManager.yearlyProduct {
                            SubscriptionOption(
                                title: "Yearly",
                                price: yearly.displayPrice,
                                description: "per year — Best Value",
                                isSelected: selectedProduct?.id == yearly.id,
                                isBestValue: true
                            ) {
                                selectedProduct = yearly
                            }
                        }

                        if let lifetime = purchaseManager.lifetimeProduct {
                            SubscriptionOption(
                                title: "Lifetime",
                                price: lifetime.displayPrice,
                                description: "One-time purchase",
                                isSelected: selectedProduct?.id == lifetime.id
                            ) {
                                selectedProduct = lifetime
                            }
                        }
                    }
                    .padding(.horizontal)

                    Button {
                        guard let product = selectedProduct ?? purchaseManager.yearlyProduct else { return }
                        Task {
                            isPurchasing = true
                            let success = await purchaseManager.purchase(product)
                            isPurchasing = false
                            if success {
                                dismiss()
                            }
                        }
                    } label: {
                        if isPurchasing {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Subscribe Now")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .disabled(isPurchasing)

                    Button {
                        Task {
                            await purchaseManager.restorePurchases()
                            if purchaseManager.isPro {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Restore Purchases")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 4) {
                        Text("Payment will be charged to your Apple ID account at confirmation of purchase.")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Text("Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period.")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .padding(.top)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                selectedProduct = purchaseManager.yearlyProduct
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }
}

struct SubscriptionOption: View {
    let title: String
    let price: String
    let description: String
    let isSelected: Bool
    var isBestValue = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(title)
                            .font(.headline)
                        if isBestValue {
                            Text("Best Value")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                    }
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(price)
                    .font(.title3.weight(.semibold))

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? .blue : .gray)
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
