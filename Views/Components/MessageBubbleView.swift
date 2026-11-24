import SwiftUI

// MARK: - Message Bubble Component (Ported from Jetpack Compose MessageListItem)

public struct MessageBubbleView: View {
    public let message: MessagePayload
    public let onCopy: (String) -> Void
    public let onRegenerate: (() -> Void)?

    @State private var showCopiedAlert: Bool = false

    public init(
        message: MessagePayload,
        onCopy: @escaping (String) -> Void,
        onRegenerate: (() -> Void)? = nil
    ) {
        self.message = message
        self.onCopy = onCopy
        self.onRegenerate = onRegenerate
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.author.role == .assistant {
                // Assistant Avatar
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Color.green.gradient)
                    .clipShape(Circle())
            } else {
                Spacer(minLength: 44)
            }

            VStack(alignment: message.author.role == .user ? .trailing : .leading, spacing: 6) {
                // Text / Content
                if message.author.role == .user {
                    Text(message.content.joinedText)
                        .font(.body)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.accentColor.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey(message.content.joinedText))
                            .font(.body)
                            .foregroundStyle(.primary)
                            .textSelection(.enabled)

                        if message.status == .inProgress {
                            ProgressView()
                                .controlSize(.small)
                                .padding(.top, 4)
                        } else {
                            // Assistant action toolbar
                            HStack(spacing: 16) {
                                Button {
                                    onCopy(message.content.joinedText)
                                    showCopiedAlert = true
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.success)
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                if let onRegenerate = onRegenerate {
                                    Button {
                                        onRegenerate()
                                    } label: {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()
                            }
                            .padding(.top, 6)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }

            if message.author.role == .user {
                // User Avatar (or align trailing)
            } else {
                Spacer(minLength: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}
