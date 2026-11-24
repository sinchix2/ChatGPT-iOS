import SwiftUI
import StoreKit

// MARK: - ChatGPT Plus Subscription Paywall (StoreKit 2)

public struct SubscriptionPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing: Bool = false
    @State private var purchaseErrorMessage: String?

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.purple)

                        Text("ChatGPT Plus")
                            .font(.largeTitle.bold())

                        Text("Get expanded access to our most capable models and features.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)

                    // Value Propositions
                    VStack(alignment: .leading, spacing: 20) {
                        featureRow(
                            icon: "brain.head.profile",
                            title: "Access to OpenAI o1",
                            description: "Advanced reasoning model designed for math, coding, and complex science."
                        )
                        featureRow(
                            icon: "sparkle",
                            title: "Expanded GPT-4o limits",
                            description: "Up to 5x more messages with our flagship model."
                        )
                        featureRow(
                            icon: "headphones",
                            title: "Advanced Voice Mode",
                            description: "Natural, real-time conversations with fluid audio and vision."
                        )
                        featureRow(
                            icon: "paintpalette",
                            title: "DALL-E & Canvas",
                            description: "Create images, browse the web, analyze data, and code in an interactive workspace."
                        )
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 20)

                    // Price & CTA Button
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                await initiatePurchase()
                            }
                        } label: {
                            HStack {
                                if isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Upgrade to Plus — $19.99/month")
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.purple)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .disabled(isPurchasing)

                        Text("Renews automatically every month. Cancel anytime in App Store settings.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.purple)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func initiatePurchase() async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            // Load StoreKit product for ChatGPT Plus
            let products = try await Product.products(for: ["com.openai.chatgpt.plus.monthly"])
            guard let plusProduct = products.first else {
                // Simulator/Fallback sandbox handling
                try await Task.sleep(nanoseconds: 1_000_000_000)
                dismiss()
                return
            }

            let result = try await plusProduct.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    dismiss()
                case .unverified:
                    purchaseErrorMessage = "Transaction could not be verified."
                }
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseErrorMessage = error.localizedDescription
        }
    }
}
