import SwiftUI

// MARK: - Model Picker Bottom Sheet

public struct ModelPickerSheet: View {
    @Binding public var selectedModel: ModelSpec
    public let onSelect: (ModelSpec) -> Void
    @Environment(\.dismiss) private var dismiss

    public init(selectedModel: Binding<ModelSpec>, onSelect: @escaping (ModelSpec) -> Void) {
        self._selectedModel = selectedModel
        self.onSelect = onSelect
    }

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(ModelSpec.availableModels) { model in
                        Button {
                            selectedModel = model
                            onSelect(model)
                            dismiss()
                        } label: {
                            HStack(alignment: .top, spacing: 14) {
                                Image(systemName: iconForModel(model))
                                    .font(.title3)
                                    .foregroundStyle(selectedModel.id == model.id ? Color.accentColor : Color.secondary)
                                    .frame(width: 28)

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Text(model.title)
                                            .font(.headline)
                                            .foregroundStyle(.primary)

                                        if model.requiredPlan == .plus {
                                            Text("PLUS")
                                                .font(.caption2.bold())
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.purple.opacity(0.15))
                                                .foregroundStyle(.purple)
                                                .clipShape(Capsule())
                                        }
                                    }

                                    if let subtitle = model.subtitle {
                                        Text(subtitle)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                if selectedModel.id == model.id {
                                    Image(systemName: "checkmark")
                                        .font(.headline)
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                } header: {
                    Text("Model Selection")
                }
            }
            .navigationTitle("Select Model")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func iconForModel(_ model: ModelSpec) -> String {
        switch model.slug {
        case "o1": return "brain.head.profile"
        case "gpt-4o": return "sparkle"
        default: return "bolt"
        }
    }
}
